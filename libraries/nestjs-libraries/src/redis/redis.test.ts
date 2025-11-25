import { Redis } from 'ioredis';
import * as Sentry from '@sentry/nextjs';
import { createRedisConfig, checkRedisHealth, getRedisMetrics } from './redis.config';

const { logger } = Sentry;

/**
 * Redis Connection Test Utility
 * Use this to test your Redis configuration and connection
 */

/**
 * Test Redis connection with current configuration
 */
export async function testRedisConnection(): Promise<{
    success: boolean;
    config: any;
    connectionTime: number;
    error?: string;
    metrics?: any;
}> {
    const startTime = Date.now();
    let redis: Redis | null = null;

    try {
        logger.info('Testing Redis connection...');

        // Get configuration
        const config = createRedisConfig();
        logger.info('Redis configuration:', {
            host: config.host,
            port: config.port,
            db: config.db,
            tls: !!config.tls,
            connectTimeout: config.connectTimeout,
            commandTimeout: config.commandTimeout,
        });

        // Create Redis instance
        redis = new Redis(config);

        // Test connection
        const pingResult = await redis.ping();
        const connectionTime = Date.now() - startTime;

        if (pingResult !== 'PONG') {
            throw new Error(`Unexpected ping response: ${pingResult}`);
        }

        // Get metrics
        const metrics = await getRedisMetrics(redis);

        logger.info('Redis connection test successful', {
            connectionTime: `${connectionTime}ms`,
            metrics,
        });

        return {
            success: true,
            config: {
                host: config.host,
                port: config.port,
                db: config.db,
                tls: !!config.tls,
            },
            connectionTime,
            metrics,
        };

    } catch (error) {
        const connectionTime = Date.now() - startTime;
        logger.error('Redis connection test failed', {
            error: error.message,
            connectionTime: `${connectionTime}ms`,
        });

        return {
            success: false,
            config: {},
            connectionTime,
            error: error.message,
        };
    } finally {
        if (redis) {
            await redis.quit();
        }
    }
}

/**
 * Test Redis operations (set, get, delete)
 */
export async function testRedisOperations(): Promise<{
    success: boolean;
    operations: Record<string, boolean>;
    error?: string;
}> {
    let redis: Redis | null = null;

    try {
        logger.info('Testing Redis operations...');

        const config = createRedisConfig();
        redis = new Redis(config);

        const testKey = `postiz:test:${Date.now()}`;
        const testValue = { message: 'Hello from Postiz Redis test!', timestamp: Date.now() };
        const operations: Record<string, boolean> = {};

        // Test SET operation
        try {
            const setResult = await redis.setex(testKey, 60, JSON.stringify(testValue));
            operations.set = setResult === 'OK';
            logger.info('SET operation result:', setResult);
        } catch (error) {
            operations.set = false;
            logger.error('SET operation failed:', error.message);
        }

        // Test GET operation
        try {
            const getValue = await redis.get(testKey);
            const parsedValue = getValue ? JSON.parse(getValue) : null;
            operations.get = parsedValue?.message === testValue.message;
            logger.info('GET operation result:', { retrieved: !!getValue, matches: operations.get });
        } catch (error) {
            operations.get = false;
            logger.error('GET operation failed:', error.message);
        }

        // Test EXISTS operation
        try {
            const existsResult = await redis.exists(testKey);
            operations.exists = existsResult === 1;
            logger.info('EXISTS operation result:', existsResult);
        } catch (error) {
            operations.exists = false;
            logger.error('EXISTS operation failed:', error.message);
        }

        // Test DEL operation
        try {
            const delResult = await redis.del(testKey);
            operations.delete = delResult === 1;
            logger.info('DEL operation result:', delResult);
        } catch (error) {
            operations.delete = false;
            logger.error('DEL operation failed:', error.message);
        }

        // Test TTL operation
        try {
            const ttlTestKey = `postiz:ttl:test:${Date.now()}`;
            await redis.setex(ttlTestKey, 30, 'ttl-test');
            const ttlResult = await redis.ttl(ttlTestKey);
            operations.ttl = ttlResult > 0 && ttlResult <= 30;
            await redis.del(ttlTestKey);
            logger.info('TTL operation result:', ttlResult);
        } catch (error) {
            operations.ttl = false;
            logger.error('TTL operation failed:', error.message);
        }

        const allOperationsSuccessful = Object.values(operations).every(Boolean);

        logger.info('Redis operations test completed', {
            success: allOperationsSuccessful,
            operations,
        });

        return {
            success: allOperationsSuccessful,
            operations,
        };

    } catch (error) {
        logger.error('Redis operations test failed', { error: error.message });
        return {
            success: false,
            operations: {},
            error: error.message,
        };
    } finally {
        if (redis) {
            await redis.quit();
        }
    }
}

/**
 * Test Redis performance
 */
