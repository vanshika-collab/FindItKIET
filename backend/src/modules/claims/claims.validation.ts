import { z } from 'zod';
import { CONSTANTS } from '../../config/constants';

// Create claim schema
export const createClaimSchema = z.object({
    body: z.object({
        proofs: z
            .array(
                z.object({
                    type: z.enum(CONSTANTS.PROOF_TYPES as any, {
                        errorMap: () => ({ message: 'Invalid proof type' }),
                    }),
                    value: z.string().min(5, 'Proof value must be at least 5 characters').max(500),
                    imageUrl: z.string().url().optional(),
                })
            )
            .min(1, 'At least one proof is required')
            .max(5, 'Maximum 5 proofs allowed'),
    }),
});

// Item ID param schema
export const itemIdParamSchema = z.object({
    params: z.object({
        itemId: z.string().uuid('Invalid item ID'),
    }),
});

// Claim ID param schema
export const claimIdParamSchema = z.object({
    params: z.object({
        claimId: z.string().uuid('Invalid claim ID'),
    }),
});

// Types
export type CreateClaimRequest = z.infer<typeof createClaimSchema.body>;
export type ItemIdParam = z.infer<typeof itemIdParamSchema.params>;
export type ClaimIdParam = z.infer<typeof claimIdParamSchema.params>;
