# Dokumentasi Lengkap Orthanc DICOM Server

## Daftar Isi
1. [Pengenalan Orthanc](#pengenalan-orthanc)
2. [Instalasi dan Setup](#instalasi-dan-setup)
3. [Struktur Folder](#struktur-folder)
4. [Konfigurasi](#konfigurasi)
5. [Penggunaan Dasar](#penggunaan-dasar)
6. [DICOM Operations](#dicom-operations)
7. [Web Interface](#web-interface)
8. [REST API](#rest-api)
9. [Troubleshooting](#troubleshooting)

---

## Pengenalan Orthanc

Orthanc adalah server DICOM ringan dan RESTful yang dikembangkan untuk aplikasi kesehatan dan penelitian medis. Dibuat di University of Louvain (UCL), Orthanc menawarkan:

- **Server DICOM** yang memenuhi standar DICOM
- **Interface web** yang intuitif untuk manajemen data
- **RESTful API** untuk integrasi dengan aplikasi lain
- **Compression** lossless untuk penyimpanan efisien
- **Indexing** cepat dengan SQLite database
- **Plugins** untuk ekstensi fungsionalitas

---

## Instalasi dan Setup

### 1. Persyaratan Sistem
- Docker atau Podman
- Minimal 1GB RAM (direkomendasikan 4GB untuk produksi)
- 2GB ruang disk untuk data DICOM
- Port HTTP (default 8042) dan DICOM (default 4242) terbuka

### 2. Installasi dengan Docker/Podman

#### Clone atau Buat Proyek
```bash
# Buat direktori proyek
mkdir belajar-orthanc
cd belajar-orthanc

# Inisialisasi Docker Compose
cat > docker-compose.yml << 'EOF'
version: '3.8'

services:
  orthanc:
    # Kita menggunakan image yang sudah berisi plugin lengkap
    image: docker.io/jodogne/orthanc-plugins:latest 
    container_name: server-orthanc
    ports:
      - "8042:8042"  # Port HTTP untuk GUI dan REST API
      - "4242:4242"  # Port DICOM untuk transfer gambar medis
    volumes:
      - ./orthanc-data:/var/lib/orthanc/db  # Persistent data storage
    restart: unless-stopped
EOF
```

#### Mulai Container Orthanc
```bash
# Menggunakan Docker
docker-compose up -d

# Atau menggunakan Podman
podman-compose up -d  # Jika menggunakan podman-compose
atau
podman run -d --name server-orthanc \
  -p 8042:8042 \
  -p 4242:4242 \
  -v $(pwd)/orthanc-data:/var/lib/orthanc/db \
  docker.io/jodogne/orthanc-plugins:latest
```

### 3. Verifikasi Instalasi
```bash
# Cek status container
docker-compose ps
atau
podman ps

# Test orthanc running
curl http://localhost:8042
```

---

## Struktur Folder

### Struktur Direktori Setelah Setup
```
belajar-orthanc/
├── docker-compose.yml          # Konfigurasi container
├── orthanc-data/               # Data persisten Orthanc
│   ├── index                   # SQLite database file
│   ├── index-wal              # SQLite WAL file
│   ├── WebViewerCache/        # Cache untuk web viewer
│   ├── [hex-folders]/         # Folder penyimpanan DICOM
│   └── ...                    # Data DICOM
├── DOKUMENTASI-ORTHANC.md      # Dokumentasi ini
├── DICOM_SAMPLES/             # Contoh file DICOM
└── BACKUPS/                   # Backup configuration
```

### Penjelasan Folder
- **`orthanc-data`**: Berisi database SQLite dan file DICOM
- **`index`**: Database SQLite yang berisi metadata DICOM
- **`index-wal`**: Write-Ahead Log untuk database
- **`WebViewerCache`**: Cache untuk tampilan DICOM di web
- **`[hex-folders]`**: Penyimpanan aktual file DICOM (nama folder hexadecimal)
- **`DICOM_SAMPLES`**: Contoh file DICOM untuk testing

---

## Konfigurasi

### 1. Konfigurasi Standar (Default)

Orthanc berjalan dengan konfigurasi default:

```json
{
  "Name": "MyOrthanc",
  "HttpPort": 8042,
  "DicomPort": 4242,
  "StorageDirectory": "OrthancStorage",
  "StorageCompression": false,
  "AuthenticationEnabled": false,
  "DefaultEncoding": "ExplicitVRLittleEndian"
}
```

### 2. Custom Configuration

#### Buat file konfigurasi custom:
```json
{
  "Name": "Orthanc (DICOM Server)",
  "Description": "Orthanc DICOM server with plugins",
  "HttpPort": 8042,
  "DicomPort": 4242,
  "AuthenticationEnabled": false,
  "DefaultEncoding": "ExplicitVRLittleEndian",
  "StorageDirectory": "/var/lib/orthanc/db",
  
  "HttpCompression": true,
  "DicomAet": "ORTHANC",
  "DicomFindSCU": {
    "AET": "ORTHANC-FIND",
    "CalledAET": "ANY-SCP",
    "Timeout": 30
  },
  
  "IndexDirectory": "/var/lib/orthanc/db",
  "StorageCompression": true,
  "MaximumStorageSize": 0,
  "DefaultLostResourceCompression": true,
  
  "Logging": {
    "Level": "info",
    "File": "/var/log/orthanc/orthanc.log"
  }
}
```

#### Update docker-compose.yml untuk mounting config:
```yaml
services:
  orthanc:
    image: docker.io/jodogne/orthanc-plugins:latest
    container_name: server-orthanc
    ports:
      - "8042:8042"
      - "4242:4242"
    volumes:
      - ./orthanc-data:/var/lib/orthanc/db
      - ./orthanc.json:/etc/orthanc/orthanc.json
    restart: unless-stopped
```

### 3. Pentingnya Persistent Storage
- **StorageDirectory**: Lokasi penyimpanan DICOM
- **IndexDirectory**: Database SQLite
- Pastikan direktori memiliki permission yang benar
- Backup rutin database penting

---

## Penggunaan Dasar

### 1. Akses Web Interface
Buka browser dan akses: `http://localhost:8042`

- **Username/Password**: Tidak ada (authentication disabled)
- Main interface berisi:
  - Patients list
  - Studies list
  - Series list
  - Instances list

### 2. Upload DICOM File

#### Via Web Interface
1. Klik "Browse" pada section "File"
2. Pilih file DICOM (.dcm)
3. Klik "Upload"

#### Via Command Line
```bash
# Upload single DICOM file
curl -X POST -T MR000000.dcm http://localhost:8042/studies

# Upload via DICOM SCU (using tools like dcm4chee)
# atau SCP listener
```

### 3. Operasi Dasar di Web Interface

#### Patient Management
- View patient demographics
- View studies untuk patient
- Export patient data

#### Study Management
- View study metadata
- View series dalam study
- Export study
- Delete study

#### Series Management
- View series images
- Basic image manipulation
- Export series
- View metadata

#### Instance Management
- View single DICOM instance
- Extract metadata
- Export instance
- Delete instance

---

## DICOM Operations

### 1. DICOM Associations

#### Standar Association Parameters
- **Application Entity Title (AET)**: "ORTHANC"
- **Calling AET**: "ANY-SCP"
- **Port**: 4242
- **Timeout**: 30 detik

### 2. DICOM Store SCP (Server)
Orthanc berfungsi sebagai SCP menerima DICOM:
```bash
# Cek port DICOM listening
netstat -tlnp | grep 4242
```

### 3. DICOM Store SCU (Client)

#### Menggunakan dcm4che tools
```bash
# Store file DICOM ke Orthanc
storescu localhost 4242 MR000000.dcm -aec ORTHANC -aet ORTHANC-SCP
```

### 4. DICOM Query/Retrieve

#### Query PACS
```bash
# Query patient list
findscu localhost 4242 -k QueryRetrieveLevel=PATIENT -P "PatientName=*"

# Query studies
findscu localhost 4242 -k QueryRetrieveLevel=STUDY -P "PatientName=John*"
```

### 5. Configuration untuk PACS Integration

#### Tambahkan ke orthanc.json:
```json
{
  "DicomModalities": {
    "MY-PACS": {
      "Address": "192.168.1.100",
      "AET": "PACS-AET",
      "Port": 4242,
      "Username": "username",
      "Password": "password"
    }
  },
  
  "DicomFindSCU": {
    "AET": "ORTHANC-FIND",
    "CalledAET": "MY-PACS",
    "Timeout": 30
  }
}
```

---
> **Untuk tutorial web interface yang lebih detail** (viewer DICOM, MPR, 3D, export, search lanjutan, dll), lihat [TUTORIAL-ORTHANC-WEB.md](TUTORIAL-ORTHANC-WEB.md).

## Web Interface

### 1. Navigasi Web Interface

#### Home Page (/)
- System information
- Memory usage
- Version info
- Connected modalities

#### Patients (/patients)
- List semua patients
- Search functionality
- Pagination

#### Studies (/studies)
- List semua studies
- Grouped by patient
- Metadata display

#### Series (/series)
- List series dalam study
- Thumbnail preview
- Number of images

#### Instances (/instances)
- List individual DICOM instances
- Metadata
- Preview capability

### 2. Tools & Features

#### Reconstruction Tools
- Merge series
- Extract data
- Convert formats

#### Export Options
- DICOM
- ZIP archive
- C-STORE transfer
- Media creation

#### Search Filters
- Patient Name
- Study Date
- Study UID
- Series Description

### 3. API Explorer

Akses di: `http://localhost:8042/apidocs`

REST API endpoints:
- `/patients` - Patients operations
- `/studies` - Studies operations
- `/series` - Series operations
- `/instances` - Instances operations

---
> **Referensi cepat semua endpoint** tersedia di [ORTHANC-CHEAT-SHEET.md](ORTHANC-CHEAT-SHEET.md).

## REST API

### 1. General API Pattern

#### Base URL
```
http://localhost:8042
```

#### Headers
```
Content-Type: application/json
Accept: application/json
```

### 2. Patients API

#### Get Patients List
```bash
curl -X GET "http://localhost:8042/patients"
```

#### Get Patient Details
```bash
curl -X GET "http://localhost:8042/patients/<patient-id>"
```

#### Get Patient Studies
```bash
curl -X GET "http://localhost:8042/patients/<patient-id>/studies"
```

### 3. Studies API

#### Get Studies List
```bash
curl -X GET "http://localhost:8042/studies"
```

#### Get Study Details
```bash
curl -X GET "http://localhost:8042/studies/<study-id>"
```

#### Get Study Series
```bash
curl -X GET "http://localhost:8042/studies/<study-id>/series"
```

#### Export Study
```bash
curl -X POST "http://localhost:8042/studies/<study-id>/archive" \
  -H "Content-Type: application/json" \
  -d '{"Format": "zip"}'
```

### 4. Series API

#### Get Series List
```bash
curl -X GET "http://localhost:8042/series"
```

#### Get Series Details
```bash
curl -X GET "http://localhost:8042/series/<series-id>"
```

#### Get Series Instances
```bash
curl -X GET "http://localhost:8042/series/<series-id>/instances"
```

#### Reconstruct Series
```bash
curl -X POST "http://localhost:8042/series/<series-id>/reconstruct" \
  -H "Content-Type: application/json" \
  -d '{"Slices": "corrected"}'
```

### 5. Instances API

#### Get Instances List
```bash
curl -X GET "http://localhost:8042/instances"
```

#### Get Instance Details
```bash
curl -X GET "http://localhost:8042/instances/<instance-id>"
```

#### Get Instance File
```bash
curl -X GET "http://localhost:8042/instances/<instance-id>/file"
```

#### Get Instance Metadata
```bash
curl -X GET "http://localhost:8042/instances/<instance-id>/metadata"
```

### 6. System API

#### Get System Info
```bash
curl -X GET "http://localhost:8042/system"
```

#### Get Changes
```bash
curl -X GET "http://localhost:8042/changes"
```

#### Get Statistics
```bash
curl -X GET "http://localhost:8042/tools/statistics"
```

---
> **Troubleshooting lebih lengkap** ada di [ORTHANC-CHEAT-SHEET.md](ORTHANC-CHEAT-SHEET.md) dan [ORTHANC-FOR-BEGINNERS-COMPLETE.md](ORTHANC-FOR-BEGINNERS-COMPLETE.md).

## Troubleshooting

### 1. Common Issues

#### Port Already in Use
```bash
# Check port usage
netstat -tlnp | grep 8042
netstat -tlnp | grep 4242

# Change ports in docker-compose.yml
ports:
  - "8043:8042"
  - "4243:4242"
```

#### Permission Issues
```bash
# Fix permissions
sudo chown -R $USER:$USER orthanc-data
sudo chmod -R 755 orthanc-data
```

#### Container Not Starting
```bash
# Check logs
docker-compose logs orthanc
podman logs server-orthanc

# Restart container
docker-compose restart orthanc
podman restart server-orthanc
```

#### Database Corruption
```bash
# Stop container
docker-compose stop

# Backup current database
cp -r orthanc-data orthanc-data.backup

# Remove corrupted files
rm -f orthanc-data/index orthanc-data/index-wal

# Restart container (database will be recreated)
docker-compose up -d
```

### 2. Performance Tips

#### Memory Usage
```bash
# Monitor memory usage
docker stats

# If high memory, consider:
# - Reduce cache settings
# - Enable compression
# - Increase swap space
```

#### Storage Optimization
```json
{
  "StorageCompression": true,
  "DefaultLostResourceCompression": true,
  "MaximumStorageSize": 10240  # 10GB limit
}
```

#### Index Optimization
- Use SSD for database directory
- Regular cleanup of old studies
- Monitor SQLite database size

### 3. Backup Strategy

#### Daily Backup Script
```bash
#!/bin/bash
# backup-orthanc.sh

DATE=$(date +%Y%m%d_%H%M%S)
BACKUP_DIR="./BACKUPS"

mkdir -p $BACKUP_DIR

# Backup database
cp -r orthanc-data $BACKUP_DIR/orthanc-data_$DATE

# Export configuration
cp orthanc.json $BACKUP_DIR/orthanc_config_$DATE.json

echo "Backup completed: $BACKUP_DIR/orthanc-data_$DATE"
```

#### Schedule Cron Job
```bash
# Add to crontab
0 2 * * * /path/to/backup-orthanc.sh
```

---

## Security Considerations

### 1. Basic Security Setup

#### Enable Authentication
```json
{
  "AuthenticationEnabled": true,
  "Username": "admin",
  "Password": "password123"
}
```

#### Configure HTTPS
```bash
# Generate SSL certificate
openssl req -x509 -newkey rsa:4096 -keyout key.pem -out cert.pem -days 365

# Update docker-compose.yml
volumes:
  - ./cert.pem:/etc/ssl/certs/orthanc.crt
  - ./key.pem:/etc/ssl/private/orthanc.key

# Configure orthanc.json for HTTPS
{
  "HttpsPort": 8043,
  "CertificateFile": "/etc/ssl/certs/orthanc.crt",
  "KeyFile": "/etc/ssl/private/orthanc.key"
}
```

### 2. Network Security

#### Firewall Rules
```bash
# Allow only necessary ports
sudo ufw allow 8042/tcp
sudo ufw allow 4242/tcp
sudo ufw deny 80/tcp  # Close HTTP port
```

#### Network Isolation
- Run container in custom network
- Limit external access
- Use reverse proxy

---

## References

### Official Documentation
- [Orthanc Book](https://orthanc.uclouvain.be/book/)
- [REST API Reference](https://orthanc.uclouvain.be/book/developers/rest.html)
- [Plugin Documentation](https://orthanc.uclouvain.be/book/developers/plugins/)

### Community Resources
- [Orthanc Forum](https://www.orthanc-server.com/forum/)
- [GitHub Repository](https://github.com/jodogne/orthanc-server)
- [Docker Hub](https://hub.docker.com/r/jodogne/orthanc-plugins/)

### Useful Tools
- [DICOM Toolkit (dcm4che)](https://www.dcm4che.org/)
- [Papyrus DICOM](https://www.papyrus-project.org/)
- [Image Viewer (RadiAnt)](https://www.radiantviewer.com/)

---

**Catatan**: Dokumentasi ini dibuat untuk Orthanc dengan jodogne/orthanc-plugins image. Konfigurasi mungkin berbeda dengan versi atau image lainnya.