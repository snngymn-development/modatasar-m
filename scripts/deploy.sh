#!/bin/bash

# Deneme1 Deployment Script
# Usage: ./deploy.sh [staging|production]

set -e

ENVIRONMENT=${1:-staging}
PROJECT_NAME="deneme1"
DOCKER_COMPOSE_FILE="docker-compose.yml"

echo "🚀 Starting deployment to $ENVIRONMENT environment..."

# Check if environment is valid
if [[ "$ENVIRONMENT" != "staging" && "$ENVIRONMENT" != "production" ]]; then
    echo "❌ Invalid environment. Use 'staging' or 'production'"
    exit 1
fi

# Set environment-specific variables
if [[ "$ENVIRONMENT" == "production" ]]; then
    DOCKER_COMPOSE_FILE="ops/deploy/prod/docker-compose.yml"
    echo "🔒 Deploying to PRODUCTION environment"
else
    DOCKER_COMPOSE_FILE="ops/deploy/staging/docker-compose.yml"
    echo "🧪 Deploying to STAGING environment"
fi

# Check if Docker Compose file exists
if [[ ! -f "$DOCKER_COMPOSE_FILE" ]]; then
    echo "❌ Docker Compose file not found: $DOCKER_COMPOSE_FILE"
    exit 1
fi

# Backup current deployment (if exists)
if docker-compose -f "$DOCKER_COMPOSE_FILE" ps -q | grep -q .; then
    echo "📦 Creating backup..."
    docker-compose -f "$DOCKER_COMPOSE_FILE" exec -T postgres pg_dump -U postgres deneme1 > "backup_$(date +%Y%m%d_%H%M%S).sql" || true
fi

# Pull latest images
echo "📥 Pulling latest images..."
docker-compose -f "$DOCKER_COMPOSE_FILE" pull

# Build and start services
echo "🔨 Building and starting services..."
docker-compose -f "$DOCKER_COMPOSE_FILE" up -d --build

# Wait for services to be ready
echo "⏳ Waiting for services to be ready..."
sleep 30

# Run database migrations
echo "🗄️ Running database migrations..."
docker-compose -f "$DOCKER_COMPOSE_FILE" exec -T api npx prisma migrate deploy || true

# Health check
echo "🏥 Performing health checks..."
API_URL="http://localhost:3001"
WEB_URL="http://localhost:3000"

if [[ "$ENVIRONMENT" == "production" ]]; then
    API_URL="https://api.deneme1.com"
    WEB_URL="https://deneme1.com"
fi

# Check API health
if curl -f "$API_URL/health" > /dev/null 2>&1; then
    echo "✅ API is healthy"
else
    echo "❌ API health check failed"
    exit 1
fi

# Check Web health
if curl -f "$WEB_URL" > /dev/null 2>&1; then
    echo "✅ Web application is healthy"
else
    echo "❌ Web application health check failed"
    exit 1
fi

# Show deployment status
echo "📊 Deployment Status:"
docker-compose -f "$DOCKER_COMPOSE_FILE" ps

echo "🎉 Deployment to $ENVIRONMENT completed successfully!"
echo "🌐 Web: $WEB_URL"
echo "🔌 API: $API_URL"

# Send notification (if configured)
if [[ -n "$SLACK_WEBHOOK_URL" ]]; then
    curl -X POST -H 'Content-type: application/json' \
        --data "{\"text\":\"✅ Deneme1 deployed successfully to $ENVIRONMENT environment\"}" \
        "$SLACK_WEBHOOK_URL" || true
fi
