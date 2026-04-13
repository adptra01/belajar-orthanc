# Belajar Orthanc DICOM Server

Proyek untuk belajar dan eksplorasi Orthanc, server DICOM ringan dan RESTful.

## Struktur Folder

```
belajar-orthanc/
├── docker-compose.yml          # Konfigurasi container
├── README.md                  # File ini
├── DOKUMENTASI-ORTHANC.md     # Dokumentasi lengkap dasar
├── PLUGIN-ORTHANC-DETAILED.md # Dokumentasi plugin & konfigurasi detail
├── TUTORIAL-ORTHANC-WEB.md   # Tutorial penggunaan aplikasi web
├── ORTHANC-CHEAT-SHEET.md    # Cheat sheet & referensi cepat
├── check_dicom.sh             # Script untuk check DICOM file
├── check-orthanc.sh          # Script check status Orthanc
├── orthanc.json              # Konfigurasi Orthanc
├── orthanc.json.example      # Contoh konfigurasi
├── orthanc-data/              # Data persisten Orthanc
├── BACKUPS/                   # Backup files
│   ├── orthanc.json.backup   # Backup konfigurasi
│   ├── daae3df7f522b56724aed7e3e544c0fe.zip
│   ├── daae3df7f522b56724aed7e3e544c0fe/
│   ├── images.tar
│   └── MR000000.dcm
└── DICOM_SAMPLES/             # Contoh file DICOM
    ├── sample_file_dcom/     # Contoh DICOM series
    └── MR000000.dcm          # File DICOM contoh
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
./check-orthanc.sh
```

## 📚 Dokumentasi Lengkap

### [DOKUMENTASI-ORTHANC.md](DOKUMENTASI-ORTHANC.md)
- Instalasi dan setup langkah demi langkah
- Konfigurasi detail
- Penggunaan dasar melalui web interface
- REST API dengan contoh
- DICOM operations
- Troubleshooting
- Security considerations

### [PLUGIN-ORTHANC-DETAILED.md](PLUGIN-ORTHANC-DETAILED.md)
- Pengenalan plugin Orthanc
- Jenis plugin dan fungsinya
- Instalasi plugin
- Konfigurasi plugin
- Plugin populer (Lua, Web Viewer, PDF Export)
- Tutorial penggunaan aplikasi web detail
- API plugin
- Konfigurasi lanjutan
- Optimasi performa
- Debugging dan troubleshooting

### [TUTORIAL-ORTHANC-WEB.md](TUTORIAL-ORTHANC-WEB.md)
- Dashboard dan overview
- Navigasi interface
- Mengelola pasien
- Studi dan series
- Viewer gambar DICOM (MPR, 3D)
- Export dan sharing
- Search dan filter advanced
- Tools utilities
- Workflows otomatis (Lua scripting)
- Tips dan best practices

### [ORTHANC-CHEAT-SHEET.md](ORTHANC-CHEAT-SHEET.md)
- Commands quick reference (Docker/Podman)
- API endpoints
- Common operations
- Configuration examples
- Common issues & solutions
- Quick scripts
- URLs

## 🛠️ Useful Commands

### Upload DICOM File
```bash
# Upload via curl
curl -X POST -T DICOM_SAMPLES/MR000000.dcm http://localhost:8042/studies

# Gunakan script bawaan
./check_dicom.sh DICOM_SAMPLES/MR000000.dcm
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

## ⚙️ Konfigurasi

- **HTTP Port**: 8042
- **DICOM Port**: 4242
- **Data Storage**: `./orthanc-data`
- **Authentication**: Disabled

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
- Reset database jika diperlukan (lihat dokumentasi lengkap)# belajar-orthanc
# belajar-orthanc
# belajar-orthanc
# belajar-orthanc
