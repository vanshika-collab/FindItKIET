import { Request, Response, NextFunction } from 'express';
import { LeaderboardService } from './leaderboard.service';
import { MonthlyLeaderboardQuery } from './leaderboard.validation';

const leaderboardService = new LeaderboardService();

export class LeaderboardController {
    // GET /api/v1/leaderboard/monthly
    async getMonthlyLeaderboard(req: Request, res: Response, next: NextFunction) {
        try {
            const query = req.query as unknown as MonthlyLeaderboardQuery;
            const result = await leaderboardService.getMonthlyLeaderboard(query);

            res.json({
                success: true,
                data: result,
            });
        } catch (error) {
            next(error);
        }
    }
}
