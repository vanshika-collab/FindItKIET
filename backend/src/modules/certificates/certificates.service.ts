import { prisma } from '../../config/database';

export class CertificatesService {
    async generateCertificate(name: string, email: string) {
        // ... (mock implementation or forwarded if needed)
        console.log(`Generating certificate for ${name} (${email})`);
        return {
            status: 'success',
            message: 'Certificate request process initiated',
            data: { recipient: email, name, sentAt: new Date().toISOString() }
        };
    }

    async recordCertificate(email: string) {
        const user = await prisma.user.findUnique({ where: { email } });
        if (!user) {
            throw new Error('User not found');
        }

        // Check if already exists to avoid duplicates
        const existing = await prisma.certificate.findFirst({
            where: { userId: user.id }
        });

        if (existing) return existing;

        return await prisma.certificate.create({
            data: {
                userId: user.id
            }
        });
    }

    async hasCertificate(userId: string) {
        const count = await prisma.certificate.count({
            where: { userId }
        });
        return count > 0;
    }
}
