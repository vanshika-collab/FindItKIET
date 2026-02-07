import { Router } from 'express';
import { ItemsController } from './items.controller';
import { validate } from '../../middlewares/validation.middleware';
import { authenticate } from '../../middlewares/auth.middleware';
import { requireUser } from '../../middlewares/role.middleware';
import { createItemLimiter } from '../../middlewares/rateLimit.middleware';
import {
    createItemSchema,
    updateItemSchema,
    listItemsSchema,
    itemIdSchema,
} from './items.validation';
import { itemClaimRoutes } from '../claims/claims.routes';

const router = Router();
const itemsController = new ItemsController();

// Public routes (no authentication required for viewing)
router.get(
    '/',
    validate(listItemsSchema),
    itemsController.listItems
);

router.get(
    '/:id',
    validate(itemIdSchema),
    itemsController.getItem
);

// Protected routes (require authentication)
router.post(
    '/',
    authenticate,
    requireUser,
    createItemLimiter,
    validate(createItemSchema),
    itemsController.createItem
);

router.get(
    '/me/items',
    authenticate,
    requireUser,
    itemsController.getMyItems
);

router.patch(
    '/:id',
    authenticate,
    requireUser,
    validate({ ...itemIdSchema, ...updateItemSchema }),
    itemsController.updateItem
);

router.delete(
    '/:id',
    authenticate,
    requireUser,
    validate(itemIdSchema),
    itemsController.deleteItem
);

// Claim routes for specific items
router.use('/:itemId/claims', itemClaimRoutes);

export default router;
