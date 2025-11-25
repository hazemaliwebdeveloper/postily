# Pozmixal Vercel Deployment Guide

**Version:** 1.0.0
**Target:** Vercel (Pro/Enterprise)

## 1. Vercel Project Setup

1.  **Import Repository:** Connect your GitHub account and import the `pozmixal` repository.
2.  **Framework Preset:** Select `Next.js`.
3.  **Root Directory:** Leave as `./` (Root). **Do NOT change this to apps/frontend**.
    *   *Note:* The `vercel.json` file in the root handles the directory switching during the build process.
4.  **Build Command:** `cd apps/frontend && pnpm build` (Should auto-fill from vercel.json).
5.  **Output Directory:** `apps/frontend/.next` (Should auto-fill from vercel.json).
6.  **Install Command:** `pnpm install --no-frozen-lockfile` (Should auto-fill from vercel.json).

## 2. Environment Variables (Required)

Go to **Settings > Environment Variables** and add the following:

### Core
*   `NODE_ENV`: `production`
*   `NEXT_PUBLIC_APP_URL`: `https://app.pozmixal.com` (Your Vercel Domain)
*   `FRONTEND_URL`: `https://app.pozmixal.com` (**CRITICAL** for middleware)
*   `NEXT_PUBLIC_API_URL`: `https://api.pozmixal.com` (Your Backend URL)

### Security & Auth
*   `JWT_SECRET`: `[Generate a random 32-char string]`
*   `NOT_SECURED`: `false` (**CRITICAL** for secure cookies)
*   `POSTIZ_GENERIC_OAUTH`: `false`

### Database & Infrastructure
*   `DATABASE_URL`: `postgres://user:pass@host:port/dbname?sslmode=require` (Use a pooled connection string if possible)
*   `REDIS_URL`: `redis://:pass@host:port`

### Storage (S3/R2)
*   `STORAGE_PROVIDER`: `s3`
*   `S3_ENDPOINT`: `https://[account-id].r2.cloudflarestorage.com`
*   `S3_BUCKET`: `pozmixal-assets`
*   `S3_ACCESS_KEY`: `[Your Access Key]`
*   `S3_SECRET_KEY`: `[Your Secret Key]`
*   `S3_REGION`: `auto`

### Third-Party
*   `STRIPE_SECRET_KEY`: `sk_live_...`
*   `STRIPE_WEBHOOK_SECRET`: `whsec_...`
*   `OPENAI_API_KEY`: `sk-...`

## 3. Post-Deployment Verification

1.  **Check Health:** Visit your domain. The app should load.
2.  **Check Auth:** Attempt to sign up/login.
3.  **Check Assets:** Upload an image to verify S3 connection.
4.  **Check Logs:** Look for any 500 errors in the Vercel dashboard.

---
**Troubleshooting:**
If the build fails with "module not found", ensure `pnpm-workspace.yaml` is correctly configured and all dependencies are listed in `package.json`.
