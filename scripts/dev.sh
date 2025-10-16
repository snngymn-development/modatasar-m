#!/bin/bash

# Deneme1 Development Environment Setup Script
# This script sets up the complete development environment

set -e

echo "🚀 Starting Deneme1 Development Environment Setup..."

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

# Check if required tools are installed
check_requirements() {
    print_status "Checking requirements..."
    
    # Check Node.js
    if ! command -v node &> /dev/null; then
        print_error "Node.js is not installed. Please install Node.js 18+ first."
        exit 1
    fi
    
    # Check npm
    if ! command -v npm &> /dev/null; then
        print_error "npm is not installed. Please install npm first."
        exit 1
    fi
    
    # Check Docker
    if ! command -v docker &> /dev/null; then
        print_warning "Docker is not installed. Some features may not work."
    fi
    
    # Check Flutter
    if ! command -v flutter &> /dev/null; then
        print_warning "Flutter is not installed. Mobile development will not work."
    fi
    
    print_success "Requirements check completed."
}

# Install dependencies
install_dependencies() {
    print_status "Installing dependencies..."
    
    # Install root dependencies
    npm install
    
    # Install workspace dependencies
    npm run install:all
    
    print_success "Dependencies installed successfully."
}

# Setup environment files
setup_environment() {
    print_status "Setting up environment files..."
    
    # Copy .env.example files
    if [ ! -f "backend/api/.env" ]; then
        cp backend/api/.env.example backend/api/.env
        print_success "Created backend/api/.env"
    fi
    
    if [ ! -f "frontend/web/.env" ]; then
        cp frontend/web/.env.example frontend/web/.env
        print_success "Created frontend/web/.env"
    fi
    
    print_success "Environment files setup completed."
}

# Setup database
setup_database() {
    print_status "Setting up database..."
    
    # Start PostgreSQL with Docker
    if command -v docker &> /dev/null; then
        docker-compose -f ops/docker/docker-compose.minimal.yml up -d postgres
        sleep 5
        print_success "PostgreSQL started with Docker."
    else
        print_warning "Docker not available. Please start PostgreSQL manually."
    fi
    
    # Generate Prisma client
    cd backend/api
    npm run db:generate
    npm run db:migrate
    cd ../..
    
    print_success "Database setup completed."
}

# Start development servers
start_servers() {
    print_status "Starting development servers..."
    
    # Start all services
    npm run dev:minimal
    
    print_success "Development servers started successfully."
    print_status "Access points:"
    echo "  🌐 Web App: http://localhost:3001"
    echo "  🔧 API: http://localhost:3000"
    echo "  📱 Mobile: Run 'flutter run' in frontend/mobile"
    echo "  📊 Monitoring: http://localhost:3000/health"
}

# Main execution
main() {
    echo "=========================================="
    echo "  DENEME1 DEVELOPMENT ENVIRONMENT SETUP"
    echo "=========================================="
    echo ""
    
    check_requirements
    install_dependencies
    setup_environment
    setup_database
    start_servers
    
    echo ""
    echo "=========================================="
    print_success "Development environment is ready!"
    echo "=========================================="
    echo ""
    echo "Next steps:"
    echo "1. Open http://localhost:3001 in your browser"
    echo "2. Check API health at http://localhost:3000/health"
    echo "3. Run 'flutter run' in frontend/mobile for mobile app"
    echo "4. Check logs with 'npm run docker:logs'"
    echo ""
    echo "Happy coding! 🎉"
}

# Run main function
main "$@"
