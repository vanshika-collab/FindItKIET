import { Request, Response } from 'express';
import { AuthService } from './auth.service';
import { successResponse } from '../../utils/apiResponse';
import { asyncHandler } from '../../middlewares/error.middleware';

const authService = new AuthService();

export class AuthController {
    // POST /api/v1/auth/register
    register = asyncHandler(async (req: Request, res: Response) => {
        const result = await authService.register(req.body);

        return successResponse(
            res,
            {
                user: result.user,
                accessToken: result.accessToken,
                refreshToken: result.refreshToken,
            },
            201
        );
    });

    // POST /api/v1/auth/login
    login = asyncHandler(async (req: Request, res: Response) => {
        const result = await authService.login(req.body);

        return successResponse(res, {
            user: result.user,
            accessToken: result.accessToken,
            refreshToken: result.refreshToken,
        });
    });

    // POST /api/v1/auth/refresh
    refresh = asyncHandler(async (req: Request, res: Response) => {
        const { refreshToken } = req.body;
        const result = await authService.refreshAccessToken(refreshToken);

        return successResponse(res, {
            accessToken: result.accessToken,
            refreshToken: result.refreshToken,
        });
    });

    // POST /api/v1/auth/logout
    logout = asyncHandler(async (req: Request, res: Response) => {
        const { refreshToken } = req.body;
        await authService.logout(refreshToken);

        return successResponse(res, { message: 'Logged out successfully' }, 200);
    });

    // POST /api/v1/auth/logout-all
    logoutAll = asyncHandler(async (req: Request, res: Response) => {
        if (!req.user) {
            return successResponse(res, { message: 'User not authenticated' }, 401);
        }

        await authService.logoutAll(req.user.userId);

        return successResponse(res, { message: 'All sessions logged out' }, 200);
        return successResponse(res, { message: 'All sessions logged out' }, 200);
    });

    // GET /api/v1/auth/me
    me = asyncHandler(async (req: Request, res: Response) => {
        if (!req.user) {
            return successResponse(res, { message: 'User not authenticated' }, 401);
        }

        const user = await authService.getUserById(req.user.userId);

        return successResponse(res, { user }, 200);
    });
}
