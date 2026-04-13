# Panduan Lengkap Orthanc untuk Pemula: Dari Perencanaan hingga Deployment Online

## Daftar Isi
1. [Perkenalan dan Tujuan](#perkenalan-dan-tujuan)
2. [Perencanaan Proyek](#perencanaan-proyek)
3. [Menentukan Spesifikasi Sistem](#menentukan-spek-sistem)
4. [Kebutuhan Aplikasi](#kebutuhan-aplikasi)
5. [Konfigurasi Jaringan](#konfigurasi-jaringan)
6. [Instalasi Orthanc](#instalasi-orthanc)
7. [Setup Lokal](#setup-lokal)
8. [Konfigurasi Cloudflare Tunnel](#konfigurasi-cloudflare-tunnel)
9. **[Tutorial: Cara Akses Private](#tutorial-cara-akses-private)**
10. **[Tutorial: Cara Akses Online](#tutorial-cara-akses-online)**
11. **[Tutorial: Cara Akses dari Komputer Lain](#tutorial-cara-akses-dari-komputer-lain)**
12. **[Tutorial: Cara Akses dari Mobile](#tutorial-cara-akses-dari-mobile)**
13. [Keamanan dan Best Practices](#keamanan-dan-best-practices)
14. [Troubleshooting](#troubleshooting)
15. [Monitoring dan Maintenance](#monitoring-dan-maintenance)

---

## Perkenalan dan Tujuan

### Apa itu Orthanc?
Orthanc adalah server DICOM (Digital Imaging and Communications in Medicine) yang ringan dan RESTful, dikembangkan untuk:
- Menyimpan dan mengelola file medis (CT Scan, MRI, X-Ray, dll)
- Menghubungkan dengan sistem lain (PACS, RIS, HIS)
- Menyediakan interface web untuk visualisasi data
- Mendukung standar medis internasional

### Tujuan Tutorial Ini
Membantu pemula menginstall, mengkonfigurasi, dan menjalankan Orthanc server dari:
- **Setup lokal di komputer**
- **Setup online dengan akses private**
- **Setup online dengan akses publik (via Cloudflare Tunnel)**
- **Setup multi-device (komputer, mobile, tablet)**

---

## Perencanaan Proyek

### 1. Pemahaman Kebutuhan

#### Jenis Pengguna
- **Radiologist**: Untuk membaca gambar medis
- **Administrator IT**: Untuk maintenance sistem
- **Dokter**: Untuk melihat riwayat pasien
- **Researcher**: Untuk analisis data

#### Volume Data (Estimasi)
- **Small Clinic**: < 1GB/hari
- **Medium Hospital**: 1-5GB/hari
- **Large Hospital**: 5-20GB/hari
- **Research Center**: 20-100GB/hari

### 2. Desain Arsitektur

#### Arsitektur Dasar
```
[Client Device] -> [Internet] -> [Router/Firewall] -> [Server Orthanc] -> [Storage]
                    |
                    +-- [Cloudflare Tunnel] --> [DNS Management]
```

### 3. Timeline Implementasi
- **Week 1**: Planning dan setup dasar
- **Week 2**: Instalasi dan konfigurasi lokal
- **Week 3**: Setup jaringan dan keamanan
- **Week 4**: Deployment dan testing

---

## Menentukan Spesifikasi Sistem

### Untuk Pengembangan/Learning
```
CPU: Intel i3 / AMD Ryzen 3 (minimal)
RAM: 4GB (direkomendasikan 8GB)
Storage: 50GB SSD
OS: Windows 10/11, Ubuntu 20.04+, atau macOS
Network: Broadband internet
```

### Untuk Production/SKala Kecil
```
CPU: Intel i5 / AMD Ryzen 5 (4 core)
RAM: 8GB (minimal)
Storage: 100GB SSD (direkomendasikan 200GB+)
OS: Ubuntu 22.04 LTS
Network: Stabil, minimal 10Mbps upload
```

### Untuk Production/SKala Menengah
```
CPU: Intel i7 / AMD Ryzen 7 (6+ core)
RAM: 16GB+
Storage: 500GB SSD + 1TB HDD untuk archive
OS: Ubuntu 22.04 LTS Server
Network: Fiber, minimal 100Mbps upload
```

---

## Kebutuhan Aplikasi

### 1. Software Wajib
- **Docker Desktop** (Windows/macOS) atau **Docker** (Linux)
- **Docker Compose**
- **Web Browser** (Chrome/Firefox recommended)
- **Text Editor** (VS Code recommended)

### 2. Software Opsional
- **DICOM Viewer** (RadiAnt, OsiriX, Horos)
- **PACS Server** (untuk integrasi)
- **Backup Software** (rsync, duplicati)
- **Monitoring Tools** (Prometheus, Grafana)

### 3. Plugin yang Diperlukan
- **Web Viewer**: Untuk tampilan gambar di browser
- **Lua Scripting**: Untuk otomasi
- **PDF Export**: Untuk export laporan

---

## Konfigurasi Jaringan

### 1. Network Basics

#### Port yang Dibutuhkan
```yaml
HTTP/REST API: 8042
DICOM: 4242
HTTPS: 8443 (opsional)
SSH: 22 (untuk admin)
```

#### Network Diagram
```
Internet
    |
    +-- [Router] -- Port Forwarding -- [Server Orthanc]
    |
    +-- [Cloudflare] -- Tunnel -- [Server Orthanc]
```

### 2. Local Network Setup

#### Router Configuration
1. Login ke router
2. Port Forwarding:
   - **External Port**: 8042
   - **Internal IP**: IP server (misal: 192.168.1.100)
   - **Internal Port**: 8042
   - **Protocol**: TCP

#### Firewall (Ubuntu)
```bash
# Install UFW jika belum terinstall
sudo apt update
sudo apt install ufw

# Izin akses
sudo ufw allow ssh
sudo ufw allow 8042/tcp
sudo ufw allow 4242/tcp

# Aktifkan firewall
sudo ufw enable
```

### 3. Static IP Assignment
```bash
# Check IP saat ini
ip addr

# Edit netplan (Ubuntu 22.04)
sudo nano /etc/netplan/01-netcfg.yaml

# Tambahkan konfigurasi
network:
  version: 2
  ethernets:
    enp0s3:  # Ganti dengan interface yang sesuai
      dhcp4: no
      addresses: [192.168.1.100/24]
      gateway4: 192.168.1.1
      nameservers:
          addresses: [8.8.8.8, 1.1.1.1]
```

---

## Instalasi Orthanc

### 1. Setup Dasar

#### Install Docker (Ubuntu)
```bash
# Update system
sudo apt update
sudo apt upgrade -y

# Install Docker
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh

# Install Docker Compose
sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose

# Add user to docker group
sudo usermod -aG docker $USER

# Logout dan login kembali
```

#### Install Docker (Windows/macOS)
1. Download [Docker Desktop](https://www.docker.com/products/docker-desktop/)
2. Install dan jalankan
3. Pastikan Docker berjalan

### 2. Buat Project Directory
```bash
# Buat folder proyek
mkdir -p ~/orthanc-server
cd ~/orthanc-server

# Buat folder struktur
mkdir -p {orthanc-data,backups,plugins,scripts}
```

### 3. Docker Compose Configuration
```yaml
# docker-compose.yml
version: '3.8'

services:
  orthanc:
    image: jodogne/orthanc-plugins:latest
    container_name: orthanc-server
    restart: unless-stopped
    ports:
      - "8042:8042"    # HTTP API
      - "4242:4242"    # DICOM port
    volumes:
      - ./orthanc-data:/var/lib/orthanc/db
      - ./plugins:/usr/share/orthanc/plugins
      - ./scripts:/scripts
    environment:
      - ORTHANCPlugins=/usr/share/orthanc/plugins
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:8042/system"]
      interval: 30s
      timeout: 10s
      retries: 3
```

### 4. Basic Configuration
```json
// orthanc.json
{
  "Name": "Orthanc Server",
  "Description": "DICOM Server for Medical Imaging",
  "HttpPort": 8042,
  "DicomPort": 4242,
  "AuthenticationEnabled": false,
  "StorageDirectory": "/var/lib/orthanc/db",
  "IndexDirectory": "/var/lib/orthanc/db",
  "HttpCompression": true,
  "DefaultEncoding": "ExplicitVRLittleEndian"
}
```

### 5. Start Orthanc
```bash
# Start service
docker-compose up -d

# Cek status
docker-compose ps

# Cek logs
docker-compose logs -f orthanc
```

---

## Setup Lokal

### 1. Testing Setup Lokal

#### Akses Web Interface
Buka browser: `http://localhost:8042`

#### Test DICOM Server
```bash
# Cek port
netstat -tlnp | grep 8042
netstat -tlnp | grep 4242

# Test API
curl -s http://localhost:8042/system | jq '.Name'
```

#### Upload File DICOM
```bash
# Download sample DICOM
wget https://raw.githubusercontent.com/jodogne/Orthanc/master/Resources/Samples/MR000000.dcm

# Upload ke Orthanc
curl -X POST -T MR000000.dcm http://localhost:8042/studies

# Cek hasil
curl -X GET http://localhost:8042/studies | jq '.[] | .ID'
```

### 2. Create Sample DICOM Data
```bash
# Buat folder untuk sample data
mkdir -p samples

# Copy beberapa sample
cp ~/Downloads/*.dcm samples/ 2>/dev/null || true

# Bulk upload
for file in samples/*.dcm; do
  if [ -f "$file" ]; then
    echo "Uploading $file..."
    curl -X POST -T "$file" http://localhost:8042/studies >/dev/null
  fi
done
```

### 3. Basic User Interface Tour
1. **Dashboard**: System overview
2. **Patients**: List semua pasien
3. **Studies**: Studi radiologi
4. **Series**: Series gambar
5. **Instances**: File individual

---

## Konfigurasi Cloudflare Tunnel

### 1. Persiapan Cloudflare

#### Create Cloudflare Account
1. Daftar di [cloudflare.com](https://cloudflare.com)
2. Add domain Anda
3. Update nameserver ke Cloudflare
4. Install Cloudflare CLI di server

#### Install Cloudflared
```bash
# Download cloudflared
wget https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-amd64.deb
sudo dpkg -i cloudflared-linux-amd64.deb

# Login ke Cloudflare
cloudflared tunnel login
```

### 2. Create Tunnel
```bash
# Buat tunnel baru
cloudflared tunnel create orthanc-tunnel

# Simpan tunnel configuration
# Output akan menampilkan tunnel UUID dan credentials path
```

### 3. Configure Tunnel
```bash
# Buat file konfigurasi
mkdir -p ~/.cloudflared
nano ~/.cloudflared/config.yml

# Tambahkan konfigurasi
tunnel: orthanc-tunnel
credentials-file: /home/user/.cloudflared/orthanc-tunnel.json

ingress:
  - hostname: orthanc.yourdomain.com
    service: http://localhost:8042
  - hostname: *yourdomain.com
    service: http://localhost:8042
  - service: http_status:404
```

### 4. Create DNS Records
```bash
# Update DNS dengan Cloudflare CLI
cloudflared tunnel route dns orthanc-tunnel orthanc.yourdomain.com
```

### 5. Setup Service untuk Auto-start
```bash
# Create systemd service
sudo nano /etc/systemd/system/cloudflared.service

# Tambahkan konfigurasi
[Unit]
Description=Cloudflared tunnel
After=network.target

[Service]
Type=simple
User=cloudflared
ExecStart=/usr/local/bin/cloudflared tunnel run --config /home/user/.cloudflared/config.yml
Restart=always
RestartSec=10

[Install]
WantedBy=multi-user.target
```

### 6. Enable dan Start Service
```bash
# Reload systemd
sudo systemctl daemon-reload

# Enable service
sudo systemctl enable cloudflared

# Start service
sudo systemctl start cloudflared

# Cek status
sudo systemctl status cloudflared
```

---

## Tutorial: Cara Akses Private

### 1. Local Access Setup

#### Setup di Komputer yang Sama
```bash
# Akses langsung
open http://localhost:8042
# atau
open http://127.0.0.1:8042
```

#### Setup di Jaringan Lokal
1. **Cari IP Server**
```bash
# Cek IP server
ip addr show
# atau
hostname -I
```

2. **Akses dari Komputer Lain di Jaringan**
```bash
# Dari komputer lain di jaringan yang sama
http://192.168.1.100:8042
```

3. **Setup Port Forwarding di Router**
   - Login ke router
   - Menu Port Forwarding
   - Tambahkan rule:
     - External Port: 8042
     - Internal IP: 192.168.1.100
     - Internal Port: 8042

### 2. Private Access Script
```bash
#!/bin/bash
# get-access-info.sh

echo "=============================================="
echo "Orthanc Private Access Information"
echo "=============================================="
echo

# Get local IP
LOCAL_IP=$(hostname -I | awk '{print $1}')

echo "Access URLs:"
echo "  Local: http://localhost:8042"
echo "  Network: http://${LOCAL_IP}:8042"
echo

echo "Network Info:"
echo "  Your IP: ${LOCAL_IP}"
echo "  Subnet: $(ip route | grep default | awk '{print $3}')/24"
echo

echo "Commands:"
echo "  Check status: ./check-orthanc.sh"
echo "  Upload DICOM: ./check_dicom.sh <file>"
echo
```

---

## Tutorial: Cara Akses Online

### 1. Setup Cloudflare Tunnel (sudah di atas)

### 2. Configuration untuk HTTPS
```json
// Update orthanc.json tambahkan HTTPS
{
  "Name": "Orthanc Server",
  "HttpPort": 8042,
  "HttpsPort": 8443,
  "CertificateFile": "/etc/ssl/certs/orthanc.crt",
  "KeyFile": "/etc/ssl/private/orthanc.key",
  "AuthenticationEnabled": true,
  "UserName": "admin",
  "Password": "your-secure-password"
}
```

### 3. Generate Self-Signed Certificate (Opsional)
```bash
# Generate certificate
openssl req -x509 -newkey rsa:4096 -keyout orthanc.key -out orthanc.crt -days 365 -nodes

# Pindahkan ke folder
sudo mkdir -p /etc/ssl/certs /etc/ssl/private
sudo cp orthanc.crt /etc/ssl/certs/
sudo cp orthanc.key /etc/ssl/private/

# Update permissions
sudo chmod 600 /etc/ssl/private/orthanc.key
```

### 4. Update Docker Compose untuk HTTPS
```yaml
# docker-compose.yml
services:
  orthanc:
    # ... existing config
    volumes:
      - ./orthanc-data:/var/lib/orthanc/db
      - ./plugins:/usr/share/orthanc/plugins
      - /etc/ssl/certs/orthanc.crt:/etc/ssl/certs/orthanc.crt
      - /etc/ssl/private/orthanc.key:/etc/ssl/private/orthanc.key
    environment:
      - ORTHANCPlugins=/usr/share/orthanc/plugins
```

### 5. Restart Service
```bash
# Restart Orthanc
docker-compose restart

# Restart tunnel
sudo systemctl restart cloudflared
```

### 6. Test Online Access
```bash
# Test dengan curl
curl -I https://orthanc.yourdomain.com

# Test API
curl -s https://orthanc.yourdomain.com/system | jq '.Name'
```

### 7. Browser Access
1. Buka browser
2. Akses `https://orthanc.yourdomain.com`
3. Login jika authentication diaktifkan

---

## Tutorial: Cara Akses dari Komputer Lain

### 1. Setup Remote Access

#### Prerequisites
- Cloudflare Tunnel aktif
- Domain terdaftar di Cloudflare
- SSL/TLS certificate di Cloudflare

#### Network Requirements
```bash
# Cek koneksi ke server
ping orthanc.yourdomain.com

# Cek DNS resolution
nslookup orthanc.yourdomain.com

# Cek port
telnet orthanc.yourdomain.com 443
```

### 2. Access dari Komputer Lain

#### Windows
```powershell
# PowerShell
Invoke-WebRequest -Uri https://orthanc.yourdomain.com -UseBasicParsing

# CMD
curl https://orthanc.yourdomain.com
```

#### macOS
```bash
# Terminal
open https://orthanc.yourdomain.com

# atau
curl -s https://orthanc.yourdomain.com/system | jq '.Name'
```

#### Linux
```bash
# Browser
xdg-open https://orthanc.yourdomain.com

# Terminal
curl -s https://orthanc.yourdomain.com/system
```

### 3. Create Desktop Shortcut

#### Windows
1. Right-click desktop
2. New > Shortcut
3. Location: `https://orthanc.yourdomain.com`
4. Name: "Orthanc Server"

#### macOS
1. Finder
2. Applications > Utilities > Automator
3. New > Quick Action
4. Add "Run Shell Script"
5. Script: `open "https://orthanc.yourdomain.com"`
6. Save as "Open Orthanc"

#### Linux (Ubuntu)
```bash
# Create .desktop file
cat > ~/Desktop/Orthanc.desktop << 'EOF'
[Desktop Entry]
Version=1.0
Type=Application
Name=Orthanc Server
Exec=xdg-open https://orthanc.yourdomain.com
Icon=web-browser
Terminal=false
Categories=Network;WebBrowser;
EOF

# Make executable
chmod +x ~/Desktop/Orthanc.desktop
```

### 4. Network Configuration for Remote Access

#### Firewall Settings
```bash
# Ubuntu UFW
sudo ufw allow 443/tcp    # HTTPS
sudo ufw allow 80/tcp     # HTTP
sudo ufw allow 22/tcp     # SSH

# Enable UFW
sudo ufw enable
```

#### Router Configuration
1. Login ke router
2. Port Forwarding:
   - External Port: 80, 443
   - Internal IP: Server IP
   - Protocol: TCP
3. Enable UPnP (optional)

### 5. Testing Remote Access

#### Connection Test
```bash
# Test dari lokasi lain
ssh user@yourserver "curl -s https://localhost:8042/system"

# Test dengan curl
curl -v https://orthanc.yourdomain.com
```

#### Browser Test
1. Buka browser dari lokasi lain
2. Akses `https://orthanc.yourdomain.com`
3. Verify semua fitur berfungsi
4. Cek DICOM viewer
5. Test upload file

---

## Tutorial: Cara Akses dari Mobile

### 1. Mobile Setup Requirements

#### iOS Requirements
- iOS 12.0 atau lebih baru
- Safari browser
- Optional: iOS app (bukan resmi)

#### Android Requirements
- Android 8.0 atau lebih baru
- Chrome browser
- Optional: Android app

### 2. Browser Access

#### Mobile Web Browser
1. Buka browser mobile
2. Akses `https://orthanc.yourdomain.com`
3. Login jika diperlukan
4. Gunah interface yang responsive

#### Optimasi untuk Mobile
```css
/* Tambahkan ke CSS jika perlu */
@media (max-width: 768px) {
  .viewer-controls {
    font-size: 14px;
  }
  
  .thumbnail-grid {
    grid-template-columns: repeat(2, 1fr);
  }
}
```

### 3. Create Mobile-Only Access

#### Alternative Domain (Opsional)
```bash
# Buat subdomain khusus mobile
cloudflared tunnel route dns orthanc-tunnel mobile.orthanc.yourdomain.com
```

### 4. Mobile Apps (Experimental)

#### iOS Shortcut
1. Buka Shortcuts app
2. Create New Shortcut
3. Add "Open URL"
4. URL: `https://orthanc.yourdomain.com`
5. Add to Home Screen

#### Android Homescreen Shortcut
1. Chrome browser
2. Akses `https://orthanc.yourdomain.com`
3. Menu > Add to Home Screen
4. Customize shortcut name

### 5. Testing Mobile Access

#### Checklist Testing
- [ ] Load time < 3 seconds
- [ ] Touch/click responsive
- [ ] DICOM images load properly
- [ ] Zoom/pinch works
- [ ] Navigation menus accessible
- [ ] Forms work (upload, search)
- [ ] All buttons tappable

#### Performance Optimization
```bash
# Enable compression
curl -X POST "http://localhost:8042/system" \
  -H "Content-Type: application/json" \
  -d '{"HttpCompression": true}'
```

### 6. Offline Access (Opsional)

#### Cache Strategy
```javascript
// Service Worker for caching
const CACHE_NAME = 'orthanc-cache-v1';
const urlsToCache = [
  '/',
  '/app/main.js',
  '/css/style.css',
  '/images/icon.png'
];

self.addEventListener('install', event => {
  event.waitUntil(
    caches.open(CACHE_NAME)
      .then(cache => cache.addAll(urlsToCache))
  );
});
```

---

## Keamanan dan Best Practices

### 1. Security Configuration

#### Basic Security
```json
// orthanc.json
{
  "AuthenticationEnabled": true,
  "UserName": "admin",
  "Password": "your-strong-password-123",
  "AllowAnonymous": false,
  "Acl": {
    "DefaultUser": "reader",
    "Rules": [
      {
        "User": "admin",
        "Permissions": ["Read", "Write", "Anonymize", "Delete"]
      },
      {
        "User": "viewer",
        "Permissions": ["Read"]
      }
    ]
  }
}
```

#### HTTPS Configuration
```json
{
  "HttpsPort": 8443,
  "CertificateFile": "/etc/ssl/certs/orthanc.crt",
  "KeyFile": "/etc/ssl/private/orthanc.key"
}
```

### 2. Network Security

#### Firewall Rules
```bash
# Install UFW
sudo apt install ufw

# Default deny
sudo ufw default deny incoming
sudo ufw default allow outgoing

# Allow specific services
sudo ufw allow ssh
sudo ufw allow 8042/tcp
sudo ufw allow 8443/tcp
sudo ufw allow 4242/tcp

# Enable
sudo ufw enable
```

#### Fail2Ban Configuration
```bash
# Install fail2ban
sudo apt install fail2ban

# Create jail config
sudo nano /etc/fail2ban/jail.local

# Add configuration
[orthanc]
enabled = true
port = 8042,4242
filter = orthanc
logpath = /var/log/orthanc/orthanc.log
maxretry = 3
bantime = 1h
```

### 3. Data Security

#### Backup Strategy
```bash
#!/bin/bash
# backup-orthanc.sh

DATE=$(date +%Y%m%d_%H%M%S)
BACKUP_DIR="/backup/orthanc"

# Create backup
mkdir -p $BACKUP_DIR/$DATE

# Database backup
cp -r orthanc-data $BACKUP_DIR/$DATE/db

# Configuration backup
cp orthanc.json $BACKUP_DIR/$Date/config.json

# Compress
cd $BACKUP_DIR
tar -czf orthanc-$DATE.tar.gz $DATE

# Clean old backups (keep 30 days)
find . -name "orthanc-*.tar.gz" -mtime +30 -delete
```

#### Encryption for Backup
```bash
# Encrypt backup
openssl enc -aes-256-cbc -salt -in orthanc-$DATE.tar.gz -out orthanc-$DATE.enc
# Remove unencrypted
rm orthanc-$DATE.tar.gz
```

### 4. SSL/TLS Configuration

#### Cloudflare SSL Modes
1. **Off**: Tidak direkomendasikan
2. **Flexible**: HTTP ke Cloudflare, Cloudflare ke HTTP (tidak aman)
3. **Full**: HTTP ke Cloudflare, Cloudflare ke HTTPS (self-signed)
4. **Full (strict)**: HTTPS ke Cloudflare, HTTPS ke HTTPS (recommended)

#### Enable SSL Strict
```bash
# Update Cloudflare tunnel configuration
nano ~/.cloudflared/config.yml

# Tambahkan
tunnel: orthanc-tunnel
credentials-file: /home/user/.cloudflared/orthanc-tunnel.json

ingress:
  - hostname: orthanc.yourdomain.com
    service: http://localhost:8042
```

### 5. User Management

#### Role-Based Access
```json
{
  "Users": {
    "admin": {
      "Password": "admin-password",
      "IsReadOnly": false,
      "Acl": {
        "DefaultUser": "admin",
        "Rules": [
          {"Permissions": ["Read", "Write", "Anonymize", "Delete"]}
        ]
      }
    },
    "viewer": {
      "Password": "viewer-password",
      "IsReadOnly": true,
      "Acl": {
        "DefaultUser": "viewer",
        "Rules": [
          {"Permissions": ["Read"]}
        ]
      }
    }
  }
}
```

#### Session Management
```json
{
  "SessionsTimeout": 3600,  // 1 hour
  "EnableHttpSessions": true,
  "SessionsCleanup": true
}
```

---

## Troubleshooting

### 1. Common Issues

#### Port Already in Use
```bash
# Check port usage
sudo lsof -i :8042
sudo lsof -i :4242

# Kill process
sudo kill -9 <PID>

# Or change port in docker-compose.yml
ports:
  - "8043:8042"
```

#### Container Won't Start
```bash
# Check logs
docker-compose logs orthanc

# Check disk space
df -h

# Check memory
free -h

# Rebuild container
docker-compose down
docker-compose build --no-cache
docker-compose up -d
```

#### Cloudflare Tunnel Issues
```bash
# Check tunnel status
cloudflaced tunnel info orthanc-tunnel

# Check tunnel logs
sudo journalctl -u cloudflared -f

# Reset tunnel
cloudflared tunnel delete orthanc-tunnel
cloudflared tunnel create orthanc-tunnel
```

#### DICOM Connection Issues
```bash
# Test DICOM port
telnet localhost 4242
nc -zv localhost 4242

# Check DICOM configuration
curl -s http://localhost:8042/dicom-modes

# Test C-FIND
findscu localhost 4242 -k QueryRetrieveLevel=PATIENT -P "PatientName=*"
```

### 2. Network Troubleshooting

#### Connection Test
```bash
# Test from remote location
curl -v https://orthanc.yourdomain.com

# Test DNS
nslookup orthanc.yourdomain.com
dig orthanc.yourdomain.com

# Test TLS
openssl s_client -connect orthanc.yourdomain.com:443
```

#### Packet Capture
```bash
# Capture traffic
tcpdump -i any -s 0 -w orthanc.pcap 'port 8042 or port 4242'

# Analyze with Wireshark
wireshark orthanc.pcap
```

### 3. Performance Issues

#### Slow Performance
```bash
# Check system resources
htop
df -h
free -h

# Check Orthanc performance
curl -s http://localhost:8042/tools/performance

# Enable compression
curl -X POST "http://localhost:8042/system" \
  -H "Content-Type: application/json" \
  -d '{"HttpCompression": true}'
```

#### Memory Issues
```bash
# Monitor memory
docker stats orthanc-server

# Increase memory limits in docker-compose.yml
services:
  orthanc:
    deploy:
      resources:
        limits:
          memory: 4G
```

### 4. Recovery Procedures

#### Database Recovery
```bash
# Stop service
docker-compose down

# Backup
cp -r orthanc-data orthanc-data.backup

# Remove corrupted files
rm -f orthanc-data/index*
rm -f orthanc-data/journal/*

# Restart
docker-compose up -d
```

#### Configuration Recovery
```bash
# Restore from backup
cp orthanc-data.backup/* orthanc-data/

# Restart service
docker-compose restart
```

#### Tunnel Recovery
```bash
# Recreate tunnel
cloudflared tunnel delete orthanc-tunnel
cloudflared tunnel create orthanc-tunnel

# Update DNS
cloudflared tunnel route dns orthanc-tunnel orthanc.yourdomain.com

# Restart service
sudo systemctl restart cloudflared
```

---

## Monitoring dan Maintenance

### 1. Monitoring Setup

#### System Monitoring
```bash
# Install monitoring tools
sudo apt install htop iotop nethogs

# Monitor Docker
docker stats --no-stream

# Monitor logs
tail -f orthanc-data/index-wal
```

#### Health Check Script
```bash
#!/bin/bash
# health-check.sh

# Check Orthanc
if curl -s http://localhost:8042/system >/dev/null 2>&1; then
    echo "✓ Orthanc is running"
else
    echo "✗ Orthanc is down"
    docker-compose restart orthanc
fi

# Check Cloudflare tunnel
if cloudflared tunnel info orthanc-tunnel >/dev/null 2>&1; then
    echo "✓ Cloudflare tunnel is running"
else
    echo "✗ Cloudflare tunnel is down"
    sudo systemctl restart cloudflared
fi

# Check disk space
DISK_USAGE=$(df -h | grep -vE '^Filesystem|tmpfs|cdrom' | awk '{print $5}' | sed 's/%//')
if [ $DISK_USAGE -gt 80 ]; then
    echo "⚠ Disk usage is ${DISK_USAGE}%"
fi
```

### 2. Regular Maintenance

#### Daily Tasks
```bash
#!/bin/bash
# daily-maintenance.sh

# Check system health
./health-check.sh

# Log rotation (handled by docker)
# Cleanup temporary files
docker system prune -f

# Monitor backups
BACKUP_COUNT=$(ls -1 /backup/orthanc/ | grep "$(date +%Y%m%d)" | wc -l)
echo "Today's backups: $BACKUP_COUNT"
```

#### Weekly Tasks
```bash
#!/bin/bash
# weekly-maintenance.sh

# Full system backup
./backup-orthanc.sh

# Update Docker images
docker-compose pull
docker-compose up -d

# Update system
sudo apt update && sudo apt upgrade -y

# Check security
sudo fail2ban-client status
```

#### Monthly Tasks
```bash
#!/bin/bash
# monthly-maintenance.sh

# Comprehensive backup
tar -czf /backup/orthanc/monthly-$(date +%Y%m).tar.gz \
  orthanc-data/ \
  orthanc.json \
  docker-compose.yml

# Performance review
echo "Monthly Performance Report:"
echo "=========================="
curl -s http://localhost:8042/tools/statistics | jq .

# Security audit
sudo ufw status
sudo fail2ban-client status
```

### 3. Alert Setup

#### Email Notifications
```bash
#!/bin/bash
# alert.sh

EMAIL="admin@yourdomain.com"
SUBJECT="Orthanc Alert"
MESSAGE="$1"

# Send email
echo "$MESSAGE" | mail -s "$SUBJECT" $EMAIL

# Log
echo "$(date): $MESSAGE" >> /var/log/orthanc/alerts.log
```

#### Integration with Monitoring Services
```bash
# Prometheus metrics endpoint
curl -s http://localhost:8042/tools/statistics | jq . > metrics.json

# Push to monitoring service
curl -X POST "https://monitoring.yourdomain.com/api/v1/metrics" \
  -H "Content-Type: application/json" \
  -d @metrics.json
```

### 4. Disaster Recovery

#### Backup Strategy
```bash
# 3-2-1 Backup Strategy
# - 3 copies of data
# - 2 different media types
# - 1 offsite backup

# Daily backups to local disk
# Weekly backups to cloud storage
# Monthly backups to external drive
```

#### Recovery Plan
1. **Data Recovery**: Use latest backup
2. **System Recovery**: Restore configuration
3. **Service Recovery**: Restart services
4. **Verification**: Test all functionality
5. **Monitoring**: Watch for issues

```bash
#!/bin/bash
# disaster-recovery.sh

# 1. Stop services
docker-compose down

# 2. Restore from backup
cp /backup/orthanc/latest/orthanc-data/* orthanc-data/

# 3. Restore configuration
cp /backup/orthanc/latest/orthanc.json orthanc.json

# 4. Start services
docker-compose up -d

# 5. Verify
curl -s http://localhost:8042/system
```

---

## Kesimpulan

### Checklist Deployment
- [ ] Server specifications met
- [ ] Docker installed and configured
- [ ] Orthanc running locally
- [ ] Cloudflare account configured
- [ ] Tunnel created and running
- [ ] DNS records set
- [ ] SSL/TLS configured
- [ ] Firewall rules applied
- [ ] User authentication enabled
- [ ] Backup system in place
- [ ] Monitoring configured

### Next Steps
1. **Train users** on the system
2. **Establish workflows** for DICOM handling
3. **Implement integration** with other systems
4. **Regular maintenance** schedule
5. **Security audits** periodically

### Resources
- [Orthanc Documentation](https://orthanc.uclouvain.be/book/)
- [Cloudflare Documentation](https://developers.cloudflare.com/cloudflare-one/)
- [DICOM Standard](https://medical.nema.org/)
- [HIPAA Guidelines](https://www.hhs.gov/hipaa/for-professionals/index.html)

---

**Catatan**: Tutorial ini dirancang untuk membantu pemula menginstall dan mengkonfigurasi Orthanc server dengan akses online yang aman. Pastikan untuk mengikuti semua langkah dengan hati-hati dan melakukan backup data secara rutin.