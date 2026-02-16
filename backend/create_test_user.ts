
import { PrismaClient, Role } from '@prisma/client';
import bcrypt from 'bcrypt';

const prisma = new PrismaClient();

async function main() {
    console.log('Creating valid test user...');

    const email = 'test@example.com';
    const password = '<your-password>';

    // Hash the password
    const salt = await bcrypt.genSalt(10);
    const passwordHash = await bcrypt.hash(password, salt);

    const user = await prisma.user.upsert({
        where: { email },
        update: {
            passwordHash,
            name: 'Test User (Valid)'
        },
        create: {
            email,
            name: 'Test User (Valid)',
            passwordHash,
            role: Role.USER
        }
    });

    console.log('-------------------------------------------');
    console.log('✅ User Created/Updated Successfully');
    console.log(`📧 Email: ${user.email}`);
    console.log(`🔑 Password: ${password}`);
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
