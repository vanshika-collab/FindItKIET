import { PrismaClient } from '@prisma/client';
import { v4 as uuidv4 } from 'uuid';

const prisma = new PrismaClient();

async function main() {
    console.log('Seeding leaderboard data...');

    // Create 5 users
    const users = [];
    for (let i = 0; i < 5; i++) {
        const user = await prisma.user.create({
            data: {
                name: `Test User ${i + 1}`,
                email: `test_user_${i + 1}_${Date.now()}@example.com`,
                passwordHash: 'hashed_password', // Dummy hash
            },
        });
        users.push(user);
    }

    // Create items for these users with different counts
    // User 0: 10 items
    // User 1: 8 items
    // User 2: 5 items
    // User 3: 3 items
    // User 4: 0 items

    const counts = [10, 8, 5, 3, 0];

    for (let i = 0; i < users.length; i++) {
        const count = counts[i];
        if (count === 0) continue;

        console.log(`Creating ${count} items for ${users[i].name}...`);

        await prisma.item.createMany({
            data: Array(count).fill(null).map((_, idx) => ({
                title: `Lost Item ${idx} by ${users[i].name}`,
                description: 'This is a test lost item',
                category: 'ELECTRONICS',
                status: 'LOST', // Important: status must be LOST
                createdById: users[i].id,
                reportedAt: new Date(), // Current month
            })),
        });
    }

    console.log('Seeding complete.');
}

main()
    .catch((e) => {
        console.error(e);
        process.exit(1);
    })
    .finally(async () => {
        await prisma.$disconnect();
    });
