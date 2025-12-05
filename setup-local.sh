#!/bin/bash
# POZMIXAL - LOCAL DEVELOPMENT SETUP SCRIPT
# This script sets up and runs the complete Pozmixal application locally

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}
╔════════════════════════════════════════════════════════════════╗
║          POZMIXAL - LOCAL DEVELOPMENT SETUP                    ║
║         Enterprise Social Media Orchestration Platform         ║
╚════════════════════════════════════════════════════════════════╝
${NC}"

# Check prerequisites
echo -e "${YELLOW}[1/8] Checking prerequisites...${NC}"

# Check Node.js
if ! command -v node &> /dev/null; then
    echo -e "${RED}❌ Node.js not found. Please install Node.js 20+${NC}"
    exit 1
fi
NODE_VERSION=$(node -v)
echo -e "${GREEN}✓ Node.js ${NODE_VERSION}${NC}"

# Check pnpm
if ! command -v pnpm &> /dev/null; then
    echo -e "${RED}❌ pnpm not found. Installing pnpm globally...${NC}"
    npm install -g pnpm
fi
PNPM_VERSION=$(pnpm -v)
echo -e "${GREEN}✓ pnpm ${PNPM_VERSION}${NC}"

# Check Docker
if ! command -v docker &> /dev/null; then
    echo -e "${RED}❌ Docker not found. Please install Docker Desktop${NC}"
    exit 1
fi
DOCKER_VERSION=$(docker --version)
echo -e "${GREEN}✓ ${DOCKER_VERSION}${NC}"

# Check Docker daemon
if ! docker info &> /dev/null; then
    echo -e "${RED}❌ Docker daemon not running. Please start Docker Desktop${NC}"
    exit 1
fi
echo -e "${GREEN}✓ Docker daemon running${NC}"

# Setup environment
echo -e "${YELLOW}\n[2/8] Setting up environment configuration...${NC}"

if [ ! -f ".env" ]; then
    echo "Creating .env file..."
    cat > .env << 'EOF'
# Database Configuration
DATABASE_URL="postgresql://pozmixal-user:pozmixal-password@localhost:5432/pozmixal-db-local"
DATABASE_DIRECT_URL="postgresql://pozmixal-user:pozmixal-password@localhost:5432/pozmixal-db-local"

# Redis Configuration
REDIS_URL="redis://localhost:6379"

# JWT Secret
JWT_SECRET="dev-jwt-secret-change-in-production-$(date +%s)"

# URL Configuration
FRONTEND_URL="http://localhost:4200"
NEXT_PUBLIC_BACKEND_URL="http://localhost:3000"
BACKEND_URL="http://localhost:3000"
BACKEND_INTERNAL_URL="http://localhost:3000"

# Development Settings
ALLOW_ALL_FEATURES="true"
NODE_ENV="development"
STORAGE_PROVIDER="local"

# Optional: Social Media API Keys (add your own)
X_API_KEY=""
X_API_SECRET=""
LINKEDIN_CLIENT_ID=""
LINKEDIN_CLIENT_SECRET=""
EOF
    echo -e "${GREEN}✓ .env file created${NC}"
else
    echo -e "${GREEN}✓ .env file already exists${NC}"
fi

# Start Docker services
echo -e "${YELLOW}\n[3/8] Starting Docker services (PostgreSQL, Redis)...${NC}"

# Check if services are already running
if docker ps | grep -q "pozmixal-postgres"; then
    echo -e "${GREEN}✓ PostgreSQL already running${NC}"
else
    echo "Starting PostgreSQL..."
    docker compose -f docker-compose.dev.yaml up -d pozmixal-postgres
    echo -e "${GREEN}✓ PostgreSQL started${NC}"
    sleep 3
fi

if docker ps | grep -q "pozmixal-redis"; then
    echo -e "${GREEN}✓ Redis already running${NC}"
else
    echo "Starting Redis..."
    docker compose -f docker-compose.dev.yaml up -d pozmixal-redis
    echo -e "${GREEN}✓ Redis started${NC}"
fi

# Optional: Start pgAdmin and RedisInsight
echo "Starting optional services (pgAdmin on 8081, RedisInsight on 8001)..."
docker compose -f docker-compose.dev.yaml up -d pozmixal-pg-admin pozmixal-redisinsight 2>/dev/null || true

# Install dependencies
echo -e "${YELLOW}\n[4/8] Installing dependencies with pnpm...${NC}"

if [ ! -d "node_modules" ]; then
    echo "Running pnpm install (this may take a few minutes)..."
    pnpm install --frozen-lockfile 2>&1 | tail -20
    echo -e "${GREEN}✓ Dependencies installed${NC}"
else
    echo -e "${GREEN}✓ Dependencies already installed${NC}"
fi

# Generate Prisma Client
echo -e "${YELLOW}\n[5/8] Generating Prisma client...${NC}"

pnpm run prisma-generate
echo -e "${GREEN}✓ Prisma client generated${NC}"

# Wait for PostgreSQL to be ready
echo -e "${YELLOW}\n[6/8] Waiting for PostgreSQL to be ready...${NC}"

for i in {1..30}; do
    if docker exec pozmixal-postgres pg_isready -U pozmixal-user &> /dev/null; then
        echo -e "${GREEN}✓ PostgreSQL is ready${NC}"
        break
    fi
    if [ $i -eq 30 ]; then
        echo -e "${RED}❌ PostgreSQL failed to start${NC}"
        exit 1
    fi
    echo "Waiting... ($i/30)"
    sleep 1
done

# Run database migrations
echo -e "${YELLOW}\n[7/8] Running database migrations...${NC}"

pnpm run prisma-db-push
echo -e "${GREEN}✓ Database migrations complete${NC}"

# Display startup information
echo -e "${YELLOW}\n[8/8] Starting Pozmixal application...${NC}"

echo -e "${BLUE}
╔════════════════════════════════════════════════════════════════╗
║                  SETUP COMPLETE - STARTING SERVICES            ║
╠════════════════════════════════════════════════════════════════╣
║                                                                 ║
║  The following services will start:                            ║
║                                                                 ║
║  🌐 Frontend  (Next.js)       http://localhost:4200            ║
║  🔧 Backend   (NestJS)        http://localhost:3000            ║
║  🗄️  Database  (PostgreSQL)    localhost:5432                  ║
║  💾 Cache     (Redis)         localhost:6379                   ║
║  📊 pgAdmin   (Database UI)   http://localhost:8081            ║
║  📊 RedisInsight              http://localhost:8001            ║
║                                                                 ║
║  Credentials:                                                   ║
║  - DB User: pozmixal-user                                      ║
║  - DB Pass: pozmixal-password                                  ║
║  - pgAdmin: admin@admin.com / admin                            ║
║                                                                 ║
╚════════════════════════════════════════════════════════════════╝
${NC}"

# Start all services in parallel
pnpm run dev

echo -e "${GREEN}✓ All services started successfully!${NC}"