export async function testRedisPerformance(iterations: number = 100): Promise<{
    success: boolean;
    performance: {
        avgSetTime: number;
        avgGetTime: number;
        totalTime: number;
        operationsPerSecond: number;
    };
    error?: string;
}> {
    let redis: Redis | null = null;

    try {
        logger.info(`Testing Redis performance with ${iterations} iterations...`);

        const config = createRedisConfig();
        redis = new Redis(config);

        const setTimes: number[] = [];
        const getTimes: number[] = [];
        const testKeys: string[] = [];

        const startTime = Date.now();

        // Test SET operations
        for (let i = 0; i < iterations; i++) {
            const key = `postiz:perf:test:${i}:${Date.now()}`;
            const value = { iteration: i, data: `test-data-${i}`, timestamp: Date.now() };

            const setStart = Date.now();
            await redis.setex(key, 300, JSON.stringify(value));
            const setEnd = Date.now();

            setTimes.push(setEnd - setStart);
            testKeys.push(key);
        }

        // Test GET operations
        for (const key of testKeys) {
            const getStart = Date.now();
            await redis.get(key);
            const getEnd = Date.now();

            getTimes.push(getEnd - getStart);
        }

        const totalTime = Date.now() - startTime;

        // Calculate averages
        const avgSetTime = setTimes.reduce((a, b) => a + b, 0) / setTimes.length;
        const avgGetTime = getTimes.reduce((a, b) => a + b, 0) / getTimes.length;
        const operationsPerSecond = (iterations * 2) / (totalTime / 1000);

        // Cleanup
        if (testKeys.length > 0) {
            await redis.del(...testKeys);
        }

        const performance = {
            avgSetTime: Math.round(avgSetTime * 100) / 100,
            avgGetTime: Math.round(avgGetTime * 100) / 100,
            totalTime,
            operationsPerSecond: Math.round(operationsPerSecond * 100) / 100,
        };

        logger.info('Redis performance test completed', performance);

        return {
            success: true,
            performance,
        };

    } catch (error) {
        logger.error('Redis performance test failed', { error: error.message });
        return {
            success: false,
            performance: {
                avgSetTime: 0,
                avgGetTime: 0,
                totalTime: 0,
                operationsPerSecond: 0,
            },
            error: error.message,
        };
    } finally {
        if (redis) {
            await redis.quit();
        }
    }
}

/**
 * Run comprehensive Redis tests
 */
export async function runRedisTests(): Promise<{
    connection: any;
    operations: any;
    performance: any;
    overall: boolean;
}> {
    logger.info('Starting comprehensive Redis tests...');

    const [connectionTest, operationsTest, performanceTest] = await Promise.all([
        testRedisConnection(),
        testRedisOperations(),
        testRedisPerformance(50),
    ]);

    const overall = connectionTest.success && operationsTest.success && performanceTest.success;

    const results = {
        connection: connectionTest,
        operations: operationsTest,
        performance: performanceTest,
        overall,
    };

    logger.info('Comprehensive Redis tests completed', {
        overall,
        connectionSuccess: connectionTest.success,
        operationsSuccess: operationsTest.success,
        performanceSuccess: performanceTest.success,
    });

    return results;
}

/**
 * CLI function to run tests from command line
 */
export async function runRedisTestsCLI(): Promise<void> {
    console.log('🔄 Starting Redis tests...\n');

    try {
        const results = await runRedisTests();

        console.log('📊 Test Results:');
        console.log('================');

        console.log(`\n🔗 Connection Test: ${results.connection.success ? '✅ PASSED' : '❌ FAILED'}`);
        if (results.connection.success) {
            console.log(`   - Connection time: ${results.connection.connectionTime}ms`);
            console.log(`   - Host: ${results.connection.config.host}`);
            console.log(`   - Port: ${results.connection.config.port}`);
            console.log(`   - TLS: ${results.connection.config.tls ? 'Enabled' : 'Disabled'}`);
        } else {
            console.log(`   - Error: ${results.connection.error}`);
        }

        console.log(`\n⚙️  Operations Test: ${results.operations.success ? '✅ PASSED' : '❌ FAILED'}`);
        if (results.operations.success) {
            const ops = results.operations.operations;
            console.log(`   - SET: ${ops.set ? '✅' : '❌'}`);
            console.log(`   - GET: ${ops.get ? '✅' : '❌'}`);
            console.log(`   - EXISTS: ${ops.exists ? '✅' : '❌'}`);
            console.log(`   - DELETE: ${ops.delete ? '✅' : '❌'}`);
            console.log(`   - TTL: ${ops.ttl ? '✅' : '❌'}`);
        } else {
            console.log(`   - Error: ${results.operations.error}`);
        }

        console.log(`\n🚀 Performance Test: ${results.performance.success ? '✅ PASSED' : '❌ FAILED'}`);
        if (results.performance.success) {
            const perf = results.performance.performance;
            console.log(`   - Avg SET time: ${perf.avgSetTime}ms`);
            console.log(`   - Avg GET time: ${perf.avgGetTime}ms`);
            console.log(`   - Operations/sec: ${perf.operationsPerSecond}`);
            console.log(`   - Total time: ${perf.totalTime}ms`);
        } else {
            console.log(`   - Error: ${results.performance.error}`);
        }

        console.log(`\n🎯 Overall Result: ${results.overall ? '✅ ALL TESTS PASSED' : '❌ SOME TESTS FAILED'}`);

    } catch (error) {
        console.error('❌ Test execution failed:', error.message);
        process.exit(1);
    }
}

// If this file is run directly, execute the CLI tests
if (require.main === module) {
    runRedisTestsCLI().catch(console.error);
}