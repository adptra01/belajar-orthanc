# Belajar Orthanc DICOM Server

Proyek untuk belajar dan eksplorasi Orthanc, server DICOM ringan dan RESTful.

## Struktur Folder

```
belajar-orthanc/
├── docker-compose.yml          # Konfigurasi container
├── README.md                  # File ini
├── config/                    # File konfigurasi
│   └── orthanc.json.example  # Contoh konfigurasi Orthanc
├── data/                      # Data runtime
│   ├── orthanc/               # Data persisten Orthanc (database + DICOM)
│   └── backups/               # Backup files
├── docs/                      # Dokumentasi
│   ├── guide/                 # Panduan setup bertahap (15 bagian)
│   └── reference/             # Dokumentasi referensi
│       ├── DOKUMENTASI-ORTHANC.md
│       ├── PLUGIN-ORTHANC-DETAILED.md
│       ├── TUTORIAL-ORTHANC-WEB.md
│       └── ...
└── scripts/                   # Script utilities
    ├── check-orthanc.sh       # Cek status Orthanc
    ├── check-dicom.sh         # Validasi file DICOM
    └── deploy-orthanc.sh      # Deploy ke produksi
```

## 🚀 Cepat Mulai

### 1. Start Orthanc Server
```bash
# Menggunakan Docker
docker-compose up -d

# Atau menggunakan Podman
podman-compose up -d
```

### 2. Akses Web Interface
Buka browser ke: `http://localhost:8042`

### 3. Check Status
```bash
# Cek container
docker-compose ps

# Cek log
docker-compose logs orthanc

# Gunakan script bawaan
./scripts/check-orthanc.sh
```

## 📚 Landskap Dokumentasi

### Dokumentasi Inti

| File | Fokus | Ukuran |
|------|-------|--------|
| [DOKUMENTASI-ORTHANC.md](docs/reference/DOKUMENTASI-ORTHANC.md) | Dokumentasi lengkap (install, API, troubleshooting) | ~26KB |
| [PLUGIN-ORTHANC-DETAILED.md](docs/reference/PLUGIN-ORTHANC-DETAILED.md) | Plugin, konfigurasi lanjutan, API plugin | ~45KB |
| [TUTORIAL-ORTHANC-WEB.md](docs/reference/TUTORIAL-ORTHANC-WEB.md) | Panduan lengkap web interface | ~42KB |
| [ORTHANC-CHEAT-SHEET.md](docs/reference/ORTHANC-CHEAT-SHEET.md) | Referensi cepat perintah & API | ~12KB |
| [ORTHANC-FOR-BEGINNERS-COMPLETE.md](docs/reference/ORTHANC-FOR-BEGINNERS-COMPLETE.md) | Panduan pemula: planning hingga deployment online | ~45KB |
| [DOKUMENTASI-LENGKAP-ORTHANC.md](docs/reference/DOKUMENTASI-LENGKAP-ORTHANC.md) | Index/ringkasan yang mereferensi ke file sumber lain | ~3KB |

### Panduan Setup Bertahap

[docs/guide/](./docs/guide/) — 15 bagian dari spesifikasi sistem hingga troubleshooting:

| Bagian | Topik |
|--------|-------|
| 01-03 | Spesifikasi sistem, alat, konfigurasi jaringan |
| 04-06 | API, plugin, konfigurasi PACS |
| 07-09 | Konfigurasi inti, akses lokal & online |
| 10 | Troubleshooting |
| 11-15 | Referensi, cheat sheet, plugin, web, setup pemula |

### Catatan Duplikasi (Tersisa)

Topik yang masih muncul di banyak file. Jika mengedit, periksa konsistensi antar file:
- **Install & Docker commands**: README, DOKUMENTASI-ORTHANC, CHEAT-SHEET, panduan setup
- **API endpoints**: DOKUMENTASI-ORTHANC, CHEAT-SHEET, panduan API
- **Troubleshooting**: DOKUMENTASI-ORTHANC, CHEAT-SHEET, ORTHANC-FOR-BEGINNERS, PLUGIN
- **Web interface**: DOKUMENTASI-ORTHANC, TUTORIAL-ORTHANC-WEB, PLUGIN

> Duplikasi besar yang telah diperbaiki:
> - `DOKUMENTASI-LENGKAP-ORTHANC.md` (257KB→3KB): Diubah jadi index yang mereferensi file sumber
> - `Orthanc-Complete-Setup-Guide/11-15`: Diubah jadi thin reference ke file referensi masing-masing

## 📜 Scripts Reference

