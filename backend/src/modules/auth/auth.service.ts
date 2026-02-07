import { prisma } from '../../config/database';
import { hashPassword, verifyPassword } from '../../utils/password';
import {
    generateAccessToken,
    generateRefreshToken,
    verifyRefreshToken,
    JwtPayload,
} from '../../utils/jwt';
import {
    UnauthorizedError,
    ConflictError,
    NotFoundError,
    ForbiddenError,
} from '../../utils/errors';
import { LoginRequest, RegisterRequest } from './auth.validation';

export class AuthService {
    // Register new user
    async register(data: RegisterRequest) {
        // Check if user already exists
        const existingUser = await prisma.user.findUnique({
            where: { email: data.email },
        });

        if (existingUser) {
            throw new ConflictError('User with this email already exists');
        }

        // Hash password
        const passwordHash = await hashPassword(data.password);

        // Create user
        const user = await prisma.user.create({
            data: {
                email: data.email,
                name: data.name,
                passwordHash,
                role: 'USER',
            },
            select: {
                id: true,
                email: true,
                name: true,
                role: true,
                createdAt: true,
            },
        });

        // Generate tokens
        const payload: JwtPayload = {
            userId: user.id,
            email: user.email,
            role: user.role,
        };

        const accessToken = generateAccessToken(payload);
        const refreshToken = generateRefreshToken(payload);

        // Store refresh token
        const expiresAt = new Date();
        expiresAt.setDate(expiresAt.getDate() + 7); // 7 days

        await prisma.refreshToken.create({
            data: {
                token: refreshToken,
                userId: user.id,
                expiresAt,
            },
        });

        return {
            user,
            accessToken,
            refreshToken,
        };
    }

    // Login user
    async login(data: LoginRequest) {
        // Find user
        const user = await prisma.user.findUnique({
            where: { email: data.email },
        });

        if (!user) {
            throw new UnauthorizedError('Invalid credentials');
        }

        // Verify password
        const isValidPassword = await verifyPassword(data.password, user.passwordHash);

        if (!isValidPassword) {
            throw new UnauthorizedError('Invalid credentials');
        }

        // Check if user is banned
        if (user.bannedUntil && user.bannedUntil > new Date()) {
            throw new ForbiddenError(
                `Your account has been temporarily suspended for suspicious activity. Ban lifts on: ${user.bannedUntil.toLocaleString()}`
            );
        }

        // Generate tokens
        const payload: JwtPayload = {
            userId: user.id,
            email: user.email,
            role: user.role,
        };

        const accessToken = generateAccessToken(payload);
        const refreshToken = generateRefreshToken(payload);

        // Store refresh token
        const expiresAt = new Date();
        expiresAt.setDate(expiresAt.getDate() + 7);

        await prisma.refreshToken.create({
            data: {
                token: refreshToken,
                userId: user.id,
                expiresAt,
            },
        });

        return {
            user: {
                id: user.id,
                email: user.email,
                name: user.name,
                role: user.role,
            },
            accessToken,
            refreshToken,
        };
    }

    // Refresh access token
    async refreshAccessToken(token: string) {
        // Verify refresh token
        let payload: JwtPayload;
        try {
            payload = verifyRefreshToken(token);
        } catch (error) {
            throw new UnauthorizedError('Invalid or expired refresh token');
        }

        // Check if refresh token exists in database
        const storedToken = await prisma.refreshToken.findUnique({
            where: { token },
            include: { user: true },
        });

        if (!storedToken) {
            throw new UnauthorizedError('Refresh token not found');
        }

        // Check if token is expired
        if (storedToken.expiresAt < new Date()) {
            // Delete expired token
            await prisma.refreshToken.delete({
                where: { id: storedToken.id },
            });
            throw new UnauthorizedError('Refresh token expired');
        }

        // Generate new access token
        const newPayload: JwtPayload = {
            userId: storedToken.user.id,
            email: storedToken.user.email,
            role: storedToken.user.role,
        };

        const accessToken = generateAccessToken(newPayload);

        // Optionally rotate refresh token (recommended for security)
        const newRefreshToken = generateRefreshToken(newPayload);

        // Delete old refresh token and create new one
        await prisma.$transaction([
            prisma.refreshToken.delete({
                where: { id: storedToken.id },
            }),
            prisma.refreshToken.create({
                data: {
                    token: newRefreshToken,
                    userId: storedToken.user.id,
                    expiresAt: new Date(Date.now() + 7 * 24 * 60 * 60 * 1000),
                },
            }),
        ]);

        return {
            accessToken,
            refreshToken: newRefreshToken,
        };
    }

    // Logout user (invalidate refresh token)
    async logout(token: string) {
        await prisma.refreshToken.deleteMany({
            where: { token },
        });
    }

    // Logout all sessions for a user
    async logoutAll(userId: string) {
        await prisma.refreshToken.deleteMany({
            where: { userId },
        });
    }

    // Get user by ID (for /me)
    async getUserById(userId: string) {
        const user = await prisma.user.findUnique({
            where: { id: userId },
            select: {
                id: true,
                email: true,
                name: true,
                role: true,
                createdAt: true,
            },
        });

        if (!user) {
            throw new NotFoundError('User not found');
        }

        return user;
    }

    // Clean up expired tokens (can be run periodically)
    async cleanupExpiredTokens() {
        const deleted = await prisma.refreshToken.deleteMany({
            where: {
                expiresAt: {
                    lt: new Date(),
                },
            },
        });
        return deleted.count;
    }
}
