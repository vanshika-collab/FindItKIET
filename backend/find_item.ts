
import { PrismaClient } from '@prisma/client';

const prisma = new PrismaClient();

async function main() {
    console.log('Searching for "Black Phone" variants...');

    const items = await prisma.item.findMany({
        where: {
            title: {
                contains: 'Black',
                mode: 'insensitive'
            }
        },
        select: {
            id: true,
            title: true,
            description: true,
            status: true
        }
    });

    console.log(`Found ${items.length} items:`);
    items.forEach(item => {
        console.log(`[${item.id}] ${item.title} - ${item.status}`);
    });
}

main()
    .catch(console.error)
    .finally(() => prisma.$disconnect());
