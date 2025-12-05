@echo off
title Pozmixal Production Deployment
color 0A

echo ================================================
echo   POZMIXAL PRODUCTION DEPLOYMENT
echo   Quick Start Guide
echo ================================================

echo.
echo Select your production deployment strategy:
echo.
echo 1. Vercel + Railway (RECOMMENDED)
echo    - Frontend on Vercel (CDN, automatic scaling)
echo    - Backend on Railway (managed infrastructure)
echo    - Cost: ~$30-60/month
echo.
echo 2. Full Docker Deployment
echo    - Complete containerized deployment
echo    - Self-hosted or cloud VPS
echo    - Cost: ~$20-100/month (depending on provider)
echo.
echo 3. Railway Full Stack
echo    - Everything on Railway platform
echo    - Simplified management
echo    - Cost: ~$40-80/month
echo.
echo 4. Environment Setup Only
echo    - Configure environment variables
echo    - Prepare for manual deployment
echo.
echo 5. View Documentation
echo    - Open deployment guides
echo.

set /p choice="Enter your choice (1-5): "

if "%choice%"=="1" goto vercel_railway
if "%choice%"=="2" goto docker_deployment
if "%choice%"=="3" goto railway_full
if "%choice%"=="4" goto env_setup
if "%choice%"=="5" goto documentation
goto invalid_choice

:vercel_railway
echo.
echo ================================================
echo   VERCEL + RAILWAY DEPLOYMENT
echo ================================================
echo.
echo Step 1: Frontend to Vercel
echo --------------------------
echo 1. Install Vercel CLI: npm install -g vercel
echo 2. Login: vercel login
echo 3. Deploy: vercel --prod
echo 4. Configure custom domain (optional)
echo.
echo Step 2: Backend to Railway
echo --------------------------
echo 1. Install Railway CLI: npm install -g @railway/cli
echo 2. Login: railway login
echo 3. Create project: railway new
echo 4. Add PostgreSQL: railway add --database postgresql
echo 5. Add Redis: railway add --database redis
echo 6. Deploy: railway up
echo.
echo Step 3: Environment Variables
echo ----------------------------
echo Configure these in both Vercel and Railway:
echo - FRONTEND_URL (Vercel domain)
echo - NEXT_PUBLIC_BACKEND_URL (Railway domain)
echo - JWT_SECRET (generate strong secret)
echo - Database URLs (Railway provides these)
echo - OAuth keys for social media
echo - Stripe keys for payments
echo - Email service keys
echo.
echo 📖 Full guide: VERCEL_DEPLOYMENT.md
echo 📖 Backend guide: RAILWAY_BACKEND_DEPLOYMENT.md
goto end

:docker_deployment
echo.
echo ================================================
echo   DOCKER DEPLOYMENT
echo ================================================
echo.
echo Prerequisites:
echo - Docker and Docker Compose installed
echo - SSL certificates (Let's Encrypt recommended)
echo - Domain name configured
echo.
echo Step 1: Build Production Images
echo ------------------------------
echo docker-compose -f docker-compose.production.yaml build
echo.
echo Step 2: Configure Environment
echo ---------------------------
echo Copy .env.production and configure all variables
echo.
echo Step 3: Start Services
echo --------------------
echo docker-compose -f docker-compose.production.yaml up -d
echo.
echo Step 4: Setup SSL
echo ----------------
echo Configure nginx with SSL certificates
echo.
echo 📖 Full guide: docker-compose.production.yaml
echo 📖 Environment guide: .env.production
goto end

:railway_full
echo.
echo ================================================
echo   RAILWAY FULL STACK
echo ================================================
echo.
echo Step 1: Setup Railway Project
echo ----------------------------
echo 1. railway login
echo 2. railway new pozmixal
echo 3. railway add --database postgresql
echo 4. railway add --database redis
echo.
echo Step 2: Deploy Services
echo ---------------------
echo 1. railway up (deploys all services)
echo 2. Configure environment variables
echo 3. Set custom domains
echo.
echo Step 3: Configure Scaling
echo -----------------------
echo 1. Scale backend: railway scale backend --replicas 2
echo 2. Monitor performance
echo 3. Adjust resources as needed
echo.
echo 📖 Full guide: RAILWAY_BACKEND_DEPLOYMENT.md
goto end

:env_setup
echo.
echo ================================================
echo   ENVIRONMENT SETUP
echo ================================================
echo.
echo Creating production environment template...
echo.

echo # ==============================================  > .env.production.local
echo # POZMIXAL PRODUCTION ENVIRONMENT >> .env.production.local
echo # CONFIGURE ALL VALUES BEFORE DEPLOYMENT >> .env.production.local
echo # ============================================== >> .env.production.local
echo. >> .env.production.local
echo # Core Application >> .env.production.local
echo NODE_ENV=production >> .env.production.local
echo FRONTEND_URL=https://your-domain.com >> .env.production.local
echo NEXT_PUBLIC_BACKEND_URL=https://api.your-domain.com >> .env.production.local
echo. >> .env.production.local
echo # Security >> .env.production.local
echo JWT_SECRET=CHANGE-THIS-TO-SECURE-SECRET >> .env.production.local
echo NOT_SECURED=false >> .env.production.local
echo. >> .env.production.local
echo # Database >> .env.production.local
echo DATABASE_URL=postgresql://user:password@host:port/database >> .env.production.local
echo REDIS_URL=redis://host:port >> .env.production.local
echo. >> .env.production.local
echo # Storage >> .env.production.local
echo STORAGE_PROVIDER=cloudflare >> .env.production.local
echo S3_BUCKET=your-bucket-name >> .env.production.local
echo S3_ACCESS_KEY=your-access-key >> .env.production.local
echo S3_SECRET_KEY=your-secret-key >> .env.production.local
echo. >> .env.production.local
echo # Add your other environment variables... >> .env.production.local

echo ✅ Created .env.production.local template
echo.
echo Next steps:
echo 1. Edit .env.production.local with your actual values
echo 2. Generate secure JWT secret: 
echo    node -e "console.log(require('crypto').randomBytes(64).toString('base64'))"
echo 3. Configure your chosen deployment platform
echo 4. Set environment variables in your platform
echo.
goto end

:documentation
echo.
echo ================================================
echo   OPENING DOCUMENTATION
echo ================================================
echo.
echo Available deployment guides:
echo.
start "" "PRODUCTION_DEPLOYMENT_GUIDE.md"
start "" "VERCEL_DEPLOYMENT.md" 
start "" "RAILWAY_BACKEND_DEPLOYMENT.md"
start "" "PRODUCTION_ENVIRONMENT_SETUP.md"
echo.
echo Documentation opened in your default editor.
goto end

:invalid_choice
echo.
echo ❌ Invalid choice. Please select 1-5.
echo.
pause
goto start

:end
echo.
echo ================================================
echo   DEPLOYMENT PREPARATION COMPLETE
echo ================================================
echo.
echo Your Pozmixal application is ready for production!
echo.
echo 📊 Estimated production costs:
echo   - Vercel + Railway: $30-60/month
echo   - Docker VPS: $20-100/month
echo   - Railway Full: $40-80/month
echo.
echo 🔧 Next steps:
echo 1. Choose deployment method
echo 2. Configure environment variables
echo 3. Set up domains and SSL
echo 4. Configure monitoring
echo 5. Launch your application!
echo.
echo 📖 All guides are ready in your project directory.
echo.
pause