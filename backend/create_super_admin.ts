
import { PrismaClient, Role } from '@prisma/client';
import bcrypt from 'bcrypt';

const prisma = new PrismaClient();

async function main() {
    console.log('Creating SUPER admin user...');

    const email = 'superadmin@kiet.edu';
    const password = 'SuperSecret123!';

    // Hash the password
    const salt = await bcrypt.genSalt(10);
    const passwordHash = await bcrypt.hash(password, salt);

    const user = await prisma.user.upsert({
        where: { email },
        update: {
            passwordHash,
            name: 'Super Admin',
            role: Role.ADMIN
        },
        create: {
            email,
            name: 'Super Admin',
            passwordHash,
            role: Role.ADMIN
        }
    });

    console.log('-------------------------------------------');
    console.log('✅ Super Admin Created Successfully');
    console.log(`📧 Email: ${user.email}`);
    console.log(`🔑 Password: ${password}`);
    console.log(`🛡️ Role: ${user.role}`);
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
