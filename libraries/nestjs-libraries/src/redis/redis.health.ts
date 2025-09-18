import { Injectable } from '@nestjs/common';
import { HealthIndicator, HealthIndicatorResult, HealthCheckError } from '@nestjs/terminus';
import * as Sentry from '@sentry/nextjs';
import { ioRedis } from './redis.service';
import { checkRedisHealth, getRedisMetrics, getRedisMemoryUsage } from './redis.config';

const { logger } = Sentry;

/**
 * Redis Health Check Service for Postiz
 * Provides comprehensive health monitoring for Redis connections
 */
@Injectable()
export class RedisHealthIndicator extends HealthIndicator {
    /**
     * Basic Redis health check
     */
    async isHealthy(key: string): Promise<HealthIndicatorResult> {
        try {
            const isHealthy = await checkRedisHealth(ioRedis);

            if (!isHealthy) {
                throw new HealthCheckError('Redis health check failed', {
                    redis: {
                        status: 'down',
                        message: 'Redis ping failed',
                    },
                });
            }

            return this.getStatus(key, true, {
                status: 'up',
                message: 'Redis is responding to ping',
            });
        } catch (error) {
            logger.error('Redis health check failed', { error: error.message });
            throw new HealthCheckError('Redis health check failed', {
                redis: {
                    status: 'down',
                    error: error.message,
                },
            });
        }
    }

    /**
     * Detailed Redis health check with metrics
     */
    async getDetailedHealth(key: string): Promise<HealthIndicatorResult> {
        try {
            const [isHealthy, metrics, memoryUsage] = await Promise.all([
                checkRedisHealth(ioRedis),
                getRedisMetrics(ioRedis),
                getRedisMemoryUsage(ioRedis),
            ]);

            if (!isHealthy) {
                throw new HealthCheckError('Redis detailed health check failed', {
                    redis: {
                        status: 'down',
                        message: 'Redis ping failed',
                    },
                });
            }

            // Check memory usage (warn if over 80%)
            const memoryUsagePercent = memoryUsage.available > 0
                ? (memoryUsage.used / memoryUsage.available) * 100
                : 0;

            const status = memoryUsagePercent > 90 ? 'warning' : 'up';

            return this.getStatus(key, true, {
                status,
                connection: {
                    ping: 'OK',
                    connectedClients: metrics.connectedClients,
                },
                performance: {
                    totalCommandsProcessed: metrics.totalCommandsProcessed,
                    keyspaceHits: metrics.keyspaceHits,
                    keyspaceMisses: metrics.keyspaceMisses,
                    hitRate: `${metrics.hitRate}%`,
                },
                memory: {
                    used: this.formatBytes(memoryUsage.used),
                    peak: this.formatBytes(memoryUsage.peak),
                    available: this.formatBytes(memoryUsage.available),
                    usagePercent: `${Math.round(memoryUsagePercent * 100) / 100}%`,
                },
                warnings: memoryUsagePercent > 80 ? ['High memory usage detected'] : [],
            });
        } catch (error) {
            logger.error('Redis detailed health check failed', { error: error.message });
            throw new HealthCheckError('Redis detailed health check failed', {
                redis: {
                    status: 'down',
                    error: error.message,
                },
            });
        }
    }

    /**
     * Check Redis connection latency
     */
    async checkLatency(key: string, maxLatencyMs: number = 100): Promise<HealthIndicatorResult> {
        try {
            const startTime = Date.now();
            await ioRedis.ping();
            const latency = Date.now() - startTime;

            const status = latency > maxLatencyMs ? 'warning' : 'up';
            const isHealthy = latency < maxLatencyMs * 2; // Fail if latency is more than 2x the threshold

            if (!isHealthy) {
                throw new HealthCheckError('Redis latency check failed', {
                    redis: {
                        status: 'down',
                        latency: `${latency}ms`,
                        threshold: `${maxLatencyMs}ms`,
                        message: 'Redis latency too high',
                    },
                });
            }

            return this.getStatus(key, true, {
                status,
                latency: `${latency}ms`,
                threshold: `${maxLatencyMs}ms`,
                message: latency > maxLatencyMs ? 'High latency detected' : 'Latency within acceptable range',
            });
        } catch (error) {
            logger.error('Redis latency check failed', { error: error.message });
            throw new HealthCheckError('Redis latency check failed', {
                redis: {
                    status: 'down',
                    error: error.message,
                },
            });
        }
    }

