import { Request, Response } from 'express';
import { ItemsService } from './items.service';
import { successResponse } from '../../utils/apiResponse';
import { asyncHandler } from '../../middlewares/error.middleware';

const itemsService = new ItemsService();

export class ItemsController {
    // POST /api/v1/items
    createItem = asyncHandler(async (req: Request, res: Response) => {
        const userId = req.user!.userId;
        const item = await itemsService.createItem(req.body, userId);

        return successResponse(res, item, 201);
    });

    // GET /api/v1/items
    listItems = asyncHandler(async (req: Request, res: Response) => {
        const result = await itemsService.listItems(req.query as any);

        return successResponse(res, result.items, 200, result.pagination);
    });

    // GET /api/v1/items/:id
    getItem = asyncHandler(async (req: Request, res: Response) => {
        const { id } = req.params;
        const item = await itemsService.getItemById(id);

        return successResponse(res, item);
    });

    // PATCH /api/v1/items/:id
    updateItem = asyncHandler(async (req: Request, res: Response) => {
        const { id } = req.params;
        const userId = req.user!.userId;
        const userRole = req.user!.role;

        const item = await itemsService.updateItem(id, req.body, userId, userRole);

        return successResponse(res, item);
    });

    // DELETE /api/v1/items/:id
    deleteItem = asyncHandler(async (req: Request, res: Response) => {
        const { id } = req.params;
        const userId = req.user!.userId;
        const userRole = req.user!.role;

        await itemsService.deleteItem(id, userId, userRole);

        return successResponse(res, { message: 'Item deleted successfully' });
    });

    // GET /api/v1/items/me/items
    getMyItems = asyncHandler(async (req: Request, res: Response) => {
        const userId = req.user!.userId;
        const items = await itemsService.getUserItems(userId);

        return successResponse(res, items);
    });
}
