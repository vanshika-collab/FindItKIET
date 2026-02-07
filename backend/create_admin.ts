
import { prisma } from './src/config/database';
import bcrypt from 'bcrypt';

async function createAdmin() {
    const email = 'admin2@findit.com';
    const password = 'adminpassword123';
    const name = 'Admin User Two';

    try {
        // Check if exists
        const existing = await prisma.user.findUnique({ where: { email } });
        if (existing) {
            console.log('User already exists. Updating to ADMIN...');
            await prisma.user.update({
                where: { email },
                data: { role: 'ADMIN' }
            });
            console.log(`✅ User ${email} is now an ADMIN.`);
            return;
        }

        // Create new
        const hashedPassword = await bcrypt.hash(password, 10);
        await prisma.user.create({
            data: {
                email,
                name,
                passwordHash: hashedPassword,
                role: 'ADMIN'
            }
        });

        console.log('✅ New Admin Created!');
        console.log(`Email: ${email}`);
        console.log(`Password: ${password}`);

    } catch (error) {
        console.error('Error creating admin:', error);
    } finally {
        await prisma.$disconnect();
    }
}

createAdmin();
