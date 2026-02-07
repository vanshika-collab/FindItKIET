import { prisma } from '../../config/database';
import { NotFoundError, ConflictError } from '../../utils/errors';
import { CONSTANTS } from '../../config/constants';
import {
    ApproveClaimRequest,
    RejectClaimRequest,
    HandoverItemRequest,
    ListClaimsQuery,
} from './admin.validation';

export class AdminService {
    // Create audit log entry
    private async createAuditLog(
        actorId: string,
        action: string,
        entity: string,
        entityId: string,
        metadata?: any
    ) {
        await prisma.auditLog.create({
            data: {
                actorId,
                action,
                entity,
                entityId,
                metadata,
            },
        });
    }

    // Get all claims with filters
    async getAllClaims(query: ListClaimsQuery) {
        const { status, page, limit } = query;

        const currentPage = page ? Math.max(1, Number(page)) : 1;
        const pageSize = limit ? Math.min(Number(limit), 100) : 10;
        const skip = (currentPage - 1) * pageSize;

        const where: any = {};
        if (status) {
            where.status = status;
        }

        const [claims, total] = await Promise.all([
            prisma.claim.findMany({
                where,
                skip,
                take: pageSize,
                orderBy: { createdAt: 'desc' },
                include: {
                    proofs: true,
                    user: {
                        select: {
                            id: true,
                            name: true,
                            email: true,
                        },
                    },
                    item: {
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
                    },
                },
            }),
            prisma.claim.count({ where }),
        ]);

        return {
            claims,
            pagination: {
                page: currentPage,
                limit: pageSize,
                total,
                totalPages: Math.ceil(total / pageSize),
            },
        };
    }

    // Approve claim
    async approveClaim(claimId: string, data: ApproveClaimRequest, adminId: string) {
        const claim = await prisma.claim.findUnique({
            where: { id: claimId },
            include: { item: true },
        });

        if (!claim) {
            throw new NotFoundError('Claim not found');
        }

        if (claim.status !== 'PENDING') {
            throw new ConflictError('Only pending claims can be approved');
        }

        // Update claim and reject other claims for the same item
        const updatedClaim = await prisma.$transaction(async (tx) => {
            // Approve this claim
            const approved = await tx.claim.update({
                where: { id: claimId },
                data: {
                    status: 'APPROVED',
                    adminComment: data.comment,
                },
                include: {
                    proofs: true,
                    user: {
                        select: {
                            id: true,
                            name: true,
                            email: true,
                        },
                    },
                    item: true,
                },
            });

            // Reject all other pending claims for this item
            await tx.claim.updateMany({
                where: {
                    itemId: claim.itemId,
                    id: { not: claimId },
                    status: 'PENDING',
                },
                data: {
                    status: 'REJECTED',
                    adminComment: 'Another claim was approved',
                },
            });

            return approved;
        });

        // Check for collusion/fraud (Anti-Cheat)
        // Heuristic: If User (Claimant) has claimed multiple items from the SAME Reporter in short time
        const reporterId = claim.item.createdById;
        const claimantId = claim.userId;
        const lookbackDays = 7;
        const claimThreshold = 3; // If this is the 3rd claim from same reporter in 7 days -> BAN

        const collusionCount = await prisma.claim.count({
            where: {
                userId: claimantId,
                status: 'APPROVED',
                item: {
                    createdById: reporterId
                },
                createdAt: {
                    gte: new Date(Date.now() - lookbackDays * 24 * 60 * 60 * 1000)
                }
            }
        });

        if (collusionCount >= claimThreshold) {
            console.warn(`[Anti-Cheat] Suspicious activity detected! User ${claimantId} claiming too many items from ${reporterId}`);

            // Ban the claimant for 3 days
            const banDurationDays = 3;
            const bannedUntil = new Date(Date.now() + banDurationDays * 24 * 60 * 60 * 1000);

            await prisma.user.update({
                where: { id: claimantId },
                data: { bannedUntil }
            });

            // Logout user (revoke tokens)
            await prisma.refreshToken.deleteMany({
                where: { userId: claimantId }
            });

            // Log this action
            await this.createAuditLog(
                adminId,
                'USER_BANNED',
                'User',
                claimantId,
                { reason: 'Collusion / Fake Claims detected', durationDays: banDurationDays }
            );

            // Note: We still approve the claim technically, or should we reject?
            // User asked to ban. Usually if it's fraud, we should probably NOT approve.
            // But if we ban them, they can't login anyway.
            // Let's approve this one (as the trigger) but ban them immediately.
        }

        // Create audit log
        await this.createAuditLog(
            adminId,
            CONSTANTS.AUDIT_ACTIONS.CLAIM_APPROVED,
            'Claim',
            claimId,
            { itemId: claim.itemId, comment: data.comment, collusionCheck: collusionCount }
        );

        return updatedClaim;
    }

