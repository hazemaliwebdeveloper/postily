# 🚀 Postiz Development Guide

## Quick Start

### For Windows Users
```bash
# Option 1: Batch file (simplest)
START_DEV.bat

# Option 2: PowerShell
powershell -ExecutionPolicy Bypass -File START_DEV.ps1

# Option 3: Manual (see below)
```

### For Mac/Linux Users
```bash
# Start all services
pnpm run dev
```

## Project Overview

**Postiz** is a social media scheduling and analytics platform built with:
- **Frontend**: Next.js (React + TypeScript) on port 4200
- **Backend**: NestJS on port 3000
- **Database**: PostgreSQL
- **Cache**: Redis
- **Extension**: Chrome extension for content creators
- **Queue**: BullMQ for background jobs

## Key Files & Directories

| Path | Purpose |
|------|---------|
| `apps/backend/` | NestJS API server |
| `apps/frontend/` | Next.js web application |
| `apps/extension/` | Chrome browser extension |
| `apps/cron/` | Scheduled tasks |
| `apps/workers/` | Background job processor |
| `libraries/nestjs-libraries/src/database/prisma/` | Database schema |
| `.env` | Environment configuration |

## Important Commands

### Installation & Database
```bash
# Install all dependencies
pnpm install

# Generate Prisma Client
pnpm run prisma-generate

# Sync database with schema
pnpm run prisma-db-push

# Reset database completely
pnpm run prisma-reset
```

### Development
```bash
# Run all services (parallel)
pnpm run dev

# Run individual services
pnpm --filter ./apps/backend run dev
pnpm --filter ./apps/frontend run dev
pnpm --filter ./apps/extension run dev:chrome
pnpm --filter ./apps/workers run dev
pnpm --filter ./apps/cron run dev
```

### Build & Testing
```bash
# Build all apps
pnpm run build

# Build only extension
pnpm run build:extension
# OR
pnpm --filter ./apps/extension run build:chrome

# Run tests
pnpm test

# Run specific tests
pnpm --filter ./apps/backend test
```

## Extension Development

### Build the Extension
```bash
# Development build (Chrome)
pnpm --filter ./apps/extension run build:chrome

# Firefox build
pnpm --filter ./apps/extension run build:firefox

# Watch mode (rebuilds on changes)
pnpm --filter ./apps/extension run dev:chrome
```

### Load in Chrome
1. Open `chrome://extensions`
2. Enable "Developer mode" (top right toggle)
3. Click "Load unpacked"
4. Select folder: `apps/extension/dist/`

### Key Extension Files
- `apps/extension/src/pages/background/index.ts` - Service worker (handles messages)
- `apps/extension/src/pages/popup/Popup.tsx` - Popup UI
- `apps/extension/src/pages/content/` - Content scripts (injected into web pages)
- `apps/extension/src/utils/chrome-message.wrapper.ts` - Retry logic for messaging

## Database

### Schema Location
`libraries/nestjs-libraries/src/database/prisma/schema.prisma`

### Common Operations
```bash
# View current schema
cat libraries/nestjs-libraries/src/database/prisma/schema.prisma

# Push schema to database
pnpm run prisma-db-push

# Generate migrations
pnpm run prisma-migrate-dev

# Open Prisma Studio (visual database explorer)
pnpm run prisma-studio
```

## Environment Setup

### Required Services
- PostgreSQL (port 5432)
- Redis (port 6379)
- Node.js 22

### Docker Commands
```bash
# Start all services with Docker Compose
docker compose -f ./docker-compose.dev.yaml up -d

# Stop services
docker compose -f ./docker-compose.dev.yaml down

# View logs
docker compose -f ./docker-compose.dev.yaml logs -f
```

### Environment Variables
All configured in `.env`:
- `FRONTEND_URL=http://localhost:4200`
- `BACKEND_URL=http://localhost:3000`
- `DATABASE_URL=postgresql://...`
- `REDIS_URL=redis://localhost:6379`

## Troubleshooting

### Service Won't Start
```bash
# Clear cache and reinstall
pnpm install

# Rebuild specific service
pnpm --filter ./apps/backend run build

# Check for port conflicts
# Port 3000 (backend) or 4200 (frontend) already in use?
```

### Extension Not Loading
```bash
# Rebuild extension
pnpm --filter ./apps/extension run build:chrome

# Check manifest.json
cat apps/extension/dist/manifest.json

# View Service Worker logs
# chrome://extensions → Postiz → "Service Worker"
```

### Database Issues
```bash
# Check PostgreSQL connection
# Ensure DATABASE_URL in .env is correct

# Reset database
pnpm run prisma-reset

# Generate Prisma Client
pnpm run prisma-generate
```

### Extension Messaging Errors
See: `EXTENSION_DEBUG.md` for detailed debugging guide

## Code Conventions

### Commits
Use conventional commits:
```bash
git commit -m "feat: add new feature"
git commit -m "fix: resolve issue"
git commit -m "chore: update dependencies"
```

### Code Style
- TypeScript for all new code
- React functional components with hooks
- NestJS with dependency injection
- Comments for complex logic only
- No console.logs in production code (use Sentry logger)

### Logging
In NestJS:
```typescript
import * as Sentry from "@sentry/nextjs";
const { logger } = Sentry;

logger.info("User logged in", { userId: 123 });
logger.error("Failed to fetch data", { error: err });
```

In Extension:
```javascript
console.log('[Service Worker] Message received');
if (isDevelopment) {
  console.log('[Debug] Detailed info:', data);
}
```

## PR Checklist

Before submitting a PR:
- [ ] Code builds without errors
- [ ] Tests pass (`pnpm test`)
- [ ] No new console.logs in production code
- [ ] Comments added for complex logic
- [ ] Environment variables updated in `.env.example`
- [ ] Related issue linked in description
- [ ] Screenshots/GIFs for UI changes

## Performance Tips

### Frontend
- Use React.memo for expensive components
- Lazy load routes with dynamic imports
- Check bundle size: `npm run build:frontend`

### Backend
- Use database indexes for common queries
- Implement pagination for large result sets
- Cache frequently accessed data in Redis

### Extension
- Minimize service worker work
- Use message batching for multiple requests
- Keep popup lightweight

## Useful Resources

- **Docs**: https://docs.postiz.com/
- **Developer Guide**: https://docs.postiz.com/developer-guide
- **Public API**: https://docs.postiz.com/public-api
- **Prisma Docs**: https://www.prisma.io/docs/
- **NestJS Docs**: https://docs.nestjs.com/
- **Next.js Docs**: https://nextjs.org/docs

## Getting Help

### If Something Breaks
1. Check the relevant debug guide:
   - Extension issues: `EXTENSION_DEBUG.md`
   - Setup issues: `SETUP_LOCAL.md`
   - Deployment: `DEPLOYMENT_VALIDATION_CHECKLIST.md`

2. Run `pnpm install` to ensure dependencies are up to date

3. Rebuild the component that's failing:
   ```bash
   pnpm --filter ./apps/[component] run build
   ```

4. Check logs in the appropriate terminal or DevTools

5. Ask for help with context:
   - Error message (exact text)
   - What you were doing when it happened
   - Relevant console/terminal output
   - Which service(s) are affected

## Next Steps for New Developers

1. ✅ Clone the repository
2. ✅ Run `pnpm install`
3. ✅ Setup `.env` (already configured)
4. ✅ Start PostgreSQL and Redis
5. ✅ Run `pnpm run prisma-db-push`
6. ✅ Run `pnpm run dev` or use `START_DEV.bat`
7. ✅ Load extension in Chrome
8. ✅ Start developing!

Happy coding! 🚀
