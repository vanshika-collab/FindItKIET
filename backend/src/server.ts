import { createApp } from './app';
import { env } from './config/env';
import { logger } from './utils/logger';
import { prisma, disconnectDatabase } from './config/database';

const startServer = async () => {
    try {
        // Test database connection
        await prisma.$connect();
        logger.info('✅ Database connected successfully');

        // Create Express app
        const app = createApp();

        // Start server
        const server = app.listen(env.PORT, () => {
            logger.info(`🚀 Server running on port ${env.PORT}`);
            logger.info(`📝 Environment: ${env.NODE_ENV}`);
            logger.info(`🔗 API Base URL: http://localhost:${env.PORT}/api/${env.API_VERSION}`);
        });

        // Graceful shutdown
        const gracefulShutdown = async (signal: string) => {
            logger.info(`${signal} signal received: closing HTTP server`);

            server.close(async () => {
                logger.info('HTTP server closed');
                await disconnectDatabase();
                process.exit(0);
            });

            // Force shutdown after 10 seconds
            setTimeout(() => {
                logger.error('Forced shutdown after timeout');
                process.exit(1);
            }, 10000);
        };

        process.on('SIGTERM', () => gracefulShutdown('SIGTERM'));
        process.on('SIGINT', () => gracefulShutdown('SIGINT'));

    } catch (error) {
        logger.error('Failed to start server:', error);
        process.exit(1);
    }
};

// Start the server
startServer();