<!-- AUTO-GENERATED from scripts/ directory -->
| Script | Perintah | Deskripsi |
|--------|----------|-----------|
| `scripts/check-orthanc.sh` | `./scripts/check-orthanc.sh all` | Cek status lengkap Orthanc (Docker, API, disk, DB, network) |
| | `./scripts/check-orthanc.sh status` | Ringkasan status container |
| | `./scripts/check-orthanc.sh docker` | Cek Docker service |
| | `./scripts/check-orthanc.sh container` | Cek container Orthanc |
| | `./scripts/check-orthanc.sh api` | Cek Orthanc API |
| | `./scripts/check-orthanc.sh db` | Cek integritas database |
| | `./scripts/check-orthanc.sh disk` | Cek ruang disk |
| `scripts/check-dicom.sh` | `./scripts/check-dicom.sh <file.dcm>` | Validasi file DICOM + upload ke Orthanc |
| `scripts/deploy-orthanc.sh` | `./scripts/deploy-orthanc.sh deploy` | Deploy ke server produksi |
| | `./scripts/deploy-orthanc.sh backup` | Backup instalasi |
| | `./scripts/deploy-orthanc.sh rollback` | Rollback ke backup terakhir |
| | `./scripts/deploy-orthanc.sh check` | Cek status deployment |
<!-- AUTO-GENERATED -->

## ⚙️ Konfigurasi Lingkungan

<!-- AUTO-GENERATED from docker-compose.yml & orthanc.json.example -->
- **HTTP Port**: 8042 | **DICOM Port**: 4242 | **Storage**: `./data/orthanc` | **Auth**: Disabled

| Key | Default | Deskripsi |
|-----|---------|-----------|
| `Name` | `Orthanc (DICOM Server)` | Nama server |
| `HttpPort` | `8042` | Port HTTP |
| `DicomPort` | `4242` | Port DICOM |
| `AuthenticationEnabled` | `false` | Aktifkan login |
| `DefaultEncoding` | `ExplicitVRLittleEndian` | Encoding DICOM |
| `StorageDirectory` | `/var/lib/orthanc/db` | Lokasi penyimpanan |
<!-- AUTO-GENERATED -->

## 🛠️ Useful Commands

### Upload DICOM File
```bash
# Upload via curl
curl -X POST -T DICOM_SAMPLES/MR000000.dcm http://localhost:8042/studies

# Gunakan script bawaan
./scripts/check-dicom.sh DICOM_SAMPLES/MR000000.dcm
```

### Export Data
```bash
# Export study sebagai ZIP
curl -X POST http://localhost:8042/studies/<study-id>/archive \
  -H "Content-Type: application/json" \
  -d '{"Format": "zip"}'
```

### Anonymize Data
```bash
# Anonymize study
curl -X POST http://localhost:8042/studies/<study-id>/anonymize

# Anonymize dengan custom tags
curl -X POST http://localhost:8042/studies/<study-id>/anonymize \
  -H "Content-Type: application/json" \
  -d '{"ReplaceTags": {"PatientName": "ANONYMOUS"}}'
```

### Search
```bash
# Cari pasien berdasarkan nama
curl "http://localhost:8042/patients?expand=true&limit=100" | jq '.[] | select(.MainDicomTags.PatientName | contains("John"))'

# Cari studi berdasarkan tanggal
curl "http://localhost:8042/studies?date=20240101-20240131"

# Cari berdasarkan modality
curl "http://localhost:8042/studies?modality=CT"
```

### Stop Server
```bash
# Menggunakan Docker
docker-compose down

# Atau menggunakan Podman
podman-compose down
```

## 🔧 Instalasi Plugin (Opsional)

Jika ingin menggunakan plugin tambahan:

1. Download plugin dari [Orthanc Plugins](https://orthanc.uclouvain.be/plugins/)
2. Masukkan ke folder `./plugins`
3. Tambahkan konfigurasi ke `orthanc.json`
4. Restart container

```json
{
  "LuaScripts": {
    "Enabled": true,
    "Directory": "/etc/orthanc/scripts"
  }
}
```

## 💡 Tips & Notes

- Pastikan port 8042 dan 4242 tidak digunakan aplikasi lain
- Data Orthanc akan tersimpan meskipun container dihentikan
- Backup penting untuk menghindari kehilangan data
- Gunakan dokumentasi cheat sheet untuk referensi cepat
- Tutorial web interface sangat detail untuk penggunaan visual

## 🔍 Troubleshooting

- Pastikan container berjalan: `docker-compose ps`
- Cek log: `docker-compose logs orthanc`
- Cek port: `netstat -tlnp | grep 8042`
- Reset database jika diperlukan (lihat dokumentasi lengkap)
