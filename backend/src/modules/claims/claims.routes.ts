import { Router } from 'express';
import { ClaimsController } from './claims.controller';
import { validate } from '../../middlewares/validation.middleware';
import { authenticate } from '../../middlewares/auth.middleware';
import { requireUser } from '../../middlewares/role.middleware';
import { claimLimiter } from '../../middlewares/rateLimit.middleware';
import {
    createClaimSchema,
    itemIdParamSchema,
    claimIdParamSchema,
} from './claims.validation';

const router = Router();
const claimsController = new ClaimsController();

// All claim routes require authentication
router.use(authenticate);
router.use(requireUser);

// Get user's own claims
router.get('/me', claimsController.getMyClaims);

// Get specific claim details
router.get(
    '/:claimId',
    validate(claimIdParamSchema),
    claimsController.getClaim
);

export default router;

// Export a separate router for item-specific claim routes
export const itemClaimRoutes = Router({ mergeParams: true });

// Create claim for an item - should be mounted under /items/:itemId/claims
itemClaimRoutes.post(
    '/',
    authenticate,
    requireUser,
    claimLimiter,
    validate(createClaimSchema),
    claimsController.createClaim
);

// Get all claims for an item
itemClaimRoutes.get(
    '/',
    authenticate,
    requireUser,
    claimsController.getItemClaims
);
