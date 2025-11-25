# Redis Configuration for Postiz

This document describes the comprehensive Redis setup for the Postiz application, including configuration, monitoring, and deployment options.

## 🚀 Quick Start

### Test Your Current Redis Connection

```bash
# Test your Redis connection (uses your .env REDIS_URL)
pnpm redis:test
# or
node test-redis.js
```

### Development Setup

```bash
# Start local Redis for development
pnpm redis:dev

# Start Redis with production configuration
pnpm redis:prod

# Start Redis with monitoring (Prometheus metrics)
pnpm redis:monitor
```

## 📋 Configuration Files

### Core Files

- **`redis.conf`** - Production Redis server configuration
- **`redis-sentinel.conf`** - High availability configuration
- **`redis-cluster.conf`** - Clustering configuration
- **`docker-compose.redis.yaml`** - Production Docker setup

### Code Files

- **`libraries/nestjs-libraries/src/redis/`** - Redis service modules
  - `redis.service.ts` - Core Redis service with cloud provider support
  - `redis.config.ts` - Configuration management and parsing
  - `redis.utils.ts` - Caching utilities and patterns
  - `redis.health.ts` - Health monitoring for NestJS
  - `redis.monitor.ts` - Continuous monitoring service
  - `redis.test.ts` - Testing utilities
  - `index.ts` - Main exports

## 🔧 Environment Configuration

### Required Environment Variables

```bash
# Redis connection URL
REDIS_URL="redis://localhost:6379"

# For cloud providers (Upstash example)
REDIS_URL="redis://default:password@host.upstash.io:6379"

# For TLS connections
REDIS_URL="rediss://user:pass@host:6380"

# Environment
NODE_ENV="development" # or "production" or "test"
```

### Supported Redis Providers

✅ **Local Redis** - `redis://localhost:6379`  
✅ **Upstash** - `redis://default:password@host.upstash.io:6379`  
✅ **Redis Cloud** - `rediss://user:pass@host.redis.cloud:port`  
✅ **AWS ElastiCache** - `rediss://cluster.cache.amazonaws.com:6380`  
✅ **Azure Cache** - `rediss://cache.redis.cache.windows.net:6380`  
✅ **Google Cloud Memorystore** - `redis://host:6379`  

## 🏗️ Architecture

### Connection Management

- **Automatic TLS Detection** - Enables TLS for `rediss://` URLs and cloud providers
- **Connection Pooling** - Optimized connection settings per environment
- **Retry Strategy** - Exponential backoff with configurable limits
- **Health Monitoring** - Continuous health checks and alerting

### Caching Patterns

```typescript
import { cacheSet, cacheGet, cacheGetOrSet } from '@gitroom/nestjs-libraries/redis';

// Basic caching
await cacheSet('user:123', userData, 3600); // 1 hour TTL
const user = await cacheGet('user:123');

// Cache with fallback
const user = await cacheGetOrSet(
  'user:123',
  () => fetchUserFromDatabase(123),
  3600
);

// Rate limiting
import { rateLimit } from '@gitroom/nestjs-libraries/redis';
const { allowed, remaining } = await rateLimit('user:123', 100, 3600);
```

### Postiz-Specific Utilities

```typescript
import { 
  cacheUser, 
  getCachedUser, 
  cacheIntegration,
  invalidateUserCache 
} from '@gitroom/nestjs-libraries/redis';

// Cache user data
await cacheUser('123', userData);
const user = await getCachedUser('123');

// Cache social media integrations
await cacheIntegration('integration-id', integrationData);

// Invalidate all user-related cache
await invalidateUserCache('123');
```

## 🐳 Docker Deployment

### Development

```bash
# Basic Redis for development
docker-compose -f docker-compose.dev.yaml up -d postiz-redis
```

### Production

```bash
# Production Redis with custom configuration
docker-compose -f docker-compose.dev.yaml -f docker-compose.redis.yaml up -d
```

### High Availability

```bash
# Redis with Sentinel for automatic failover
docker-compose -f docker-compose.dev.yaml -f docker-compose.redis.yaml --profile sentinel up -d
```

### Clustering

```bash
# Redis Cluster for horizontal scaling
docker-compose -f docker-compose.dev.yaml -f docker-compose.redis.yaml --profile cluster up -d
```

### Monitoring

```bash
# Redis with Prometheus monitoring
docker-compose -f docker-compose.dev.yaml -f docker-compose.redis.yaml --profile monitoring up -d
```

## 📊 Monitoring & Health Checks

### Health Monitoring

```typescript
import { RedisHealthIndicator } from '@gitroom/nestjs-libraries/redis';

// Basic health check
const health = await healthIndicator.isHealthy('redis');

// Detailed health with metrics
const detailedHealth = await healthIndicator.getDetailedHealth('redis');

// Check specific metrics
const latencyCheck = await healthIndicator.checkLatency('redis', 100);
const memoryCheck = await healthIndicator.checkMemoryUsage('redis', 80);
```

