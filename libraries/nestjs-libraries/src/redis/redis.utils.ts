import { Redis } from 'ioredis';
import * as Sentry from '@sentry/nextjs';
import { ioRedis } from './redis.service';

const { logger } = Sentry;

/**
 * Redis utility functions for Postiz application
 * Provides common caching patterns and utilities
 */

/**
 * Cache key prefixes for different data types
 */
export const CACHE_KEYS = {
    USER: 'user:',
    POST: 'post:',
    INTEGRATION: 'integration:',
    SOCIAL_ACCOUNT: 'social:',
    QUEUE_JOB: 'job:',
    SESSION: 'session:',
    RATE_LIMIT: 'rate:',
    ANALYTICS: 'analytics:',
    WEBHOOK: 'webhook:',
    NOTIFICATION: 'notification:',
    MEDIA: 'media:',
    SCHEDULE: 'schedule:',
} as const;

/**
 * Default cache TTL values (in seconds)
 */
export const CACHE_TTL = {
    SHORT: 300, // 5 minutes
    MEDIUM: 1800, // 30 minutes
    LONG: 3600, // 1 hour
    VERY_LONG: 86400, // 24 hours
    WEEK: 604800, // 7 days
} as const;

/**
 * Cache a value with automatic JSON serialization
 */
export async function cacheSet(
    key: string,
    value: any,
    ttl: number = CACHE_TTL.MEDIUM,
    redis: Redis = ioRedis
): Promise<boolean> {
    try {
        const serializedValue = typeof value === 'string' ? value : JSON.stringify(value);
        const result = await redis.setex(key, ttl, serializedValue);
        return result === 'OK';
    } catch (error) {
        logger.error('Failed to set cache', { key, error: error.message });
        return false;
    }
}

/**
 * Get a cached value with automatic JSON deserialization
 */
export async function cacheGet<T = any>(
    key: string,
    redis: Redis = ioRedis
): Promise<T | null> {
    try {
        const value = await redis.get(key);
        if (!value) return null;

        try {
            return JSON.parse(value) as T;
        } catch {
            // If JSON parsing fails, return as string
            return value as unknown as T;
        }
    } catch (error) {
        logger.error('Failed to get cache', { key, error: error.message });
        return null;
    }
}

/**
 * Delete cached values by key or pattern
 */
export async function cacheDel(
    keys: string | string[],
    redis: Redis = ioRedis
): Promise<number> {
    try {
        const keyArray = Array.isArray(keys) ? keys : [keys];
        return await redis.del(...keyArray);
    } catch (error) {
        logger.error('Failed to delete cache', { keys, error: error.message });
        return 0;
    }
}

/**
 * Check if a key exists in cache
 */
export async function cacheExists(
    key: string,
    redis: Redis = ioRedis
): Promise<boolean> {
    try {
        const result = await redis.exists(key);
        return result === 1;
    } catch (error) {
        logger.error('Failed to check cache existence', { key, error: error.message });
        return false;
    }
}

/**
 * Get or set cache with a fallback function
 */
export async function cacheGetOrSet<T>(
    key: string,
    fallbackFn: () => Promise<T>,
    ttl: number = CACHE_TTL.MEDIUM,
    redis: Redis = ioRedis
): Promise<T> {
    try {
        // Try to get from cache first
        const cached = await cacheGet<T>(key, redis);
        if (cached !== null) {
            return cached;
        }

        // If not in cache, execute fallback function
        const value = await fallbackFn();

        // Cache the result
        await cacheSet(key, value, ttl, redis);

        return value;
    } catch (error) {
        logger.error('Failed to get or set cache', { key, error: error.message });
        // If caching fails, still return the fallback value
        return await fallbackFn();
    }
}

/**
 * Increment a counter in Redis
 */
export async function cacheIncrement(
    key: string,
    increment: number = 1,
    ttl?: number,
    redis: Redis = ioRedis
): Promise<number> {
    try {
        const result = await redis.incrby(key, increment);

        if (ttl && result === increment) {
            // Set TTL only if this is the first increment
            await redis.expire(key, ttl);
        }

        return result;
    } catch (error) {
        logger.error('Failed to increment cache', { key, increment, error: error.message });
        return 0;
    }
}

/**
 * Rate limiting using Redis
 */
export async function rateLimit(
    identifier: string,
    limit: number,
    windowSeconds: number,
    redis: Redis = ioRedis
): Promise<{ allowed: boolean; remaining: number; resetTime: number }> {
    try {
        const key = `${CACHE_KEYS.RATE_LIMIT}${identifier}`;
        const current = await redis.incr(key);

        if (current === 1) {
            // First request in the window, set expiration
            await redis.expire(key, windowSeconds);
        }

        const ttl = await redis.ttl(key);
        const resetTime = Date.now() + (ttl * 1000);

        return {
            allowed: current <= limit,
            remaining: Math.max(0, limit - current),
            resetTime,
        };
    } catch (error) {
        logger.error('Failed to check rate limit', { identifier, error: error.message });
        // On error, allow the request
        return { allowed: true, remaining: limit - 1, resetTime: Date.now() + (windowSeconds * 1000) };
    }
}

/**
 * Lock mechanism using Redis
 */
export async function acquireLock(
    lockKey: string,
    ttl: number = 30,
    redis: Redis = ioRedis
): Promise<string | null> {
    try {
        const lockValue = `${Date.now()}-${Math.random()}`;
        const result = await redis.set(lockKey, lockValue, 'EX', ttl, 'NX');

        return result === 'OK' ? lockValue : null;
    } catch (error) {
        logger.error('Failed to acquire lock', { lockKey, error: error.message });
        return null;
    }
}

