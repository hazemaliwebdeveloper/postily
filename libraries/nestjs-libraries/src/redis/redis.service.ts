import { Redis } from 'ioredis';
import * as Sentry from '@sentry/nextjs';
import {
  createRedisConfig,
  checkRedisHealth,
  getRedisMetrics,
  getRedisMemoryUsage,
  PostizRedisConfig
} from './redis.config';

const { logger } = Sentry;

// Create a mock Redis implementation for testing environments
class MockRedis {
  private data: Map<string, any> = new Map();
  private expirations: Map<string, NodeJS.Timeout> = new Map();

  async get(key: string) {
    return this.data.get(key) || null;
  }

  async set(key: string, value: any, mode?: string, duration?: number) {
    this.data.set(key, value);

    // Handle expiration
    if (mode === 'EX' && duration) {
      const timeout = setTimeout(() => {
        this.data.delete(key);
        this.expirations.delete(key);
      }, duration * 1000);

      // Clear existing timeout if any
      const existingTimeout = this.expirations.get(key);
      if (existingTimeout) {
        clearTimeout(existingTimeout);
      }

      this.expirations.set(key, timeout);
    }

    return 'OK';
  }

  async setex(key: string, seconds: number, value: any) {
    return this.set(key, value, 'EX', seconds);
  }

  async del(key: string | string[]) {
    const keys = Array.isArray(key) ? key : [key];
    let deleted = 0;

    for (const k of keys) {
      if (this.data.has(k)) {
        this.data.delete(k);

        // Clear expiration timeout
        const timeout = this.expirations.get(k);
        if (timeout) {
          clearTimeout(timeout);
          this.expirations.delete(k);
        }

        deleted++;
      }
    }

    return deleted;
  }

  async exists(key: string) {
    return this.data.has(key) ? 1 : 0;
  }

  async expire(key: string, seconds: number) {
    if (!this.data.has(key)) return 0;

    const timeout = setTimeout(() => {
      this.data.delete(key);
      this.expirations.delete(key);
    }, seconds * 1000);

    // Clear existing timeout if any
    const existingTimeout = this.expirations.get(key);
    if (existingTimeout) {
      clearTimeout(existingTimeout);
    }

    this.expirations.set(key, timeout);
    return 1;
  }

  async ttl(key: string) {
    return this.data.has(key) ? -1 : -2; // -1 for no expiration, -2 for key not exists
  }

  async keys(pattern: string) {
    const regex = new RegExp(pattern.replace(/\*/g, '.*'));
    return Array.from(this.data.keys()).filter(key => regex.test(key));
  }

  async flushall() {
    this.data.clear();
    this.expirations.forEach(timeout => clearTimeout(timeout));
    this.expirations.clear();
    return 'OK';
  }

  async ping() {
    return 'PONG';
  }

  async info() {
    return `# Server
redis_version:7.0.0-mock
# Memory
used_memory:${this.data.size * 100}
# Stats
total_commands_processed:1000
keyspace_hits:800
keyspace_misses:200
# Clients
connected_clients:1`;
  }

  // BullMQ specific methods
  async eval(script: string, numKeys: number, ...args: any[]) {
    // Mock implementation for BullMQ scripts
    return 'OK';
  }

  async multi() {
    return {
      exec: async () => [['OK'], ['OK']],
      set: () => this,
      del: () => this,
      expire: () => this,
    };
  }

  // Add other Redis methods as needed for your tests
}

/**
 * Enhanced Redis service with production features
 */
class RedisService {
  private redis: Redis;
  private isConnected: boolean = false;
  private connectionAttempts: number = 0;
  private maxConnectionAttempts: number = 5;

  constructor(config: PostizRedisConfig) {
    this.redis = new Redis(config);
    this.setupEventHandlers();
  }

  private setupEventHandlers() {
    this.redis.on('connect', () => {
      logger.info('Redis connected successfully');
      this.isConnected = true;
      this.connectionAttempts = 0;
    });

    this.redis.on('ready', () => {
      logger.info('Redis ready to accept commands');
    });

    this.redis.on('error', (error) => {
      logger.error('Redis connection error', { error: error.message });
      this.isConnected = false;
    });

    this.redis.on('close', () => {
      logger.warn('Redis connection closed');
      this.isConnected = false;
    });

    this.redis.on('reconnecting', (delay) => {
      this.connectionAttempts++;
      logger.info(`Redis reconnecting in ${delay}ms (attempt ${this.connectionAttempts})`);

      if (this.connectionAttempts >= this.maxConnectionAttempts) {
        logger.error('Max Redis connection attempts reached');
        this.redis.disconnect();
      }
    });

    this.redis.on('end', () => {
      logger.info('Redis connection ended');
      this.isConnected = false;
    });
  }

  getClient(): Redis {
    return this.redis;
  }

  async healthCheck(): Promise<boolean> {
    return checkRedisHealth(this.redis);
  }

  async getMetrics() {
    return getRedisMetrics(this.redis);
  }

  async getMemoryUsage() {
    return getRedisMemoryUsage(this.redis);
  }

  isHealthy(): boolean {
    return this.isConnected;
  }

  async disconnect(): Promise<void> {
    await this.redis.quit();
  }
}

// Create Redis instance based on environment
let redisInstance: Redis;

if (process.env.NODE_ENV === 'test' || !process.env.REDIS_URL) {
  // Use MockRedis for testing or when REDIS_URL is not provided
  logger.info('Using MockRedis for testing/development');
  redisInstance = new MockRedis() as unknown as Redis;
} else {
  // Use real Redis for production/development with REDIS_URL
  try {
    const config = createRedisConfig();
    const redisService = new RedisService(config);
    redisInstance = redisService.getClient();

    logger.info('Redis service initialized', {
      host: config.host,
      port: config.port,
      db: config.db,
    });
  } catch (error) {
    logger.error('Failed to initialize Redis service', { error: error.message });
    // Fallback to MockRedis
    redisInstance = new MockRedis() as unknown as Redis;
  }
}

export const ioRedis = redisInstance;

// Export Redis service class for advanced usage
export { RedisService };

// Export configuration utilities
export { createRedisConfig, checkRedisHealth, getRedisMetrics, getRedisMemoryUsage };