    // Reject claim
    async rejectClaim(claimId: string, data: RejectClaimRequest, adminId: string) {
        const claim = await prisma.claim.findUnique({
            where: { id: claimId },
            include: { item: true },
        });

        if (!claim) {
            throw new NotFoundError('Claim not found');
        }

        if (claim.status !== 'PENDING') {
            throw new ConflictError('Only pending claims can be rejected');
        }

        // Update claim and item status
        const updatedClaim = await prisma.$transaction(async (tx) => {
            const rejected = await tx.claim.update({
                where: { id: claimId },
                data: {
                    status: 'REJECTED',
                    adminComment: data.reason,
                },
                include: {
                    proofs: true,
                    user: {
                        select: {
                            id: true,
                            name: true,
                            email: true,
                        },
                    },
                    item: true,
                },
            });

            // Check if there are other pending claims
            const otherPendingClaims = await tx.claim.count({
                where: {
                    itemId: claim.itemId,
                    status: 'PENDING',
                },
            });

            // If no other pending claims, revert item status back to original
            if (otherPendingClaims === 0) {
                await tx.item.update({
                    where: { id: claim.itemId },
                    data: {
                        status: claim.item.status === 'CLAIMED' ? 'FOUND' : claim.item.status,
                    },
                });
            }

            return rejected;
        });

        // Create audit log
        await this.createAuditLog(
            adminId,
            CONSTANTS.AUDIT_ACTIONS.CLAIM_REJECTED,
            'Claim',
            claimId,
            { itemId: claim.itemId, reason: data.reason }
        );

        return updatedClaim;
    }

    // Mark item as recovered (handover complete)
    async handoverItem(itemId: string, data: HandoverItemRequest, adminId: string) {
        const item = await prisma.item.findUnique({
            where: { id: itemId },
            include: {
                claims: {
                    where: { status: 'APPROVED' },
                },
            },
        });

        if (!item) {
            throw new NotFoundError('Item not found');
        }

        if (item.claims.length === 0) {
            throw new ConflictError('Item must have an approved claim before handover');
        }

        // Update item status
        const updatedItem = await prisma.item.update({
            where: { id: itemId },
            data: { status: 'RECOVERED' },
            include: {
                images: true,
                claims: {
                    where: { status: 'APPROVED' },
                    include: {
                        user: {
                            select: {
                                id: true,
                                name: true,
                                email: true,
                            },
                        },
                    },
                },
            },
        });

        // Create audit log
        await this.createAuditLog(
            adminId,
            CONSTANTS.AUDIT_ACTIONS.ITEM_HANDOVER,
            'Item',
            itemId,
            { notes: data.notes }
        );

        return updatedItem;
    }

    // Delete item (admin moderation)
    async deleteItem(itemId: string, adminId: string, reason?: string) {
        const item = await prisma.item.findUnique({
            where: { id: itemId },
        });

        if (!item) {
            throw new NotFoundError('Item not found');
        }

        // Delete item
        await prisma.item.delete({
            where: { id: itemId },
        });

        // Create audit log
        await this.createAuditLog(
            adminId,
            CONSTANTS.AUDIT_ACTIONS.ITEM_DELETED,
            'Item',
            itemId,
            { reason }
        );
    }

    // Get all items (admin view)
    async getAllItems(page: number = 1, limit: number = 20) {
        const currentPage = Math.max(1, page);
        const pageSize = Math.min(limit, 100);
        const skip = (currentPage - 1) * pageSize;

        const [items, total] = await Promise.all([
            prisma.item.findMany({
                skip,
                take: pageSize,
                orderBy: { createdAt: 'desc' },
                include: {
                    images: {
                        take: 1,
                    },
                    createdBy: {
                        select: {
                            id: true,
                            name: true,
                            email: true,
                        },
                    },
                    claims: {
                        select: {
                            id: true,
                            status: true,
                        },
                    },
                },
            }),
            prisma.item.count(),
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

    // Get audit logs
    async getAuditLogs(page: number = 1, limit: number = 50) {
        const currentPage = Math.max(1, page);
        const pageSize = Math.min(limit, 100);
        const skip = (currentPage - 1) * pageSize;

        const [logs, total] = await Promise.all([
            prisma.auditLog.findMany({
                skip,
                take: pageSize,
                orderBy: { createdAt: 'desc' },
                include: {
                    actor: {
                        select: {
                            id: true,
                            name: true,
                            email: true,
                        },
                    },
                },
            }),
            prisma.auditLog.count(),
        ]);

        return {
            logs,
            pagination: {
                page: currentPage,
                limit: pageSize,
                total,
                totalPages: Math.ceil(total / pageSize),
            },
        };
    }
}
