# Quick Start Guide

Get your Radiology Information System running in 5 minutes!

## Prerequisites

- Docker Desktop installed ([Download here](https://www.docker.com/products/docker-desktop))
- 4GB+ RAM available
- 10GB+ free disk space

## Installation Steps

### 1️⃣ Download

```bash
git clone https://github.com/your-org/Radiologi_RIS.git
cd Radiologi_RIS
```

### 2️⃣ Start

```bash
docker-compose up -d

# Wait for services to be ready (30-60 seconds)
docker-compose ps
```

### 3️⃣ Access

| Service | URL | Credentials |
|---------|-----|-------------|
| **Worklist Web** | http://localhost:8000 | `admin` / `admin` |
| **Orthanc PACS** | http://localhost:8042 | - |
| **Database Viewer** | http://localhost:8081 | - |

## Basic Usage

### Create a Worklist

1. Open http://localhost:8000
2. Login dengan `admin` / `admin`
3. Click "Add Worklist"
4. Fill in patient information
5. Click "Save"

### DICOM Integration

Configure your DICOM modality:

- **AE Title:** `ORTHANC`
- **Host:** Your server IP
- **Port:** `4242`

Worklist query dan image send menggunakan address yang sama.

View received images at: http://localhost:8042

## Stop Services

```bash
# Stop all services
docker-compose down

# Stop and remove all data (reset)
docker-compose down -v
```

## Backup

```bash
docker-compose --profile backup run --rm backup /scripts/backup.sh
```

Backups saved to `./containers/backup/data/` folder.

## Update

```bash
docker-compose pull
docker-compose up -d
```

## Troubleshooting

### Services not starting?

```bash
docker-compose logs -f
```

### Can't access web interface?

1. Wait 60 seconds for services to fully start
2. Check: `docker-compose ps` — all should be "healthy"
3. Try: `docker-compose restart`

### Port already in use?

Edit `docker-compose.yml` and change the port:
```yaml
ports:
  - "8001:8000"  # Changed from 8000 to 8001
```

## Next Steps

- **Production Setup:** Read [README.md](README.md) for security configuration
- **Integration:** Configure your DICOM modality to connect
- **Backup:** Setup automatic daily backups

---

**Happy imaging! 🏥📸**
