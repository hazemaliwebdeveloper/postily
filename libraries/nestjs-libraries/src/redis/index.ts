/**
 * Redis Module for Postiz
 * 
 * This module provides comprehensive Redis functionality including:
 * - Connection management with cloud provider support
 * - Caching utilities and patterns
 * - Health monitoring and alerting
 * - Performance testing and metrics
 * - Production-ready configuration
 */

// Core Redis service and configuration
export { ioRedis, RedisService } from './redis.service';
export {
    createRedisConfig,
    parseRedisUrl,
    checkRedisHealth,
    getRedisMetrics,
    getRedisMemoryUsage,
    getEnvironmentRedisConfig,
    defaultRedisConfig,
    redisConfigs,
    type PostizRedisConfig,
} from './redis.config';

// Redis utilities and caching patterns
export {
    CACHE_KEYS,
    CACHE_TTL,
    cacheSet,
    cacheGet,
    cacheDel,
    cacheExists,
    cacheGetOrSet,
    cacheIncrement,
    rateLimit,
    acquireLock,
    releaseLock,
    cacheInvalidatePattern,
    cacheMSet,
    cacheMGet,
    getCacheStats,
    // Postiz-specific utilities
    cacheUser,
    getCachedUser,
    cacheIntegration,
    getCachedIntegration,
    cacheScheduledPost,
    getCachedScheduledPost,
    invalidateUserCache,
} from './redis.utils';

// Health monitoring
export {
    RedisHealthIndicator,
    RedisHealthModule,
} from './redis.health';

// Monitoring service
export {
    RedisMonitorService,
    RedisMonitorModule,
} from './redis.monitor';

// Testing utilities
export {
    testRedisConnection,
    testRedisOperations,
    testRedisPerformance,
    runRedisTests,
    runRedisTestsCLI,
} from './redis.test';

/**
 * Quick start examples:
 * 
 * // Basic usage
 * import { ioRedis, cacheSet, cacheGet } from '@gitroom/nestjs-libraries/redis';
 * 
 * // Cache user data
 * await cacheSet('user:123', userData, 3600);
 * const user = await cacheGet('user:123');
 * 
 * // Rate limiting
 * import { rateLimit } from '@gitroom/nestjs-libraries/redis';
 * const { allowed, remaining } = await rateLimit('user:123', 100, 3600);
 * 
 * // Health monitoring
 * import { RedisHealthIndicator } from '@gitroom/nestjs-libraries/redis';
 * const healthCheck = await healthIndicator.isHealthy('redis');
 * 
 * // Testing connection
 * import { testRedisConnection } from '@gitroom/nestjs-libraries/redis';
 * const result = await testRedisConnection();
 */

/**
 * Environment Variables Required:
 * 
 * REDIS_URL - Redis connection URL (supports redis:// and rediss:// for TLS)
 * NODE_ENV - Environment (development, production, test)
 * 
 * Example Redis URLs:
 * - Local: redis://localhost:6379
 * - Upstash: redis://default:password@host.upstash.io:6379
 * - AWS ElastiCache: rediss://cluster.cache.amazonaws.com:6380
 * - Redis Cloud: rediss://user:pass@host.redis.cloud:port
 */

/**
 * Docker Compose Usage:
 * 
 * For local development:
 * docker-compose -f docker-compose.dev.yaml up
 * 
 * For production with Redis configuration:
 * docker-compose -f docker-compose.dev.yaml -f docker-compose.redis.yaml up
 * 
 * For high availability with Sentinel:
 * docker-compose -f docker-compose.dev.yaml -f docker-compose.redis.yaml --profile sentinel up
 * 
 * For clustering:
 * docker-compose -f docker-compose.dev.yaml -f docker-compose.redis.yaml --profile cluster up
 * 
 * For monitoring:
 * docker-compose -f docker-compose.dev.yaml -f docker-compose.redis.yaml --profile monitoring up
 */