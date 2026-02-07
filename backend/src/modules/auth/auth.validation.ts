import { z } from 'zod';

// Login request schema
export const loginSchema = z.object({
    body: z.object({
        email: z.string().email('Invalid email address'),
        password: z.string().min(6, 'Password must be at least 6 characters'),
    }),
});

// Register request schema
export const registerSchema = z.object({
    body: z.object({
        email: z.string().email('Invalid email address'),
        password: z.string().min(6, 'Password must be at least 6 characters'),
        name: z.string().min(2, 'Name must be at least 2 characters'),
    }),
});

// Refresh token request schema
export const refreshTokenSchema = z.object({
    body: z.object({
        refreshToken: z.string().min(1, 'Refresh token is required'),
    }),
});

// Types
export type LoginRequest = z.infer<typeof loginSchema.body>;
export type RegisterRequest = z.infer<typeof registerSchema.body>;
export type RefreshTokenRequest = z.infer<typeof refreshTokenSchema.body>;
