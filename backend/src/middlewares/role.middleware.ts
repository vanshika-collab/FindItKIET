import { Request, Response, NextFunction } from 'express';
import { ForbiddenError, UnauthorizedError } from '../utils/errors';

// Role-based authorization middleware factory
export const requireRole = (...allowedRoles: string[]) => {
    return (req: Request, res: Response, next: NextFunction): void => {
        // Check if user is authenticated
        if (!req.user) {
            return next(new UnauthorizedError('Authentication required'));
        }

        // Check if user has required role
        console.log(`[RoleGuard] User: ${req.user.email}, Role: ${req.user.role}, Required: ${allowedRoles.join(',')}`);
        if (!allowedRoles.includes(req.user.role)) {
            return next(
                new ForbiddenError(
                    `Access denied. Required role: ${allowedRoles.join(' or ')}`
                )
            );
        }

        next();
    };
};

// Specific role guards
export const requireUser = requireRole('USER', 'ADMIN');
export const requireAdmin = requireRole('ADMIN');
