import { Request, Response, NextFunction } from 'express';
import { verifyAccessToken, JwtPayload } from '../utils/jwt';
import { UnauthorizedError } from '../utils/errors';

// Extend Express Request type to include user
declare global {
    namespace Express {
        interface Request {
            user?: JwtPayload;
        }
    }
}

// Authentication middleware - verifies JWT token
export const authenticate = (
    req: Request,
    res: Response,
    next: NextFunction
): void => {
    try {
        // Get token from Authorization header
        const authHeader = req.headers.authorization;

        if (!authHeader || !authHeader.startsWith('Bearer ')) {
            throw new UnauthorizedError('No token provided');
        }

        const token = authHeader.substring(7); // Remove 'Bearer ' prefix

        // Verify token
        const payload = verifyAccessToken(token);

        // Attach user to request
        req.user = payload;

        next();
    } catch (error) {
        if (error instanceof Error) {
            next(new UnauthorizedError(error.message));
        } else {
            next(new UnauthorizedError());
        }
    }
};

// Optional authentication - doesn't fail if no token
export const optionalAuthenticate = (
    req: Request,
    res: Response,
    next: NextFunction
): void => {
    try {
        const authHeader = req.headers.authorization;

        if (authHeader && authHeader.startsWith('Bearer ')) {
            const token = authHeader.substring(7);
            const payload = verifyAccessToken(token);
            req.user = payload;
        }

        next();
    } catch (error) {
        // Silently fail - user is just not authenticated
        next();
    }
};
