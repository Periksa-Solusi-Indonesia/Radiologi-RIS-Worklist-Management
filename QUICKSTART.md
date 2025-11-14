# Quick Start Guide

Get your Radiology Information System running in 5 minutes!

## Prerequisites

- Docker Desktop installed ([Download here](https://www.docker.com/products/docker-desktop))
- 4GB+ RAM available
- 10GB+ free disk space

## Installation Steps

### 1️⃣ Download

```bash
# Clone the repository
git clone https://github.com/your-org/Radiologi_RIS.git
cd Radiologi_RIS/deployment
```

Or download and extract the deployment folder.

### 2️⃣ Configure (Optional)

```bash
# Copy environment template
cp .env.example .env

# (Optional) Edit configuration
nano .env
```

**Quick Start:** Bisa skip step ini dan langsung pakai default configuration!

### 3️⃣ Start

```bash
# Start all services
docker-compose up -d

# Wait for services to be ready (30-60 seconds)
docker-compose ps
```

### 4️⃣ Access

**Worklist Management:**
- URL: http://localhost:8000
- Username: `admin`
- Password: `admin`

**PACS Server (Orthanc):**
- URL: http://localhost:8042

**Database Viewer:**
- URL: http://localhost:8081

## Basic Usage

### Create a Worklist

1. Open http://localhost:8000
2. Login dengan `admin` / `admin`
3. Click "Add Worklist"
4. Fill in patient information
5. Click "Save"

### View in DICOM Modality

Your DICOM modality can now query worklists from:
- **AE Title:** `ORTHANC`
- **Host:** Your server IP
- **Port:** `4242`

### Send DICOM Images

Configure your modality to send images to:
- **AE Title:** `ORTHANC`
- **Host:** Your server IP
- **Port:** `4242`

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
# Create backup
docker-compose --profile backup run --rm backup /scripts/backup.sh
```

Backups saved to `./backups/` folder.

## Update

```bash
# Pull latest version
docker-compose pull

# Restart services
docker-compose up -d
```

## Troubleshooting

### Services not starting?

```bash
# Check logs
docker-compose logs -f

# Check if ports are available
lsof -i :8000
lsof -i :8042
```

### Can't access web interface?

1. Wait 60 seconds for services to fully start
2. Check: `docker-compose ps` - all should be "healthy"
3. Try: `docker-compose restart`

### Port already in use?

Edit `docker-compose.yml` and change the port:
```yaml
ports:
  - "8001:8000"  # Changed from 8000 to 8001
```

## Next Steps

✅ **Production Setup:** Read [README.md](README.md) for security configuration

✅ **Integration:** Configure your DICOM modality to connect

✅ **Backup:** Setup automatic daily backups

## Need Help?

- 📖 Full documentation: [README.md](README.md)
- 🐛 Issues: Open a GitHub issue
- 💬 Questions: Check documentation first

---

**Happy imaging! 🏥📸**
