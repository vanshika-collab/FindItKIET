import { z } from 'zod';

// Approve claim schema
export const approveClaimSchema = z.object({
    body: z.object({
        comment: z.string().max(500).optional(),
    }),
});

// Reject claim schema
export const rejectClaimSchema = z.object({
    body: z.object({
        reason: z.string().min(10, 'Rejection reason must be at least 10 characters').max(500),
    }),
});

// Mark item as recovered schema
export const handoverItemSchema = z.object({
    body: z.object({
        notes: z.string().max(500).optional(),
    }),
});

// Claim ID param schema
export const claimIdSchema = z.object({
    params: z.object({
        claimId: z.string().uuid('Invalid claim ID'),
    }),
});

// Item ID param schema
export const itemIdSchema = z.object({
    params: z.object({
        itemId: z.string().uuid('Invalid item ID'),
    }),
});

// Query schema for listing claims
export const listClaimsSchema = z.object({
    query: z.object({
        status: z.enum(['PENDING', 'APPROVED', 'REJECTED']).optional(),
        page: z.string().transform(Number).default('1'),
        limit: z.string().transform(Number).default('20'),
    }),
});

// Types
export type ApproveClaimRequest = z.infer<typeof approveClaimSchema.body>;
export type RejectClaimRequest = z.infer<typeof rejectClaimSchema.body>;
export type HandoverItemRequest = z.infer<typeof handoverItemSchema.body>;
export type ListClaimsQuery = z.infer<typeof listClaimsSchema.query>;
