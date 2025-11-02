# Zammad Production Deployment

## 🚀 Quick Start

```bash
# Deploy to production
sudo ./deploy.sh
```

## 📁 Directory Structure

```
production/
├── docker-compose.yml    # Production Docker Compose configuration
├── .env                 # Environment variables
├── deploy.sh            # Deployment script
├── README.md            # This file
└── data/                # Bind mounted data directories
    ├── postgresql/      # PostgreSQL data
    ├── elasticsearch/   # Elasticsearch data
    ├── redis/           # Redis data
    ├── zammad-storage/  # Zammad file storage
    └── zammad-backup/   # Backup data
```

## 🔧 Configuration

### Environment Variables (.env)
- **Domain:** `ir.codesec.in`
- **Database:** PostgreSQL with secure password
- **Elasticsearch:** Enabled for reporting
- **Network:** Connected to `nginxproxy_nginx_proxy`

### Bind Mounts
All data is stored in local directories for easy backup and migration:
- `./data/postgresql` → PostgreSQL data
- `./data/elasticsearch` → Elasticsearch indices
- `./data/redis` → Redis data
- `./data/zammad-storage` → Zammad files
- `./data/zammad-backup` → Backup files

## 🌐 NPM Configuration

**Use these settings in Nginx Proxy Manager:**
- **Domain:** `ir.codesec.in`
- **Forward IP:** `172.18.0.19:8080` (check with `docker network inspect nginxproxy_nginx_proxy`)
- **Port:** `8080`
- **SSL:** Enable Let's Encrypt

## 🔍 Monitoring

```bash
# Check container status
docker-compose ps

# View logs
docker-compose logs -f

# Test connectivity
curl -I http://localhost:8080
curl http://localhost:9200/_cluster/health
```

## 🔄 Maintenance

```bash
# Update Zammad
docker-compose pull
docker-compose up -d

# Backup data
tar -czf zammad-backup-$(date +%Y%m%d).tar.gz data/

# Restore data
tar -xzf zammad-backup-YYYYMMDD.tar.gz
```

## 🛡️ Security

- Change default admin password immediately
- Use strong database password
- Enable firewall rules
- Regular backups
- Keep Zammad updated

## 📞 Support

- **Zammad Docs:** https://docs.zammad.org/
- **Container Logs:** `docker-compose logs [service-name]`
- **Network:** `docker network inspect nginxproxy_nginx_proxy`
