
import { PrismaClient, Role } from '@prisma/client';
import bcrypt from 'bcrypt';

const prisma = new PrismaClient();

async function main() {
    console.log('Creating admin user...');

    const email = 'admin@example.com';
    const password = 'admin123';

    // Hash the password
    const salt = await bcrypt.genSalt(10);
    const passwordHash = await bcrypt.hash(password, salt);

    const user = await prisma.user.upsert({
        where: { email },
        update: {
            passwordHash,
            name: 'Admin User',
            role: Role.ADMIN
        },
        create: {
            email,
            name: 'Admin User',
            passwordHash,
            role: Role.ADMIN
        }
    });

    console.log('-------------------------------------------');
    console.log('✅ Admin User Created/Updated Successfully');
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
