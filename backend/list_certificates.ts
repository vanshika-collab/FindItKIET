
import { PrismaClient } from '@prisma/client';

const prisma = new PrismaClient();

async function checkStatus() {
    try {
        const client = prisma as any;

        console.log("--- Certificate Status ---");
        const certs = await client.certificate.findMany({
            include: { user: true }
        });

        if (certs.length === 0) {
            console.log("No certificates issued yet.");
        } else {
            console.log(`Issued: ${certs.length}`);
            certs.forEach((c: any) => console.log(`- ${c.user.name} (${c.user.email})`));
        }

        console.log("\n--- Leaderboard Candidates (Top Reporters) ---");
        // Aggregate items count by user
        const topReporters = await client.item.groupBy({
            by: ['createdById'],
            _count: {
                id: true
            },
            where: {
                status: 'LOST'
            },
            orderBy: {
                _count: {
                    id: 'desc'
                }
            },
            take: 5
        });

        if (topReporters.length === 0) {
            console.log("No items reported yet.");
        } else {
            for (const r of topReporters) {
                const user = await client.user.findUnique({ where: { id: r.createdById } });
                console.log(`- ${user?.name} (${user?.email}): ${r._count.id} items`);
            }
        }

    } catch (error) {
        console.error('Error:', error);
    } finally {
        await prisma.$disconnect();
    }
}

checkStatus();
