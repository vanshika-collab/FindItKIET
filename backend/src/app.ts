import express, { Application } from 'express';
import helmet from 'helmet';
import cors from 'cors';
import { env } from './config/env';
import { logger } from './utils/logger';
import { errorHandler, notFoundHandler } from './middlewares/error.middleware';
import { apiLimiter } from './middlewares/rateLimit.middleware';

// Import routes
import authRoutes from './modules/auth/auth.routes';
import itemsRoutes from './modules/items/items.routes';
import claimsRoutes from './modules/claims/claims.routes';
import adminRoutes from './modules/admin/admin.routes';
import leaderboardRoutes from './modules/leaderboard/leaderboard.routes';
import uploadRoutes from './routes/upload.routes';
import certificatesRoutes from './modules/certificates/certificates.routes';
import { CertificatesController } from './modules/certificates/certificates.controller';

export const createApp = (): Application => {
    const app = express();

    // Security middleware
    app.use(helmet());

    // CORS configuration
    const allowedOrigins = env.ALLOWED_ORIGINS.split(',').map(origin => origin.trim());
    app.use(
        cors({
            origin: (origin, callback) => {
                // Allow requests with no origin (like mobile apps or Postman)
                if (!origin) return callback(null, true);

                if (allowedOrigins.includes('*') || allowedOrigins.includes(origin)) {
                    callback(null, true);
                } else {
                    callback(new Error('Not allowed by CORS'));
                }
            },
            credentials: true,
        })
    );

    // Body parsing middleware
    app.use(express.json()); // Parse JSON bodies
    app.use(express.urlencoded({ extended: true })); // Parse URL-encoded bodies

    // Serve uploaded files statically
    app.use('/uploads', express.static('uploads'));

    // Request logging
    app.use((req, res, next) => {
        logger.info(`${req.method} ${req.path}`, {
            ip: req.ip,
            userAgent: req.get('user-agent'),
        });
        next();
    });

    // API rate limiting
    // API rate limiting
    // app.use(`/api/${env.API_VERSION}`, apiLimiter); // Disabled per user request

    // Health check endpoint
    app.get('/health', (req, res) => {
        res.json({
            status: 'ok',
            timestamp: new Date().toISOString(),
            environment: env.NODE_ENV,
        });
    });

    // API Routes
    app.use(`/api/${env.API_VERSION}/auth`, authRoutes);
    app.use(`/api/${env.API_VERSION}/items`, itemsRoutes);
    app.use(`/api/${env.API_VERSION}/claims`, claimsRoutes);
    app.use(`/api/${env.API_VERSION}/admin`, adminRoutes);
    app.use(`/api/${env.API_VERSION}/leaderboard`, leaderboardRoutes);
    app.use(`/api/${env.API_VERSION}/upload`, uploadRoutes);
    app.use(`/api/${env.API_VERSION}/certificates`, certificatesRoutes);

    // Certificate generation route (Direct mount as per requirement)
    const certificatesController = new CertificatesController();
    app.post(`/api/${env.API_VERSION}/generate-certificate`, certificatesController.generateCertificate);

    // 404 handler
    app.use(notFoundHandler);

    // Global error handler (must be last)
    app.use(errorHandler);

    return app;
};
