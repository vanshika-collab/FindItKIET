import { z } from 'zod';
import { CONSTANTS } from '../../config/constants';

// Create item schema
export const createItemSchema = z.object({
    body: z.object({
        title: z.string().min(3, 'Title must be at least 3 characters').max(100),
        description: z.string().min(10, 'Description must be at least 10 characters').max(1000),
        category: z.enum(CONSTANTS.ITEM_CATEGORIES as any, {
            errorMap: () => ({ message: 'Invalid category' }),
        }),
        status: z.enum(['LOST', 'FOUND'], {
            errorMap: () => ({ message: 'Status must be LOST or FOUND' }),
        }),
        location: z.string().max(200).optional(),
        reportedAt: z.string().datetime().or(z.date()).transform(str => new Date(str)),
        imageUrls: z.array(z.string().url()).max(CONSTANTS.MAX_IMAGES_PER_ITEM).optional(),
    }),
});

// Update item schema
export const updateItemSchema = z.object({
    body: z.object({
        title: z.string().min(3).max(100).optional(),
        description: z.string().min(10).max(1000).optional(),
        category: z.enum(CONSTANTS.ITEM_CATEGORIES as any).optional(),
        location: z.string().max(200).optional(),
    }),
});

// Query params schema for listing items
export const listItemsSchema = z.object({
    query: z.object({
        status: z.enum(['LOST', 'FOUND', 'CLAIMED', 'RECOVERED']).optional(),
        category: z.enum(CONSTANTS.ITEM_CATEGORIES as any).optional(),
        search: z.string().max(100).optional(),
        page: z.coerce.number().int().positive().default(1),
        limit: z.coerce.number().int().positive().max(100).default(20),
    }),
});

// Item ID param schema
export const itemIdSchema = z.object({
    params: z.object({
        id: z.string().uuid('Invalid item ID'),
    }),
});

// Types
export type CreateItemRequest = z.infer<typeof createItemSchema>['body'];
export type UpdateItemRequest = z.infer<typeof updateItemSchema>['body'];
export type ListItemsQuery = z.infer<typeof listItemsSchema>['query'];
export type ItemIdParam = z.infer<typeof itemIdSchema>['params'];

