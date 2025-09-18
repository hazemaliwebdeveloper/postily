#!/usr/bin/env node

/**
 * Redis Connection Test Script for Postiz
 * 
 * This script tests the Redis connection using your current .env configuration
 * Run with: node test-redis.js
 */

const { Redis } = require('ioredis');
require('dotenv').config();

// ANSI color codes for console output
const colors = {
    reset: '\x1b[0m',
    bright: '\x1b[1m',
    red: '\x1b[31m',
    green: '\x1b[32m',
    yellow: '\x1b[33m',
    blue: '\x1b[34m',
    magenta: '\x1b[35m',
    cyan: '\x1b[36m',
};

function log(message, color = colors.reset) {
    console.log(`${color}${message}${colors.reset}`);
}

function logSuccess(message) {
    log(`✅ ${message}`, colors.green);
}

function logError(message) {
    log(`❌ ${message}`, colors.red);
}

function logWarning(message) {
    log(`⚠️  ${message}`, colors.yellow);
}

function logInfo(message) {
    log(`ℹ️  ${message}`, colors.blue);
}

async function parseRedisUrl(redisUrl) {
    try {
        const url = new URL(redisUrl);

        const config = {
            host: url.hostname,
            port: parseInt(url.port) || 6379,
            db: parseInt(url.pathname.slice(1)) || 0,
            maxRetriesPerRequest: 3,
            retryDelayOnFailover: 100,
            connectTimeout: 10000,
            commandTimeout: 5000,
            lazyConnect: true,
            keepAlive: 30000,
            family: 4,
        };

        if (url.password) {
            config.password = url.password;
        }

        if (url.username && url.username !== 'default') {
            config.username = url.username;
        }

        // Enable TLS for secure connections or cloud providers
        if (url.protocol === 'rediss:' || url.hostname.includes('upstash.io') ||
            url.hostname.includes('redis.cloud') || url.hostname.includes('amazonaws.com')) {
            config.tls = {
                servername: url.hostname,
            };
        }

        // Upstash specific optimizations
        if (url.hostname.includes('upstash.io')) {
            config.connectTimeout = 15000;
            config.commandTimeout = 10000;
            config.maxRetriesPerRequest = 5;
            config.retryDelayOnFailover = 200;
        }

        return config;
    } catch (error) {
        throw new Error(`Invalid Redis URL: ${error.message}`);
    }
}

