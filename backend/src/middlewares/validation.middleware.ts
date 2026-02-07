import { Request, Response, NextFunction } from 'express';
import { z, ZodSchema } from 'zod';
import { ValidationError } from '../utils/errors';

// Validation middleware factory
export const validate = (schema: {
    body?: ZodSchema;
    query?: ZodSchema;
    params?: ZodSchema;
}) => {
    return (req: Request, res: Response, next: NextFunction): void => {
        try {
            // Validate request body
            if (schema.body) {
                req.body = schema.body.parse(req.body);
            }

            // Validate query parameters
            if (schema.query) {
                req.query = schema.query.parse(req.query) as any;
            }

            // Validate route parameters
            if (schema.params) {
                req.params = schema.params.parse(req.params);
            }

            next();
        } catch (error) {
            if (error instanceof z.ZodError) {
                const details = error.errors.map((err) => ({
                    field: err.path.join('.'),
                    message: err.message,
                }));

                next(new ValidationError('Request validation failed', details));
            } else {
                next(error);
            }
        }
    };
};
