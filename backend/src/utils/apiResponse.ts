import { Response } from 'express';

// Standard API response structure
export interface ApiResponse<T = any> {
    success: boolean;
    data?: T;
    error?: {
        code: string;
        message: string;
        details?: any;
    };
    meta?: {
        page?: number;
        limit?: number;
        total?: number;
        totalPages?: number;
    };
}

// Success response helper
export const successResponse = <T>(
    res: Response,
    data: T,
    statusCode: number = 200,
    meta?: ApiResponse['meta']
): Response => {
    const response: ApiResponse<T> = {
        success: true,
        data,
        ...(meta && { meta }),
    };
    return res.status(statusCode).json(response);
};

// Error response helper
export const errorResponse = (
    res: Response,
    code: string,
    message: string,
    statusCode: number = 400,
    details?: any
): Response => {
    const response: ApiResponse = {
        success: false,
        error: {
            code,
            message,
            ...(details && { details }),
        },
    };
    return res.status(statusCode).json(response);
};

// Pagination helper
export const createPaginationMeta = (
    page: number,
    limit: number,
    total: number
) => ({
    page,
    limit,
    total,
    totalPages: Math.ceil(total / limit),
});
