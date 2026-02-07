import { prisma } from '../../config/database';
import {
    NotFoundError,
    ConflictError,
    ForbiddenError,
} from '../../utils/errors';
import { CreateClaimRequest } from './claims.validation';
import { ImageVerificationService } from '../../services/ImageVerificationService';
import { GeminiService } from '../../services/GeminiService';

export class ClaimsService {
    // Create a new claim
    async createClaim(itemId: string, data: CreateClaimRequest, userId: string) {
        // Check if item exists
        const item = await prisma.item.findUnique({
            where: { id: itemId },
            include: {
                createdBy: true,
                images: true,
            },
        });

        if (!item) {
            throw new NotFoundError('Item not found');
        }

        // Prevent claiming own item
        if (item.createdById === userId) {
            throw new ConflictError('You cannot claim your own item');
        }

        // Only LOST and FOUND items can be claimed
        if (item.status !== 'LOST' && item.status !== 'FOUND') {
            throw new ConflictError('This item cannot be claimed');
        }

        // Check if user already has a claim for this item
        const existingClaim = await prisma.claim.findUnique({
            where: {
                itemId_userId: {
                    itemId,
                    userId,
                },
            },
        });

        if (existingClaim) {
            throw new ConflictError('You already have a claim for this item');
        }

        // Check if there's already a pending or approved claim
        const activeClaim = await prisma.claim.findFirst({
            where: {
                itemId,
                status: { in: ['PENDING', 'APPROVED'] },
            },
        });

        if (activeClaim) {
            throw new ConflictError('This item already has an active claim');
        }


        // Calculate Verification Score
        let verificationScore = 0;
        let checksCount = 0;
        let verificationDetails = [];

        try {
            const imageVerificationService = new ImageVerificationService();
            const geminiService = new GeminiService();

            // 1. Verify Images
            if (item.images && item.images.length > 0) {
                const originalImageUrl = item.images[0].imageUrl; // Use primary image

                for (const proof of data.proofs) {
                    if (proof.type === 'IMAGE' && proof.imageUrl) {
                        try {
                            // Helper to get local path from URL if it's a local upload
                            // Assuming imageUrl is relative path like 'uploads/...' or full URL
                            // For now, let's pass it as is, the service handles logic
                            // But ImageVerificationService expects a local path for claim image
                            // We need to resolve proof.imageUrl to a local path if it was just uploaded via multer

                            // Note: In a real app, we need to know where the file is stored locally
                            // If imageUrl is 'uploads/verified/file.jpg', we might need to prepend 'backend/' or similar
                            // Let's assume proof.imageUrl is the path saved in DB which matches file system relative to root or public

                            // Simple heuristic: if it doesn't start with http, it's local
                            let claimImagePath = proof.imageUrl;
                            if (!claimImagePath.startsWith('http') && !claimImagePath.startsWith('/')) {
                                claimImagePath = `./${claimImagePath}`; // Relative to backend root
                            }

                            const score = await imageVerificationService.verifyImage(originalImageUrl, claimImagePath);
                            verificationScore += score;
                            checksCount++;
                            verificationDetails.push(`Image Match: ${Math.round(score)}%`);
                        } catch (err) {
                            console.error('Image verification error:', err);
                        }
                    }
                }
            }

            // 2. Verify Text Description
            if (item.description) {
                for (const proof of data.proofs) {
                    if (proof.type === 'DESCRIPTION' || proof.type === 'ANSWERS') {
                        try {
                            const score = await geminiService.verifyDescription(item.description, proof.value);
                            verificationScore += score;
                            checksCount++;
                            verificationDetails.push(`Text Match: ${Math.round(score)}%`);
                        } catch (err) {
                            console.error('Text verification error:', err);
                        }
                    }
                }
            }
        } catch (verificationError) {
            console.error('Verification process failed:', verificationError);
        }

        // Calculate average score
        const finalScore = checksCount > 0 ? Math.round(verificationScore / checksCount) : 0;
        const verificationComment = `Auto-Verification Score: ${finalScore}% [${verificationDetails.join(', ')}]`;

        // Create claim with proofs in a transaction
        const claim = await prisma.$transaction(async (tx) => {
            // Create claim
            const newClaim = await tx.claim.create({
                data: {
                    itemId,
                    userId,
                    status: 'PENDING',
                    adminComment: verificationComment, // Store score here
                },
            });

            // Create proofs
            await tx.claimProof.createMany({
                data: data.proofs.map((proof) => ({
                    claimId: newClaim.id,
                    proofType: proof.type,
                    proofValue: proof.value,
                    imageUrl: proof.imageUrl,
                })),
            });

            // Update item status to CLAIMED
            await tx.item.update({
                where: { id: itemId },
                data: { status: 'CLAIMED' },
            });

            // Return claim with proofs
            return tx.claim.findUnique({
                where: { id: newClaim.id },
                include: {
                    proofs: true,
                    user: {
                        select: {
                            id: true,
                            name: true,
                            email: true,
                        },
                    },
                    item: {
                        include: {
                            images: true,
                            createdBy: {
                                select: {
                                    id: true,
                                    name: true,
                                    email: true,
                                },
                            },
                        },
                    },
                },
            });
        });

        return claim;
    }

    // Get user's claims
    async getUserClaims(userId: string) {
        const claims = await prisma.claim.findMany({
            where: { userId },
            orderBy: { createdAt: 'desc' },
            include: {
                proofs: true,
                item: {
                    include: {
                        images: {
                            take: 1,
                        },
                        createdBy: {
                            select: {
                                id: true,
                                name: true,
                            },
                        },
                    },
                },
            },
        });

        return claims;
    }

    // Get claim by ID
    async getClaimById(claimId: string) {
        const claim = await prisma.claim.findUnique({
            where: { id: claimId },
            include: {
                proofs: true,
                user: {
                    select: {
                        id: true,
                        name: true,
                        email: true,
                    },
                },
                item: {
                    include: {
                        images: true,
                        createdBy: {
                            select: {
                                id: true,
                                name: true,
                                email: true,
                            },
                        },
                    },
                },
            },
        });

        if (!claim) {
            throw new NotFoundError('Claim not found');
        }

        return claim;
    }

    // Get claims for a specific item
    async getItemClaims(itemId: string) {
        const claims = await prisma.claim.findMany({
            where: { itemId },
            orderBy: { createdAt: 'desc' },
            include: {
                proofs: true,
                user: {
                    select: {
                        id: true,
                        name: true,
                    },
                },
            },
        });

        return claims;
    }
}
