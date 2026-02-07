import { Router } from 'express';
import { CertificatesController } from './certificates.controller';
import { authenticate } from '../../middlewares/auth.middleware'; // Verify path

const router = Router();
const controller = new CertificatesController();

// Protected routes
router.post('/record', authenticate, controller.recordCertificate); // Call after 8000 success
router.get('/me', authenticate, controller.checkMyCertificate);

export default router;
