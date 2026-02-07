import { Router, Request, Response } from 'express';
import multer from 'multer';
import path from 'path';
import { v4 as uuidv4 } from 'uuid';
import { authenticate } from '../middlewares/auth.middleware';
import { asyncHandler } from '../middlewares/error.middleware';
import { successResponse } from '../utils/apiResponse';

const router = Router();

// Configure multer for file storage
const storage = multer.diskStorage({
    destination: (req, file, cb) => {
        cb(null, 'uploads/');
    },
    filename: (req, file, cb) => {
        const uniqueName = `${uuidv4()}${path.extname(file.originalname)}`;
        cb(null, uniqueName);
    },
});

// File filter - only allow images
const fileFilter = (req: Request, file: Express.Multer.File, cb: multer.FileFilterCallback) => {
    const allowedTypes = /jpeg|jpg|png|gif|webp/;
    const extname = allowedTypes.test(path.extname(file.originalname).toLowerCase());
    const mimetype = allowedTypes.test(file.mimetype);

    if (extname && mimetype) {
        cb(null, true);
    } else {
        cb(new Error('Only image files are allowed (jpeg, jpg, png, gif, webp)'));
    }
};

// Configure multer
const upload = multer({
    storage,
    fileFilter,
    limits: {
        fileSize: 5 * 1024 * 1024, // 5MB max file size
    },
});

// Single image upload
router.post(
    '/single',
    authenticate,
    upload.single('image'),
    asyncHandler(async (req: Request, res: Response) => {
        if (!req.file) {
            return res.status(400).json({
                success: false,
                error: { code: 'NO_FILE', message: 'No file uploaded' },
            });
        }

        const imageUrl = `${req.protocol}://${req.get('host')}/uploads/${req.file.filename}`;

        return successResponse(res, {
            filename: req.file.filename,
            url: imageUrl,
            size: req.file.size,
            mimetype: req.file.mimetype,
        });
    })
);

// Multiple images upload
router.post(
    '/multiple',
    authenticate,
    upload.array('images', 5), // Max 5 images
    asyncHandler(async (req: Request, res: Response) => {
        if (!req.files || !Array.isArray(req.files) || req.files.length === 0) {
            return res.status(400).json({
                success: false,
                error: { code: 'NO_FILES', message: 'No files uploaded' },
            });
        }

        const uploadedImages = req.files.map((file) => ({
            filename: file.filename,
            url: `${req.protocol}://${req.get('host')}/uploads/${file.filename}`,
            size: file.size,
            mimetype: file.mimetype,
        }));

        return successResponse(res, {
            count: uploadedImages.length,
            images: uploadedImages,
        });
    })
);

export default router;
