# Deployment Folder Structure

Complete folder structure with descriptions.

```
deployment/
├── docker-compose.yml          # Main compose file with bind mounts
├── .env.example               # Environment variables template
├── .env                       # Your local configuration (gitignored)
├── .gitignore                 # Git ignore rules
├── README.md                  # Complete documentation
├── QUICKSTART.md              # Quick start guide
├── STRUCTURE.md               # This file
│
├── config/                    # Configuration files
│   └── orthanc.json          # Orthanc PACS configuration
│
├── data/                      # All persistent data (gitignored)
│   ├── orthanc/              # Orthanc DICOM storage
│   ├── postgresql/           # PostgreSQL database files
│   ├── worklist-static/      # Django static files
│   └── worklist-media/       # User uploaded files
│
├── worklists/                 # DICOM worklist files (gitignored)
│   └── *.wl                  # Generated worklist files
│
├── backups/                   # Database backups (gitignored)
│   └── *.sql.gz              # Backup files
│
└── scripts/                   # Utility scripts
    └── backup.sh             # Database backup script
```

## Volume Mapping

All services use **bind mounts** (not Docker volumes) to maintain folder structure:

### Orthanc Service
- `./data/orthanc` → `/var/lib/orthanc/db` (DICOM storage)
- `./config/orthanc.json` → `/etc/orthanc/orthanc.json` (config, read-only)
- `./worklists` → `/worklists` (DICOM worklists)

### PostgreSQL Service
- `./data/postgresql` → `/var/lib/postgresql/data` (database files)

### Worklist Web Service
- `./worklists` → `/worklists` (shared with Orthanc)
- `./data/worklist-static` → `/app/staticfiles` (static assets)
- `./data/worklist-media` → `/app/media` (uploads)

### Backup Service
- `./backups` → `/backups` (backup destination)
- `./scripts` → `/scripts` (backup scripts, read-only)

## Gitignore Rules

The following are ignored by git but structure is preserved:

- `data/*` - All data files (but keep `.gitkeep`)
- `worklists/*` - DICOM worklist files (but keep `.gitkeep`)
- `backups/*` - Backup files (but keep `.gitkeep`)
- `.env` - Local environment variables

## Why Bind Mounts?

Using bind mounts instead of Docker volumes provides:

1. ✅ **Visible folder structure** - You can see all files in your file system
2. ✅ **Easy backup** - Just copy the `data/` folder
3. ✅ **Easy migration** - Move entire `deployment/` folder to new server
4. ✅ **Direct access** - No need for `docker cp` commands
5. ✅ **Better control** - You manage the file permissions

## Data Persistence

All data persists across container restarts/removals:

- **DICOM Images**: `data/orthanc/`
- **Database**: `data/postgresql/`
- **Worklists**: `worklists/`
- **Static Files**: `data/worklist-static/`
- **Uploads**: `data/worklist-media/`

## Folder Permissions

Docker will create files as root user. To access:

```bash
# Change ownership to your user
sudo chown -R $USER:$USER data/ worklists/

# Or use docker to manage
docker-compose exec worklist-web ls -la /worklists
```

## Clean Install

To start fresh (⚠️ deletes all data):

```bash
# Stop services
docker-compose down

# Remove all data
rm -rf data/orthanc/* data/postgresql/* worklists/* data/worklist-static/* data/worklist-media/*

# Start fresh
docker-compose up -d
```

## Backup Everything

```bash
# Backup entire deployment folder (excluding .env)
tar --exclude='deployment/.env' \
    -czf deployment-backup-$(date +%Y%m%d).tar.gz \
    deployment/

# Restore
tar -xzf deployment-backup-20231201.tar.gz
```

## Migration to Another Server

```bash
# On old server
docker-compose down
tar -czf deployment-full.tar.gz deployment/

# Transfer to new server
scp deployment-full.tar.gz user@newserver:/path/

# On new server
tar -xzf deployment-full.tar.gz
cd deployment
cp .env.example .env  # Adjust if needed
docker-compose up -d
```

## Disk Space Management

```bash
# Check disk usage
du -sh data/*
du -sh worklists/
du -sh backups/

# Clean old backups (keep last 7 days)
find backups/ -name "*.sql.gz" -mtime +7 -delete

# Clean Docker system
docker system prune -a
```
