import { Redis, RedisOptions } from 'ioredis';
import * as Sentry from '@sentry/nextjs';

const { logger } = Sentry;

/**
 * Redis Configuration for Pozmixal
 * Provides production-ready Redis configuration with error handling,
 * connection pooling, and monitoring
 */
export interface PozmixalRedisConfig extends RedisOptions {
    // Connection settings
    host?: string;
    port?: number;
    password?: string;
    db?: number;

    // Connection pool settings
    maxRetriesPerRequest?: number;
    retryDelayOnFailover?: number;
    connectTimeout?: number;
    commandTimeout?: number;
    lazyConnect?: boolean;

    // Cluster settings (if using Redis Cluster)
    enableReadyCheck?: boolean;
    maxRetriesPerRequest?: number;

    // Performance settings
    keepAlive?: number;
    family?: number;
}

/**
 * Default Redis configuration for Pozmixal
 */
export const defaultRedisConfig: PozmixalRedisConfig = {
    // Connection settings
    maxRetriesPerRequest: 3,
    retryDelayOnFailover: 100,
    connectTimeout: 10000,
    commandTimeout: 5000,
    lazyConnect: true,

    // Performance optimization
    keepAlive: 30000,
    family: 4, // IPv4

    // Error handling
    enableReadyCheck: true,

    // TLS settings for cloud providers (Upstash, etc.)
    tls: {},

    // Reconnection strategy
    reconnectOnError: (err) => {
        const targetError = 'READONLY';
        return err.message.includes(targetError);
    },

    // Retry strategy
    retryStrategy: (times) => {
        const delay = Math.min(times * 50, 2000);
        logger.warn(`Redis connection retry attempt ${times}, delay: ${delay}ms`);
        return delay;
    },
};

/**
 * Parse Redis URL and create configuration
 */
export function parseRedisUrl(redisUrl: string): PozmixalRedisConfig {
    try {
        const url = new URL(redisUrl);

        const config: PozmixalRedisConfig = {
            ...defaultRedisConfig,
            host: url.hostname,
            port: parseInt(url.port) || 6379,
            db: parseInt(url.pathname.slice(1)) || 0,
        };

        if (url.password) {
            config.password = url.password;
        }

        if (url.username && url.username !== 'default') {
            config.username = url.username;
        }

        // Enable TLS for secure connections (rediss://) or cloud providers
        if (url.protocol === 'rediss:' || isCloudRedisProvider(url.hostname)) {
            config.tls = {
                // For cloud providers, we typically don't need to specify cert details
                // as they handle TLS termination
                servername: url.hostname,
            };
        }

        // Cloud provider specific optimizations
        if (isUpstashRedis(url.hostname)) {
            // Upstash specific optimizations
            config.connectTimeout = 15000;
            config.commandTimeout = 10000;
            config.maxRetriesPerRequest = 5;
            config.retryDelayOnFailover = 200;
        }

        return config;
    } catch (error) {
        logger.error('Failed to parse Redis URL', { error: error.message, redisUrl });
        throw new Error(`Invalid Redis URL: ${error.message}`);
    }
}

/**
 * Check if hostname belongs to a cloud Redis provider
 */
function isCloudRedisProvider(hostname: string): boolean {
    const cloudProviders = [
        'upstash.io',
        'redis.cloud',
        'redislabs.com',
        'amazonaws.com',
        'azure.com',
        'googleusercontent.com',
    ];

    return cloudProviders.some(provider => hostname.includes(provider));
}

/**
 * Check if hostname is Upstash Redis
 */
function isUpstashRedis(hostname: string): boolean {
    return hostname.includes('upstash.io');
}

/**
 * Create Redis configuration based on environment
 */
export function createRedisConfig(): PozmixalRedisConfig {
    const redisUrl = process.env.REDIS_URL;

    if (!redisUrl) {
        logger.warn('REDIS_URL not provided, using default localhost configuration');
        return {
            ...defaultRedisConfig,
            host: 'localhost',
            port: 6379,
            db: 0,
        };
    }

    return parseRedisUrl(redisUrl);
}

