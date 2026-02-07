import { prisma } from '../../config/database';
import { NotFoundError, ForbiddenError } from '../../utils/errors';
import { CONSTANTS } from '../../config/constants';
import { CreateItemRequest, UpdateItemRequest, ListItemsQuery } from './items.validation';

export class ItemsService {
    // Create a new item (lost or found)
    async createItem(data: CreateItemRequest, userId: string) {
        // Create item with images in a transaction
        const item = await prisma.$transaction(async (tx) => {
            // Create item
            const newItem = await tx.item.create({
                data: {
                    title: data.title,
                    description: data.description,
                    category: data.category,
                    status: data.status,
                    location: data.location,
                    reportedAt: data.reportedAt,
                    createdById: userId,
                },
                include: {
                    images: true,
                    createdBy: {
                        select: {
                            id: true,
                            name: true,
                            email: true,
                        },
                    },
                },
            });

            // Add images if provided
            if (data.imageUrls && data.imageUrls.length > 0) {
                await tx.itemImage.createMany({
                    data: data.imageUrls.map((url) => ({
                        itemId: newItem.id,
                        imageUrl: url,
                    })),
                });

                // Fetch item with images
                return tx.item.findUnique({
                    where: { id: newItem.id },
                    include: {
                        images: true,
                        createdBy: {
                            select: {
                                id: true,
                                name: true,
                                email: true,
                            },
                        },
                    },
                });
            }

            return newItem;
        });

        return item;
    }

    // Get all items with filters and pagination
    async listItems(query: ListItemsQuery) {
        const { status, category, search } = query;

        // Ensure page and limit have valid values with fallback defaults
        const page = query.page && !isNaN(query.page) ? query.page : 1;
        const limit = query.limit && !isNaN(query.limit) ? query.limit : 20;

        // Ensure page is at least 1
        const currentPage = Math.max(1, page);
        const pageSize = Math.min(limit, CONSTANTS.MAX_PAGE_SIZE);
        const skip = (currentPage - 1) * pageSize;

        // Build where clause
        const where: any = {};

        if (status) {
            where.status = status;
        }

        if (category) {
            where.category = category;
        }

        if (search) {
            where.OR = [
                { title: { contains: search, mode: 'insensitive' } },
                { description: { contains: search, mode: 'insensitive' } },
                { location: { contains: search, mode: 'insensitive' } },
            ];
        }

        // Get items and total count
        const [items, total] = await Promise.all([
            prisma.item.findMany({
                where,
                skip,
                take: pageSize,
                orderBy: { reportedAt: 'desc' },
                include: {
                    images: {
                        take: 1, // Only first image for list view
                    },
                    createdBy: {
                        select: {
                            id: true,
                            name: true,
                        },
                    },
                    claims: {
                        where: { status: 'PENDING' },
                        select: { id: true },
                    },
                },
            }),
            prisma.item.count({ where }),
        ]);

        return {
            items,
            pagination: {
                page: currentPage,
                limit: pageSize,
                total,
                totalPages: Math.ceil(total / pageSize),
            },
        };
    }

    // Get item by ID
    async getItemById(itemId: string) {
        const item = await prisma.item.findUnique({
            where: { id: itemId },
            include: {
                images: true,
                createdBy: {
                    select: {
                        id: true,
                        name: true,
                        email: true,
                    },
                },
                claims: {
                    include: {
                        user: {
                            select: {
                                id: true,
                                name: true,
                            },
                        },
                        proofs: true,
                    },
                    orderBy: { createdAt: 'desc' },
                },
            },
        });

        if (!item) {
            throw new NotFoundError('Item not found');
        }

        return item;
    }

    // Update item (only by owner)
    async updateItem(
        itemId: string,
        data: UpdateItemRequest,
        userId: string,
        userRole: string
    ) {
        // Get item to check ownership
        const item = await prisma.item.findUnique({
            where: { id: itemId },
        });

        if (!item) {
            throw new NotFoundError('Item not found');
        }

        // Only owner or admin can update
        if (item.createdById !== userId && userRole !== 'ADMIN') {
            throw new ForbiddenError('You can only update your own items');
        }

        // Update item
        const updatedItem = await prisma.item.update({
            where: { id: itemId },
            data: {
                ...(data.title && { title: data.title }),
                ...(data.description && { description: data.description }),
                ...(data.category && { category: data.category }),
                ...(data.location !== undefined && { location: data.location }),
            },
            include: {
                images: true,
                createdBy: {
                    select: {
                        id: true,
                        name: true,
                        email: true,
                    },
                },
            },
        });

        return updatedItem;
    }

    // Delete item (only by owner or admin)
    async deleteItem(itemId: string, userId: string, userRole: string) {
        // Get item to check ownership
        const item = await prisma.item.findUnique({
            where: { id: itemId },
        });

        if (!item) {
            throw new NotFoundError('Item not found');
        }

        // Only owner or admin can delete
        if (item.createdById !== userId && userRole !== 'ADMIN') {
            throw new ForbiddenError('You can only delete your own items');
        }

        // Delete item (cascade deletes images and claims)
        await prisma.item.delete({
            where: { id: itemId },
        });
    }

    // Get user's own items
    async getUserItems(userId: string) {
        const items = await prisma.item.findMany({
            where: { createdById: userId },
            orderBy: { createdAt: 'desc' },
            include: {
                images: {
                    take: 1,
                },
                claims: {
                    where: { status: 'PENDING' },
                    select: { id: true },
                },
            },
        });

        return items;
    }
}
