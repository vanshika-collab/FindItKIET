import { z } from 'zod';

// Query params schema for leaderboard
export const monthlyLeaderboardSchema = {
    query: z.object({
        limit: z.coerce.number().int().positive().max(100).default(10),
    }),
};

// Types
export type MonthlyLeaderboardQuery = z.infer<typeof monthlyLeaderboardSchema.query>;
