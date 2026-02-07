
import { PrismaClient } from '@prisma/client';

const prisma = new PrismaClient();
const TARGET_EMAIL = 'pulkitverma2008@gmail.com';

async function issueCertificate() {
    try {
        const client = prisma as any;

        // 1. Find User
        const user = await client.user.findUnique({
            where: { email: TARGET_EMAIL }
        });

        if (!user) {
            console.error(`User with email ${TARGET_EMAIL} not found.`);
            return;
        }

        console.log(`Found user: ${user.name} (${user.id})`);

        // 2. Check if already has certificate
        const existing = await client.certificate.findFirst({
            where: { userId: user.id }
        });

        if (existing) {
            console.log(`User already has a certificate (Issued: ${existing.issuedAt}).`);
            return;
        }

        // 3. Issue Certificate
        // URL is optional, using placeholder or the known generator URL structure
        const cert = await client.certificate.create({
            data: {
                userId: user.id,
                url: `http://localhost:8000/api/download-certificate?email=${TARGET_EMAIL}`, // Metadata mainly
                issuedAt: new Date()
            }
        });

        console.log(`✅ Certificate issued successfully! ID: ${cert.id}`);
        console.log("The user should now see the 'Download Certificate' button in the app.");

    } catch (error) {
        console.error('Error issuing certificate:', error);
    } finally {
        await prisma.$disconnect();
    }
}

issueCertificate();
