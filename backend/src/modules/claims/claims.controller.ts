import { Request, Response } from 'express';
import { ClaimsService } from './claims.service';
import { successResponse } from '../../utils/apiResponse';
import { asyncHandler } from '../../middlewares/error.middleware';

const claimsService = new ClaimsService();

export class ClaimsController {
    // POST /api/v1/items/:itemId/claims
    createClaim = asyncHandler(async (req: Request, res: Response) => {
        const { itemId } = req.params;
        const userId = req.user!.userId;

        const claim = await claimsService.createClaim(itemId, req.body, userId);

        return successResponse(res, claim, 201);
    });

    // GET /api/v1/claims/me
    getMyClaims = asyncHandler(async (req: Request, res: Response) => {
        const userId = req.user!.userId;
        const claims = await claimsService.getUserClaims(userId);

        return successResponse(res, claims);
    });

    // GET /api/v1/claims/:claimId
    getClaim = asyncHandler(async (req: Request, res: Response) => {
        const { claimId } = req.params;
        const claim = await claimsService.getClaimById(claimId);

        return successResponse(res, claim);
    });

    // GET /api/v1/items/:itemId/claims
    getItemClaims = asyncHandler(async (req: Request, res: Response) => {
        const { itemId } = req.params;
        const claims = await claimsService.getItemClaims(itemId);

        return successResponse(res, claims);
    });
}
