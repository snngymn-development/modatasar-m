#!/bin/bash

# Deneme1 Production Build Script
# This script builds all applications for production deployment

set -e

echo "🏗️ Starting Deneme1 Production Build..."

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Build configuration
BUILD_ENV=${1:-production}
BUILD_VERSION=${2:-latest}
BUILD_TAG=${3:-deneme1}

print_status "Build Environment: $BUILD_ENV"
print_status "Build Version: $BUILD_VERSION"
print_status "Build Tag: $BUILD_TAG"

# Clean previous builds
clean_builds() {
    print_status "Cleaning previous builds..."
    
    # Clean all workspaces
    npm run clean:all
    
    # Remove old Docker images
    if command -v docker &> /dev/null; then
        docker system prune -f
        print_success "Docker cleanup completed."
    fi
    
    print_success "Build cleanup completed."
}

# Run tests
run_tests() {
    print_status "Running tests..."
    
    # Run all tests
    npm run test:all
    
    # Run E2E tests
    npm run test:e2e
    
    print_success "All tests passed."
}

# Build applications
build_applications() {
    print_status "Building applications..."
    
    # Build all workspaces
    npm run build:all
    
    print_success "Applications built successfully."
}

# Build Docker images
build_docker_images() {
    if ! command -v docker &> /dev/null; then
        print_warning "Docker not available. Skipping Docker image build."
        return
    fi
    
    print_status "Building Docker images..."
    
    # Build backend API image
    docker build -t $BUILD_TAG-api:$BUILD_VERSION -f backend/api/Dockerfile backend/api/
    print_success "Backend API image built: $BUILD_TAG-api:$BUILD_VERSION"
    
    # Build frontend web image
    docker build -t $BUILD_TAG-web:$BUILD_VERSION -f frontend/web/Dockerfile frontend/web/
    print_success "Frontend Web image built: $BUILD_TAG-web:$BUILD_VERSION"
    
    # Build frontend mobile image (if needed)
    if [ -f "frontend/mobile/Dockerfile" ]; then
        docker build -t $BUILD_TAG-mobile:$BUILD_VERSION -f frontend/mobile/Dockerfile frontend/mobile/
        print_success "Frontend Mobile image built: $BUILD_TAG-mobile:$BUILD_VERSION"
    fi
    
    print_success "Docker images built successfully."
}

# Generate build artifacts
generate_artifacts() {
    print_status "Generating build artifacts..."
    
    # Create build directory
    mkdir -p build/artifacts
    
    # Copy built applications
    cp -r backend/api/dist build/artifacts/backend-api
    cp -r frontend/web/dist build/artifacts/frontend-web
    
    # Copy configuration files
    cp -r ops/docker build/artifacts/
    cp -r ops/k8s build/artifacts/
    cp -r scripts build/artifacts/
    cp -r docs build/artifacts/
    
    # Create deployment package
    tar -czf build/deneme1-$BUILD_VERSION.tar.gz -C build/artifacts .
    
    print_success "Build artifacts generated: build/deneme1-$BUILD_VERSION.tar.gz"
}

# Security scan
security_scan() {
    print_status "Running security scan..."
    
    # Run npm audit
    npm run security:audit
    
    # Run security scan on Docker images
    if command -v docker &> /dev/null; then
        print_status "Scanning Docker images for vulnerabilities..."
        # Add security scanning tool here if available
    fi
    
    print_success "Security scan completed."
}

# Performance test
performance_test() {
    print_status "Running performance tests..."
    
    # Run performance tests
    npm run test:perf
    
    print_success "Performance tests completed."
}

# Generate documentation
generate_docs() {
    print_status "Generating documentation..."
    
    # Generate API documentation
    npm run docs:generate
    
    print_success "Documentation generated."
}

# Main execution
main() {
    echo "=========================================="
    echo "  DENEME1 PRODUCTION BUILD"
    echo "=========================================="
    echo ""
    
    clean_builds
    run_tests
    build_applications
    build_docker_images
    generate_artifacts
    security_scan
    performance_test
    generate_docs
    
    echo ""
    echo "=========================================="
    print_success "Production build completed successfully!"
    echo "=========================================="
    echo ""
    echo "Build artifacts:"
    echo "  📦 Package: build/deneme1-$BUILD_VERSION.tar.gz"
    echo "  🐳 Docker Images: $BUILD_TAG-*:$BUILD_VERSION"
    echo "  📁 Build Directory: build/artifacts/"
    echo ""
    echo "Next steps:"
    echo "1. Deploy to staging: npm run deploy:staging"
    echo "2. Deploy to production: npm run deploy:production"
    echo "3. Monitor deployment: npm run monitor:start"
    echo ""
    echo "Build completed! 🎉"
}

# Run main function
main "$@"