    /**
     * Check Redis memory usage
     */
    async checkMemoryUsage(key: string, maxUsagePercent: number = 80): Promise<HealthIndicatorResult> {
        try {
            const memoryUsage = await getRedisMemoryUsage(ioRedis);

            const usagePercent = memoryUsage.available > 0
                ? (memoryUsage.used / memoryUsage.available) * 100
                : 0;

            const status = usagePercent > maxUsagePercent ? 'warning' : 'up';
            const isHealthy = usagePercent < 95; // Fail if usage is over 95%

            if (!isHealthy) {
                throw new HealthCheckError('Redis memory usage check failed', {
                    redis: {
                        status: 'down',
                        memoryUsage: `${Math.round(usagePercent * 100) / 100}%`,
                        threshold: `${maxUsagePercent}%`,
                        message: 'Redis memory usage too high',
                    },
                });
            }

            return this.getStatus(key, true, {
                status,
                memory: {
                    used: this.formatBytes(memoryUsage.used),
                    available: this.formatBytes(memoryUsage.available),
                    usagePercent: `${Math.round(usagePercent * 100) / 100}%`,
                    threshold: `${maxUsagePercent}%`,
                },
                message: usagePercent > maxUsagePercent
                    ? 'High memory usage detected'
                    : 'Memory usage within acceptable range',
            });
        } catch (error) {
            logger.error('Redis memory usage check failed', { error: error.message });
            throw new HealthCheckError('Redis memory usage check failed', {
                redis: {
                    status: 'down',
                    error: error.message,
                },
            });
        }
    }

    /**
     * Check Redis hit rate
     */
    async checkHitRate(key: string, minHitRate: number = 80): Promise<HealthIndicatorResult> {
        try {
            const metrics = await getRedisMetrics(ioRedis);
            const hitRate = metrics.hitRate;

            const status = hitRate < minHitRate ? 'warning' : 'up';
            const isHealthy = hitRate > minHitRate / 2; // Fail if hit rate is less than half the minimum

            if (!isHealthy) {
                throw new HealthCheckError('Redis hit rate check failed', {
                    redis: {
                        status: 'down',
                        hitRate: `${hitRate}%`,
                        threshold: `${minHitRate}%`,
                        message: 'Redis hit rate too low',
                    },
                });
            }

            return this.getStatus(key, true, {
                status,
                performance: {
                    hitRate: `${hitRate}%`,
                    threshold: `${minHitRate}%`,
                    keyspaceHits: metrics.keyspaceHits,
                    keyspaceMisses: metrics.keyspaceMisses,
                },
                message: hitRate < minHitRate
                    ? 'Low cache hit rate detected'
                    : 'Cache hit rate within acceptable range',
            });
        } catch (error) {
            logger.error('Redis hit rate check failed', { error: error.message });
            throw new HealthCheckError('Redis hit rate check failed', {
                redis: {
                    status: 'down',
                    error: error.message,
                },
            });
        }
    }

    /**
     * Comprehensive Redis health check
     */
    async getComprehensiveHealth(key: string): Promise<HealthIndicatorResult> {
        try {
            const [
                basicHealth,
                latencyCheck,
                memoryCheck,
                hitRateCheck,
            ] = await Promise.allSettled([
                this.isHealthy('basic'),
                this.checkLatency('latency', 100),
                this.checkMemoryUsage('memory', 80),
                this.checkHitRate('hitRate', 70),
            ]);

            const results = {
                basic: this.getResultValue(basicHealth),
                latency: this.getResultValue(latencyCheck),
                memory: this.getResultValue(memoryCheck),
                hitRate: this.getResultValue(hitRateCheck),
            };

            // Determine overall status
            const hasFailures = Object.values(results).some(result =>
                result?.status === 'down' || result === null
            );

            const hasWarnings = Object.values(results).some(result =>
                result?.status === 'warning'
            );

            const overallStatus = hasFailures ? 'down' : hasWarnings ? 'warning' : 'up';

            return this.getStatus(key, !hasFailures, {
                status: overallStatus,
                checks: results,
                summary: {
                    total: 4,
                    passed: Object.values(results).filter(r => r?.status === 'up').length,
                    warnings: Object.values(results).filter(r => r?.status === 'warning').length,
                    failed: Object.values(results).filter(r => r?.status === 'down' || r === null).length,
                },
            });
        } catch (error) {
            logger.error('Redis comprehensive health check failed', { error: error.message });
            throw new HealthCheckError('Redis comprehensive health check failed', {
                redis: {
                    status: 'down',
                    error: error.message,
                },
            });
        }
    }

    /**
     * Format bytes to human readable format
     */
    private formatBytes(bytes: number): string {
        if (bytes === 0) return '0 Bytes';

        const k = 1024;
        const sizes = ['Bytes', 'KB', 'MB', 'GB', 'TB'];
        const i = Math.floor(Math.log(bytes) / Math.log(k));

        return parseFloat((bytes / Math.pow(k, i)).toFixed(2)) + ' ' + sizes[i];
    }

    /**
     * Extract result value from Promise.allSettled result
     */
    private getResultValue(result: PromiseSettledResult<HealthIndicatorResult>): any {
        if (result.status === 'fulfilled') {
            return Object.values(result.value)[0];
        }
        return null;
    }
}

/**
 * Redis Health Check Module
 */
export class RedisHealthModule {
    static forRoot() {
        return {
            module: RedisHealthModule,
            providers: [RedisHealthIndicator],
            exports: [RedisHealthIndicator],
        };
    }
}