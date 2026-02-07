import { Router } from 'express';
import { LeaderboardController } from './leaderboard.controller';
import { validate } from '../../middlewares/validation.middleware';
import { monthlyLeaderboardSchema } from './leaderboard.validation';

const router = Router();
const controller = new LeaderboardController();

// GET /api/v1/leaderboard/monthly - Get top reporters of the month
router.get(
    '/monthly',
    validate(monthlyLeaderboardSchema),
    controller.getMonthlyLeaderboard.bind(controller)
);

export default router;
