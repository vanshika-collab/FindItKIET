import { prisma } from '../../config/database';
import { MonthlyLeaderboardQuery } from './leaderboard.validation';

export class LeaderboardService {
    // Get top reporters of the current month
    async getMonthlyLeaderboard(query: MonthlyLeaderboardQuery) {
        const limit = query.limit || 10;

        // Get start and end of current month
        const now = new Date();
        const startOfMonth = new Date(now.getFullYear(), now.getMonth(), 1);
        const endOfMonth = new Date(now.getFullYear(), now.getMonth() + 1, 0, 23, 59, 59, 999);

        // Query to get top reporters for the month using raw SQL for correct sorting
        // We count LOST items reported by each user in the current month
        const leaderboard = await prisma.$queryRaw<Array<{ id: string; name: string; email: string; itemCount: bigint }>>`
            SELECT u.id, u.name, u.email, COUNT(i.id) as "itemCount"
            FROM "User" u
            JOIN "Item" i ON u.id = i."createdById"
            WHERE i.status = 'LOST'
            AND i."reportedAt" >= ${startOfMonth}
            AND i."reportedAt" <= ${endOfMonth}
            GROUP BY u.id, u.name, u.email
            ORDER BY "itemCount" DESC
            LIMIT ${limit}
        `;

        // Transform to include rank and itemCount (handling BigInt)
        const leaderboardWithRank = leaderboard.map((user, index) => ({
            id: user.id,
            name: user.name,
            email: user.email,
            itemCount: Number(user.itemCount),
            rank: index + 1,
        }));

        return {
            month: now.toLocaleString('default', { month: 'long', year: 'numeric' }),
            leaderboard: leaderboardWithRank,
        };
    }
}
