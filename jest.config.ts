import { getJestProjects } from '@nx/jest';

export default {
  projects: getJestProjects(),
  maxWorkers: '50%',
  workerIdleMemoryLimit: '512MB',
  testTimeout: 30000,
  setupFilesAfterEnv: ['<rootDir>/jest.setup.js'],
  moduleNameMapping: {
    '^@/(.*)$': '<rootDir>/$1',
  },
};
