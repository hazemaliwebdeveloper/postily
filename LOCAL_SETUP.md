# Local Development Setup

## Prerequisites

- **Node.js**: 22+ (already verified)
- **pnpm**: 8+ (package manager)
- **Docker**: For PostgreSQL and Redis (already installed)
- **Docker Desktop**: Must be running

## Setup Steps

### 1. Start Docker Containers

Ensure Docker Desktop is running, then start PostgreSQL and Redis:

```bash
docker compose -f docker-compose.dev.yaml up -d
```

This will start:
- **PostgreSQL**: `localhost:5432`
- **Redis**: `localhost:6379`

### 2. Install Dependencies

```bash
pnpm install
```

This may take 5-10 minutes on first install.

### 3. Generate Prisma Client

```bash
pnpm run prisma-generate
```

### 4. Initialize Database

```bash
pnpm run prisma-db-push
```

This will create all necessary database tables.

### 5. Start Development Servers

```bash
pnpm run dev
```

This starts all services in parallel:
- **Frontend**: `http://localhost:4200` (Next.js)
- **Backend**: `http://localhost:3000` (NestJS API)
- **Workers**: Background job processor
- **Cron**: Scheduled tasks
- **Extension**: Browser extension dev server

## Environment Variables

A `.env` file has been created with default local development settings.

**Key variables**:
- `DATABASE_URL`: PostgreSQL connection string
- `REDIS_URL`: Redis connection URL
- `FRONTEND_URL`: Frontend URL (`http://localhost:4200`)
- `NEXT_PUBLIC_BACKEND_URL`: Backend API URL (`http://localhost:3000`)

## Verify Setup

Check if services are running:

```bash
docker ps  # See running containers
docker compose logs  # View logs
pnpm run dev  # Check dev server output
```

## Troubleshooting

### Docker Desktop not running
```bash
# Start Docker Desktop or use:
# Windows: Press Start, search for "Docker Desktop"
# Mac: Applications > Docker
```

### Database connection errors
```bash
# Reset database (⚠️ will delete all data)
pnpm run prisma-reset

# Or manually with psql:
# psql -U postiz-user -d postiz-db-local -c "DROP SCHEMA public CASCADE; CREATE SCHEMA public;"
```

### Port conflicts
If ports 3000, 4200, or 6379 are in use:
- Change ports in `.env`
- Or kill existing processes using those ports

### Installation timeout
If `pnpm install` times out:
```bash
# Resume installation
pnpm install --no-frozen-lockfile
```

## Next Steps

1. Open `http://localhost:4200` in your browser
2. Create an account or login
3. Connect social media channels to test functionality

## Development Commands

```bash
pnpm run dev              # Start all services
pnpm run dev:frontend     # Frontend only
pnpm run dev:backend      # Backend only
pnpm run build            # Build for production
pnpm test                 # Run tests
pnpm run lint             # Check code quality
```
