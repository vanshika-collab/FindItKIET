import { PrismaClient } from '@prisma/client';
import { logger } from '../utils/logger';

// Singleton Prisma Client instance
const prismaClientSingleton = () => {
    return new PrismaClient({
        log: [
            { level: 'query', emit: 'event' },
            { level: 'error', emit: 'event' },
            { level: 'warn', emit: 'event' },
        ],
    });
};

declare global {
    // eslint-disable-next-line no-var
    var prismaGlobal: ReturnType<typeof prismaClientSingleton> | undefined;
}

export const prisma = globalThis.prismaGlobal ?? prismaClientSingleton();

if (process.env.NODE_ENV !== 'production') {
    globalThis.prismaGlobal = prisma;
}

// Log database queries in development
if (process.env.NODE_ENV === 'development') {
    prisma.$on('query', (e) => {
        logger.debug(`Query: ${e.query}`);
        logger.debug(`Duration: ${e.duration}ms`);
    });
}

// Log database errors
prisma.$on('error', (e) => {
    logger.error('Database error:', e);
});

// Log database warnings
prisma.$on('warn', (e) => {
    logger.warn('Database warning:', e);
});

// Graceful shutdown
export const disconnectDatabase = async () => {
    await prisma.$disconnect();
    logger.info('Database disconnected');
};
