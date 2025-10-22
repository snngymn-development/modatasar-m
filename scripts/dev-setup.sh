#!/bin/bash

# Deneme1 Development Setup Script
# This script sets up the development environment

set -e

echo "🚀 Setting up Deneme1 development environment..."

# Check if pnpm is installed
if ! command -v pnpm &> /dev/null; then
    echo "📦 Installing pnpm..."
    npm install -g pnpm
fi

# Check if Docker is installed
if ! command -v docker &> /dev/null; then
    echo "❌ Docker is not installed. Please install Docker first."
    exit 1
fi

# Check if Docker Compose is installed
if ! command -v docker-compose &> /dev/null; then
    echo "❌ Docker Compose is not installed. Please install Docker Compose first."
    exit 1
fi

# Install dependencies
echo "📦 Installing dependencies..."
pnpm install

# Build packages
echo "🔨 Building packages..."
pnpm --filter @deneme1/core build
pnpm --filter @deneme1/shared build

# Start database services
echo "🗄️ Starting database services..."
docker-compose up -d postgres redis

# Wait for database to be ready
echo "⏳ Waiting for database to be ready..."
sleep 10

# Run database migrations
echo "🗄️ Running database migrations..."
cd backend/api
npx prisma migrate dev --name init || true
npx prisma generate
cd ../..

# Seed database
echo "🌱 Seeding database..."
cd backend/api
npx prisma db seed || true
cd ../..

# Start development servers
echo "🎯 Starting development servers..."

# Start API in background
echo "🔌 Starting API server..."
cd backend/api
pnpm run start:dev &
API_PID=$!
cd ../..

# Start Web in background
echo "🌐 Starting Web server..."
cd frontend/web
pnpm run dev &
WEB_PID=$!
cd ../..

# Function to cleanup on exit
cleanup() {
    echo "🛑 Shutting down servers..."
    kill $API_PID 2>/dev/null || true
    kill $WEB_PID 2>/dev/null || true
    docker-compose down
    exit 0
}

# Set trap to cleanup on script exit
trap cleanup EXIT INT TERM

echo "✅ Development environment is ready!"
echo "🌐 Web: http://localhost:5173"
echo "🔌 API: http://localhost:3001"
echo "📊 API Docs: http://localhost:3001/docs"
echo "🗄️ Database: localhost:5432"
echo ""
echo "Press Ctrl+C to stop all services"

# Wait for user to stop
wait
