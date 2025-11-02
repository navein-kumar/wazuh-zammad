#!/bin/bash

# Zammad Production Deployment Script
set -e

echo "🚀 Starting Zammad Production Deployment..."

# Check if running as root
if [ "$EUID" -ne 0 ]; then
    echo "❌ Please run as root (use sudo)"
    exit 1
fi

# Create data directories with proper permissions
echo "📁 Setting up data directories..."
mkdir -p data/{postgresql,elasticsearch,redis,zammad-storage,zammad-backup}
chmod -R 755 data/
chown -R 1000:1000 data/elasticsearch data/postgresql data/redis data/zammad-storage data/zammad-backup

# Check if nginxproxy_nginx_proxy network exists
echo "🌐 Checking Docker network..."
if ! docker network ls | grep -q nginxproxy_nginx_proxy; then
    echo "❌ nginxproxy_nginx_proxy network not found!"
    echo "Please ensure Nginx Proxy Manager is running and connected to this network."
    exit 1
fi

# Stop any existing containers
echo "🛑 Stopping existing containers..."
docker-compose down 2>/dev/null || true

# Pull latest images
echo "📥 Pulling latest images..."
docker-compose pull

# Start services
echo "🚀 Starting Zammad services..."
docker-compose up -d

# Wait for services to start
echo "⏳ Waiting for services to initialize..."
sleep 30

# Check service status
echo "🔍 Checking service status..."
docker-compose ps

# Test connectivity
echo "🧪 Testing connectivity..."
if curl -f -s http://localhost:8080 > /dev/null; then
    echo "✅ Zammad is responding on port 8080"
else
    echo "❌ Zammad is not responding on port 8080"
    echo "Checking logs..."
    docker-compose logs zammad-nginx --tail=10
fi

# Check Elasticsearch
echo "🔍 Checking Elasticsearch..."
if curl -f -s http://localhost:9200/_cluster/health > /dev/null; then
    echo "✅ Elasticsearch is healthy"
else
    echo "⚠️  Elasticsearch may still be starting up"
fi

echo "🎉 Deployment completed!"
echo ""
echo "📋 Next steps:"
echo "1. Configure NPM with IP: $(docker network inspect nginxproxy_nginx_proxy | grep -A 5 zammad-nginx | grep IPv4Address | cut -d'"' -f4 | head -1)"
#echo "2. Access Zammad at: https://ir.codesec.in"
#echo "3. Default login: admin@example.com / admin"
echo ""
echo "📊 Container status:"
docker-compose ps --format "table {{.Name}}\t{{.Status}}\t{{.Ports}}"