/**
 * Release a lock using Redis
 */
export async function releaseLock(
    lockKey: string,
    lockValue: string,
    redis: Redis = ioRedis
): Promise<boolean> {
    try {
        const script = `
      if redis.call("get", KEYS[1]) == ARGV[1] then
        return redis.call("del", KEYS[1])
      else
        return 0
      end
    `;

        const result = await redis.eval(script, 1, lockKey, lockValue);
        return result === 1;
    } catch (error) {
        logger.error('Failed to release lock', { lockKey, error: error.message });
        return false;
    }
}

/**
 * Cache invalidation by pattern
 */
export async function cacheInvalidatePattern(
    pattern: string,
    redis: Redis = ioRedis
): Promise<number> {
    try {
        const keys = await redis.keys(pattern);
        if (keys.length === 0) return 0;

        return await redis.del(...keys);
    } catch (error) {
        logger.error('Failed to invalidate cache pattern', { pattern, error: error.message });
        return 0;
    }
}

/**
 * Batch cache operations
 */
export async function cacheMSet(
    keyValuePairs: Record<string, any>,
    ttl?: number,
    redis: Redis = ioRedis
): Promise<boolean> {
    try {
        const pipeline = redis.pipeline();

        for (const [key, value] of Object.entries(keyValuePairs)) {
            const serializedValue = typeof value === 'string' ? value : JSON.stringify(value);
            pipeline.set(key, serializedValue);

            if (ttl) {
                pipeline.expire(key, ttl);
            }
        }

        const results = await pipeline.exec();
        return results?.every(([error]) => !error) ?? false;
    } catch (error) {
        logger.error('Failed to batch set cache', { error: error.message });
        return false;
    }
}

/**
 * Batch cache get operations
 */
export async function cacheMGet<T = any>(
    keys: string[],
    redis: Redis = ioRedis
): Promise<Record<string, T | null>> {
    try {
        const values = await redis.mget(...keys);
        const result: Record<string, T | null> = {};

        keys.forEach((key, index) => {
            const value = values[index];
            if (value) {
                try {
                    result[key] = JSON.parse(value) as T;
                } catch {
                    result[key] = value as unknown as T;
                }
            } else {
                result[key] = null;
            }
        });

        return result;
    } catch (error) {
        logger.error('Failed to batch get cache', { keys, error: error.message });
        return keys.reduce((acc, key) => ({ ...acc, [key]: null }), {});
    }
}

/**
 * Cache statistics
 */
export async function getCacheStats(redis: Redis = ioRedis): Promise<{
    totalKeys: number;
    keysByPrefix: Record<string, number>;
    memoryUsage: number;
}> {
    try {
        const allKeys = await redis.keys('*');
        const keysByPrefix: Record<string, number> = {};

        // Count keys by prefix
        for (const key of allKeys) {
            const prefix = key.split(':')[0] + ':';
            keysByPrefix[prefix] = (keysByPrefix[prefix] || 0) + 1;
        }

        // Get memory usage
        const info = await redis.info('memory');
        const memoryMatch = info.match(/used_memory:(\d+)/);
        const memoryUsage = memoryMatch ? parseInt(memoryMatch[1]) : 0;

        return {
            totalKeys: allKeys.length,
            keysByPrefix,
            memoryUsage,
        };
    } catch (error) {
        logger.error('Failed to get cache stats', { error: error.message });
        return {
            totalKeys: 0,
            keysByPrefix: {},
            memoryUsage: 0,
        };
    }
}

/**
 * Postiz-specific cache utilities
 */

/**
 * Cache user data
 */
export async function cacheUser(userId: string, userData: any, ttl: number = CACHE_TTL.LONG) {
    return cacheSet(`${CACHE_KEYS.USER}${userId}`, userData, ttl);
}

/**
 * Get cached user data
 */
export async function getCachedUser<T = any>(userId: string): Promise<T | null> {
    return cacheGet<T>(`${CACHE_KEYS.USER}${userId}`);
}

/**
 * Cache social media integration data
 */
export async function cacheIntegration(integrationId: string, data: any, ttl: number = CACHE_TTL.MEDIUM) {
    return cacheSet(`${CACHE_KEYS.INTEGRATION}${integrationId}`, data, ttl);
}

/**
 * Get cached integration data
 */
export async function getCachedIntegration<T = any>(integrationId: string): Promise<T | null> {
    return cacheGet<T>(`${CACHE_KEYS.INTEGRATION}${integrationId}`);
}

/**
 * Cache post scheduling data
 */
export async function cacheScheduledPost(postId: string, data: any, ttl: number = CACHE_TTL.VERY_LONG) {
    return cacheSet(`${CACHE_KEYS.SCHEDULE}${postId}`, data, ttl);
}

/**
 * Get cached scheduled post data
 */
export async function getCachedScheduledPost<T = any>(postId: string): Promise<T | null> {
    return cacheGet<T>(`${CACHE_KEYS.SCHEDULE}${postId}`);
}

/**
 * Invalidate user-related cache
 */
export async function invalidateUserCache(userId: string) {
    const patterns = [
        `${CACHE_KEYS.USER}${userId}*`,
        `${CACHE_KEYS.SESSION}${userId}*`,
        `${CACHE_KEYS.INTEGRATION}${userId}*`,
    ];

    let totalInvalidated = 0;
    for (const pattern of patterns) {
        totalInvalidated += await cacheInvalidatePattern(pattern);
    }

    return totalInvalidated;
}