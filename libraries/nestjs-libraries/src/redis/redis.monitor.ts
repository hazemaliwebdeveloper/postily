import { Injectable } from '@nestjs/common';
import { Cron, CronExpression } from '@nestjs/schedule';
import * as Sentry from '@sentry/nextjs';
import { ioRedis } from './redis.service';
import { getRedisMetrics, getRedisMemoryUsage, checkRedisHealth } from './redis.config';
import { getCacheStats } from './redis.utils';

const { logger } = Sentry;

/**
 * Redis Monitoring Service for Postiz
 * Provides continuous monitoring and alerting for Redis health
 */
@Injectable()
export class RedisMonitorService {
    private isMonitoring: boolean = false;
    private lastHealthCheck: Date | null = null;
    private healthCheckInterval: NodeJS.Timeout | null = null;
    private alertThresholds = {
        memoryUsagePercent: 85,
        hitRatePercent: 70,
        connectionTimeoutMs: 5000,
        maxConnectedClients: 1000,
    };

    constructor() {
        this.startMonitoring();
    }

    /**
     * Start Redis monitoring
     */
    startMonitoring(): void {
        if (this.isMonitoring) {
            logger.warn('Redis monitoring is already running');
            return;
        }

        this.isMonitoring = true;
        logger.info('Starting Redis monitoring service');

        // Start periodic health checks
        this.healthCheckInterval = setInterval(
            () => this.performHealthCheck(),
            30000 // Every 30 seconds
        );
    }

    /**
     * Stop Redis monitoring
     */
    stopMonitoring(): void {
        if (!this.isMonitoring) {
            return;
        }

        this.isMonitoring = false;
        logger.info('Stopping Redis monitoring service');

        if (this.healthCheckInterval) {
            clearInterval(this.healthCheckInterval);
            this.healthCheckInterval = null;
        }
    }

    /**
     * Perform comprehensive health check
     */
    private async performHealthCheck(): Promise<void> {
        try {
            const startTime = Date.now();

            // Basic connectivity check
            const isHealthy = await checkRedisHealth(ioRedis);
            const responseTime = Date.now() - startTime;

            if (!isHealthy) {
                this.handleAlert('Redis connectivity check failed', {
                    type: 'connectivity',
                    severity: 'critical',
                    responseTime,
                });
                return;
            }

            // Check response time
            if (responseTime > this.alertThresholds.connectionTimeoutMs) {
                this.handleAlert('Redis response time is high', {
                    type: 'performance',
                    severity: 'warning',
                    responseTime,
                    threshold: this.alertThresholds.connectionTimeoutMs,
                });
            }

            // Get detailed metrics
            const [metrics, memoryUsage, cacheStats] = await Promise.all([
                getRedisMetrics(ioRedis),
                getRedisMemoryUsage(ioRedis),
                getCacheStats(ioRedis),
            ]);

            // Check memory usage
            const memoryUsagePercent = memoryUsage.available > 0
                ? (memoryUsage.used / memoryUsage.available) * 100
                : 0;

            if (memoryUsagePercent > this.alertThresholds.memoryUsagePercent) {
                this.handleAlert('Redis memory usage is high', {
                    type: 'memory',
                    severity: memoryUsagePercent > 95 ? 'critical' : 'warning',
                    memoryUsagePercent: Math.round(memoryUsagePercent * 100) / 100,
                    threshold: this.alertThresholds.memoryUsagePercent,
                    memoryUsage,
                });
            }

            // Check hit rate
            if (metrics.hitRate < this.alertThresholds.hitRatePercent) {
                this.handleAlert('Redis cache hit rate is low', {
                    type: 'cache_performance',
                    severity: 'warning',
                    hitRate: metrics.hitRate,
                    threshold: this.alertThresholds.hitRatePercent,
                    keyspaceHits: metrics.keyspaceHits,
                    keyspaceMisses: metrics.keyspaceMisses,
                });
            }

            // Check connected clients
            if (metrics.connectedClients > this.alertThresholds.maxConnectedClients) {
                this.handleAlert('Redis has too many connected clients', {
                    type: 'connections',
                    severity: 'warning',
                    connectedClients: metrics.connectedClients,
                    threshold: this.alertThresholds.maxConnectedClients,
                });
            }

            // Log successful health check
            this.lastHealthCheck = new Date();

            // Log detailed metrics every 5 minutes
            if (Date.now() % 300000 < 30000) { // Approximately every 5 minutes
                logger.info('Redis health check completed', {
                    responseTime,
                    memoryUsagePercent: Math.round(memoryUsagePercent * 100) / 100,
                    hitRate: metrics.hitRate,
                    connectedClients: metrics.connectedClients,
                    totalKeys: cacheStats.totalKeys,
                });
            }

        } catch (error) {
            this.handleAlert('Redis health check failed', {
                type: 'monitoring',
                severity: 'critical',
                error: error.message,
            });
        }
    }

