# 🚀 VERCEL DEPLOYMENT GUIDE

## 📋 **VERCEL FRONTEND DEPLOYMENT**

### **Step 1: Prepare Vercel Configuration**

Your `vercel.json` is already optimized:
```json
{
  "buildCommand": "cd apps/frontend && pnpm build",
  "outputDirectory": "apps/frontend/.next",
  "framework": "nextjs",
  "installCommand": "pnpm install --frozen-lockfile",
  "env": {
    "NODE_VERSION": "20.x",
    "PACKAGE_MANAGER": "pnpm"
  }
}
```

### **Step 2: Environment Variables Setup**

Add these to your Vercel Project Settings → Environment Variables:

```bash
# Core Application
NODE_ENV=production
NEXT_PUBLIC_APP_URL=https://your-domain.vercel.app
FRONTEND_URL=https://your-domain.vercel.app
NEXT_PUBLIC_BACKEND_URL=https://your-backend-url.railway.app

# Security
JWT_SECRET=your-super-secure-jwt-secret-here
NOT_SECURED=false

# Database (from Railway/Render)
DATABASE_URL=postgresql://user:pass@host:port/db

# Storage (Cloudflare R2 recommended)
STORAGE_PROVIDER=cloudflare
S3_BUCKET=your-bucket-name
S3_REGION=auto
S3_ENDPOINT=https://your-account-id.r2.cloudflarestorage.com
S3_ACCESS_KEY=your-r2-access-key
S3_SECRET_KEY=your-r2-secret-key
CLOUDFLARE_ACCOUNT_ID=your-cloudflare-account-id

# Email Service
RESEND_API_KEY=your-resend-api-key
EMAIL_FROM_ADDRESS=noreply@your-domain.com
EMAIL_FROM_NAME=Pozmixal

# AI Services
OPENAI_API_KEY=your-openai-key
FAL_KEY=your-fal-key

# Payments
STRIPE_SECRET_KEY=your-stripe-secret-key
NEXT_PUBLIC_STRIPE_PUBLISHABLE_KEY=your-stripe-public-key
STRIPE_WEBHOOK_SECRET=your-stripe-webhook-secret

# Analytics
NEXT_PUBLIC_POSTHOG_KEY=your-posthog-key
NEXT_PUBLIC_POSTHOG_HOST=https://app.posthog.com
SENTRY_DSN=your-sentry-dsn
NEXT_PUBLIC_SENTRY_DSN=your-sentry-public-dsn

# Social Media OAuth Keys
TWITTER_CLIENT_ID=your-twitter-client-id
TWITTER_CLIENT_SECRET=your-twitter-client-secret
LINKEDIN_CLIENT_ID=your-linkedin-client-id
LINKEDIN_CLIENT_SECRET=your-linkedin-client-secret
# ... add other social media keys as needed
```

### **Step 3: Deploy to Vercel**

```bash
# Install Vercel CLI
npm i -g vercel

# Login to Vercel
vercel login

# Deploy from project root
vercel

# Follow the prompts:
# ? Set up and deploy "pozmixal"? [Y/n] y
# ? Which scope? Your username/team
# ? Link to existing project? [y/N] n
# ? What's your project's name? pozmixal
# ? In which directory is your code located? ./

# For production deployment
vercel --prod
```

### **Step 4: Custom Domain Setup**

1. Go to Vercel Dashboard → Your Project → Settings → Domains
2. Add your custom domain: `app.pozmixal.com`
3. Configure DNS records as instructed by Vercel
4. Update environment variables with your custom domain

### **Step 5: Optimization Settings**

In Vercel Dashboard → Settings → Functions:
- **Function Timeout**: 60s
- **Memory**: 1024MB (for build optimization)

In Vercel Dashboard → Settings → Build & Output:
- **Node.js Version**: 20.x
- **Build Command**: `cd apps/frontend && pnpm build`
- **Output Directory**: `apps/frontend/.next`

---

## ✅ **VERCEL DEPLOYMENT CHECKLIST**

- [ ] Environment variables configured
- [ ] Custom domain added (optional)
- [ ] Backend URL configured in NEXT_PUBLIC_BACKEND_URL
- [ ] Storage provider configured
- [ ] Payment provider configured
- [ ] Email service configured
- [ ] Analytics configured
- [ ] Social media OAuth configured
- [ ] SSL certificate automatically provisioned
- [ ] CDN automatically configured

---

## 🔧 **TROUBLESHOOTING**

### **Build Errors:**
```bash
# If build fails due to memory issues
# Add to vercel.json:
{
  "functions": {
    "apps/frontend/pages/api/**/*.ts": {
      "memory": 1024
    }
  }
}
```

### **Environment Variable Issues:**
- Check that all required variables are set in Vercel dashboard
- Ensure no trailing spaces in variable values
- Redeploy after adding new variables

### **API Route Issues:**
- Ensure API routes are in `apps/frontend/pages/api/` or `apps/frontend/app/api/`
- Check that backend URL is correctly set

---

## 📊 **PERFORMANCE OPTIMIZATION**

Your frontend is already optimized with:
- ✅ Next.js 15+ with App Router
- ✅ Memory optimization (4GB-8GB allocation)
- ✅ Bundle splitting and optimization
- ✅ Image optimization
- ✅ CSS optimization
- ✅ Tree shaking
- ✅ Compression

Vercel automatically provides:
- ✅ Global CDN (Edge Network)
- ✅ Automatic SSL
- ✅ Image optimization
- ✅ Static file caching
- ✅ Function optimization