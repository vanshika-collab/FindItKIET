import { Router } from 'express';
import { AuthController } from './auth.controller';
import { validate } from '../../middlewares/validation.middleware';
import { authenticate } from '../../middlewares/auth.middleware';
import { authLimiter } from '../../middlewares/rateLimit.middleware';
import {
    loginSchema,
    registerSchema,
    refreshTokenSchema,
} from './auth.validation';

const router = Router();
const authController = new AuthController();

// Public routes with rate limiting
router.post(
    '/register',
    authLimiter,
    validate(registerSchema),
    authController.register
);

router.post(
    '/login',
    authLimiter,
    validate(loginSchema),
    authController.login
);

router.post(
    '/refresh',
    validate(refreshTokenSchema),
    authController.refresh
);

router.post(
    '/logout',
    validate(refreshTokenSchema),
    authController.logout
);

// Protected route
router.post(
    '/logout-all',
    authenticate,
    authController.logoutAll
);

router.get(
    '/me',
    authenticate,
    authController.me
);

export default router;
