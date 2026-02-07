import { Router } from 'express';
import { AdminController } from './admin.controller';
import { validate } from '../../middlewares/validation.middleware';
import { authenticate } from '../../middlewares/auth.middleware';
import { requireAdmin } from '../../middlewares/role.middleware';
import {
    approveClaimSchema,
    rejectClaimSchema,
    handoverItemSchema,
    listClaimsSchema,
    claimIdSchema,
    itemIdSchema,
} from './admin.validation';

const router = Router();
const adminController = new AdminController();

// All admin routes require authentication and ADMIN role
router.use(authenticate);
router.use(requireAdmin);

// Claim management
router.get(
    '/claims',
    validate(listClaimsSchema),
    adminController.getAllClaims
);

router.post(
    '/claims/:claimId/approve',
    validate({ ...claimIdSchema, ...approveClaimSchema }),
    adminController.approveClaim
);

router.post(
    '/claims/:claimId/reject',
    validate({ ...claimIdSchema, ...rejectClaimSchema }),
    adminController.rejectClaim
);

// Item management
router.get('/items', adminController.getAllItems);

router.post(
    '/items/:itemId/handover',
    validate({ ...itemIdSchema, ...handoverItemSchema }),
    adminController.handoverItem
);

router.delete(
    '/items/:itemId',
    validate(itemIdSchema),
    adminController.deleteItem
);

// Audit logs
router.get('/audit-logs', adminController.getAuditLogs);

export default router;
