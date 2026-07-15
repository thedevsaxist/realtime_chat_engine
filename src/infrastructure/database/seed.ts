import { PrismaClient } from '@prisma/client';
import { logger } from '../../shared/logger';
import { PrismaPg } from '@prisma/adapter-pg';
import { Pool } from 'pg';
import bcrypt from 'bcryptjs';

const pool = new Pool({
  connectionString: process.env.DATABASE_URL,
});

const adapter = new PrismaPg(pool);

const prisma = new PrismaClient({
  adapter,
});

async function main() {
  logger.info('Seeding database...');

  // Create users
  const hashedPassword = await bcrypt.hash('thisIS0nly@tes_t', 10);
  const [user1, user2] = await Promise.all([
    prisma.user.create({
      data: {
        email: 'johndoe@gmail.com',
        password: hashedPassword,
        firstName: 'John',
        lastName: 'Doe',
      },
    }),
    prisma.user.create({
      data: {
        email: 'janedoe@gmail.com',
        password: hashedPassword,
        firstName: 'Jane',
        lastName: 'Doe',
      },
    }),
  ]);

  logger.info(`Created user1 with ID: ${user1.id}`);
  logger.info(`Created user2 with ID: ${user2.id}`);

  // Create a conversation
  const conversation = await prisma.conversation.create({
    data: {},
    include: {
      participants: {
        include: { user: { select: { firstName: true, lastName: true } } },
      },
      messages: { orderBy: { createdAt: 'asc' } },
    },
  });
  logger.info(`Created conversation with ID: ${conversation.id}`);

  // Create some initial messages
  await prisma.message.createMany({
    data: [
      {
        conversationId: conversation.id,
        senderId: user1.id,
        content: 'Hi, Jane. You use this amazing app as well?',
      },
      {
        conversationId: conversation.id,
        senderId: user2.id,
        content: 'Hey, John. Yeah, I do. This app is the best right?',
      },
    ],
  });

  const messageCount = await prisma.message.count({
    where: { conversationId: conversation.id },
  });

  logger.info(`Created ${messageCount} messages in conversation ${conversation.id}`);
  logger.info('Database seeding completed.');
}

main()
  .catch((e) => {
    logger.error(e);
    process.exit(1);
  })
  .finally(async () => {
    await prisma.$disconnect();
  });
