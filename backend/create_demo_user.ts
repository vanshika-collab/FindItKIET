
import { PrismaClient, Role } from '@prisma/client';
import bcrypt from 'bcrypt';

const prisma = new PrismaClient();

async function main() {
    console.log('Creating demo user...');

    const email = 'demo@kiet.edu';
    const password = 'demo123';

    // Hash the password
    const salt = await bcrypt.genSalt(10);
    const passwordHash = await bcrypt.hash(password, salt);

    const user = await prisma.user.upsert({
        where: { email },
        update: {
            passwordHash,
            name: 'Demo User',
            role: Role.USER
        },
        create: {
            email,
            name: 'Demo User',
            passwordHash,
            role: Role.USER
        }
    });

    console.log('-------------------------------------------');
    console.log('✅ Demo User Created Successfully');
    console.log(`📧 Email: ${user.email}`);
    console.log(`🔑 Password: ${password}`);
    console.log(`bust Role: ${user.role}`);
    console.log('-------------------------------------------');
}

main()
    .catch(e => {
        console.error(e);
        process.exit(1);
    })
    .finally(async () => {
        await prisma.$disconnect();
    });
