# Deployment Folder Structure

Complete folder structure with descriptions.

```
Radiologi_RIS/
├── docker-compose.yml                          # Main compose file
├── .gitignore                                  # Git ignore rules
├── README.md                                   # Complete documentation
├── QUICKSTART.md                               # Quick start guide
├── STRUCTURE.md                                # This file
│
├── containers/
│   ├── orthanc/
│   │   ├── config/
│   │   │   └── orthanc.json                    # Orthanc PACS configuration
│   │   └── data/                               # Orthanc DICOM storage (gitignored)
│   │
│   ├── postgresql/
│   │   └── data/                               # PostgreSQL database files (gitignored)
│   │
│   ├── worklist-web/
│   │   └── runtime/
│   │       ├── staticfiles/                    # Django static files (gitignored)
│   │       └── media/                          # User uploaded files (gitignored)
│   │
│   ├── shared/
│   │   └── worklists/                          # DICOM worklist files (gitignored)
│   │       └── *.wl
│   │
│   └── backup/
│       └── data/                               # Database backups (gitignored)
│
└── scripts/
    └── backup.sh                               # Database backup script
```

## Volume Mapping

All services use **bind mounts** to maintain visible folder structure:

### Orthanc Service
- `./containers/orthanc/data` → `/var/lib/orthanc/db` (DICOM storage)
- `./containers/orthanc/config/orthanc.json` → `/etc/orthanc/orthanc.json` (config)
- `./containers/shared/worklists` → `/worklists` (DICOM worklists)

### PostgreSQL Service
- `./containers/postgresql/data` → `/var/lib/postgresql/data` (database files)

### Worklist Web Service
- `./containers/shared/worklists` → `/worklists` (shared with Orthanc)
- `./containers/worklist-web/runtime/staticfiles` → `/app/staticfiles` (static assets)
- `./containers/worklist-web/runtime/media` → `/app/media` (uploads)

### Backup Service
- `./containers/backup/data` → `/backups` (backup destination)
- `./scripts` → `/scripts` (backup scripts)

## Gitignore Rules

The following are ignored by git:

- `containers/orthanc/data/` — DICOM storage
- `containers/postgresql/data/` — Database files
- `containers/worklist-web/runtime/` — Static files & media
- `containers/shared/worklists/*.wl` — Worklist files
- `containers/backup/data/` — Backup files
- `.env` — Local environment variables

Each gitignored directory contains a `.gitkeep` to preserve folder structure.

## Why Bind Mounts?

1. **Visible folder structure** — Files visible in your filesystem
2. **Easy backup** — Just copy the `containers/` folder
3. **Easy migration** — Move entire project folder to new server
4. **Direct access** — No need for `docker cp` commands
5. **Better control** — You manage the file permissions

## Data Persistence

All data persists across container restarts/removals:

| Data | Location |
|------|----------|
| DICOM Images | `containers/orthanc/data/` |
| Database | `containers/postgresql/data/` |
| Worklists | `containers/shared/worklists/` |
| Static Files | `containers/worklist-web/runtime/staticfiles/` |
| Uploads | `containers/worklist-web/runtime/media/` |

## Clean Install

To start fresh (⚠️ deletes all data):

```bash
docker-compose down
rm -rf containers/orthanc/data/* containers/postgresql/data/* containers/shared/worklists/*.wl
rm -rf containers/worklist-web/runtime/staticfiles/* containers/worklist-web/runtime/media/*
docker-compose up -d
```

## Migration to Another Server

```bash
# On old server
docker-compose down
tar -czf radiologi-ris-full.tar.gz .

# Transfer to new server
scp radiologi-ris-full.tar.gz user@newserver:/path/

# On new server
tar -xzf radiologi-ris-full.tar.gz
docker-compose up -d
```

## Disk Space Management

```bash
# Check disk usage
du -sh containers/orthanc/data/
du -sh containers/postgresql/data/
du -sh containers/shared/worklists/
du -sh containers/backup/data/

# Clean old backups (keep last 7 days)
find containers/backup/data/ -name "*.sql" -mtime +7 -delete

# Clean Docker system
docker system prune -a
```
