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
- **DICOM Kemenkes** - DICOM Router untuk integrasi Satu Sehat

## 💻 System Requirements

### Minimum
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

### 1. Start Services

```bash
cd Radiologi_RIS
docker-compose up -d
```

### 2. Verify Installation

Tunggu 30-60 detik, kemudian akses:

- **Worklist Web**: http://localhost:8000 (admin/admin)
- **Orthanc PACS**: http://localhost:8042
- **PGWeb**: http://localhost:8081

Lihat [QUICKSTART.md](QUICKSTART.md) untuk panduan lengkap.

## ⚙️ Configuration

### Environment Variables

Edit environment langsung di `docker-compose.yml`, atau buat `.env` file:

```bash
# Database
POSTGRES_PASSWORD=your-secure-password

# Django Admin
DJANGO_SUPERUSER_USERNAME=admin
DJANGO_SUPERUSER_PASSWORD=your-admin-password
DJANGO_SECRET_KEY=your-secret-key-here
DJANGO_DEBUG=False
DJANGO_ALLOWED_HOSTS=your-domain.com

# Satu Sehat
SATUSEHAT_ORG_ID=your-org-id
SATUSEHAT_CLIENT=your-client-id
SATUSEHAT_SECRET=your-client-secret
```

**⚠️ IMPORTANT untuk Production:**
- Ubah semua password defaults
- Generate Django secret key baru
- Set `DJANGO_DEBUG=False`
- Konfigurasi `DJANGO_ALLOWED_HOSTS`

### Generate Django Secret Key

```bash
python -c "from django.core.management.utils import get_random_secret_key; print(get_random_secret_key())"
```

### Orthanc Configuration

Edit `containers/orthanc/config/orthanc.json` untuk:
- Authentication settings
- DICOM modalities
- Port configuration
- Storage limits

## 🌐 Services & Ports

| Service | Port | Description |
|---------|------|-------------|
| **Worklist Web** | 8000 | Django web application |
| **Orthanc PACS** | 8042 | PACS Web UI & REST API |
| **Orthanc DICOM** | 4242 | DICOM protocol (C-STORE, C-FIND) |
| **PostgreSQL** | 5432 | Database server |
| **PGWeb** | 8081 | Database web viewer |
| **DICOM Kemenkes** | 11112, 8080 | DICOM Router Satu Sehat |

### Custom Ports

Edit `docker-compose.yml` jika port conflict:

```yaml
services:
  worklist-web:
    ports:
      - "8001:8000"  # Change 8000 to 8001
```

## 💾 Backup & Restore

### Run Backup

```bash
# Manual backup
docker-compose --profile backup run --rm backup /scripts/backup.sh

# Schedule daily backup (crontab)
0 2 * * * cd /path/to/project && docker-compose --profile backup run --rm backup /scripts/backup.sh >> backup.log 2>&1
```

Backup files disimpan di `./containers/backup/data/`.

### Manual Database Backup

```bash
# Backup PostgreSQL
docker-compose exec postgresql pg_dump -U orthanc orthanc > backup_$(date +%Y%m%d).sql

# Backup with compression
docker-compose exec postgresql pg_dump -U orthanc orthanc | gzip > backup_$(date +%Y%m%d).sql.gz
```

### Restore Database

```bash
docker-compose down
cat backup_20231201.sql | docker-compose run --rm postgresql psql -U orthanc -h postgresql orthanc
docker-compose up -d
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
docker-compose ps
docker-compose restart worklist-web
```

### Database Connection Issues

```bash
docker-compose exec postgresql pg_isready -U orthanc
```

### Port Already in Use

```bash
lsof -i :8000
kill -9 <PID>
```

### Reset Everything

```bash
# Stop and remove everything (INCLUDING DATA!)
docker-compose down -v
docker-compose up -d
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

## 🔄 Updates

```bash
# Pull latest images
docker-compose pull

# Restart with new images
docker-compose up -d

# Remove old images
docker image prune
```

## 📚 Additional Resources

- [Orthanc Documentation](https://book.orthanc-server.com/)
- [Django Documentation](https://docs.djangoproject.com/)
- [Docker Compose Documentation](https://docs.docker.com/compose/)

### DICOM Integration
- Send images: `C-STORE` to `ORTHANC:4242`
- Query worklists: `C-FIND` to `ORTHANC:4242`

### API Access
- Orthanc REST API: http://localhost:8042/app/explorer.html
- Django REST API: http://localhost:8000/api/

---

**Made with ❤️ for Indonesian Healthcare**
