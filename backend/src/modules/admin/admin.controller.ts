import { Request, Response } from 'express';
import { AdminService } from './admin.service';
import { successResponse } from '../../utils/apiResponse';
import { asyncHandler } from '../../middlewares/error.middleware';

const adminService = new AdminService();

export class AdminController {
    // GET /api/v1/admin/claims
    getAllClaims = asyncHandler(async (req: Request, res: Response) => {
        const result = await adminService.getAllClaims(req.query as any);

        return successResponse(res, result.claims, 200, result.pagination);
    });

    // POST /api/v1/admin/claims/:claimId/approve
    approveClaim = asyncHandler(async (req: Request, res: Response) => {
        const { claimId } = req.params;
        const adminId = req.user!.userId;

        const claim = await adminService.approveClaim(claimId, req.body, adminId);

        return successResponse(res, claim);
    });

    // POST /api/v1/admin/claims/:claimId/reject
    rejectClaim = asyncHandler(async (req: Request, res: Response) => {
        const { claimId } = req.params;
        const adminId = req.user!.userId;

        const claim = await adminService.rejectClaim(claimId, req.body, adminId);

        return successResponse(res, claim);
    });

    // POST /api/v1/admin/items/:itemId/handover
    handoverItem = asyncHandler(async (req: Request, res: Response) => {
        const { itemId } = req.params;
        const adminId = req.user!.userId;

        const item = await adminService.handoverItem(itemId, req.body, adminId);

        return successResponse(res, item);
    });

    // DELETE /api/v1/admin/items/:itemId
    deleteItem = asyncHandler(async (req: Request, res: Response) => {
        const { itemId } = req.params;
        const adminId = req.user!.userId;
        const { reason } = req.body;

        await adminService.deleteItem(itemId, adminId, reason);

        return successResponse(res, { message: 'Item deleted successfully' });
    });

    // GET /api/v1/admin/items
    getAllItems = asyncHandler(async (req: Request, res: Response) => {
        const page = parseInt(req.query.page as string) || 1;
        const limit = parseInt(req.query.limit as string) || 20;

        const result = await adminService.getAllItems(page, limit);

        return successResponse(res, result.items, 200, result.pagination);
    });

    // GET /api/v1/admin/audit-logs
    getAuditLogs = asyncHandler(async (req: Request, res: Response) => {
        const page = parseInt(req.query.page as string) || 1;
        const limit = parseInt(req.query.limit as string) || 50;

        const result = await adminService.getAuditLogs(page, limit);

        return successResponse(res, result.logs, 200, result.pagination);
    });
}
