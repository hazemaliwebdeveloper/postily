import { defineConfig } from 'prisma';

export const prismaConfig = defineConfig({
  seed: async (prisma) => {
    console.log('Seeding database...');
  },
});
