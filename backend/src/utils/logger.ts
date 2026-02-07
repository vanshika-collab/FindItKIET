import winston from 'winston';
import { env } from '../config/env';

// Custom log format
const logFormat = winston.format.combine(
    winston.format.timestamp({ format: 'YYYY-MM-DD HH:mm:ss' }),
    winston.format.errors({ stack: true }),
    winston.format.splat(),
    winston.format.json()
);

// Console format for development
const consoleFormat = winston.format.combine(
    winston.format.colorize(),
    winston.format.timestamp({ format: 'HH:mm:ss' }),
    winston.format.printf(({ timestamp, level, message, ...meta }) => {
        let msg = `${timestamp} [${level}]: ${message}`;
        if (Object.keys(meta).length > 0) {
            msg += ` ${JSON.stringify(meta)}`;
        }
        return msg;
    })
);

// Create logger instance
export const logger = winston.createLogger({
    level: env.LOG_LEVEL,
    format: logFormat,
    defaultMeta: { service: 'finditkiet-api' },
    transports: [
        // Console transport
        new winston.transports.Console({
            format: env.NODE_ENV === 'production' ? logFormat : consoleFormat,
        }),
        // File transport for errors (production)
        ...(env.NODE_ENV === 'production'
            ? [
                new winston.transports.File({
                    filename: 'logs/error.log',
                    level: 'error',
                }),
                new winston.transports.File({
                    filename: 'logs/combined.log',
                }),
            ]
            : []),
    ],
});

// Stream for Morgan HTTP logger
export const httpLoggerStream = {
    write: (message: string) => {
        logger.http(message.trim());
    },
};
