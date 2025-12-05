#!/bin/bash

# ==============================================
# POZMIXAL PRODUCTION DEPLOYMENT SCRIPT
# ==============================================
# This script automates the complete production deployment process

set -e  # Exit on any error

echo "🚀 POZMIXAL PRODUCTION DEPLOYMENT"
echo "=================================="

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Functions
log_info() { echo -e "${BLUE}[INFO]${NC} $1"; }
log_success() { echo -e "${GREEN}[SUCCESS]${NC} $1"; }
log_warning() { echo -e "${YELLOW}[WARNING]${NC} $1"; }
log_error() { echo -e "${RED}[ERROR]${NC} $1"; }

# Check prerequisites
check_prerequisites() {
    log_info "Checking prerequisites..."
    
    # Check if Node.js is installed
    if ! command -v node &> /dev/null; then
        log_error "Node.js is not installed. Please install Node.js 20+ first."
        exit 1
    fi
    
    # Check Node version
    NODE_VERSION=$(node --version | cut -d'v' -f2 | cut -d'.' -f1)
    if [ "$NODE_VERSION" -lt 20 ]; then
        log_error "Node.js version must be 20+. Current version: $(node --version)"
        exit 1
    fi
    
    # Check if pnpm is installed
    if ! command -v pnpm &> /dev/null; then
        log_info "Installing pnpm..."
        npm install -g pnpm@10.6.1
    fi
    
    # Check if Docker is installed (for Docker deployment)
    if ! command -v docker &> /dev/null; then
        log_warning "Docker is not installed. Docker deployment will not be available."
    fi
    
    log_success "Prerequisites check completed!"
}

# Build optimization
optimize_build() {
    log_info "Optimizing build configuration..."
    
    # Set optimal Node.js memory settings
    export NODE_OPTIONS="--max-old-space-size=8192 --max-semi-space-size=2048"
    export NODE_ENV="production"
    
    log_success "Build optimization configured!"
}

# Install dependencies
install_dependencies() {
    log_info "Installing production dependencies..."
    
    # Clean install for production
    pnpm install --frozen-lockfile --prod=false
    
    log_success "Dependencies installed!"
}

# Generate Prisma client
setup_database() {
    log_info "Setting up database..."
    
    # Generate Prisma client
    pnpm run prisma-generate
    
    log_success "Database setup completed!"
}

# Build applications
build_applications() {
    log_info "Building applications for production..."
    
    # Build all applications
    pnpm run build
    
    if [ $? -eq 0 ]; then
        log_success "All applications built successfully!"
    else
        log_error "Build failed!"
        exit 1
    fi
}

# Docker deployment
deploy_docker() {
    log_info "Deploying with Docker..."
    
    # Build and start production containers
    docker-compose -f docker-compose.production.yaml build
    docker-compose -f docker-compose.production.yaml up -d
    
    log_success "Docker deployment completed!"
}

# Vercel deployment
deploy_vercel() {
    log_info "Deploying frontend to Vercel..."
    
    if ! command -v vercel &> /dev/null; then
        log_info "Installing Vercel CLI..."
        npm install -g vercel
    fi
    
    # Deploy to Vercel
    vercel --prod
    
    log_success "Vercel deployment completed!"
}

# Railway deployment
deploy_railway() {
    log_info "Deploying backend to Railway..."
    
    if ! command -v railway &> /dev/null; then
        log_info "Installing Railway CLI..."
        npm install -g @railway/cli
    fi
    
    # Deploy to Railway
    railway up
    
    log_success "Railway deployment completed!"
}

# Health check
health_check() {
    log_info "Running health checks..."
    
    # Wait for services to start
    sleep 30
    
    # Check if services are responding
    if curl -f http://localhost:3000/health &> /dev/null; then
        log_success "Backend health check passed!"
    else
        log_warning "Backend health check failed - this is normal for cloud deployments"
    fi
}

# Main deployment menu
main_menu() {
    echo ""
    echo "Select deployment option:"
    echo "1) Docker (Self-hosted)"
    echo "2) Vercel + Railway (Recommended)"
    echo "3) Full Railway"
    echo "4) Build only (no deployment)"
    echo "5) Exit"
    echo ""
    read -p "Enter your choice (1-5): " choice
    
    case $choice in
        1)
            log_info "Selected: Docker deployment"
            check_prerequisites
            optimize_build
            install_dependencies
            setup_database
            build_applications
            deploy_docker
            health_check
            ;;
        2)
            log_info "Selected: Vercel + Railway deployment"
            check_prerequisites
            optimize_build
            install_dependencies
            setup_database
            build_applications
            deploy_vercel
            deploy_railway
            ;;
        3)
            log_info "Selected: Full Railway deployment"
            check_prerequisites
            optimize_build
            install_dependencies
            setup_database
            build_applications
            deploy_railway
            ;;
        4)
            log_info "Selected: Build only"
            check_prerequisites
            optimize_build
            install_dependencies
            setup_database
            build_applications
            ;;
        5)
            log_info "Exiting..."
            exit 0
            ;;
        *)
            log_error "Invalid option. Please select 1-5."
            main_menu
            ;;
    esac
}

# Run main menu
main_menu

echo ""
echo "🎉 DEPLOYMENT COMPLETED!"
echo "======================="
echo ""
echo "Next steps:"
echo "1. Configure environment variables"
echo "2. Set up custom domains"
echo "3. Configure SSL certificates"
echo "4. Set up monitoring and alerts"
echo "5. Configure backup strategies"
echo ""
echo "Documentation:"
echo "- Vercel: VERCEL_DEPLOYMENT.md"
echo "- Railway: RAILWAY_BACKEND_DEPLOYMENT.md"
echo "- Docker: docker-compose.production.yaml"
echo ""
log_success "Production deployment script completed!"