async function testRedisConnection() {
    log('\n🔄 Testing Redis Connection for Postiz...', colors.bright);
    log('==========================================\n');

    // Check if REDIS_URL is set
    const redisUrl = process.env.REDIS_URL;
    if (!redisUrl) {
        logError('REDIS_URL environment variable is not set');
        logInfo('Please set REDIS_URL in your .env file');
        process.exit(1);
    }

    logInfo(`Redis URL: ${redisUrl.replace(/:[^:@]*@/, ':***@')}`); // Hide password

    let redis = null;

    try {
        // Parse and create configuration
        const config = await parseRedisUrl(redisUrl);

        logInfo(`Connecting to: ${config.host}:${config.port}`);
        logInfo(`Database: ${config.db}`);
        logInfo(`TLS: ${config.tls ? 'Enabled' : 'Disabled'}`);
        logInfo(`Timeout: ${config.connectTimeout}ms`);

        // Create Redis instance
        redis = new Redis(config);

        // Test basic connectivity
        log('\n📡 Testing basic connectivity...');
        const startTime = Date.now();
        const pingResult = await redis.ping();
        const connectionTime = Date.now() - startTime;

        if (pingResult === 'PONG') {
            logSuccess(`Connection successful! Response time: ${connectionTime}ms`);
        } else {
            logError(`Unexpected ping response: ${pingResult}`);
            return false;
        }

        // Test basic operations
        log('\n⚙️  Testing basic operations...');

        const testKey = `postiz:test:${Date.now()}`;
        const testValue = {
            message: 'Hello from Postiz!',
            timestamp: Date.now(),
            test: true
        };

        // Test SET
        const setResult = await redis.setex(testKey, 60, JSON.stringify(testValue));
        if (setResult === 'OK') {
            logSuccess('SET operation successful');
        } else {
            logError(`SET operation failed: ${setResult}`);
        }

        // Test GET
        const getValue = await redis.get(testKey);
        if (getValue) {
            const parsedValue = JSON.parse(getValue);
            if (parsedValue.message === testValue.message) {
                logSuccess('GET operation successful');
            } else {
                logError('GET operation returned incorrect data');
            }
        } else {
            logError('GET operation failed - no data returned');
        }

        // Test EXISTS
        const existsResult = await redis.exists(testKey);
        if (existsResult === 1) {
            logSuccess('EXISTS operation successful');
        } else {
            logError('EXISTS operation failed');
        }

        // Test TTL
        const ttlResult = await redis.ttl(testKey);
        if (ttlResult > 0 && ttlResult <= 60) {
            logSuccess(`TTL operation successful (${ttlResult}s remaining)`);
        } else {
            logWarning(`TTL operation returned unexpected value: ${ttlResult}`);
        }

        // Test DELETE
        const delResult = await redis.del(testKey);
        if (delResult === 1) {
            logSuccess('DELETE operation successful');
        } else {
            logError('DELETE operation failed');
        }

        // Get Redis info
        log('\n📊 Getting Redis information...');
        try {
            const info = await redis.info();
            const lines = info.split('\r\n');
            const redisInfo = {};

            for (const line of lines) {
                if (line.includes(':')) {
                    const [key, value] = line.split(':');
                    redisInfo[key] = value;
                }
            }

            logInfo(`Redis Version: ${redisInfo.redis_version || 'Unknown'}`);
            logInfo(`Connected Clients: ${redisInfo.connected_clients || 'Unknown'}`);
            logInfo(`Used Memory: ${redisInfo.used_memory_human || redisInfo.used_memory || 'Unknown'}`);
            logInfo(`Total Commands Processed: ${redisInfo.total_commands_processed || 'Unknown'}`);

            if (redisInfo.keyspace_hits && redisInfo.keyspace_misses) {
                const hits = parseInt(redisInfo.keyspace_hits);
                const misses = parseInt(redisInfo.keyspace_misses);
                const total = hits + misses;
                const hitRate = total > 0 ? ((hits / total) * 100).toFixed(2) : 0;
                logInfo(`Cache Hit Rate: ${hitRate}%`);
            }

        } catch (infoError) {
            logWarning(`Could not retrieve Redis info: ${infoError.message}`);
        }

        // Performance test
        log('\n🚀 Running performance test...');
        const iterations = 50;
        const perfStartTime = Date.now();

        const setTimes = [];
        const getTimes = [];
        const testKeys = [];

        // Test SET performance
        for (let i = 0; i < iterations; i++) {
            const key = `postiz:perf:${i}:${Date.now()}`;
            const value = { iteration: i, data: `test-data-${i}` };

            const setStart = Date.now();
            await redis.setex(key, 300, JSON.stringify(value));
            setTimes.push(Date.now() - setStart);
            testKeys.push(key);
        }

        // Test GET performance
        for (const key of testKeys) {
            const getStart = Date.now();
            await redis.get(key);
            getTimes.push(Date.now() - getStart);
        }

        const totalTime = Date.now() - perfStartTime;
        const avgSetTime = setTimes.reduce((a, b) => a + b, 0) / setTimes.length;
        const avgGetTime = getTimes.reduce((a, b) => a + b, 0) / getTimes.length;
        const opsPerSecond = (iterations * 2) / (totalTime / 1000);

        logSuccess(`Performance test completed:`);
        logInfo(`  - Average SET time: ${avgSetTime.toFixed(2)}ms`);
        logInfo(`  - Average GET time: ${avgGetTime.toFixed(2)}ms`);
        logInfo(`  - Operations per second: ${opsPerSecond.toFixed(2)}`);
        logInfo(`  - Total time: ${totalTime}ms`);

        // Cleanup performance test keys
        if (testKeys.length > 0) {
            await redis.del(...testKeys);
            logInfo(`Cleaned up ${testKeys.length} test keys`);
        }

        log('\n🎉 All tests completed successfully!', colors.green + colors.bright);
        log('\n✨ Your Redis configuration is working perfectly with Postiz!');

        return true;

    } catch (error) {
        logError(`Redis connection test failed: ${error.message}`);

        if (error.message.includes('ENOTFOUND')) {
            logWarning('DNS resolution failed. Check your Redis hostname.');
        } else if (error.message.includes('ECONNREFUSED')) {
            logWarning('Connection refused. Check if Redis server is running and accessible.');
        } else if (error.message.includes('ETIMEDOUT')) {
            logWarning('Connection timed out. Check your network connection and firewall settings.');
        } else if (error.message.includes('WRONGPASS')) {
            logWarning('Authentication failed. Check your Redis password.');
        } else if (error.message.includes('NOAUTH')) {
            logWarning('Authentication required. Make sure your Redis URL includes credentials.');
        }

        return false;
    } finally {
        if (redis) {
            await redis.quit();
        }
    }
}

// Run the test
testRedisConnection()
    .then((success) => {
        process.exit(success ? 0 : 1);
    })
    .catch((error) => {
        logError(`Test execution failed: ${error.message}`);
        process.exit(1);
    });