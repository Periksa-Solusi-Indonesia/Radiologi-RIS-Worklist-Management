# Container Runtime Layout

Folder `containers/` mengelompokkan file runtime berdasarkan service agar struktur project lebih jelas.

## Struktur

- `orthanc/config/` - konfigurasi Orthanc
- `orthanc/data/` - data persisten Orthanc
- `postgresql/data/` - data persisten PostgreSQL
- `shared/worklists/` - worklist `.wl` yang dipakai bersama Orthanc dan Django
- `worklist-web/runtime/staticfiles/` - hasil `collectstatic`
- `worklist-web/runtime/media/` - upload file dari aplikasi Django
- `backup/data/` - output backup database

## Catatan

- Path bind mount di `docker-compose-dev.yaml` dan `docker-compose-prod.yaml` sudah diarahkan ke folder ini.
- Folder lama di root seperti `orthanc-data/`, `worklists/`, dan `backups/` tidak lagi menjadi sumber utama runtime.
