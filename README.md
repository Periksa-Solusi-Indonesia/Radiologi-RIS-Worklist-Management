# Periksa Radiologi RIS - Deployment Guide

Complete Radiology Information System (RIS) dengan Orthanc PACS Server dan Django Worklist Management.

## 📋 Table of Contents

- [Overview](#overview)
- [System Requirements](#system-requirements)
- [Quick Start](#quick-start)
- [Configuration](#configuration)
- [Services & Ports](#services--ports)
- [Backup & Restore](#backup--restore)
- [Troubleshooting](#troubleshooting)
- [Security](#security)
- [Updates](#updates)

## 🎯 Overview

Sistem ini terdiri dari beberapa komponen:

- **Orthanc PACS** - DICOM server untuk storage dan viewing
- **Worklist Web** - Django web application untuk manage DICOM worklist
- **PostgreSQL** - Database untuk Orthanc dan Worklist
- **PGWeb** - Web-based database viewer

## 💻 System Requirements

### Minimum Requirements
- Docker Engine 20.10+
- Docker Compose 2.0+
- 4GB RAM
- 20GB free disk space
- Linux/macOS/Windows with WSL2

### Recommended
- 8GB RAM atau lebih
- 50GB+ disk space untuk DICOM storage
- CPU dengan 4+ cores

## 🚀 Quick Start

### 1. Preparation

```bash
# Clone atau download folder deployment ini
cd deployment
```

### 2. Configuration

```bash
# Copy environment template
cp .env.example .env

# Edit configuration (optional)
nano .env
```

**⚠️ IMPORTANT untuk Production:**
- Ubah semua password defaults
- Generate Django secret key baru
- Set `DJANGO_DEBUG=False`
- Konfigurasi `DJANGO_ALLOWED_HOSTS`

### 3. Start Services

```bash
# Start all services
docker-compose up -d

# Check service status
docker-compose ps

# View logs
docker-compose logs -f
```

### 4. Verify Installation

Tunggu sekitar 30-60 detik untuk semua services fully started, kemudian akses:

- **Worklist Web**: http://localhost:8000 (admin/admin)
- **Orthanc PACS**: http://localhost:8042
- **PGWeb**: http://localhost:8081

## ⚙️ Configuration

### Environment Variables

Edit file `.env` untuk customize configuration:

```bash
# Database
POSTGRES_PASSWORD=your-secure-password

# Django Admin
DJANGO_SUPERUSER_USERNAME=admin
DJANGO_SUPERUSER_PASSWORD=your-admin-password
DJANGO_SECRET_KEY=your-secret-key-here
DJANGO_DEBUG=False
DJANGO_ALLOWED_HOSTS=your-domain.com

# Image Version
WORKLIST_IMAGE_TAG=latest  # atau specific version: v1.0.0

# Satu Sehat (Optional)
SATUSEHAT_ORG_ID=your-org-id
SATUSEHAT_CLIENT=your-client-id
SATUSEHAT_SECRET=your-client-secret
```

### Generate Django Secret Key

```bash
python -c "from django.core.management.utils import get_random_secret_key; print(get_random_secret_key())"
```

### Orthanc Configuration

Edit `config/orthanc.json` untuk:
- Authentication settings
- DICOM modalities
- Port configuration
- Storage limits

**Enable Authentication:**
```json
{
  "AuthenticationEnabled": true,
  "RegisteredUsers": {
    "admin": "password"
  }
}
```

## 🌐 Services & Ports

| Service | Internal Port | External Port | Description |
|---------|--------------|---------------|-------------|
| **Worklist Web** | 8000 | 8000 | Django web application |
| **Orthanc PACS** | 8042 | 8042 | PACS Web UI & REST API |
| **Orthanc DICOM** | 4242 | 4242 | DICOM protocol (C-STORE, C-FIND) |
| **PostgreSQL** | 5432 | 5432 | Database server |
| **PGWeb** | 8081 | 8081 | Database web viewer |

### Custom Ports

Edit `docker-compose.yml` jika port conflict:

```yaml
services:
  worklist-web:
    ports:
      - "8001:8000"  # Change 8000 to 8001
```

## 💾 Backup & Restore

### Automatic Backup

```bash
# Run backup manually
docker-compose --profile backup run --rm backup /scripts/backup.sh

# Schedule daily backup (crontab)
0 2 * * * cd /path/to/deployment && docker-compose --profile backup run --rm backup /scripts/backup.sh >> backup.log 2>&1
```

Backup files will be stored in `./backups/` directory.

### Manual Database Backup

```bash
# Backup PostgreSQL
docker-compose exec postgresql pg_dump -U orthanc orthanc > backup_$(date +%Y%m%d).sql

# Backup with compression
docker-compose exec postgresql pg_dump -U orthanc orthanc | gzip > backup_$(date +%Y%m%d).sql.gz
```

### Restore Database

```bash
# Stop services
docker-compose down

# Restore from backup
cat backup_20231201.sql | docker-compose run --rm postgresql psql -U orthanc -h postgresql orthanc

# Or from compressed backup
gunzip -c backup_20231201.sql.gz | docker-compose run --rm postgresql psql -U orthanc -h postgresql orthanc

# Restart services
docker-compose up -d
```

### Backup Docker Volumes

```bash
# Create backup directory
mkdir -p volume-backups

# Backup volumes
docker run --rm \
  -v deployment_orthanc-data:/data \
  -v $(pwd)/volume-backups:/backup \
  alpine tar czf /backup/orthanc-data-$(date +%Y%m%d).tar.gz -C /data .

docker run --rm \
  -v deployment_postgres-data:/data \
  -v $(pwd)/volume-backups:/backup \
  alpine tar czf /backup/postgres-data-$(date +%Y%m%d).tar.gz -C /data .
```

### Restore Volumes

```bash
# Restore volumes
docker run --rm \
  -v deployment_orthanc-data:/data \
  -v $(pwd)/volume-backups:/backup \
  alpine tar xzf /backup/orthanc-data-20231201.tar.gz -C /data
```

## 🔧 Troubleshooting

### Check Service Logs

```bash
# All services
docker-compose logs -f

# Specific service
docker-compose logs -f worklist-web
docker-compose logs -f orthanc
docker-compose logs -f postgresql
```

### Service Won't Start

```bash
# Check service status
docker-compose ps

# Restart specific service
docker-compose restart worklist-web

# Restart all services
docker-compose restart
```

### Database Connection Issues

```bash
# Check PostgreSQL is healthy
docker-compose exec postgresql pg_isready -U orthanc

# Check connection from worklist-web
docker-compose exec worklist-web python manage.py dbshell
```

### Port Already in Use

```bash
# Find process using port
lsof -i :8000
netstat -tulpn | grep 8000

# Kill process
kill -9 <PID>

# Or change port in docker-compose.yml
```

### Reset Everything

```bash
# Stop and remove everything (INCLUDING DATA!)
docker-compose down -v

# Restart fresh
docker-compose up -d
```

### View Container Resources

```bash
# Real-time resource usage
docker stats

# Disk usage
docker system df
```

## 🔒 Security

### Production Checklist

- [ ] Change all default passwords
- [ ] Generate new Django secret key
- [ ] Set `DJANGO_DEBUG=False`
- [ ] Configure `DJANGO_ALLOWED_HOSTS` properly
- [ ] Enable Orthanc authentication
- [ ] Setup HTTPS/SSL certificate
- [ ] Configure firewall rules
- [ ] Regular backup schedule
- [ ] Update images regularly
- [ ] Monitor logs for suspicious activity

### Enable HTTPS

Gunakan reverse proxy (Nginx/Traefik) dengan Let's Encrypt:

```yaml
# Example with Traefik
services:
  traefik:
    image: traefik:v2.10
    command:
      - "--certificatesresolvers.letsencrypt.acme.email=your@email.com"
    ports:
      - "443:443"
      - "80:80"
```

### Firewall Configuration

```bash
# Allow only necessary ports
ufw allow 22/tcp   # SSH
ufw allow 80/tcp   # HTTP
ufw allow 443/tcp  # HTTPS
ufw enable
```

## 🔄 Updates

### Update Docker Images

```bash
# Pull latest images
docker-compose pull

# Restart with new images
docker-compose up -d

# Remove old images
docker image prune
```

### Update Specific Service

```bash
# Update worklist-web only
docker-compose pull worklist-web
docker-compose up -d worklist-web
```

### Update Configuration

```bash
# Edit configuration
nano .env
nano config/orthanc.json

# Apply changes
docker-compose up -d
```

## 📚 Additional Resources

### Documentation
- [Orthanc Documentation](https://book.orthanc-server.com/)
- [Django Documentation](https://docs.djangoproject.com/)
- [Docker Compose Documentation](https://docs.docker.com/compose/)

### Worklist Management
- Access Worklist Web at http://localhost:8000
- Create/edit/delete DICOM worklists via web interface
- Export worklists to Orthanc automatically

### DICOM Integration
- Configure modalities di Orthanc web UI
- Send images: `C-STORE` to `ORTHANC:4242`
- Query worklists: `C-FIND` to `ORTHANC:4242`

### API Access
- Orthanc REST API: http://localhost:8042/app/explorer.html
- Django REST API: http://localhost:8000/api/
- API documentation: http://localhost:8000/api/docs/

## 🆘 Support

Untuk bantuan:
1. Check troubleshooting section di atas
2. Review logs: `docker-compose logs -f`
3. Buka issue di GitHub repository
4. Check dokumentasi Orthanc dan Django

## 📄 License

Sesuai dengan license project utama.

---

**Made with ❤️ for Indonesian Healthcare**
