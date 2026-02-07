import jwt from 'jsonwebtoken';
import { env } from '../config/env';

export interface JwtPayload {
    userId: string;
    email: string;
    role: string;
}

// Generate access token
export const generateAccessToken = (payload: JwtPayload): string => {
    return jwt.sign(payload, env.JWT_ACCESS_SECRET, {
        expiresIn: env.JWT_ACCESS_EXPIRY,
    });
};

// Generate refresh token
export const generateRefreshToken = (payload: JwtPayload): string => {
    return jwt.sign(payload, env.JWT_REFRESH_SECRET, {
        expiresIn: env.JWT_REFRESH_EXPIRY,
    });
};

// Verify access token
export const verifyAccessToken = (token: string): JwtPayload => {
    try {
        return jwt.verify(token, env.JWT_ACCESS_SECRET) as JwtPayload;
    } catch (error) {
        throw new Error('Invalid or expired token');
    }
};

// Verify refresh token
export const verifyRefreshToken = (token: string): JwtPayload => {
    try {
        return jwt.verify(token, env.JWT_REFRESH_SECRET) as JwtPayload;
    } catch (error) {
        throw new Error('Invalid or expired refresh token');
    }
};

// Decode token without verification (for debugging only)
export const decodeToken = (token: string): JwtPayload | null => {
    try {
        return jwt.decode(token) as JwtPayload;
    } catch {
        return null;
    }
};
