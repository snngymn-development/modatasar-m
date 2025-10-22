#!/bin/bash

# Deneme1 Backup Script
# Creates backups of database and important files

set -e

BACKUP_DIR="backups"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
BACKUP_NAME="deneme1_backup_$TIMESTAMP"

echo "📦 Creating backup: $BACKUP_NAME"

# Create backup directory
mkdir -p "$BACKUP_DIR/$BACKUP_NAME"

# Database backup
echo "🗄️ Backing up database..."
docker-compose exec -T postgres pg_dump -U postgres deneme1 > "$BACKUP_DIR/$BACKUP_NAME/database.sql"

# Backup important files
echo "📁 Backing up important files..."
cp -r backend/api/prisma/migrations "$BACKUP_DIR/$BACKUP_NAME/" 2>/dev/null || true
cp backend/api/prisma/schema.prisma "$BACKUP_DIR/$BACKUP_NAME/" 2>/dev/null || true
cp docker-compose.yml "$BACKUP_DIR/$BACKUP_NAME/" 2>/dev/null || true
cp -r ops "$BACKUP_DIR/$BACKUP_NAME/" 2>/dev/null || true

# Create backup info file
cat > "$BACKUP_DIR/$BACKUP_NAME/backup_info.txt" << EOF
Deneme1 Backup Information
=========================
Backup Date: $(date)
Backup Name: $BACKUP_NAME
Database: PostgreSQL
Files: Migrations, Schema, Docker Compose, Ops
EOF

# Compress backup
echo "🗜️ Compressing backup..."
cd "$BACKUP_DIR"
tar -czf "${BACKUP_NAME}.tar.gz" "$BACKUP_NAME"
rm -rf "$BACKUP_NAME"
cd ..

# Show backup info
BACKUP_SIZE=$(du -h "$BACKUP_DIR/${BACKUP_NAME}.tar.gz" | cut -f1)
echo "✅ Backup completed!"
echo "📦 Backup file: $BACKUP_DIR/${BACKUP_NAME}.tar.gz"
echo "📏 Backup size: $BACKUP_SIZE"

# Cleanup old backups (keep last 7 days)
echo "🧹 Cleaning up old backups..."
find "$BACKUP_DIR" -name "deneme1_backup_*.tar.gz" -mtime +7 -delete 2>/dev/null || true

echo "🎉 Backup process completed successfully!"