### Continuous Monitoring

```typescript
import { RedisMonitorService } from '@gitroom/nestjs-libraries/redis';

// Get dashboard data
const dashboard = await monitorService.getDashboardData();

// Update alert thresholds
monitorService.updateAlertThresholds({
  memoryUsagePercent: 85,
  hitRatePercent: 70,
});
```

### Metrics Available

- **Connection Health** - Ping response time and connectivity
- **Memory Usage** - Used/available memory with percentage
- **Cache Performance** - Hit rate, keyspace hits/misses
- **Client Connections** - Number of connected clients
- **Command Statistics** - Total commands processed
- **Key Statistics** - Total keys by prefix

## 🧪 Testing

### Connection Testing

```bash
# Test Redis connection
pnpm redis:test

# Or run directly
node test-redis.js
```

### Programmatic Testing

```typescript
import { 
  testRedisConnection, 
  testRedisOperations, 
  testRedisPerformance,
  runRedisTests 
} from '@gitroom/nestjs-libraries/redis';

// Test connection only
const connectionResult = await testRedisConnection();

// Test all operations
const operationsResult = await testRedisOperations();

// Performance test
const performanceResult = await testRedisPerformance(100);

// Comprehensive test suite
const allResults = await runRedisTests();
```

## 🔒 Security

### Authentication

- **Password Protection** - Configured via REDIS_URL
- **TLS Encryption** - Automatic for cloud providers
- **Command Renaming** - Dangerous commands can be renamed/disabled

### Production Security

```bash
# In redis.conf, uncomment and configure:
requirepass your_strong_password_here
rename-command FLUSHDB ""
rename-command FLUSHALL ""
rename-command CONFIG ""
```

## ⚡ Performance Optimization

### Environment-Specific Settings

- **Development** - Lower timeouts, fewer retries
- **Production** - Higher timeouts, more retries, aggressive retry strategy
- **Test** - Minimal timeouts, MockRedis fallback

### Cloud Provider Optimizations

- **Upstash** - Extended timeouts, increased retry attempts
- **AWS ElastiCache** - Cluster-aware configuration
- **Redis Cloud** - TLS optimization

### Memory Management

```bash
# In redis.conf
maxmemory 2gb
maxmemory-policy allkeys-lru
maxmemory-samples 10
```

## 🚨 Troubleshooting

### Common Issues

1. **Connection Timeout**
   ```bash
   # Check network connectivity
   pnpm redis:test
   
   # Verify REDIS_URL format
   echo $REDIS_URL
   ```

2. **Authentication Errors**
   ```bash
   # Ensure password is in URL
   REDIS_URL="redis://default:password@host:6379"
   ```

3. **TLS Issues**
   ```bash
   # Use rediss:// for TLS or ensure cloud provider detection
   REDIS_URL="rediss://user:pass@host:6380"
   ```

4. **Memory Issues**
   ```bash
   # Check memory usage
   docker exec postiz-redis redis-cli info memory
   ```

### Debug Mode

```typescript
// Enable debug logging
process.env.DEBUG = 'ioredis:*';

// Or use the monitoring service
const dashboard = await monitorService.getDashboardData();
console.log('Redis Status:', dashboard);
```

## 📈 Scaling

### Vertical Scaling

- Increase memory limits in Docker Compose
- Adjust `maxmemory` in redis.conf
- Optimize connection pool settings

### Horizontal Scaling

- Use Redis Cluster configuration
- Enable cluster profile in Docker Compose
- Update application to use cluster-aware client

### High Availability

- Deploy Redis Sentinel
- Configure automatic failover
- Use multiple Redis instances

## 🔄 Migration

### From Local to Cloud

1. Update `REDIS_URL` in `.env`
2. Test connection: `pnpm redis:test`
3. Migrate data if needed
4. Update monitoring thresholds

### From Single Instance to Cluster

1. Deploy cluster configuration
2. Update application configuration
3. Migrate data using Redis migration tools
4. Update monitoring for cluster metrics

## 📚 Additional Resources

- [Redis Official Documentation](https://redis.io/documentation)
- [ioredis Documentation](https://github.com/luin/ioredis)
- [Upstash Redis Documentation](https://docs.upstash.com/redis)
- [Redis Best Practices](https://redis.io/docs/manual/patterns/)

## 🤝 Contributing

When contributing to Redis configuration:

1. Test changes with `pnpm redis:test`
2. Update documentation
3. Consider backward compatibility
4. Add appropriate monitoring
5. Test with different providers

---

For questions or issues, please check the [main README](./README.md) or create an issue in the repository.