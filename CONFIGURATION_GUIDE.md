# Pozmixal Configuration & Setup Guide

This guide explains how to obtain every API key and credential required to run Pozmixal in production.

## 1. Core & Security
- **`JWT_SECRET`**: We have generated one for you in the `.env.production` file. If you need a new one, run `openssl rand -base64 32` in your terminal.
- **`NEXT_PUBLIC_APP_URL`**: This is your domain. On Vercel, this will be `https://your-project.vercel.app` initially, then your custom domain (e.g., `https://app.pozmixal.com`).

## 2. Database (PostgreSQL)
You need a PostgreSQL database. We recommend **Neon**, **Supabase**, or **Railway**.
1.  **Create a Project** on [Neon.tech](https://neon.tech) or [Supabase.com](https://supabase.com).
2.  **Get Connection String**: Look for the "Connection String" or "Database URL".
3.  **Format**: It should look like `postgres://user:password@ep-xyz.region.neon.tech/dbname?sslmode=require`.
4.  **Paste** into `DATABASE_URL`.

## 3. Queue (Redis)
You need a Redis instance for background jobs. We recommend **Upstash**.
1.  **Sign up** at [Upstash.com](https://upstash.com).
2.  **Create Database**: Name it `pozmixal-redis`.
3.  **Get URL**: Copy the `UPSTASH_REDIS_REST_URL` (or the standard connection string).
4.  **Format**: `redis://:password@fly-xyz.upstash.io:6379`.
5.  **Paste** into `REDIS_URL`.

## 4. File Storage (S3 / R2)
You need object storage for images/videos. We recommend **Cloudflare R2** (cheaper/faster) or **AWS S3**.

### Option A: Cloudflare R2 (Recommended)
1.  Go to Cloudflare Dashboard > **R2**.
2.  **Create Bucket**: Name it `pozmixal-assets`.
3.  **Manage R2 API Tokens**: Create a new token with "Edit" permissions.
4.  **Copy Details**:
    -   `S3_ACCESS_KEY` = Access Key ID
    -   `S3_SECRET_KEY` = Secret Access Key
    -   `S3_ENDPOINT` = `https://<account_id>.r2.cloudflarestorage.com`
5.  **Paste** into the respective env vars.

### Option B: AWS S3
1.  Go to AWS Console > **S3**.
2.  **Create Bucket**: Uncheck "Block all public access" (or configure CloudFront).
3.  Go to **IAM** > Users > Create User > Attach `AmazonS3FullAccess`.
4.  **Create Access Key** for that user.
5.  **Paste** keys into env vars.

## 5. Authentication (Social Login)
You need to create "Apps" on each developer platform to allow users to login/post.

### X (Twitter)
1.  Go to [X Developer Portal](https://developer.twitter.com/en/portal/dashboard).
2.  **Create Project & App**.
3.  **User Authentication Settings**:
    -   App Type: **Web App**.
    -   Callback URL: `https://app.pozmixal.com/api/auth/callback/twitter`.
4.  **Keys**: Copy `Client ID` and `Client Secret`.

### LinkedIn
1.  Go to [LinkedIn Developers](https://www.linkedin.com/developers/).
2.  **Create App**.
3.  **Products**: Request access to "Sign In with LinkedIn" and "Share on LinkedIn".
4.  **Auth**: Add Redirect URL: `https://app.pozmixal.com/api/auth/callback/linkedin`.
5.  **Keys**: Copy `Client ID` and `Client Secret`.

### Facebook / Instagram
1.  Go to [Meta Developers](https://developers.facebook.com/).
2.  **Create App** (Type: Business).
3.  **Add Products**: "Facebook Login for Business".
4.  **Settings**: Add Redirect URL: `https://app.pozmixal.com/api/auth/callback/facebook`.
5.  **Keys**: Copy `App ID` and `App Secret`.

*(Repeat similar steps for other networks like TikTok, Slack, etc. using the callback pattern: `.../api/auth/callback/[provider]`)*

## 6. Payments (Stripe)
1.  Go to [Stripe Dashboard](https://dashboard.stripe.com/).
2.  **Developers > API Keys**: Copy `Secret Key` and `Publishable Key`.
3.  **Developers > Webhooks**:
    -   Add Endpoint: `https://app.pozmixal.com/api/webhooks/stripe`.
    -   Select Events: `checkout.session.completed`, `invoice.paid`, `customer.subscription.updated`.
    -   Copy `Signing Secret` (`whsec_...`).

## 7. AI (OpenAI)
1.  Go to [OpenAI Platform](https://platform.openai.com/).
2.  **API Keys**: Create new secret key.
3.  **Paste** into `OPENAI_API_KEY`.

---
**Deployment Checklist:**
1.  Fill in all variables in `.env.production`.
2.  Go to Vercel > Project Settings > Environment Variables.
3.  Copy-paste the entire content of `.env.production` (Vercel supports pasting the whole file content).
4.  Hit **Deploy**.