/**
 * Redis connection health check
 */
export async function checkRedisHealth(redis: Redis): Promise<boolean> {
    try {
        const result = await redis.ping();
        return result === 'PONG';
    } catch (error) {
        logger.error('Redis health check failed', { error: error.message });
        return false;
    }
}

/**
 * Redis connection info
 */
export async function getRedisInfo(redis: Redis): Promise<Record<string, any>> {
    try {
        const info = await redis.info();
        const lines = info.split('\r\n');
        const result: Record<string, any> = {};

        for (const line of lines) {
            if (line.includes(':')) {
                const [key, value] = line.split(':');
                result[key] = value;
            }
        }

        return result;
    } catch (error) {
        logger.error('Failed to get Redis info', { error: error.message });
        return {};
    }
}

/**
 * Redis memory usage information
 */
export async function getRedisMemoryUsage(redis: Redis): Promise<{
    used: number;
    peak: number;
    total: number;
    available: number;
}> {
    try {
        const info = await getRedisInfo(redis);

        return {
            used: parseInt(info.used_memory) || 0,
            peak: parseInt(info.used_memory_peak) || 0,
            total: parseInt(info.total_system_memory) || 0,
            available: parseInt(info.maxmemory) || 0,
        };
    } catch (error) {
        logger.error('Failed to get Redis memory usage', { error: error.message });
        return { used: 0, peak: 0, total: 0, available: 0 };
    }
}

/**
 * Redis performance metrics
 */
export async function getRedisMetrics(redis: Redis): Promise<{
    connectedClients: number;
    totalCommandsProcessed: number;
    keyspaceHits: number;
    keyspaceMisses: number;
    hitRate: number;
}> {
    try {
        const info = await getRedisInfo(redis);

        const hits = parseInt(info.keyspace_hits) || 0;
        const misses = parseInt(info.keyspace_misses) || 0;
        const total = hits + misses;
        const hitRate = total > 0 ? (hits / total) * 100 : 0;

        return {
            connectedClients: parseInt(info.connected_clients) || 0,
            totalCommandsProcessed: parseInt(info.total_commands_processed) || 0,
            keyspaceHits: hits,
            keyspaceMisses: misses,
            hitRate: Math.round(hitRate * 100) / 100,
        };
    } catch (error) {
        logger.error('Failed to get Redis metrics', { error: error.message });
        return {
            connectedClients: 0,
            totalCommandsProcessed: 0,
            keyspaceHits: 0,
            keyspaceMisses: 0,
            hitRate: 0,
        };
    }
}

/**
 * Environment-specific Redis configurations
 */
export const redisConfigs = {
    development: {
        ...defaultRedisConfig,
        connectTimeout: 8000,
        commandTimeout: 5000,
        retryDelayOnFailover: 100,
        maxRetriesPerRequest: 3,
    },

    production: {
        ...defaultRedisConfig,
        connectTimeout: 20000,
        commandTimeout: 15000,
        retryDelayOnFailover: 300,
        maxRetriesPerRequest: 10,
        keepAlive: 60000,
        // More aggressive retry strategy for production
        retryStrategy: (times) => {
            const delay = Math.min(times * 100, 5000);
            logger.warn(`Redis production retry attempt ${times}, delay: ${delay}ms`);
            return delay;
        },
    },

    test: {
        ...defaultRedisConfig,
        connectTimeout: 2000,
        commandTimeout: 1000,
        maxRetriesPerRequest: 1,
        lazyConnect: false,
        // Disable TLS for local testing
        tls: undefined,
    },
};

/**
 * Get environment-specific Redis configuration
 */
export function getEnvironmentRedisConfig(): PozmixalRedisConfig {
    const env = process.env.NODE_ENV || 'development';
    const baseConfig = redisConfigs[env as keyof typeof redisConfigs] || redisConfigs.development;

    if (process.env.REDIS_URL) {
        const urlConfig = parseRedisUrl(process.env.REDIS_URL);
        return { ...baseConfig, ...urlConfig };
    }

    return baseConfig;
}