
import { PrismaClient, ItemStatus } from '@prisma/client';
const prisma = new PrismaClient();

async function main() {
    console.log('Seeding items...');

    // 1. Create Users
    const user1 = await prisma.user.upsert({
        where: { email: 'user1@example.com' },
        update: {},
        create: {
            email: 'user1@example.com',
            name: 'Alice Johnson',
            passwordHash: 'hashed<your-password>', // Mock password
        }
    });

    const user2 = await prisma.user.upsert({
        where: { email: 'user2@example.com' },
        update: {},
        create: {
            email: 'user2@example.com',
            name: 'Bob Smith',
            passwordHash: 'hashed<your-password>',
        }
    });

    console.log('Created users:', user1.name, user2.name);

    // 2. Create Items
    const items = [
        {
            title: 'Lost iPhone 14',
            description: 'Black iPhone with a transparent case. Lost near the library.',
            category: 'ELECTRONICS',
            location: 'Library, 2nd Floor',
            status: ItemStatus.LOST,
            createdById: user1.id,
            imageUrls: ['https://images.unsplash.com/photo-1510557880182-3d4d3cba35a5?auto=format&fit=crop&w=500&q=80']
        },
        {
            title: 'Blue Water Bottle',
            description: 'Metal water bottle, blue color with stickers.',
            category: 'OTHER',
            location: 'Cafeteria',
            status: ItemStatus.LOST,
            createdById: user2.id,
            imageUrls: ['https://images.unsplash.com/photo-1602143407151-011141950038?auto=format&fit=crop&w=500&q=80']
        },
        {
            title: 'Calculus Textbook',
            description: 'Thomas Calculus 14th Edition. Hardcover.',
            category: 'BOOKS',
            location: 'Room 304',
            status: ItemStatus.LOST,
            createdById: user1.id,
            imageUrls: []
        },
        {
            title: 'Car Keys',
            description: 'Honda car keys with a red keychain.',
            category: 'OTHER',
            location: 'Parking Lot B',
            status: ItemStatus.LOST,
            createdById: user2.id,
            imageUrls: ['https://images.unsplash.com/photo-1627453625062-75ca46440266?auto=format&fit=crop&w=500&q=80']
        },
        {
            title: 'Beige Hoodie',
            description: 'Nike beige hoodie size L.',
            category: 'CLOTHING',
            location: 'Gym Locker Room',
            status: ItemStatus.LOST,
            createdById: user1.id,
            imageUrls: ['https://images.unsplash.com/photo-1556905055-8f358a7a47b2?auto=format&fit=crop&w=500&q=80']
        },
        {
            title: 'AirPods Pro',
            description: 'White case with a scratch on the back.',
            category: 'ELECTRONICS',
            location: 'Student Center',
            status: ItemStatus.LOST,
            createdById: user2.id,
            imageUrls: ['https://images.unsplash.com/photo-1588156979435-379182d65d6c?auto=format&fit=crop&w=500&q=80']
        },
        {
            title: 'ID Card',
            description: 'Student ID card for Bob Smith.',
            category: 'DOCUMENTS',
            location: 'Reception',
            status: ItemStatus.LOST,
            createdById: user2.id,
            imageUrls: []
        },
        {
            title: 'Black Backpack',
            description: 'North Face backpack with laptop inside.',
            category: 'OTHER',
            location: 'Lab 101',
            status: ItemStatus.LOST,
            createdById: user1.id,
            imageUrls: ['https://images.unsplash.com/photo-1553062407-98eeb64c6a62?auto=format&fit=crop&w=500&q=80']
        }
    ];

    for (const item of items) {
        const { imageUrls, ...itemData } = item;

        await prisma.item.create({
            data: {
                ...itemData,
                reportedAt: new Date(),
                images: {
                    create: imageUrls.map(url => ({ imageUrl: url }))
                }
            }
        });
    }

    console.log(`Seeded ${items.length} items.`);
}

main()
    .catch(e => {
        console.error(e);
        process.exit(1);
    })
    .finally(async () => {
        await prisma.$disconnect();
    });
