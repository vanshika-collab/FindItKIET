import rateLimit from 'express-rate-limit';
import { env } from '../config/env';
import { CONSTANTS } from '../config/constants';

// General API rate limiter
export const apiLimiter = rateLimit({
    windowMs: 15 * 60 * 1000,
    max: 5000, // Relaxed
    message: {
        success: false,
        error: {
            code: 'RATE_LIMIT_EXCEEDED',
            message: 'Too many requests, please try again later',
        },
    },
    standardHeaders: true,
    legacyHeaders: false,
});

// Strict rate limiter for authentication endpoints
export const authLimiter = rateLimit({
    windowMs: 15 * 60 * 1000,
    max: 1000, // Relaxed
    message: {
        success: false,
        error: {
            code: 'AUTH_RATE_LIMIT_EXCEEDED',
            message: 'Too many login attempts, please try again later',
        },
    },
    standardHeaders: true,
    legacyHeaders: false,
    skipSuccessfulRequests: true,
});

// Rate limiter for item creation
export const createItemLimiter = rateLimit({
    windowMs: 60 * 60 * 1000,
    max: 1000, // Relaxed
    message: {
        success: false,
        error: {
            code: 'CREATE_LIMIT_EXCEEDED',
            message: 'Too many items created, please try again later',
        },
    },
    standardHeaders: true,
    legacyHeaders: false,
});

// Rate limiter for claim submission
export const claimLimiter = rateLimit({
    windowMs: 15 * 60 * 1000, // 15 minutes
    max: 5, // 5 claims per 15 minutes
    message: {
        success: false,
        error: {
            code: 'CLAIM_LIMIT_EXCEEDED',
            message: 'Too many claim submissions, please try again later',
        },
    },
    standardHeaders: true,
    legacyHeaders: false,
});
