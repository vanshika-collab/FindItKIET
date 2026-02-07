import { Request, Response, NextFunction } from 'express';
import { AppError } from '../utils/errors';
import { errorResponse } from '../utils/apiResponse';
import { logger } from '../utils/logger';
import { env } from '../config/env';

// Global error handling middleware
export const errorHandler = (
    err: Error,
    req: Request,
    res: Response,
    next: NextFunction
): Response => {
    // Log error
    logger.error('Error occurred:', {
        error: err.message,
        stack: err.stack,
        path: req.path,
        method: req.method,
        ip: req.ip,
    });

    // Handle known AppError instances
    if (err instanceof AppError) {
        return errorResponse(
            res,
            err.code,
            err.message,
            err.statusCode,
            err.details
        );
    }

    // Handle Prisma errors
    if (err.name === 'PrismaClientKnownRequestError') {
        const prismaError = err as any;

        // Unique constraint violation
        if (prismaError.code === 'P2002') {
            return errorResponse(
                res,
                'UNIQUE_CONSTRAINT_VIOLATION',
                'A record with this value already exists',
                409,
                env.NODE_ENV === 'development' ? { field: prismaError.meta?.target } : undefined
            );
        }

        // Foreign key constraint violation
        if (prismaError.code === 'P2003') {
            return errorResponse(
                res,
                'FOREIGN_KEY_CONSTRAINT',
                'Referenced record does not exist',
                400
            );
        }

        // Record not found
        if (prismaError.code === 'P2025') {
            return errorResponse(
                res,
                'NOT_FOUND',
                'Record not found',
                404
            );
        }
    }

    // Handle Zod validation errors
    if (err.name === 'ZodError') {
        const zodError = err as any;
        return errorResponse(
            res,
            'VALIDATION_ERROR',
            'Request validation failed',
            400,
            env.NODE_ENV === 'development' ? zodError.errors : undefined
        );
    }

    // Handle JWT errors
    if (err.name === 'JsonWebTokenError') {
        return errorResponse(
            res,
            'INVALID_TOKEN',
            'Invalid authentication token',
            401
        );
    }

    if (err.name === 'TokenExpiredError') {
        return errorResponse(
            res,
            'TOKEN_EXPIRED',
            'Authentication token has expired',
            401
        );
    }

    // Handle unknown errors (don't leak details in production)
    return errorResponse(
        res,
        'INTERNAL_ERROR',
        env.NODE_ENV === 'production' ? 'An unexpected error occurred' : err.message,
        500,
        env.NODE_ENV === 'development' ? { stack: err.stack } : undefined
    );
};

// 404 handler for undefined routes
export const notFoundHandler = (
    req: Request,
    res: Response
): Response => {
    return errorResponse(
        res,
        'ROUTE_NOT_FOUND',
        `Route ${req.method} ${req.path} not found`,
        404
    );
};

// Async handler wrapper to catch errors
export const asyncHandler = (
    fn: (req: Request, res: Response, next: NextFunction) => Promise<any>
) => {
    return (req: Request, res: Response, next: NextFunction) => {
        Promise.resolve(fn(req, res, next)).catch(next);
    };
};
