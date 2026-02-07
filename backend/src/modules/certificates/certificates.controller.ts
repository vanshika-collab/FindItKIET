import { Request, Response } from 'express';
import { CertificatesService } from './certificates.service';
import { asyncHandler } from '../../middlewares/error.middleware';

const certificatesService = new CertificatesService();

export class CertificatesController {
    // Generate (Legacy/Main functionality)
    generateCertificate = asyncHandler(async (req: Request, res: Response) => {
        const { name, email } = req.body;
        if (!name || !email) {
            res.status(400).json({ status: 'error', message: 'Name and email are required' });
            return;
        }
        const result = await certificatesService.generateCertificate(name, email);
        res.status(200).json(result);
    });

    // Record that a certificate was sent (called after port 8000 success)
    recordCertificate = asyncHandler(async (req: Request, res: Response) => {
        const { email } = req.body;
        if (!email) {
            res.status(400).json({ status: 'error', message: 'Email required' });
            return;
        }
        await certificatesService.recordCertificate(email);
        res.status(200).json({ status: 'success', message: 'Record saved' });
    });

    // Check if current user has a certificate
    checkMyCertificate = asyncHandler(async (req: Request, res: Response) => {
        // Assumes auth middleware sets req.user
        const userId = (req as any).user?.id;
        if (!userId) {
            res.status(401).json({ status: 'error', message: 'Unauthorized' });
            return;
        }

        const hasCert = await certificatesService.hasCertificate(userId);
        res.json({
            status: 'success',
            hasCertificate: hasCert
        });
    });
}