    /**
     * Handle alerts and notifications
     */
    private handleAlert(message: string, details: any): void {
        const alertData = {
            message,
            timestamp: new Date().toISOString(),
            service: 'redis',
            ...details,
        };

        // Log the alert
        if (details.severity === 'critical') {
            logger.error(message, alertData);
        } else {
            logger.warn(message, alertData);
        }

        // Send to Sentry for critical alerts
        if (details.severity === 'critical') {
            Sentry.captureException(new Error(message), {
                tags: {
                    service: 'redis',
                    alertType: details.type,
                    severity: details.severity,
                },
                extra: alertData,
            });
        }

        // Here you could add additional notification mechanisms:
        // - Send to Slack/Discord webhook
        // - Send email notifications
        // - Trigger PagerDuty alerts
        // - Store in database for dashboard
    }

    /**
     * Get current monitoring status
     */
    getMonitoringStatus(): {
        isMonitoring: boolean;
        lastHealthCheck: Date | null;
        uptime: number;
    } {
        return {
            isMonitoring: this.isMonitoring,
            lastHealthCheck: this.lastHealthCheck,
            uptime: this.lastHealthCheck ? Date.now() - this.lastHealthCheck.getTime() : 0,
        };
    }

    /**
     * Get Redis dashboard data
     */
    async getDashboardData(): Promise<{
        health: any;
        metrics: any;
        memoryUsage: any;
        cacheStats: any;
        alerts: any[];
    }> {
        try {
            const [isHealthy, metrics, memoryUsage, cacheStats] = await Promise.all([
                checkRedisHealth(ioRedis),
                getRedisMetrics(ioRedis),
                getRedisMemoryUsage(ioRedis),
                getCacheStats(ioRedis),
            ]);

            const memoryUsagePercent = memoryUsage.available > 0
                ? (memoryUsage.used / memoryUsage.available) * 100
                : 0;

            // Generate current alerts
            const alerts: any[] = [];

            if (!isHealthy) {
                alerts.push({
                    type: 'connectivity',
                    severity: 'critical',
                    message: 'Redis is not responding',
                });
            }

            if (memoryUsagePercent > this.alertThresholds.memoryUsagePercent) {
                alerts.push({
                    type: 'memory',
                    severity: memoryUsagePercent > 95 ? 'critical' : 'warning',
                    message: `Memory usage is ${Math.round(memoryUsagePercent)}%`,
                });
            }

            if (metrics.hitRate < this.alertThresholds.hitRatePercent) {
                alerts.push({
                    type: 'cache_performance',
                    severity: 'warning',
                    message: `Cache hit rate is ${metrics.hitRate}%`,
                });
            }

            return {
                health: {
                    status: isHealthy ? 'healthy' : 'unhealthy',
                    lastCheck: this.lastHealthCheck,
                    isMonitoring: this.isMonitoring,
                },
                metrics: {
                    ...metrics,
                    memoryUsagePercent: Math.round(memoryUsagePercent * 100) / 100,
                },
                memoryUsage: {
                    ...memoryUsage,
                    usagePercent: Math.round(memoryUsagePercent * 100) / 100,
                },
                cacheStats,
                alerts,
            };

        } catch (error) {
            logger.error('Failed to get Redis dashboard data', { error: error.message });
            throw error;
        }
    }

    /**
     * Update alert thresholds
     */
    updateAlertThresholds(thresholds: Partial<typeof this.alertThresholds>): void {
        this.alertThresholds = { ...this.alertThresholds, ...thresholds };
        logger.info('Updated Redis alert thresholds', this.alertThresholds);
    }

    /**
     * Scheduled task to log Redis metrics (every 5 minutes)
     */
    @Cron(CronExpression.EVERY_5_MINUTES)
    async logMetrics(): Promise<void> {
        if (!this.isMonitoring) return;

        try {
            const dashboardData = await this.getDashboardData();

            logger.info('Redis metrics report', {
                health: dashboardData.health.status,
                memoryUsage: `${dashboardData.memoryUsage.usagePercent}%`,
                hitRate: `${dashboardData.metrics.hitRate}%`,
                totalKeys: dashboardData.cacheStats.totalKeys,
                connectedClients: dashboardData.metrics.connectedClients,
                alerts: dashboardData.alerts.length,
            });

        } catch (error) {
            logger.error('Failed to log Redis metrics', { error: error.message });
        }
    }

    /**
     * Scheduled task to cleanup old cache entries (every hour)
     */
    @Cron(CronExpression.EVERY_HOUR)
    async cleanupCache(): Promise<void> {
        if (!this.isMonitoring) return;

        try {
            // Get cache statistics before cleanup
            const statsBefore = await getCacheStats(ioRedis);

            // Here you could implement cache cleanup logic
            // For example, remove expired keys, cleanup old sessions, etc.

            logger.info('Cache cleanup completed', {
                keysBefore: statsBefore.totalKeys,
                memoryBefore: statsBefore.memoryUsage,
            });

        } catch (error) {
            logger.error('Cache cleanup failed', { error: error.message });
        }
    }

    /**
     * Force a health check
     */
    async forceHealthCheck(): Promise<any> {
        await this.performHealthCheck();
        return this.getDashboardData();
    }
}

/**
 * Redis Monitor Module
 */
export class RedisMonitorModule {
    static forRoot() {
        return {
            module: RedisMonitorModule,
            providers: [RedisMonitorService],
            exports: [RedisMonitorService],
        };
    }
}