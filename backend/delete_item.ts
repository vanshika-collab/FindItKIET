
import { PrismaClient } from '@prisma/client';

const prisma = new PrismaClient();

async function main() {
    const itemId = 'd8c7a228-6e8b-4bf9-8bda-c433522bd905';
    console.log(`Deleting item ${itemId}...`);

    /* 
       We must delete related records first if CASCADE is not set in DB level,
       but Prisma schema usually handles relations.
       Item has:
       - images (ItemImage)
       - claims (Claim) - checking if any
    */

    // Delete related images first to be safe
    await prisma.itemImage.deleteMany({
        where: { itemId }
    });

    // Delete related claims
    await prisma.claim.deleteMany({
        where: { itemId }
    });

    // Delete item
    const deleted = await prisma.item.delete({
        where: { id: itemId }
    });

    console.log('✅ Deleted Item:', deleted.title);
}

main()
    .catch(console.error)
    .finally(() => prisma.$disconnect());
