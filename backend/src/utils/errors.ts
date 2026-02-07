// Custom error class for API errors
export class AppError extends Error {
    constructor(
        public code: string,
        public message: string,
        public statusCode: number = 400,
        public details?: any
    ) {
        super(message);
        this.name = 'AppError';
        Error.captureStackTrace(this, this.constructor);
    }
}

// Predefined error types
export class ValidationError extends AppError {
    constructor(message: string, details?: any) {
        super('VALIDATION_ERROR', message, 400, details);
    }
}

export class UnauthorizedError extends AppError {
    constructor(message: string = 'Unauthorized') {
        super('UNAUTHORIZED', message, 401);
    }
}

export class ForbiddenError extends AppError {
    constructor(message: string = 'Forbidden') {
        super('FORBIDDEN', message, 403);
    }
}

export class NotFoundError extends AppError {
    constructor(message: string = 'Resource not found') {
        super('NOT_FOUND', message, 404);
    }
}

export class ConflictError extends AppError {
    constructor(message: string) {
        super('CONFLICT', message, 409);
    }
}

export class InternalServerError extends AppError {
    constructor(message: string = 'Internal server error') {
        super('INTERNAL_ERROR', message, 500);
    }
}
