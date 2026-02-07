
import { PrismaClient } from '@prisma/client';

const prisma = new PrismaClient();

async function main() {
    console.log('Verifying admin user...');

    const user = await prisma.user.findUnique({
        where: { email: 'admin@kiet.edu' }
    });

    if (user) {
        console.log(`User Found: ${user.email}`);
        console.log(`Role: ${user.role}`);
        console.log(`ID: ${user.id}`);
    } else {
        console.log('User admin@kiet.edu NOT FOUND');
    }
}

main()
    .catch(console.error)
    .finally(() => prisma.$disconnect());
