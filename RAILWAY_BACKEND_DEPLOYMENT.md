# 🚂 RAILWAY BACKEND DEPLOYMENT GUIDE

## 📋 **RAILWAY FULL-STACK DEPLOYMENT**

Railway is perfect for your backend because:
- ✅ Automatic Docker builds from your existing Dockerfile
- ✅ Integrated PostgreSQL database
- ✅ Redis addon available
- ✅ Environment variable management
- ✅ Automatic deployments from Git

## 🚀 **STEP-BY-STEP DEPLOYMENT**

### **Step 1: Railway Setup**

```bash
# Install Railway CLI
npm install -g @railway/cli

# Login to Railway
railway login

# Initialize project
railway init
```

### **Step 2: Create Railway Project Structure**

```bash
# Create new project
railway new

# Project name: pozmixal-backend
# Template: Empty Project
```

### **Step 3: Add Services**

```bash
# Add PostgreSQL database
railway add --database postgresql

# Add Redis
railway add --database redis

# Deploy backend application
railway up
```

### **Step 4: Configure Railway Services**

Create `railway.toml` (already exists, but optimize it):

```toml
[build]
builder = "nixpacks"
buildCommand = "pnpm install && pnpm run build:backend"

[deploy]
healthcheckPath = "/health"
healthcheckTimeout = 300
restartPolicyType = "always"

# Backend Service
[[services]]
name = "backend"
source = "apps/backend"
buildCommand = "pnpm install && pnpm run build"
startCommand = "pnpm run start:prod:backend"

[services.variables]
NODE_ENV = "production"
PORT = "3000"

# Workers Service
[[services]]
name = "workers"
source = "apps/workers"
buildCommand = "pnpm install && pnpm run build:workers"
startCommand = "pnpm run start:prod:workers"

# Cron Service
[[services]]
name = "cron"
source = "apps/cron"
buildCommand = "pnpm install && pnpm run build:cron"
startCommand = "pnpm run start:prod:cron"
```

### **Step 5: Environment Variables**

Set these in Railway Dashboard → Your Project → Variables:

```bash
# Core Application
NODE_ENV=production
PORT=3000
FRONTEND_URL=https://your-vercel-domain.vercel.app

# Database (Railway will provide these automatically)
DATABASE_URL=${{Postgres.DATABASE_URL}}
REDIS_URL=${{Redis.REDIS_URL}}

# Security
JWT_SECRET=your-super-secure-jwt-secret
NOT_SECURED=false

# Storage
STORAGE_PROVIDER=cloudflare
S3_BUCKET=your-bucket-name
S3_REGION=auto
S3_ENDPOINT=https://your-account-id.r2.cloudflarestorage.com
S3_ACCESS_KEY=your-access-key
S3_SECRET_KEY=your-secret-key

# Email
RESEND_API_KEY=your-resend-key
EMAIL_FROM_ADDRESS=noreply@pozmixal.com
EMAIL_FROM_NAME=Pozmixal

# AI Services
OPENAI_API_KEY=your-openai-key
FAL_KEY=your-fal-key

# Payments
STRIPE_SECRET_KEY=your-stripe-secret-key
STRIPE_WEBHOOK_SECRET=your-stripe-webhook-secret

# Social Media OAuth
TWITTER_CLIENT_ID=your-twitter-client-id
TWITTER_CLIENT_SECRET=your-twitter-client-secret
LINKEDIN_CLIENT_ID=your-linkedin-client-id
LINKEDIN_CLIENT_SECRET=your-linkedin-client-secret
FACEBOOK_APP_ID=your-facebook-app-id
FACEBOOK_APP_SECRET=your-facebook-app-secret
# ... add other OAuth credentials

# Analytics
SENTRY_DSN=your-sentry-dsn
NEXT_PUBLIC_POSTHOG_KEY=your-posthog-key
```

### **Step 6: Custom Domain & SSL**

1. Go to Railway Dashboard → Your Project → Settings → Networking
2. Add custom domain: `api.pozmixal.com`
3. Configure DNS CNAME record: `api.pozmixal.com` → `your-app.railway.app`
4. SSL is automatically provisioned

### **Step 7: Database Setup**

Railway automatically provisions PostgreSQL. To run migrations:

```bash
# Connect to Railway database
railway connect Postgres

# Run migrations (from local machine)
railway run pnpm run prisma-db-push
```

---

## 🔧 **RAILWAY OPTIMIZATION**

### **Resource Configuration**

```toml
# Add to railway.toml
[deploy]
healthcheckPath = "/health"
healthcheckTimeout = 300
restartPolicyType = "always"

# Resource limits
[deploy.resources]
memory = "4GB"
cpu = "2"
```

### **Build Optimization**

```toml
[build]
builder = "nixpacks"
buildCommand = "pnpm install --frozen-lockfile && pnpm run prisma-generate && pnpm run build"

[build.environment]
NODE_OPTIONS = "--max-old-space-size=6144"
NODE_ENV = "production"
NIXPACKS_NODE_VERSION = "20"
```

---

## 📊 **MONITORING & SCALING**

### **Health Checks**
Railway automatically monitors your `/health` endpoint

### **Scaling**
```bash
# Scale backend service
railway scale backend --replicas 2

# Scale workers
railway scale workers --replicas 1
```

### **Logs & Monitoring**
```bash
# View logs
railway logs

# Monitor specific service
railway logs backend

# Real-time logs
railway logs --follow
```

---

## ✅ **RAILWAY DEPLOYMENT CHECKLIST**

- [ ] Railway CLI installed and authenticated
- [ ] Project created with PostgreSQL and Redis
- [ ] Environment variables configured
- [ ] Custom domain configured (optional)
- [ ] Database migrations run
- [ ] Health checks configured
- [ ] Monitoring enabled
- [ ] Scaling configured
- [ ] Backup strategy implemented

---

## 🔄 **CONTINUOUS DEPLOYMENT**

Railway automatically deploys when you push to your connected Git branch:

```bash
# Connect GitHub repository
railway link

# Set up auto-deploy from main branch
# This is configured in Railway Dashboard → Settings → GitHub
```

---

## 💰 **PRICING OPTIMIZATION**

Railway provides:
- $5/month for hobby projects
- Pay-as-you-go for resources
- PostgreSQL: $5/month
- Redis: $5/month

Estimated monthly cost for production Pozmixal:
- Backend service: $20-50/month
- PostgreSQL: $5/month  
- Redis: $5/month
- **Total: ~$30-60/month**