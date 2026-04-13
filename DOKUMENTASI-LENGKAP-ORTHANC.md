# Panduan Lengkap Orthanc DICOM Server - Dari Awal Hingga Selesai

Selamat datang di panduan lengkap dan terintegrasi untuk Orthanc, server DICOM yang ringan dan RESTful! Dokumentasi ini dirancang khusus untuk pemula dan mencakup semuanya dari perencanaan, instalasi, konfigurasi, hingga deployment produksi.

## 📚 Daftar Isi

### BAGIAN 1: PERKENALAN & PERSIAPAN
- **[Pengenalan Orthanc](#pengenalan-orthanc)** - Apa itu Orthanc dan kenapa menggunakannya
- **[Ringkasan Panduan Ini](#ringkasan-panduan-ini)** - Cara membaca dan menggunakan panduan ini

### BAGIAN 2: SETUP DASAR (Langkah 1-10)
1. **[01. Spesifikasi Sistem & Requirements](#1-spesifikasi-sistem--requirements)**
   - Hardware requirements
   - Software requirements
   - Resource planning
   - Compatibility

2. **[02. Alat dan Perlengkapan](#2-alat-dan-perlengkapan)**
   - Checklist tools
   - Installation guide
   - Environment setup
   - Testing tools

3. **[03. Konfigurasi Jaringan](#3-konfigurasi-jaringan)**
   - Local network setup
   - Port forwarding
   - Cloudflare Tunnel
   - Firewall configuration

4. **[04. Dokumentasi REST API](#4-dokumentasi-rest-api)**
   - API overview
   - Authentication
   - Endpoints reference
   - Usage examples

5. **[05. Memasang & Menggunakan Plugin](#5-memasang--menggunakan-plugin)**
   - Plugin types
   - Installation guide
   - Configuration
   - Management

6. **[06. Konfigurasi PACS](#6-konfigurasi-pacs)**
   - DICOM networking
   - SCP/SCU setup
   - Integration guide
   - Data routing

7. **[07. Konfigurasi Inti Orthanc](#7-konfigurasi-inti-orthanc)**
   - Configuration file
   - Essential settings
   - Database setup
   - Optimization

8. **[08. Akses Lokal](#8-akses-lokal)**
   - Localhost access
   - LAN access
   - DNS configuration
   - Troubleshooting

9. **[09. Akses Online/Remote](#9-akses-onlineremote)**
   - Cloudflare setup
   - SSL/TLS configuration
   - Security best practices
   - Monitoring

10. **[10. Troubleshooting](#10-troubleshooting)**
    - Common issues
    - Debugging tools
    - Recovery procedures
    - Next steps

### BAGIAN 3: PANDUAN LANJUTAN (Referensi 11-15)
- **[11. Panduan Lengkap Orthanc](#11-panduan-lengkap-orthanc)** - Referensi detail lengkap
- **[12. Referensi Cepat Orthanc](#12-referensi-cepat-orthanc)** - Command dan cheat sheet
- **[13. Guide Plugin Lengkap](#13-guide-plugin-lengkap)** - Plugin advanced dan development
- **[14. Guide Web Interface](#14-guide-web-interface)** - Tutorial penggunaan aplikasi web
- **[15. Setup Lengkap untuk Pemula](#15-setup-lengkap-untuk-pemula)** - Overview keseluruhan

---

## 🎯 Cara Menggunakan Panduan Ini

### Pemula (Belum Pernah Menggunakan Orthanc)
1. Baca **[Ringkasan Panduan Ini](#ringkasan-panduan-ini)**
2. Ikuti **BAGIAN 2: SETUP DASAR** dari langkah 1-10
3. Pelajari dengan **[14. Guide Web Interface](#14-guide-web-interface)**

### Administrator/Sysadmin
1. Ikuti **BAGIAN 2: SETUP DASAR** lengkap
2. Fokus ke **[06. Konfigurasi PACS](#6-konfigurasi-pacs)** dan **[09. Akses Online](#9-akses-onlineremote)**
3. Gunakan **[12. Referensi Cepat Orthanc](#12-referensi-cepat-orthanc)** untuk troubleshooting

### Developer
1. Baca **[04. Dokumentasi REST API](#4-dokumentasi-rest-api)** lengkap
2. Pelajari **[11. Panduan Lengkap Orthanc](#11-panduan-lengkap-orthanc)** untuk detail
3. Lihat **[13. Guide Plugin Lengkap](#13-guide-plugin-lengkap)** untuk development

---

## 💡 Tips Penting

- ✅ **Baca semua instruksi** sebelum memulai instalasi
- ✅ **Lakukan backup** data penting sebelum perubahan
- ✅ **Test setiap langkah** sebelum melanjutkan
- ✅ **Catat semua password** dan informasi kredensial
- ✅ **Simpan konfigurasi** di lokasi yang mudah diakses

---

# 01. Spesifikasi Sistem & Requirements

## 📋 Apa yang akan Anda Pelajari

- Persyaratan hardware minimal dan recommended
- Kompatibilitas sistem operasi
- Software yang perlu di-install sebelum mulai
- Resource requirements untuk berbagai skala penggunaan
- Pentingnya persiapan sebelum instalasi

---

## 🖥️ Spesifikasi Hardware

### Minimum Requirements (Untuk Learning/Development)
```
CPU: Intel Core i3 / AMD Ryzen 3 (dual-core)
RAM: 4GB DDR4
Storage: 50GB SSD (atau HDD yang cukup cepat)
GPU: Built-in graphics (tanpa GPU dedicated)
Network: Broadband internet (minimal 10Mbps)
```

### Recommended Requirements (Untuk Production/SKALA KECIL)
```
CPU: Intel Core i5 / AMD Ryzen 5 (quad-core, 4 threads)
RAM: 8GB DDR4 (minimal 16GB jika banyak pengguna)
Storage: 100GB SSD (dapat diperluas)
GPU: GPU dedicated 2GB (untuk rendering gambar)
Network: Fiber atau broadband stabil (minimal 50Mbps)
```

### Production Requirements (Untuk SKALA MENENGAH/BESAR)
```
CPU: Intel Core i7 / AMD Ryzen 7 (6+ cores)
RAM: 32GB+ DDR4
Storage: 500GB SSD + 1TB+ HDD untuk archive
GPU: NVIDIA RTX 3060 / AMD RX 6600 XT (6GB VRAM)
Network: Fiber dedicated (100Mbps+)
Redundancy: Power supply, RAID storage
```

---

## 💻 Kompatibilitas Sistem Operasi

### Windows
- **Windows 10** (Version 2004 atau lebih baru)
- **Windows 11** (Semua version)
- **Windows Server 2019** (Untuk production)
- **Windows Server 2022** (Terbaru)

### Linux (DIREKOMENDASIKAN)
- **Ubuntu 20.04 LTS** (Long Term Support)
- **Ubuntu 22.04 LTS** (Terbaru)
- **Debian 11** (Buster)
- **CentOS 8 / Rocky Linux 8**
- **Fedora 36+**

### macOS
- **macOS Big Sur** (11.6+)
- **macOS Monterey** (12.6+)
- **macOS Ventura** (13.0+)
- **Apple Silicon** (M1/M2) supported

---

## 📦 Software Requirements

### Wajib (Required)
1. **Docker Desktop**
   - Versi 20.10 atau lebih baru
   - Docker Compose included
   - Wajib untuk semua OS

2. **Web Browser**
   - Chrome 90+
   - Firefox 88+
   - Safari 14+
   - Edge 90+

3. **Text Editor**
   - Visual Studio Code (direkomendasikan)
   - Sublime Text
   - Notepad++ (Windows)
   - vim/nano (Linux)

### Opsional (Tapi Sangat Direkomendasikan)
1. **DICOM Viewer**
   - RadiAnt (Windows)
   - OsiriX (macOS)
   - Horos (macOS/Linux)
   - ImageJ (Cross-platform)

2. **Network Tools**
   - PuTTY (Windows SSH)
   - WinSCP (Windows file transfer)
   - FileZilla (FTP/SFTP)

3. **Monitoring Tools**
   - HTOP (Linux)
   - Task Manager (Windows)
   - Activity Monitor (macOS)

4. **Backup Tools**
   - Duplicati
   - rsync (Linux/macOS)
   - Cobian Backup (Windows)

---

## ⚡ Resource Requirements by Usage

### Learning/Laboratorium
- **Pengguna**: 1-3 orang
- **Data per hari**: < 1GB
- **Storage total**: 50-100GB
- **RAM**: 4-8GB
- **CPU**: 2-4 cores

### Klinik/Kesatuan Kesehatan Kecil
- **Pengguna**: 5-20 orang
- **Data per hari**: 1-5GB
- **Storage total**: 200-500GB
- **RAM**: 8-16GB
- **CPU**: 4-6 cores
- **Network**: 50Mbps+ recommended

### Rumah Sakit Menengah
- **Pengguna**: 20-100 orang
- **Data per hari**: 5-20GB
- **Storage total**: 1-5TB
- **RAM**: 16-32GB
- **CPU**: 6-12 cores
- **Network**: 100Mbps+ recommended
- **Redundancy**: Harus ada

### Rumah Sakit Besar/Pusat
- **Pengguna**: 100+ orang
- **Data per hari**: 20-100GB+
- **Storage total**: 5TB+
- **RAM**: 32GB+
- **CPU**: 12+ cores
- **Network**: 1Gbps+ dedicated
- **Redundancy**: Full redundancy

---

## 🧪 Persiapan Sebelum Instalasi

### 1. Checklist Sistem
```bash
# Untuk Linux
uname -a          # Info kernel dan OS
free -h            # RAM usage
df -h             # Disk space
docker --version  # Docker version

# Untuk Windows
# Open Command Prompt and run:
systeminfo        # System information
wmic computersystem get TotalPhysicalMemory  # RAM
wmic logicaldisk get size,freespace,caption  # Disk
docker --version  # Docker version
```

### 2. Cleanup Sistem
```bash
# Linux
sudo apt clean
sudo apt autoremove
docker system prune -f

# Windows
# Use Disk Cleanup utility
# Delete temporary files
```

### 3. Network Configuration
```bash
# Check internet connection
ping google.com
curl -I https://www.google.com

# Check hostname
hostname
# Set if needed (Linux)
sudo hostnamectl set-hostname orthanc-server
```

### 4. Create Project Directory
```bash
# Create main directory
mkdir -p ~/orthanc-server
cd ~/orthanc-server

# Create necessary folders
mkdir -p {orthanc-data,backups,plugins,scripts,logs}
```

---

## ⚠️ Penting! Before You Start

### 1. Backup Existing Data
- Backup semua data medis yang ada
- Export konfigurasi sistem yang sudah ada
- Simpan database yang sudah ada

### 2. Security Considerations
- **Jangan gunakan password default**
- **Update semua software ke versi terbaru**
- **Install firewall dan antivirus**
- **Disable services tidak perlu**

### 3. Storage Planning
- **Gunakan SSD untuk database**
- **Pisahkan data dan sistem operasi**
- **Plan untuk future growth**
- **Backup strategy yang jelas**

### 4. Documentation
- **Cat semua konfigurasi**
- **Simpan semua password dan credential**
- **Buat dokumentasi perubahan**
- **Test semua sebelum production**

---

## 🔄 Post-Installation Requirements

### 1. Initial Setup
- Install Docker
- Test Docker installation
- Create basic configuration
- Start Orthanc service

### 2. Network Configuration
- Configure port forwarding
- Setup firewall rules
- Test local access
- Configure remote access

### 3. Data Migration (If needed)
- Import existing DICOM files
- Validate data integrity
- Test all operations
- Monitor performance

### 4. User Training
- Train all users
- Create documentation
- Establish workflows
- Set maintenance schedule

---

## 📞 Bantuan

### Jika Mengalami Masalah dengan Spesifikasi
1. Periksa [Requirements Resmi Orthanc](https://orthanc.uclouvain.be/book/users/introduction.html)
2. Cek [Docker Requirements](https://docs.docker.com/get-docker/)
3. Tanyakan di forum komunitas

### Hardware Recommendation
- **Untuk learning**: Laptop/desktop biasa
- **Untuk production**: Server dengan redundansi
- **Untuk large scale**: Cluster dengan load balancing

---

## 📋 Checklist untuk Mulai

- [ ] Memeriksa spesifikasi sistem
- [ ] Menginstall Docker
- [ ] Membuat project directory
- [ ] Melakukan backup sistem
- [ ] Membuat plan storage
- [ ] Menyiapkan credential
- [ ] Melakukan test network

---

**🎯 Selanjutnya**: [02-Alat dan Perlengkapan](./02-Alat-dan-Perlengkapan.md) - Siapkan semua tools yang dibutuhkan untuk instalasi Orthanc!# 02. Alat dan Perlengkapan Checklist

## 📋 Apa yang akan Anda Pelajari

- Daftar lengkap software yang dibutuhkan
- Cara install setiap alat
- Ketersediaan alternatif untuk setiap tool
- Setup lingkungan kerja yang optimal
- Tools untuk monitoring dan maintenance

---

## 🛠️ Software Wajib (Mandatory)

### 1. Docker Desktop
**Fungsi**: Container platform untuk menjalankan Orthanc

**Download & Install**:
```bash
# Linux (Ubuntu)
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh
sudo usermod -aG docker $USER
# Logout dan login kembali

# Windows
Download: https://www.docker.com/products/docker-desktop
- Install sebagai Administrator
- Enable WSL 2 integration

# macOS
Download dari App Store
- Requires macOS Big Sur or later
- Apple Silicon (M1/M2) supported
```

**Verifikasi Instalasi**:
```bash
docker --version
docker run hello-world
```

### 2. Docker Compose
**Fungsi**: Orchestration untuk multi-container applications

**Install**:
```bash
# Linux
sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose

# Windows & macOS
Included with Docker Desktop
```

**Verifikasi**:
```bash
docker-compose --version
```

### 3. Web Browser
**Fungsi**: Interface untuk mengakses Orthanc Web UI

**Pilihan Browser**:
- **Google Chrome** (Recommended): Sertakan render terbaik
- **Mozilla Firefox**: Open source, ekstensi banyak
- **Microsoft Edge**: Built-in Windows
- **Safari**: Untuk pengguna Apple

**Verifikasi**:
```bash
# Buka browser dan akses:
http://localhost:8042
```

### 4. Text Editor
**Fungsi**: Edit konfigurasi file

**Pilihan Editor**:
- **Visual Studio Code** (Highly Recommended)
  - Download: https://code.visualstudio.com/
  - Install extensions: Docker, JSON, Markdown
- **Sublime Text**
- **Notepad++** (Windows)
- **Vim/Neovim** (Linux)
- **Nano** (Linux CLI)

**Setup VS Code**:
```bash
# Install extensions
code --install-extension ms-vscode.docker
code --install-extension ms-python.python
code --install-extension esbenp.prettier-vscode
```

---

## 📦 Software Opsional (Tapi Sangat Direkomendasikan)

### 1. DICOM Viewer Tools
**Fungsi**: View dan analyze DICOM images

**Pilihan Viewer**:
- **RadiAnt** (Windows)
  - Download: https://www.radiantviewer.com/
  - Free untuk non-commercial use
- **OsiriX** (macOS)
  - Download: https://www.osirix-viewer.com/
  - Free license untuk education
- **Horos** (macOS/Linux)
  - Open source alternative
- **ImageJ/Fiji**
  - Cross platform
  - Untuk analysis lanjutan

### 2. Network Tools
**Fungsi**: Diagnostic dan network configuration

**Pilihan Tools**:
- **PuTTY** (Windows SSH)
  - Download: https://www.putty.org/
- **WinSCP** (File transfer)
  - Download: https://winscp.net/
- **WireShark** (Packet analysis)
  - Download: https://www.wireshark.org/
- **Telnet/Netcat**
  - Built-in di Linux/macOS
  - Windows: Install Telnet client

### 3. Monitoring Tools
**Fungsi**: Monitor sistem performance

**Pilihan Tools**:
- **HTOP** (Linux)
  ```bash
  sudo apt install htop
  ```
- **Task Manager** (Windows)
  - Built-in (Ctrl+Shift+Esc)
- **Activity Monitor** (macOS)
  - Built-in
- **Grafana + Prometheus**
  - Untuk monitoring advanced

---

## ☁️ Cloud Services (Opsional)

### 1. Cloudflare Account
**Fungsi**: Gratis SSL dan reverse proxy untuk akses remote

**Setup**:
1. Register di [cloudflare.com](https://cloudflare.com)
2. Add domain Anda
3. Install Cloudflared CLI:
```bash
# Linux
wget https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-amd64.deb
sudo dpkg -i cloudflared-linux-amd64.deb

# Cloudflared CLI setup
cloudflared tunnel login
```

### 2. Storage Cloud (Opsional)
**Fungsi**: Backup dan archive data

**Pilihan Provider**:
- **AWS S3**: Standard untuk enterprise
- **Google Cloud Storage**: Skalable
- **Azure Blob Storage**: Integrasi MS
- **Backblaze B2**: Harga kompetitif

---

## 🔧 Development Tools

### 1. Version Control (Git)
**Fungsi**: Track changes dan kolaborasi

**Install**:
```bash
# Linux
sudo apt install git

# Windows
Download: https://git-scm.com/download/win

# macOS
```bash
brew install git
```

**Setup**:
```bash
git config --global user.name "Your Name"
git config --global user.email "your@email.com"
```

### 2. API Testing Tools
**Fungsi**: Test Orthanc REST API

**Pilihan Tools**:
- **Postman**
  - Download: https://www.postman.com/
- **Insomnia**
  - Open source alternative
- **curl** (Command line)
- **HTTPie** (Command line)

### 3. Scripting Languages
**Fungsi**: Otomasi dan custom workflows

**Python**:
```bash
# Install Python
sudo apt install python3 python3-pip

# Install useful packages
pip3 install requests pydicom pandas
```

**Lua** (Untuk Orthanc scripting):
```bash
# Install Lua
sudo apt install lua5.3

# Install luarocks (package manager)
sudo apt install luarocks
```

---

## 📁 Struktur Folder yang Direkomendasikan

### Setup Struktur
```bash
# Main directory
~/orthanc-server/
├── docker-compose.yml          # Main configuration
├── orthanc.json               # Orthanc configuration
├── orthanc-data/              # Persistent data
│   ├── db/                   # SQLite database
│   └── storage/              # DICOM files
├── plugins/                   # Custom plugins
├── scripts/                   # Automation scripts
│   ├── backup.sh            # Backup script
│   ├── restore.sh           # Restore script
│   └── monitor.sh          # Monitoring script
├── backups/                   # Backup location
├── logs/                      # Log files
│   ├── orthanc.log          # Orthanc logs
│   └── access.log           # Access logs
├── samples/                   # Sample DICOM files
├── documentation/             # Documentation
│   ├── README.md
│   └── configs/
└── certificates/              # SSL certificates
```

### Create Directory Structure
```bash
# Create all necessary directories
cd ~/orthanc-server
mkdir -p {orthanc-data/{db,storage},plugins,scripts,backups,logs,samples,documentation/configs,certificates}

# Create necessary files
touch docker-compose.yml orthanc.json
touch scripts/{backup.sh,restore.sh,monitor.sh}
chmod +x scripts/*.sh
```

---

## ⚙️ Konfigurasi Awal

### 1. Environment Setup
```bash
# Create .env file
cat > .env << 'EOF'
# Orthanc Configuration
ORTHANC_VERSION=latest
ORTHANC_HTTP_PORT=8042
ORTHANC_DICOM_PORT=4242
ORTHANC_DATA_PATH=./orthanc-data
ORTHANC_BACKUP_PATH=./backups

# Database
DB_TYPE=sqlite
DB_PATH=./orthanc-data/db

# Monitoring
ENABLE_MONITORING=true
LOG_LEVEL=info
EOF
```

### 2. Create Basic Scripts
```bash
#!/bin/bash
# scripts/health-check.sh

echo "=== Health Check ==="
echo "Docker status:"
docker ps | grep orthanc

echo -e "\nOrthanc API:"
curl -s http://localhost:8042/system | jq -r '.Name'

echo -e "\nDisk usage:"
df -h | grep orthanc-data

echo -e "\nMemory usage:"
free -h
```

### 3. Configuration Templates
```bash
# Create template files
mkdir -p templates

# Template docker-compose.yml
cat > templates/docker-compose.yml.template << 'EOF'
version: '3.8'

services:
  orthanc:
    image: jodogne/orthanc-plugins:${ORTHANC_VERSION}
    container_name: orthanc-server
    restart: unless-stopped
    ports:
      - "${ORTHANC_HTTP_PORT}:8042"
      - "${ORTHANC_DICOM_PORT}:4242"
    volumes:
      - ${ORTHANC_DATA_PATH}:/var/lib/orthanc/db
      - ./plugins:/usr/share/orthanc/plugins
      - ./logs:/var/log/orthanc
    environment:
      - ORTHANCPlugins=/usr/share/orthanc/plugins
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:8042/system"]
      interval: 30s
      timeout: 10s
      retries: 3
EOF
```

---

## 🧪 Testing Tools

### 1. System Test Script
```bash
#!/bin/bash
# scripts/test-system.sh

echo "=== System Test ==="
echo "1. Docker test:"
docker --version && docker-compose --version

echo -e "\n2. Network test:"
ping -c 3 google.com
curl -s https://www.google.com > /dev/null && echo "✓ Internet OK"

echo -e "\n3. Storage test:"
touch test_file && rm test_file && echo "✓ Storage OK"

echo -e "\n4. Memory test:"
free -h

echo -e "\n5. CPU test:"
nproc
```

### 2. Pre-Installation Checklist
```bash
#!/bin/bash
# scripts/pre-install-check.sh

echo "=== Pre-Installation Checklist ==="

# Check Docker
if docker --version > /dev/null 2>&1; then
    echo "✓ Docker installed"
else
    echo "✗ Docker not installed"
    exit 1
fi

# Check Disk Space
DISK_AVAILABLE=$(df -h . | awk 'NR==2 {print $4}' | sed 's/[Gg]//')
if (( $(echo "$DISK_AVAILABLE > 10" | bc -l) )); then
    echo "✓ Disk space OK (${DISK_AVAILABLE}GB available)"
else
    echo "✗ Insufficient disk space (${DISK_AVAILABLE}GB available)"
fi

# Check Memory
MEM_AVAILABLE=$(free -m | awk 'NR==2{printf "%.1f", $7/1024}')
if (( $(echo "$MEM_AVAILABLE > 2" | bc -l) )); then
    echo "✓ Memory OK (${MEM_AVAILABLE}GB available)"
else
    echo "✗ Insufficient memory (${MEM_AVAILABLE}GB available)"
fi

echo "=== Check Complete ==="
```

---

## 📦 Package Management

### 1. System Packages (Linux)
```bash
# Ubuntu/Debian
sudo apt update
sudo apt install -y \
    curl wget git \
    htop net-tools \
    sqlite3 \
    python3 python3-pip \
    luarocks

# CentOS/RHEL
sudo yum update -y
sudo yum install -y \
    curl wget git \
    htop net-tools \
    sqlite \
    python3 python3-pip \
    epel-release
```

### 2. Python Packages
```bash
pip3 install requests pydicom pandas
pip3 install django flask  # Untuk web interface
```

---

## 🔐 Security Tools

### 1. Firewall Configuration
```bash
# Ubuntu UFW
sudo apt install ufw
sudo ufw default deny incoming
sudo ufw default allow outgoing
sudo ufw allow ssh
sudo ufw allow 8042/tcp
sudo ufw allow 4242/tcp
sudo ufw enable
```

### 2. Fail2Ban (Opsional)
```bash
sudo apt install fail2ban
# Configuration in /etc/fail2ban/jail.local
```

---

## 📞 Support and Resources

### Official Documentation
- [Orthanc Book](https://orthanc.uclouvain.be/book/)
- [Docker Documentation](https://docs.docker.com/)
- [Cloudflare Documentation](https://developers.cloudflare.com/)

### Community Resources
- [Orthanc Forum](https://www.orthanc-server.com/forum/)
- [Docker Community](https://forums.docker.com/)
- Stack Overflow with tags: `orthanc`, `dicom`, `docker`

---

## 📋 Checklist Tools yang Terinstall

- [ ] Docker Desktop
- [ ] Docker Compose
- [ ] Web Browser (Chrome/Firefox)
- [ ] Text Editor (VS Code)
- [ ] DICOM Viewer (RadiAnt/OsiriX)
- [ ] Network Tools (PuTTY/WinSCP)
- [ ] Monitoring Tools (HTOP)
- [ ] Version Control (Git)
- [ ] API Testing Tools (Postman)
- [ ] Cloudflare Account (untuk akses remote)

---

**🎯 Selanjutnya**: [03-Konfigurasi Jaringan](./03-Konfigurasi-Jaringan.md) - Setup jaringan dan konfigurasi akses remote dengan Cloudflare Tunnel!# 03. Konfigurasi Jaringan

## 📋 Apa yang akan Anda Pelajari

- Konsep dasar jaringan untuk Orthanc
- Konfigurasi lokal (LAN)
- Setup Cloudflare Tunnel untuk akses remote
- Konfigurasi firewall dan security
- Network troubleshooting dasar
- Best practices untuk production

---

## 🌐 Konsep Jaringan Dasar

### 1. Port yang Dibutuhkan
```yaml
HTTP/REST API: 8042  # Web interface dan REST API
DICOM: 4242          # Transfer file medis
HTTPS: 8443         # Secure connection (opsional)
SSH: 22             # Remote administration
```

### 2. Network Topology
```
[Client Device] -- [Internet] -- [Router/Firewall] -- [Server Orthanc]
                      |
                 [Cloudflare] -- [Tunnel] -- [Server Orthanc]
```

### 3. IP Address Types
- **Localhost**: 127.0.0.1 (komputer sendiri)
- **Private IP**: 192.168.x.x, 10.x.x.x, 172.16-31.x.x
- **Public IP**: IP yang bisa diakses dari internet

---

## 🔧 Konfigurasi Lokal (LAN)

### 1. Cek Network Configuration
```bash
# Linux/macOS
ip addr show                    # Tampilkan semua interface
hostname -I                     # IP lokal
ip route show default           # Gateway default

# Windows
ipconfig                      # Windows Command Prompt
ipconfig /all                 # Detail network information
```

### 2. Static IP Configuration
#### Ubuntu/Debian
```bash
# Edit netplan
sudo nano /etc/netplan/01-netcfg.yaml

# Konfigurasi example
network:
  version: 2
  ethernets:
    enp0s3:  # Ganti dengan interface Anda
      dhcp4: no
      addresses: [192.168.1.100/24]
      gateway4: 192.168.1.1
      nameservers:
          addresses: [8.8.8.8, 1.1.1.1]
      optional: true

# Apply changes
sudo netplan apply
```

#### Windows
1. Control Panel > Network and Sharing Center
2. Change adapter settings
3. Right-click on network adapter > Properties
4. Internet Protocol Version 4 (TCP/IPv4) > Properties
5. Use the following IP address:
   - IP address: 192.168.1.100
   - Subnet mask: 255.255.255.0
   - Default gateway: 192.168.1.1
   - DNS servers: 8.8.8.8, 1.1.1.1

### 3. Port Forwarding di Router
#### Cek Router IP
```bash
# Linux/macOS
ip route | grep default | awk '{print $3}'

# Windows
route print | findstr "0.0.0.0"
```

#### Login ke Router
1. Buka browser
2. Akses `http://192.168.1.1` atau `http://192.168.0.1`
3. Login dengan username/password (biasanya admin/admin)

#### Setup Port Forwarding
```yaml
# Contoh konfigurasi
Service Name: Orthanc-HTTP
External Port: 8042
Internal IP: 192.168.1.100
Internal Port: 8042
Protocol: TCP
Enable: Yes

Service Name: Orthanc-DICOM
External Port: 4242
Internal IP: 192.168.1.100
Internal Port: 4242
Protocol: TCP
Enable: Yes
```

### 4. Firewall Configuration
#### Ubuntu UFW
```bash
# Install UFW jika belum terinstall
sudo apt update
sudo apt install ufw

# Default policy
sudo ufw default deny incoming
sudo ufw default allow outgoing

# Allow specific ports
sudo ufw allow ssh                    # Port 22
sudo ufw allow 8042/tcp                # Orthanc HTTP
sudo ufw allow 4242/tcp                # Orthanc DICOM
sudo ufw allow 8443/tcp                # Orthanc HTTPS

# Enable firewall
sudo ufw enable

# Check status
sudo ufw status
```

#### Windows Firewall
```powershell
# PowerShell
New-NetFirewallRule -Name "Orthanc-HTTP" -DisplayName "Orthanc HTTP" -Direction Inbound -Protocol TCP -LocalPort 8042 -Action Allow
New-NetFirewallRule -Name "Orthanc-DICOM" -DisplayName "Orthanc DICOM" -Direction Inbound -Protocol TCP -LocalPort 4242 -Action Allow

# Atau melalui GUI:
# Control Panel > System and Security > Windows Defender Firewall
# > Advanced Settings > Inbound Rules > New Rule...
```

---

## ☁️ Setup Cloudflare Tunnel

### 1. Persiapan Cloudflare
#### Buat Akun Cloudflare
1. Kunjungi [cloudflare.com](https://cloudflare.com)
2. Register atau login
3. Add domain Anda
4. Update nameserver ke Cloudflare
5. Install Cloudflare CLI di server

#### Install Cloudflared
```bash
# Download cloudflared
wget https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-amd64.deb
sudo dpkg -i cloudflared-linux-amd64.deb

# Verify installation
cloudflared --version
```

### 2. Login ke Cloudflare
```bash
# Login ke Cloudflare account
cloudflared tunnel login

# Anda akan mendapatkan link untuk login
# Buka link tersebut dan login dengan account Cloudflare Anda
```

### 3. Create Tunnel
```bash
# Buat tunnel baru
cloudflared tunnel create orthanc-tunnel

# Output akan menampilkan:
# Tunnel credentials written to /home/user/.cloudflared/orthanc-tunnel.json
# Tunnel ID: xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx
```

### 4. Configuration File
```bash
# Buat directory untuk config
mkdir -p ~/.cloudflared

# Edit configuration
nano ~/.cloudflared/config.yml

# Tambahkan konfigurasi:
tunnel: orthanc-tunnel
credentials-file: /home/user/.cloudflared/orthanc-tunnel.json

ingress:
  # Main service
  - hostname: orthanc.yourdomain.com
    service: http://localhost:8042
    
  # DICOM service (jika perlu)
  - hostname: dicom.yourdomain.com
    service: http://localhost:4242
    
  # Fallback untuk tidak dikenal
  - service: http_status:404
```

### 5. Setup DNS Records
```bash
# Update DNS dengan tunnel credentials
cloudflared tunnel route dns orthanc-tunnel orthanc.yourdomain.com

# Juga untuk DICOM jika diinginkan
# cloudflared tunnel route dns orthanc-tunnel dicom.yourdomain.com
```

### 6. Create Systemd Service
```bash
# Create service file
sudo nano /etc/systemd/system/cloudflared.service

# Tambahkan konfigurasi:
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

### 7. Enable dan Start Service
```bash
# Reload systemd
sudo systemctl daemon-reload

# Enable service
sudo systemctl enable cloudflared

# Start service
sudo systemctl start cloudflared

# Check status
sudo systemctl status cloudflared

# Enable auto-start on boot
sudo systemctl enable cloudflared
```

### 8. SSL/TLS Configuration di Cloudflare
1. Login ke Cloudflare dashboard
2. Pilih domain Anda
3. Menu SSL/TLS > Overview
4. Set mode ke **Full (strict)** untuk keamanan maksimal

---

## 🔒 Security Configuration

### 1. Basic Security Checklist
```bash
# Disable unused services
sudo systemctl stop telnet.socket
sudo systemctl disable telnet.socket

# Update system
sudo apt update && sudo apt upgrade -y

# Install security tools
sudo apt install -y fail2ban logcheck

# Configure fail2ban
sudo nano /etc/fail2ban/jail.local

# Add configuration:
[DEFAULT]
bantime = 1h
findtime = 10m
maxretry = 5

[orthanc]
enabled = true
port = 8042,4242
filter = orthanc
logpath = /var/log/orthanc/orthanc.log
maxretry = 3
bantime = 1h
```

### 2. Network Security
```bash
# Install and configure ufw
sudo apt install ufw

# Allow only necessary services
sudo ufw default deny incoming
sudo ufw default allow outgoing

# Allow SSH (jika diperlukan)
sudo ufw allow 'OpenSSH'

# Allow Orthanc ports
sudo ufw allow 8042/tcp
sudo ufw allow 4242/tcp

# Enable firewall
sudo ufw enable

# Check status
sudo ufw status verbose
```

### 3. SSL/TLS Configuration
#### Generate Self-Signed Certificate (Opsional)
```bash
# Generate certificate
openssl req -x509 -newkey rsa:4096 -keyout orthanc.key -out orthanc.crt -days 365 -nodes

# Pindahkan ke lokasi yang aman
sudo mkdir -p /etc/ssl/certs /etc/ssl/private
sudo cp orthanc.crt /etc/ssl/certs/
sudo cp orthanc.key /etc/ssl/private/

# Update permissions
sudo chmod 600 /etc/ssl/private/orthanc.key
```

#### Update Docker Compose untuk HTTPS
```yaml
# docker-compose.yml
services:
  orthanc:
    image: jodogne/orthanc-plugins:latest
    container_name: orthanc-server
    restart: unless-stopped
    ports:
      - "8042:8042"
      - "8443:8443"    # HTTPS port
    volumes:
      - ./orthanc-data:/var/lib/orthanc/db
      - ./plugins:/usr/share/orthanc/plugins
      - /etc/ssl/certs/orthanc.crt:/etc/ssl/certs/orthanc.crt
      - /etc/ssl/private/orthanc.key:/etc/ssl/private/orthanc.key
    environment:
      - ORTHANCPlugins=/usr/share/orthanc/plugins
```

#### Update Orthanc Configuration
```json
// orthanc.json
{
  "Name": "Orthanc Server",
  "HttpPort": 8042,
  "HttpsPort": 8443,
  "CertificateFile": "/etc/ssl/certs/orthanc.crt",
  "KeyFile": "/etc/ssl/private/orthanc.key",
  "AuthenticationEnabled": true,
  "UserName": "admin",
  "Password": "your-secure-password-123",
  "AllowAnonymous": false
}
```

---

## 🌍 Testing Network Configuration

### 1. Test Local Access
```bash
# Test HTTP
curl -I http://localhost:8042

# Test HTTPS (jika configured)
curl -I https://localhost:8443

# Test DICOM port
nc -zv localhost 4242

# Test from another machine on LAN
curl -I http://192.168.1.100:8042
```

### 2. Test Cloudflare Tunnel
```bash
# Check tunnel status
cloudflared tunnel info orthanc-tunnel

# Test DNS resolution
nslookup orthanc.yourdomain.com

# Test HTTPS access
curl -I https://orthanc.yourdomain.com

# Test with browser
# Buka https://orthanc.yourdomain.com
```

### 3. Network Diagnostics
```bash
# Check connectivity
ping google.com
ping orthanc.yourdomain.com

# Check port connectivity
telnet orthanc.yourdomain.com 443
nc -zv orthanc.yourdomain.com 443

# Check SSL certificate
openssl s_client -connect orthanc.yourdomain.com:443

# Trace route
traceroute orthanc.yourdomain.com
```

### 4. Performance Testing
```bash
# Test website load time
curl -o /dev/null -s -w '%{time_total}\n' https://orthanc.yourdomain.com

# Test concurrent connections
ab -n 1000 -c 10 -k http://localhost:8042/

# Monitor network usage
iftop -i eth0
nethogs
```

---

## 📊 Network Monitoring

### 1. Log Configuration
```bash
# Create log rotation for Orthanc
sudo nano /etc/logrotate.d/orthanc

# Add configuration:
/var/log/orthanc/*.log {
    daily
    missingok
    rotate 30
    compress
    delaycompress
    notifempty
    create 644 root root
    postrotate
        docker restart orthanc-server
    endscript
}
```

### 2. Monitoring Script
```bash
#!/bin/bash
# scripts/network-monitor.sh

LOG_FILE="/var/log/orthanc/network-monitor.log"
DATE=$(date '+%Y-%m-%d %H:%M:%S')

echo "=== Network Check - $DATE ===" >> $LOG_FILE

# Check Orthanc HTTP
if curl -s http://localhost:8042/system >/dev/null 2>&1; then
    echo "✓ Orthanc HTTP OK" >> $LOG_FILE
else
    echo "✗ Orthanc HTTP DOWN" >> $LOG_FILE
    docker restart orthanc-server >> $LOG_FILE 2>&1
fi

# Check DICOM port
if nc -z localhost 4242 >/dev/null 2>&1; then
    echo "✓ DICOM port OK" >> $LOG_FILE
else
    echo "✗ DICOM port DOWN" >> $LOG_FILE
fi

# Check Cloudflare tunnel
if cloudflared tunnel info orthanc-tunnel >/dev/null 2>&1; then
    echo "✓ Cloudflare tunnel OK" >> $LOG_FILE
else
    echo "✗ Cloudflare tunnel DOWN" >> $LOG_FILE
    systemctl restart cloudflared >> $LOG_FILE 2>&1
fi

# Check disk space
DISK_USAGE=$(df -h | grep orthanc-data | awk '{print $5}' | sed 's/%//')
if [ $DISK_USAGE -gt 80 ]; then
    echo "⚠ High disk usage: ${DISK_USAGE}%" >> $LOG_FILE
fi

echo "=== End Check ===" >> $LOG_FILE
```

### 3. Schedule Monitoring
```bash
# Add to crontab
crontab -e

# Add line to run every 5 minutes
*/5 * * * * /path/to/scripts/network-monitor.sh
```

---

## 🚨 Common Network Issues

### 1. Port Already in Use
```bash
# Check which process is using the port
sudo lsof -i :8042
sudo lsof -i :4242

# Kill the process
sudo kill -9 <PID>

# Or change port in docker-compose.yml
ports:
  - "8043:8042"  # Use different port
```

### 2. Connection Refused
```bash
# Check if service is running
docker ps | grep orthanc

# Check logs
docker logs orthanc-server

# Restart service
docker restart orthanc-server
```

### 3. DNS Issues
```bash
# Clear DNS cache
# Linux
sudo systemctl flush-dns

# Windows
ipconfig /flushdns

# macOS
sudo dscacheutil -flushcache
```

### 4. Firewall Blocking
```bash
# Check UFW status
sudo ufw status

# Add rule if needed
sudo ufw allow 8042/tcp
sudo ufw allow 4242/tcp
```

---

## 📞 Troubleshooting Commands

### Quick Diagnostics
```bash
# Network connectivity
ping google.com
ping 8.8.8.8

# DNS resolution
nslookup orthanc.yourdomain.com
dig orthanc.yourdomain.com

# Port checking
netstat -tlnp | grep 8042
ss -tlnp | grep 8042

# Docker network
docker network ls
docker inspect orthanc-server | grep IPAddress
```

### Advanced Network Debugging
```bash
# Capture packets
sudo tcpdump -i any -w network.pcap port 8042 or port 4242

# Monitor network connections
sudo watch -n 1 'ss -tlnp | grep 8042'

# Check routing table
ip route show
netstat -rn

# Check ARP table
arp -a
```

---

## 📋 Network Configuration Checklist

### Before Installation
- [ ] Check available IP addresses
- [ ] Configure static IP if needed
- [ ] Setup port forwarding in router
- [ ] Configure firewall rules
- [ ] Test local network connectivity

### After Installation
- [ ] Test local access (http://localhost:8042)
- [ ] Test LAN access (http://192.168.1.100:8042)
- [ ] Setup Cloudflare tunnel
- [ ] Configure HTTPS
- [ ] Test remote access

### Security Configuration
- [ ] Enable firewall
- [ ] Configure fail2ban
- [ ] Setup SSL/TLS
- [ ] Enable authentication
- [ ] Monitor network logs

---

**🎯 Selanjutnya**: [04-Dokumentasi API](./04-Dokumentasi-API.md) - Pelajari cara menggunakan REST API Orthanc untuk operasi data dan integrasi!# 04. Dokumentasi API Orthanc

## 📋 Apa yang akan Anda Pelajari

- Pengenalan REST API Orthanc
- Format dan struktur response
- Authentication dan authorization
- Endpoints untuk patients, studies, series, instances
- Contoh penggunaan curl dan JavaScript
- Error handling dan debugging

---

## 📡 Pengenalan REST API

### What is REST API?
REST (Representational State Transfer) API adalah arsitektur web untuk komunikasi antar aplikasi. Orthanc menggunakan REST API untuk:

- **Retrieve data** (Get)
- **Create data** (Post)
- **Update data** (Put/Patch)
- **Delete data** (Delete)

### Base URLs
```yaml
Local: http://localhost:8042
Remote: https://orthanc.yourdomain.com
API Explorer: http://localhost:8042/apidocs
```

### Format Response
- **JSON**: Default format untuk API response
- **XML**: Tersedia dengan menambahkan `.xml` ke URL
- **Raw**: Dapatkan file mentah (DICOM)

---

## 🔐 Authentication

### Basic Authentication (Disabled by default)
```bash
curl -u admin:password http://localhost:8042/system
```

### Token-based Authentication
```json
// Login (jika authentication diaktifkan)
curl -X POST http://localhost:8042/login \
  -H "Content-Type: application/json" \
  -d '{"username": "admin", "password": "password"}'

// Response:
{
  "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "expires": "2024-12-31T23:59:59Z"
}
```

### Using Auth Token
```bash
curl -H "Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..." \
  http://localhost:8042/system
```

---

## 📊 System API

### Get System Information
```bash
# Basic system info
curl http://localhost:8042/system

# Specific field
curl http://localhost:8042/system | jq '.Name'
curl http://localhost:8042/system | jq '.Version'
```

### Response Format
```json
{
  "Name": "Orthanc (DICOM Server)",
  "Version": "1.12.0",
  "ApiVersion": 14,
  "GlobalProperty": false,
  "OrthancId": "main",
  "DefaultEncoding": "ExplicitVRLittleEndian",
  "StorageDirectory": "/var/lib/orthanc/db",
  "IndexDirectory": "/var/lib/orthanc/db"
}
```

### Changes API
```bash
# Get recent changes
curl "http://localhost:8042/changes?since=0&limit=100"

# Filter by change type
curl "http://localhost:8042/changes?since=0&limit=100&filter=NewInstance"

# Format options
curl "http://localhost:8042/changes?expand=true"
```

### Statistics API
```bash
# Get statistics
curl http://localhost:8042/tools/statistics

# Specific time range
curl "http://localhost:8042/tools/statistics?since=2024-01-01&until=2024-12-31"

# Format as JSON
curl -H "Accept: application/json" http://localhost:8042/tools/statistics
```

---

## 👥 Patients API

### List All Patients
```bash
# Basic list
curl http://localhost:8042/patients

# With pagination
curl "http://localhost:8042/patients?limit=10&skip=0"

# Expand patient info
curl "http://localhost:8042/patients?expand=true&limit=100"

# Search by ID
curl "http://localhost:8042/patients?expand=true&limit=100" | \
  jq '.[] | select(.ID | contains("PatientID"))'
```

### Get Specific Patient
```bash
curl http://localhost:8042/patients/<patient-id>

# Get patient with metadata
curl http://localhost:8042/patients/<patient-id>?expand=true

# JSON output example:
{
  "ID": "patient-123",
  "Path": "/patients/patient-123",
  "IsStable": true,
  "MainDicomTags": {
    "PatientName": "John Doe",
    "PatientID": "P001234",
    "BirthDate": "19700101",
    "Sex": "M"
  }
}
```

### Get Patient Studies
```bash
curl http://localhost:8042/patients/<patient-id>/studies

# Count studies for patient
curl http://localhost:8042/patients/<patient-id>/studies | jq 'length'
```

### Find Patient
```bash
# Find by patient ID
curl "http://localhost:8042/patients?expand=true" | \
  jq '.[] | select(.MainDicomTags.PatientID == "P001234")'

# Find by patient name
curl "http://localhost:8042/patients?expand=true" | \
  jq '.[] | select(.MainDicomTags.PatientName | contains("John"))'

# Advanced search
curl -X POST http://localhost:8042/patients/lookup \
  -H "Content-Type: application/json" \
  -d '{"Level": "Patient", "Query": {"PatientName": "John*"}}'
```

---

## 🏥 Studies API

### List All Studies
```bash
# Basic list
curl http://localhost:8042/studies

# With pagination
curl "http://localhost:8042/studies?limit=20&skip=0"

# With metadata
curl "http://localhost:8042/studies?expand=true"

# Filter by date
curl "http://localhost:8042/studies?date=20240101-20241231"

# Filter by modality
curl "http://localhost:8042/studies?modality=CT"
```

### Get Specific Study
```bash
curl http://localhost:8042/studies/<study-id>

# With metadata
curl http://localhost:8042/studies/<study-id>?expand=true

# Response format:
{
  "ID": "study-456",
  "Path": "/studies/study-456",
  "ParentPatient": "patient-123",
  "IsStable": true,
  "MainDicomTags": {
    "StudyDate": "20240101",
    "StudyTime": "120000",
    "StudyDescription": "CT CHEST",
    "AccessionNumber": "ACC123",
    "ReferringPhysicianName": "Dr. Smith"
  },
  "Resources": {
    "Series": ["series-1", "series-2"]
  }
}
```

### Get Study Series
```bash
curl http://localhost:8042/studies/<study-id>/series

# Get series count
curl http://localhost:8042/studies/<study-id>/series | jq 'length'
```

### Study Operations
```bash
# Export study as ZIP
curl -X POST http://localhost:8042/studies/<study-id>/archive \
  -H "Content-Type: application/json" \
  -d '{"Format": "zip"}'

# Export study as directory
curl -X POST http://localhost:8042/studies/<study-id>/archive \
  -H "Content-Type: application/json" \
  -d '{"Format": "dir"}'

# Anonymize study
curl -X POST http://localhost:8042/studies/<study-id>/anonymize \
  -H "Content-Type: application/json" \
  -d '{"ReplaceTags": {"PatientName": "ANONYMOUS"}}'

# Delete study
curl -X DELETE http://localhost:8042/studies/<study-id>
```

---

## 🔬 Series API

### List All Series
```bash
# Basic list
curl http://localhost:8042/series

# With pagination
curl "http://localhost:8042/series?limit=50&skip=0"

# With metadata
curl "http://localhost:8042/series?expand=true"

# Filter by modality
curl "http://localhost:8042/series?modality=MRI"

# Filter by body part
curl "http://localhost:8042/series?body-part-exam=CHEST"
```

### Get Specific Series
```bash
curl http://localhost:8042/series/<series-id>

# With full metadata
curl http://localhost:8042/series/<series-id>?expand=true

# Response:
{
  "ID": "series-789",
  "Path": "/series/series-789",
  "ParentStudy": "study-456",
  "IsStable": true,
  "MainDicomTags": {
    "SeriesDescription": "AXIAL T1",
    "Modality": "MR",
    "SeriesNumber": "1",
    "NumberOfSeriesInstances": "20"
  },
  "Instances": ["instance-1", "instance-2", ...]
}
```

### Get Series Instances
```bash
curl http://localhost:8042/series/<series-id>/instances

# Get instance count
curl http://localhost:8042/series/<series-id>/instances | jq 'length'
```

### Series Operations
```bash
# Reconstruct series (MPR, 3D, etc.)
curl -X POST http://localhost:8042/series/<series-id>/reconstruct \
  -H "Content-Type: application/json" \
  -d '{"Type": "corrected"}'

# Export series
curl -X POST http://localhost:8042/series/<series-id>/archive \
  -H "Content-Type: application/json" \
  -d '{"Format": "zip"}'

# Anonymize series
curl -X POST http://localhost:8042/series/<series-id>/anonymize

# Delete series
curl -X DELETE http://localhost:8042/series/<series-id>
```

---

## 🖼️ Instances API

### List All Instances
```bash
# Basic list
curl http://localhost:8042/instances

# With pagination
curl "http://localhost:8042/instances?limit=100&skip=0"

# With metadata
curl "http://localhost:8042/instances?expand=true"

# Filter by date
curl "http://localhost:8042/instances?date=20240101-20241231"
```

### Get Specific Instance
```bash
curl http://localhost:8042/instances/<instance-id>

# With full metadata
curl http://localhost:8042/instances/<instance-id>?expand=true

# Response:
{
  "ID": "instance-999",
  "Path": "/instances/instance-999",
  "ParentSeries": "series-789",
  "ParentStudy": "study-456",
  "ParentPatient": "patient-123",
  "IsStable": true,
  "MainDicomTags": {
    "SOPClassUID": "1.2.840.10008.5.1.4.1.1.2",
    "SOPInstanceUID": "1.2.3.4.5.6.7.8.9.0",
    "InstanceNumber": "1",
    "ImageType": "ORIGINAL\\PRIMARY\\AXIAL"
  }
}
```

### Get Instance File
```bash
# Get DICOM file
curl http://localhost:8042/instances/<instance-id>/file -o dicom_file.dcm

# Get file info
curl -I http://localhost:8042/instances/<instance-id>/file

# Get as PNG
curl http://localhost:8042/instances/<instance-id>/file?export=png
```

### Get Instance Metadata
```bash
# Get all metadata
curl http://localhost:8042/instances/<instance-id>/metadata

# Get specific tag
curl http://localhost:8042/instances/<instance-id>/metadata/0010,0010

# DICOM tag format:
# Group,Element (e.g., 0010,0010 = Patient Name)
```

### Instance Operations
```bash
# Anonymize instance
curl -X POST http://localhost:8042/instances/<instance-id>/anonymize \
  -H "Content-Type: application/json" \
  -d '{"RemoveTags": ["0010,0010"], "ReplaceTags": {"PatientName": "ANONYMOUS"}}'

# Delete instance
curl -X DELETE http://localhost:8042/instances/<instance-id>

# Convert instance
curl -X POST http://localhost:8042/instances/<instance-id>/convert \
  -H "Content-Type: application/json" \
  -d '{"Format": "png"}'
```

---

## 📤 Upload Operations

### Upload Single DICOM File
```bash
# Upload via curl
curl -X POST -T /path/to/file.dcm http://localhost:8042/studies

# Upload with progress
curl -X POST -T /path/to/large_file.dcm http://localhost:8042/studies
```

### Upload Multiple Files
```bash
#!/bin/bash
# upload-multiple.sh

STUDY_ID="study-123"
SERVER="http://localhost:8042"

for file in /path/to/dicom_files/*.dcm; do
    if [ -f "$file" ]; then
        echo "Uploading $file..."
        curl -X POST -T "$file" "$SERVER/studies"
        echo ""
    fi
done
```

### Upload from URL
```bash
# Download and upload in one command
curl -L https://example.com/file.dcm | \
  curl -X POST -T - http://localhost:8042/studies
```

---

## 🔍 Search API

### Simple Search
```bash
# Search patients
curl "http://localhost:8042/patients?expand=true" | \
  jq '.[] | select(.MainDicomTags.PatientName | test("John"))'

# Search studies
curl "http://localhost:8042/studies?expand=true" | \
  jq '.[] | select(.MainDicomTags.Modality == "CT")'

# Search by date range
curl "http://localhost:8042/studies?date=20240101-20240131"
```

### Advanced Search with POST
```bash
# Search studies with criteria
curl -X POST http://localhost:8042/studies/lookup \
  -H "Content-Type: application/json" \
  -d '{
    "Level": "Study",
    "Query": {
      "StudyDate": "20240101",
      "ModalitiesInStudy": ["CT", "MR"]
    }
  }'

# Find instances
curl -X POST http://localhost:8042/instances/lookup \
  -H "Content-Type: application/json" \
  -d '{
    "Level": "Instance",
    "Query": {
      "PatientName": "Doe*",
      "StudyDescription": "Chest*"
    }
  }'
```

### Search Templates
```json
// saved-search.json
{
  "name": "Emergency Studies",
  "query": {
    "Level": "Study",
    "Query": {
      "Priority": "E"
    }
  }
}

# Use saved template
curl -X POST http://localhost:8042/tools/saved-searches \
  -H "Content-Type: application/json" \
  -d @saved-search.json
```

---

## ⚙️ Configuration API

### Get Configuration
```bash
# Get all configuration
curl http://localhost:8042/system

# Get specific setting
curl http://localhost:8042/system | jq '.HttpPort'
```

### Update Configuration
```bash
# Update HTTP port
curl -X PUT http://localhost:8042/system \
  -H "Content-Type: application/json" \
  -d '{"HttpPort": 8043}'

# Enable compression
curl -X PUT http://localhost:8042/system \
  -H "Content-Type: application/json" \
  -d '{"HttpCompression": true}'
```

### Plugin Configuration
```bash
# Get plugin information
curl http://localhost:8042/system | jq '.Plugins'

# Enable/disable plugin
curl -X PUT http://localhost:8042/system \
  -H "Content-Type: application/json" \
  -d '{"LuaScripts": {"Enabled": true}}'
```

---

## 🛠️ Tools API

### DICOM Validation
```bash
# Validate DICOM file
curl -X POST http://localhost:8042/tools/validate \
  -H "Content-Type: application/json" \
  -d '{"Files": ["instance-1"], "CheckSyntax": true}'

# Response:
{
  "Valid": true,
  "Warnings": [],
  "Errors": []
}
```

### Statistics Tools
```bash
# Get storage statistics
curl http://localhost:8042/tools/statistics

# Get patient counts
curl http://localhost:8042/tools/statistics | jq '.Patients'

# Get modality distribution
curl http://localhost:8042/tools/statistics | jq '.Modalities'
```

### Export Tools
```bash
# Export as PDF
curl -X POST http://localhost:8042/tools/export-pdf \
  -H "Content-Type: application/json" \
  -d '{"Studies": ["study-1"], "Format": "A4"}'

# Create DICOM CD
curl -X POST http://localhost:8042/tools/create-media \
  -H "Content-Type: application/json" \
  -d '{"Type": "dicom-cd", "Studies": ["study-1"]}'
```

### Batch Operations
```bash
# Batch anonymize
curl -X POST http://localhost:8042/tools/batch-anonymize \
  -H "Content-Type: application/json" \
  -d '{"Resources": ["instance-1", "instance-2"], "ReplaceTags": {"PatientName": "ANONYMOUS"}}'

# Batch delete
curl -X POST http://localhost:8042/tools/batch-delete \
  -H "Content-Type: application/json" \
  -d '{"Resources": ["study-1", "study-2"]}'
```

---

## 💻 JavaScript API Examples

### Basic API Client
```javascript
// orthanc-client.js
class OrthancClient {
  constructor(baseUrl, token = null) {
    this.baseUrl = baseUrl;
    this.token = token;
  }

  async request(endpoint, options = {}) {
    const url = `${this.baseUrl}${endpoint}`;
    const headers = {
      'Content-Type': 'application/json',
      ...options.headers
    };

    if (this.token) {
      headers['Authorization'] = `Bearer ${this.token}`;
    }

    const response = await fetch(url, {
      ...options,
      headers
    });

    if (!response.ok) {
      throw new Error(`HTTP ${response.status}: ${response.statusText}`);
    }

    return response.json();
  }

  // Get system info
  async getSystem() {
    return this.request('/system');
  }

  // Get patients
  async getPatients(options = {}) {
    const params = new URLSearchParams(options);
    return this.request(`/patients?${params}`);
  }

  // Get patient studies
  async getPatientStudies(patientId) {
    return this.request(`/patients/${patientId}/studies`);
  }

  // Upload file
  async uploadFile(file, studyId) {
    const formData = new FormData();
    formData.append('file', file);

    const response = await fetch(`${this.baseUrl}/studies`, {
      method: 'POST',
      body: formData
    });

    return response.json();
  }
}

// Usage example
const client = new OrthancClient('http://localhost:8042');

// Get system info
client.getSystem().then(system => {
  console.log('System:', system.Name);
});

// Get patients
client.getPatients({expand: true, limit: 10}).then(patients => {
  console.log('Patients:', patients);
});
```

### React Component Example
```jsx
// OrthancViewer.jsx
import React, { useState, useEffect } from 'react';

const OrthancViewer = ({ baseUrl }) => {
  const [patients, setPatients] = useState([]);
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState(null);

  useEffect(() => {
    fetchPatients();
  }, [baseUrl]);

  const fetchPatients = async () => {
    setLoading(true);
    try {
      const response = await fetch(`${baseUrl}/patients?expand=true&limit=100`);
      const data = await response.json();
      setPatients(data);
    } catch (err) {
      setError(err.message);
    } finally {
      setLoading(false);
    }
  };

  const uploadFile = async (file) => {
    const formData = new FormData();
    formData.append('file', file);

    try {
      const response = await fetch(`${baseUrl}/studies`, {
        method: 'POST',
        body: formData
      });
      return await response.json();
    } catch (err) {
      throw err;
    }
  };

  return (
    <div>
      <h1>Orthanc Viewer</h1>
      
      {loading && <p>Loading...</p>}
      {error && <p>Error: {error}</p>}
      
      <div>
        <h2>Upload DICOM</h2>
        <input type="file" accept=".dcm" onChange={(e) => {
          if (e.target.files[0]) {
            uploadFile(e.target.files[0])
              .then(() => fetchPatients())
              .catch(err => setError(err.message));
          }
        }} />
      </div>

      <div>
        <h2>Patients ({patients.length})</h2>
        <ul>
          {patients.map(patient => (
            <li key={patient.ID}>
              {patient.MainDicomTags.PatientName} 
              ({patient.MainDicomTags.PatientID})
            </li>
          ))}
        </ul>
      </div>
    </div>
  );
};

export default OrthancViewer;
```

---

## 🔧 Error Handling

### Common HTTP Status Codes
```yaml
200 OK - Request successful
201 Created - Resource created
400 Bad Request - Invalid request
401 Unauthorized - Authentication required
403 Forbidden - Access denied
404 Not Found - Resource not found
500 Internal Server Error - Server error
503 Service Unavailable - Service down
```

### Error Response Format
```json
{
  "StatusCode": 400,
  "Status": "Bad Request",
  "Method": "GET",
  "URI": "/patients/invalid-id",
  "Details": "Unknown resource"
}
```

### Error Handling in JavaScript
```javascript
// Error handling wrapper
async function safeApiCall(endpoint, options = {}) {
  try {
    const response = await fetch(endpoint, options);
    
    if (!response.ok) {
      const error = await response.json();
      throw new Error(`[${error.StatusCode}] ${error.Status}: ${error.Details}`);
    }
    
    return await response.json();
  } catch (error) {
    console.error('API Error:', error);
    
    // User-friendly message
    let message = 'An error occurred';
    if (error.message.includes('401')) {
      message = 'Please login first';
    } else if (error.message.includes('404')) {
      message = 'Resource not found';
    }
    
    // Show to user
    alert(message);
    throw error;
  }
}

// Usage
safeApiCall('/patients')
  .then(data => console.log(data))
  .catch(error => console.error('Failed:', error));
```

### Retry Logic
```javascript
// Retry with exponential backoff
async function fetchWithRetry(url, options = {}, retries = 3) {
  const delay = (attempt) => Math.pow(2, attempt) * 1000;
  
  for (let attempt = 0; attempt < retries; attempt++) {
    try {
      const response = await fetch(url, options);
      if (!response.ok) throw new Error(`HTTP ${response.status}`);
      return await response.json();
    } catch (error) {
      if (attempt === retries - 1) throw error;
      console.log(`Retry ${attempt + 1}/${retries}...`);
      await new Promise(resolve => setTimeout(resolve, delay(attempt)));
    }
  }
}

// Usage
fetchWithRetry('/system')
  .then(system => console.log(system))
  .catch(error => console.error('Failed after retries:', error));
```

---

## 🔄 WebSockets (Real-time Updates)

### WebSocket Connection
```javascript
// Connect to Orthanc WebSocket
const ws = new WebSocket('ws://localhost:8042/ws');

ws.onopen = () => {
  console.log('Connected to Orthanc WebSocket');
};

ws.onmessage = (event) => {
  const change = JSON.parse(event.data);
  console.log('Change detected:', change);
  
  // Handle different change types
  switch (change.changeType) {
    case 'NewInstance':
      handleNewInstance(change.resource);
      break;
    case 'StableStudy':
      handleStableStudy(change.resource);
      break;
  }
};

ws.onerror = (error) => {
  console.error('WebSocket error:', error);
};

ws.onclose = () => {
  console.log('WebSocket closed');
};

// Close connection
// ws.close();
```

### WebSocket Event Types
```json
{
  "changeType": "NewInstance",
  "resourceType": "Instance",
  "resource": {
    "ID": "instance-123",
    "Path": "/instances/instance-123"
  },
  "date": "2024-01-01T12:00:00Z"
}
```

---

## 📊 API Rate Limiting

### Check Rate Limits
```bash
# Check current rate limit status
curl -I http://localhost:8042/system

# Look for headers like:
# X-RateLimit-Limit: 100
# X-RateLimit-Remaining: 95
# X-RateLimit-Reset: 1640995200
```

### Handle Rate Limits
```javascript
// Rate limiting helper
class RateLimiter {
  constructor(limit, windowMs) {
    this.limit = limit;
    this.windowMs = windowMs;
    this.requests = [];
  }

  async execute(fn) {
    const now = Date.now();
    
    // Remove old requests
    this.requests = this.requests.filter(time => now - time < this.windowMs);
    
    // Check if limit exceeded
    if (this.requests.length >= this.limit) {
      const waitTime = this.windowMs - (now - this.requests[0]);
      await new Promise(resolve => setTimeout(resolve, waitTime));
    }
    
    // Execute request
    const result = await fn();
    this.requests.push(now);
    
    return result;
  }
}

// Usage
const limiter = new RateLimiter(10, 1000); // 10 requests per second

limiter.execute(() => fetch('/patients'))
  .then(data => console.log(data));
```

---

## 📋 API Testing Checklist

### Before Making API Calls
- [ ] Test with curl first (simple)
- [ ] Check authentication requirements
- [ ] Verify endpoint exists
- [ ] Test with sample data

### After API Integration
- [ ] Implement proper error handling
- [ ] Add loading states
- [ ] Include retry logic
- [ ] Monitor API performance
- [ ] Document any custom endpoints

### Production Considerations
- [ ] Implement proper authentication
- [ ] Use HTTPS in production
- [ ] Add rate limiting
- [ ] Monitor API usage
- [ ] Implement logging

---

**🎯 Selanjutnya**: [05-Memasang Plugin](./05-Memasang-Plugin.md) - Pelajari cara memasang dan mengkonfigurasi plugin untuk meningkatkan fungsionalitas Orthanc!# 05. Memasang & Menggunakan Plugin Orthanc

## 📋 Apa yang akan Anda Pelajari

- Pengenalan sistem plugin Orthanc
- Cara mencari dan download plugin
- Install plugin manual dan via Docker
- Konfigurasi plugin settings
- Plugin popular dan fungsinya
- Troubleshooting plugin issues

---

## 🎯 Pengenalan Plugin

### Apa itu Plugin?
Plugin adalah komponen ekstensi yang memperluas fungsi Orthanc tanpa mengubah kode inti. Plugin memungkinkan:

- **Fitur tambahan** (viewer, export, automation)
- **Format file support** baru
- **Integrasi** dengan sistem lain
- **Custom workflows** dan automation

### Jenis Plugin
```yaml
Core Plugins (Built-in):
- Web Viewer: Tampilan gambar DICOM
- Lua Scripting: Automation dan scripting
- PDF Export: Export ke PDF
- Video Support: Video medical

Third-party Plugins:
- PACS Integration: Koneksi ke PACS lain
- DICOM Structured Reporting: SR support
- Compression: Lossless compression
- Custom Auth: Authentication kustom
```

---

## 📦 Mencari & Download Plugin

### Official Plugin Repository
**URL**: [https://orthanc.uclouvain.be/plugins/](https://orthanc.uclouvain.be/plugins/)

### Plugin Categories
```markdown
1. **Image Processing**
   - Web Viewer
   - JPEG2000 Support
   - 3D Reconstruction
   
2. **Export & Sharing**
   - PDF Export
   - Video Export
   - DICOM-CD Creator
   
3. **Automation**
   - Lua Scripts
   - JavaScript Support
   - Workflow Engine
   
4. **Integration**
   - PACS Connectors
   - Database Connectors
   - EMR Integration
   
5. **Security**
   - Authentication Plugins
   - Encryption Plugins
   - Audit Logs
```

### Download Plugin
```bash
# Download plugin terbaru
wget https://orthanc.uclouvain.be/downloads/plugin-name.zip

# Atau menggunakan curl
curl -L -o plugin-name.zip https://orthanc.uclouvain.be/downloads/plugin-name.zip

# Extract plugin
unzip plugin-name.zip
cd plugin-name
```

---

## 🔧 Install Plugin

### Method 1: Manual Installation

#### Linux
```bash
# Create plugin directory
sudo mkdir -p /usr/share/orthanc/plugins

# Copy plugin
sudo cp libPluginName.so /usr/share/orthanc/plugins/

# Set permissions
sudo chmod 755 /usr/share/orthanc/plugins/libPluginName.so

# Restart Orthanc
sudo systemctl restart orthanc
```

#### Windows
```batch
# Create plugins directory
mkdir C:\Orthanc\plugins

# Copy plugin
copy plugin-name.dll C:\Orthanc\plugins\

# Restart Orthanc service
net stop orthanc
net start orthanc
```

#### macOS
```bash
# Create plugins directory
sudo mkdir -p /usr/local/share/orthanc/plugins

# Copy plugin
sudo cp libPluginName.dylib /usr/local/share/orthanc/plugins/

# Restart Orthanc
brew services restart orthanc
```

### Method 2: Docker Installation

#### Option A: Volume Mount
```yaml
# docker-compose.yml
services:
  orthanc:
    image: jodogne/orthanc-plugins:latest
    container_name: orthanc-server
    volumes:
      - ./plugins:/usr/share/orthanc/plugins
      - ./orthanc-data:/var/lib/orthanc/db
      - ./orthanc.json:/etc/orthanc/orthanc.json
```

#### Option B: Build Custom Image
```dockerfile
# Dockerfile
FROM jodogne/orthanc-plugins:latest

# Copy plugins
COPY plugins/ /usr/share/orthanc/plugins/

# Install additional dependencies if needed
RUN apt-get update && apt-get install -y \
    python3 \
    && rm -rf /var/lib/apt/lists/*

# Configure Orthanc
COPY orthanc.json /etc/orthanc/orthanc.json

CMD ["Orthanc"]
```

#### Build and Run
```bash
# Build custom image
docker build -t orthanc-with-plugins .

# Run with custom image
docker run -d \
  -p 8042:8042 \
  -p 4242:4242 \
  -v $(pwd)/orthanc-data:/var/lib/orthanc/db \
  orthanc-with-plugins
```

### Method 3: Plugin Manager (Advanced)

#### Create Plugin Manager Script
```bash
#!/bin/bash
# scripts/plugin-manager.sh

PLUGINS_DIR="./plugins"
ORTHANC_DIR="/usr/share/orthanc/plugins"
CONFIG_FILE="./orthanc.json"

# Install plugin
install_plugin() {
    local plugin_name=$1
    local plugin_url=$2
    
    echo "Installing $plugin_name..."
    
    # Download
    wget -O "$plugin_name.zip" "$plugin_url"
    
    # Extract
    unzip -o "$plugin_name.zip"
    local plugin_dir=$(find . -maxdepth 1 -type d -name "$plugin_name*")
    
    if [ -d "$plugin_dir" ]; then
        # Find plugin file
        local plugin_file=$(find "$plugin_dir" -name "*.so" -o -name "*.dll" -o -name "*.dylib")
        
        if [ -n "$plugin_file" ]; then
            # Copy to plugins directory
            cp "$plugin_file" "$PLUGINS_DIR/"
            echo "✓ Plugin $plugin_name installed successfully"
        else
            echo "✗ Plugin file not found in $plugin_dir"
        fi
    else
        echo "✗ Plugin directory not found"
    fi
    
    # Cleanup
    rm -f "$plugin_name.zip"
    rm -rf "$plugin_dir"
}

# List installed plugins
list_plugins() {
    echo "Installed Plugins:"
    ls -la $PLUGINS_DIR/ | grep -E '\.(so|dll|dylib)$'
}

# Update plugin configuration
update_config() {
    local plugin_name=$1
    local config=$2
    
    # Add to orthanc.json
    jq --arg plugin "$plugin_name" --argjson config "$config" '
    .Plugins[$plugin] = $config | 
    .LuaScripts.Enabled = true |
    .WebViewer.Enabled = true
    ' orthanc.json > tmp.json && mv tmp.json orthanc.json
    
    echo "Configuration updated for $plugin_name"
}

# Usage
case "$1" in
    install)
        install_plugin "$2" "$3"
        ;;
    list)
        list_plugins
        ;;
    config)
        update_config "$2" "$3"
        ;;
    *)
        echo "Usage: $0 {install|list|config} [args]"
        echo "  install <plugin-name> <download-url>"
        echo "  list"
        echo "  config <plugin-name> <json-config>"
        ;;
esac
```

---

## ⚙️ Konfigurasi Plugin

### Basic Configuration
```json
// orthanc.json
{
  "Name": "Orthanc with Plugins",
  "HttpPort": 8042,
  "DicomPort": 4242,
  "Plugins": {
    "Enabled": true,
    "Directory": "/usr/share/orthanc/plugins"
  },
  "LuaScripts": {
    "Enabled": true,
    "Directory": "/etc/orthanc/scripts",
    "AutoExecute": true
  },
  "WebViewer": {
    "Enabled": true,
    "CacheDirectory": "/tmp/orthanc-viewer",
    "MaxCacheSize": 1000
  }
}
```

### Plugin-Specific Configuration

#### Web Viewer Configuration
```json
{
  "WebViewer": {
    "Enabled": true,
    "CacheDirectory": "/tmp/orthanc-viewer",
    "MaxCacheSize": 2000,
    "TileSize": 512,
    "MaxConcurrency": 10,
    "Compression": true,
    "EnableMeasurements": true,
    "EnableAnnotations": true,
    "Enable3D": true,
    "EnableMPR": true
  }
}
```

#### PDF Export Configuration
```json
{
  "PdfExport": {
    "Enabled": true,
    "Template": "default",
    "Dpi": 300,
    "Compression": "jpeg",
    "Watermark": "CONFIDENTIAL",
    "IncludeImages": true,
    "IncludeMetadata": true,
    "OutputFormat": "A4"
  }
}
```

#### Lua Scripting Configuration
```json
{
  "LuaScripts": {
    "Enabled": true,
    "Directory": "/etc/orthanc/scripts",
    "AutoExecute": true,
    "GlobalVariables": {
      "hospital_name": "RS Example",
      "max_file_size": 104857600
    }
  }
}
```

#### PACS Integration Configuration
```json
{
  "PACSIntegration": {
    "Enabled": true,
    "Modalities": {
      "REMOTE-PACS": {
        "Address": "192.168.1.100",
        "Port": 4242,
        "AET": "PACS-AET",
        "Timeout": 30
      }
    },
    "FindSCU": {
      "AET": "ORTHANC-FIND",
      "CalledAET": "ANY-SCP",
      "Timeout": 30
    },
    "StoreSCU": {
      "AET": "ORTHANC-STORE",
      "CalledAET": "PACS-AET",
      "Timeout": 60
    }
  }
}
```

---

## 📦 Plugin Popular dan Cara Install

### 1. Web Viewer Plugin

#### Install
```bash
# Download Web Viewer plugin
wget https://orthanc.uclouvain.be/downloads/OrthancWebViewer.zip

# Extract
unzip OrthancWebViewer.zip
cd OrthancWebViewer/Linux/

# Copy plugin
sudo cp libOrthancWebViewer.so /usr/share/orthanc/plugins/

# Update configuration
jq '.WebViewer.Enabled = true' orthanc.json > tmp.json && mv tmp.json orthanc.json
```

#### Configuration
```json
{
  "WebViewer": {
    "Enabled": true,
    "CacheDirectory": "/tmp/orthanc-webviewer",
    "MaxCacheSize": 500,
    "TileSize": 256,
    "MaxConcurrency": 5
  }
}
```

#### Usage
1. Restart Orthanc
2. Akses `http://localhost:8042/viewer`
3. Pilih series untuk ditampilkan
4. Gunakan tools measurements, annotations, dll.

### 2. Lua Scripting Plugin

#### Install
```bash
# Lua scripting biasanya included dengan Orthanc plugins
# Cek apakah sudah ada
ls /usr/share/orthanc/plugins/ | grep -i lua

# Jika tidak ada, download
wget https://orthanc.uclouvain.be/downloads/OrthancLuaScripting.zip
unzip OrthancLuaScripting.zip
sudo cp libOrthancLua.so /usr/share/orthanc/plugins/
```

#### Create Sample Script
```bash
# Create scripts directory
mkdir -p /etc/orthanc/scripts

# Create sample script
cat > /etc/orthanc/scripts/hello.lua << 'EOF'
function OnChange(change)
    -- Log semua perubahan
    OrthancApiClient:Log("Change detected: " .. change.changeType)
    
    -- Contoh: Auto-anonymize instance baru
    if change.changeType == "NewInstance" then
        local instanceId = change.resource.id
        OrthancApiClient:AnonymizeInstance(instanceId)
        OrthancApiClient:Log("Instance " .. instanceId .. " anonymized")
    end
end
EOF

# Set permissions
chmod 755 /etc/orthanc/scripts/hello.lua
```

#### Configuration
```json
{
  "LuaScripts": {
    "Enabled": true,
    "Directory": "/etc/orthanc/scripts",
    "AutoExecute": ["hello.lua"]
  }
}
```

### 3. PDF Export Plugin

#### Install
```bash
# Download PDF Export plugin
wget https://orthanc.uclouvain.be/downloads/OrthancPdf.zip

# Extract
unzip OrthancPdf.zip
cd OrthancPdf/Linux/

# Copy plugin
sudo cp libOrthancPdf.so /usr/share/orthanc/plugins/

# Update configuration
jq '.PdfExport.Enabled = true' orthanc.json > tmp.json && mv tmp.json orthanc.json
```

#### Usage via API
```bash
# Export study as PDF
curl -X POST http://localhost:8042/studies/<study-id>/pdf \
  -H "Content-Type: application/json" \
  -d '{
    "Format": "A4",
    "Quality": "high",
    "IncludeImages": true,
    "Watermark": "MEDICAL REPORT"
  }'
```

### 4. Video Plugin

#### Install
```bash
# Download Video plugin
wget https://orthanc.uclouvain.be/downloads/OrthancVideo.zip

# Extract dan install
unzip OrthancVideo.zip
sudo cp libOrthancVideo.so /usr/share/orthanc/plugins/
```

#### Configuration
```json
{
  "Video": {
    "Enabled": true,
    "Format": "mp4",
    "Codec": "h264",
    "Quality": "high",
    "FrameRate": 30
  }
}
```

---

## 🛠️ Plugin Development

### Create Simple Plugin
```c
// simple-plugin.c
#include <orthanc/OrthancCPlugin.h>

ORTHANC_PLUGIN_ENTRY(OrthancPluginService)
{
  OrthancPluginSetDescription(service, "Simple plugin example");
  
  // Register callback
  OrthancPluginRegisterCallback(
    service,
    OrthancPluginCallback_OnChange,
    OnChangeCallback,
    NULL
  );
  
  return 0;
}

static OrthancPluginErrorCode OnChangeCallback(
  OrthancPluginService* service,
  OrthancPluginChangeType changeType,
  const char* resourceType,
  OrthancPluginResource* resource,
  void* userData)
{
  // Log changes
  OrthancPluginLogInfo(service, "Change detected: %d", changeType);
  
  return OrthancPluginErrorCode_Success;
}
```

### Build Plugin
```bash
# Install build tools
sudo apt install build-essential cmake

# Create build directory
mkdir build
cd build

# Build
cmake .. -DCMAKE_BUILD_TYPE=Release
make -j4

# Result: libSimplePlugin.so
```

---

## 🔍 Troubleshooting Plugin

### Common Issues

#### Plugin Not Loading
```bash
# Check plugin directory
ls -la /usr/share/orthanc/plugins/

# Check Orthanc logs
tail -f /var/log/orthanc/orthanc.log | grep -i plugin

# Check plugin dependencies
ldd /usr/share/orthanc/plugins/libPluginName.so
```

#### Plugin Configuration Issues
```bash
# Validate JSON configuration
jq . orthanc.json

# Check plugin-specific settings
curl http://localhost:8042/system | jq '.Plugins'

# Test individual plugin
curl -X POST http://localhost:8042/scripts/execute \
  -H "Content-Type: application/json" \
  -d '{"script": "return OrthancApiClient:GetSystem()"}'
```

#### Performance Issues
```bash
# Monitor plugin performance
curl http://localhost:8042/tools/performance

# Check memory usage
docker stats orthanc-server

# Enable debug logging
jq '.LogLevel = "debug"' orthanc.json > tmp.json && mv tmp.json orthanc.json
```

### Debug Commands
```bash
# Enable plugin debug mode
export ORTHANC_DEBUG=1
docker-compose restart orthanc

# Check plugin versions
curl http://localhost:8042/system | jq '.Plugins[]'

# Test plugin API
curl -X GET http://localhost:8042/tools | jq '.'
```

### Plugin Recovery
```bash
# Backup current plugins
cp -r /usr/share/orthanc/plugins /backup/plugins-$(date +%Y%m%d)

# Remove problematic plugin
mv /usr/share/orthanc/plugins/libProblematic.so /tmp/

# Restart Orthanc
docker-compose restart orthanc

# Test without plugin
curl -X GET http://localhost:8042/system
```

---

## 📋 Plugin Management Script

### Complete Plugin Manager
```bash
#!/bin/bash
# scripts/plugin-manager.sh

set -e

PLUGINS_DIR="./plugins"
BACKUP_DIR="./backups/plugins"
CONFIG_FILE="./orthanc.json"

# Color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

log() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Install plugin
install_plugin() {
    local plugin_name=$1
    local plugin_url=$2
    
    log "Installing plugin: $plugin_name"
    
    # Create directories
    mkdir -p $PLUGINS_DIR $BACKUP_DIR
    
    # Download
    if [ ! -f "$plugin_name.zip" ]; then
        log "Downloading plugin..."
        wget -O "$plugin_name.zip" "$plugin_url" || {
            error "Failed to download plugin"
            exit 1
        }
    fi
    
    # Extract
    local plugin_dir=$(find . -maxdepth 1 -type d -name "$plugin_name*" | head -1)
    if [ -z "$plugin_dir" ]; then
        log "Extracting plugin..."
        unzip -o "$plugin_name.zip"
        plugin_dir=$(find . -maxdepth 1 -type d -name "$plugin_name*" | head -1)
    fi
    
    if [ ! -d "$plugin_dir" ]; then
        error "Plugin directory not found"
        exit 1
    fi
    
    # Find plugin file
    local plugin_file=$(find "$plugin_dir" -name "*.so" -o -name "*.dll" -o -name "*.dylib" | head -1)
    if [ -z "$plugin_file" ]; then
        error "Plugin file not found"
        exit 1
    fi
    
    # Backup old version
    local plugin_basename=$(basename "$plugin_file")
    if [ -f "$PLUGINS_DIR/$plugin_basename" ]; then
        log "Backing up old version..."
        cp "$PLUGINS_DIR/$plugin_basename" "$BACKUP_DIR/$plugin_basename-$(date +%Y%m%d_%H%M%S)"
    fi
    
    # Install
    log "Installing plugin file..."
    cp "$plugin_file" "$PLUGINS_DIR/"
    
    # Cleanup
    rm -f "$plugin_name.zip"
    rm -rf "$plugin_dir"
    
    log "Plugin $plugin_name installed successfully"
}

# List installed plugins
list_plugins() {
    log "Installed Plugins:"
    echo "----------------------------------------"
    ls -la $PLUGINS_DIR/ | grep -E '\.(so|dll|dylib)$' | while read line; do
        local plugin=$(echo $line | awk '{print $9}')
        local size=$(du -h "$PLUGINS_DIR/$plugin" | cut -f1)
        echo "• $plugin ($size)"
    done
    echo "----------------------------------------"
}

# Update plugin configuration
update_config() {
    local plugin_name=$1
    local config=$2
    
    log "Updating configuration for $plugin_name"
    
    # Validate JSON
    echo "$config" | jq . > /dev/null 2>&1 || {
        error "Invalid JSON configuration"
        exit 1
    }
    
    # Update orthanc.json
    jq --arg plugin "$plugin_name" --argjson config "$config" '
    .Plugins[$plugin] = $config' "$CONFIG_FILE" > tmp.json && mv tmp.json "$CONFIG_FILE"
    
    log "Configuration updated for $plugin_name"
}

# Remove plugin
remove_plugin() {
    local plugin_name=$1
    
    local plugin_file=$(find $PLUGINS_DIR -name "*$plugin_name*" | head -1)
    if [ -z "$plugin_file" ]; then
        warn "Plugin $plugin_name not found"
        return
    fi
    
    log "Removing plugin: $plugin_name"
    mv "$plugin_file" "$BACKUP_DIR/"
    log "Plugin $plugin_name removed"
}

# Check plugin health
check_plugins() {
    log "Checking plugin health..."
    
    # Restart Orthanc to load plugins
    docker-compose restart orthanc
    sleep 5
    
    # Check system info
    if curl -s http://localhost:8042/system > /dev/null; then
        log "Orthanc is running"
        
        # List plugins
        local plugins=$(curl -s http://localhost:8042/system | jq '.Plugins // empty')
        if [ "$plugins" != "null" ] && [ "$plugins" != "" ]; then
            log "Plugins loaded:"
            echo "$plugins" | jq -r '.[]'
        else
            warn "No plugins loaded"
        fi
    else
        error "Orthanc is not responding"
    fi
}

# Main menu
show_menu() {
    echo "========================================"
    echo "     Plugin Management System"
    echo "========================================"
    echo "1. Install Plugin"
    echo "2. List Plugins"
    echo "3. Remove Plugin"
    echo "4. Update Configuration"
    echo "5. Check Plugin Health"
    echo "6. Backup All Plugins"
    echo "7. Exit"
    echo "========================================"
}

# Main loop
main() {
    while true; do
        show_menu
        read -p "Enter your choice [1-7]: " choice
        
        case $choice in
            1)
                read -p "Plugin name: " plugin_name
                read -p "Download URL: " plugin_url
                install_plugin "$plugin_name" "$plugin_url"
                ;;
            2)
                list_plugins
                ;;
            3)
                list_plugins
                read -p "Plugin to remove: " plugin_name
                remove_plugin "$plugin_name"
                ;;
            4)
                read -p "Plugin name: " plugin_name
                read -p "JSON configuration: " config
                update_config "$plugin_name" "$config"
                ;;
            5)
                check_plugins
                ;;
            6)
                log "Backing up all plugins..."
                cp -r $PLUGINS_DIR $BACKUP_DIR/plugins-$(date +%Y%m%d_%H%M%S)
                log "Backup completed"
                ;;
            7)
                log "Exiting..."
                exit 0
                ;;
            *)
                error "Invalid choice"
                ;;
        esac
        
        echo ""
        read -p "Press Enter to continue..."
    done
}

# Run main menu
main
```

---

## 📊 Best Practices

### 1. Plugin Management
- [ ] Backup plugin sebelum update
- [ ] Test plugin di staging environment
- [ ] Update satu plugin sekali
- [ ] Monitor performance setelah install

### 2. Security
- [ ] Download plugin dari official source
- [ ] Scan plugin untuk malware
- [ ] Restrict plugin permissions
- [ ] Audit plugin secara berkala

### 3. Performance
- [ ] Monitor memory usage
- [ ] Enable caching jika available
- [ ] Balance plugin features vs performance
- [ ] Remove unused plugins

### 4. Documentation
- [ ] Document semua plugin yang terinstall
- [ ] Simpan script configuration
- [ ] Create troubleshooting guide
- [ ] Update documentation saat update

---

## 🎯 Next Steps

Setelah menginstall plugin:
1. **Test semua fitur** yang baru tersedia
2. **Update dokumentasi** dengan fitur baru
3. **Train users** penggunaan plugin
4. **Monitor performa** secara berkala
5. **Plan future upgrades** untuk plugin

---

**🎯 Selanjutnya**: [06-Konfigurasi PACS](./06-Konfigurasi-PACS.md) - Pelajari cara mengintegrasikan Orthanc dengan PACS dan sistem lainnya!# 06. Konfigurasi PACS Integration

## 📋 Apa yang akan Anda Pelajari

- Pengenalan konsep PACS dan DICOM networking
- Setup Orthanc sebagai PACS SCP/SCU
- Konfigurasi DICOM associations
- Integrasi dengan PACS lainnya
- Data routing dan forwarding
- Monitoring dan troubleshooting PACS

---

## 🏥 Pengenalan PACS

### Apa itu PACS?
PACS (Picture Archiving and Communication System) adalah sistem untuk:
- **Storage**: Menyimpan gambar medis
- **Retrieval**: Mengakses gambar dari lokasi lain
- **Management**: Manajemen data medis
- **Distribution**: Sharing data antar fasilitas

### Komponen PACS
```yaml
1. **Modalities**: CT Scanner, MRI, X-Ray machine
2. **Workstations**: Radiology workstations
3. **Servers**: Storage and processing servers
4. **Network**: DICOM network connections
5. **Archive**: Long-term storage
```

### Orthanc dalam Ecosystem PACS
Orthanc dapat berfungsi sebagai:
- **SCP (Service Class Provider)**: Menerima data
- **SCU (Service Class User)**: Mengirim data
- **Router**: Forward data ke tempat lain
- **Gateway**: Bridge antar system

---

## 🔌 DICOM Networking Basics

### DICOM Service Classes
```yaml
1. **Storage Service**: 
   - C-STORE SCP/SCU
   - Upload/download file
   
2. **Query/Retrieve Service**:
   - C-FIND SCP/SCU
   - C-MOVE SCP/SCU
   - C-GET SCP/SCU
   
3. **Verification Service**:
   - C-ECHO SCP/SCU
   - Check connection
```

### DICOM Association
```yaml
AET (Application Entity Title): Identifier unik
Port: Port untuk komunikasi
Timeout: Wait time for response
Called/Calling AET: Who's calling whom
```

### DICOM Configuration Elements
```json
{
  "DicomModalities": {
    "MODALITY-AET": {
      "Address": "192.168.1.100",
      "Port": 4242,
      "AET": "PACS-AET"
    }
  },
  "DicomFindSCU": {
    "AET": "ORTHANC-FIND",
    "CalledAET": "ANY-SCP"
  }
}
```

---

## ⚙️ Setup Orthanc sebagai PACS SCP

### Basic SCP Configuration
```json
// orthanc.json
{
  "Name": "Orthanc PACS Server",
  "DicomPort": 4242,
  "DicomAet": "ORTHANC",
  "DicomTimeout": 30,
  "DicomMaximumPduSize": 16384,
  "DicomSopClassUids": [
    "1.2.840.10008.1.2.1",  // CR Image Storage
    "1.2.840.10008.1.2.1.1", // Enhanced MR Image Storage
    "1.2.840.10008.1.2.4.70" // Enhanced CT Image Storage
  ],
  "DicomAllowedAets": ["MODALITY*", "PACS-AET"],
  "DicomSendCalledAetInsteadCalledAet": false
}
```

### Docker Compose for SCP
```yaml
# docker-compose.yml
version: '3.8'

services:
  orthanc:
    image: jodogne/orthanc-plugins:latest
    container_name: orthanc-pacs
    restart: unless-stopped
    ports:
      - "4242:4242"  # DICOM port
      - "8042:8042"  # HTTP port
    volumes:
      - ./orthanc-data:/var/lib/orthanc/db
      - ./orthanc.json:/etc/orthanc/orthanc.json
    environment:
      - ORTHANCPlugins=/usr/share/orthanc/plugins
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:8042/system"]
      interval: 30s
      timeout: 10s
      retries: 3
```

### Test DICOM Connection
```bash
# Test DICOM port
nc -zv localhost 4242

# Test C-ECHO (DICOM ping)
dcmtk_path="/usr/bin"  # Sesuai instalasi Anda
$dcmtk_path/dcmcu -aec ORTHANC -aet ANY-SCP localhost 4242

# Atau dengan curl
curl -s http://localhost:8042/dicom-modes | jq '.Dicom'
```

---

## 🔄 Setup DICOM SCU (Client)

### Configuration for SCU
```json
// orthanc.json
{
  "Name": "Orthanc with SCU",
  "DicomModalities": {
    "LOCAL-CT": {
      "Address": "192.168.1.100",
      "Port": 4242,
      "AET": "CT-SCANNER"
    },
    "REMOTE-PACS": {
      "Address": "pacs.hospital.com",
      "Port": 104,
      "AET": "PACS-SERVER",
      "Username": "user",
      "Password": "pass"
    }
  },
  "DicomFindSCU": {
    "AET": "ORTHANC-FIND",
    "CalledAET": "REMOTE-PACS",
    "Timeout": 30
  },
  "DicomMoveSCU": {
    "AET": "ORTHANC-MOVE",
    "CalledAET": "REMOTE-PACS",
    "Timeout": 60
  },
  "DicomGetSCU": {
    "AET": "ORTHANC-GET",
    "CalledAET": "REMOTE-PACS",
    "Timeout": 60
  }
}
```

### Test SCU Operations
```bash
# Test C-FIND (search patients)
findscu -aec ORTHANC -aet REMOTE-PACS -P "PatientName=*" localhost 4242

# Test C-MOVE (transfer studies)
movescu -aec ORTHANC -aet REMOTE-PACS -P "StudyInstanceUID=1.2.3.4.5" \
  -od "ORTHANC" -x localhost 4242

# Test C-STORE (upload file)
storescu -aec ORTHANC -aet REMOTE-PACS file.dcm localhost 4242
```

### DICOM Operations API
```bash
# Query studies
curl -X POST http://localhost:8042/tools/dicom-query \
  -H "Content-Type: application/json" \
  -d '{
    "Level": "Study",
    "Query": {
      "ModalitiesInStudy": ["CT", "MR"]
    },
    "Aet": "REMOTE-PACS",
    "Peer": "REMOTE-PACS"
  }'

# Move studies
curl -X POST http://localhost:8042/tools/dicom-move \
  -H "Content-Type: application/json" \
  -d '{
    "StudyUID": "1.2.3.4.5.6",
    "TargetAet": "ORTHANC",
    "OriginAet": "REMOTE-PACS"
  }'

# Store instance
curl -X POST -T file.dcm http://localhost:8042/dicom-store
```

---

## 🌐 Multi-Site Configuration

### Central-Orthanc Architecture
```
[Site A] --- [Site B] --- [Central Orthanc]
    |             |            |
[Local PACS]  [Local PACS]  [Archive]
```

### Configuration for Multi-Site
```json
{
  "Name": "Central Orthanc",
  "DicomModalities": {
    "SITE-A-CT": {
      "Address": "site-a.local",
      "Port": 4242,
      "AET": "CT-SCANNER-A"
    },
    "SITE-B-MR": {
      "Address": "site-b.local",
      "Port": 4242,
      "AET": "MR-SCANNER-B"
    },
    "CENTRAL-PACS": {
      "Address": "archive.hospital.com",
      "Port": 11112,
      "AET": "PACS-ARCHIVE"
    }
  },
  "Routing": {
    "AutoForward": true,
    "Rules": [
      {
        "From": ["SITE-A-*", "SITE-B-*"],
        "To": "CENTRAL-PACS",
        "Condition": "Modality in ['CT', 'MR']"
      }
    ]
  }
}
```

### Site-to-Site Communication
```bash
# Setup VPN between sites
# 1. Configure VPN on each router
# 2. Test connectivity
ping site-a.local
ping site-b.local

# Test DICOM over VPN
findscu -aec ORTHANC -aet SITE-A-CT -P "PatientName=*" site-a.local 4242
```

---

## 📊 Data Routing and Filtering

### Automatic Routing Configuration
```json
{
  "Routing": {
    "Enabled": true,
    "Rules": [
      {
        "Name": "CT to PACS A",
        "Condition": "Modality == 'CT'",
        "Action": {
          "Type": "Forward",
          "Target": "PACS-A",
          "Aet": "PACS-SCU"
        }
      },
      {
        "Name": "MRI to PACS B",
        "Condition": "Modality == 'MRI'",
        "Action": {
          "Type": "Forward",
          "Target": "PACS-B",
          "Aet": "PACS-SCU"
        }
      },
      {
        "Name": "Archive old studies",
        "Condition": "StudyDate < '2024-01-01'",
        "Action": {
          "Type": "Archive",
          "Target": "LONG-TERM-ARCHIVE"
        }
      }
    ]
  }
}
```

### Routing Script Example
```lua
-- scripts/routing.lua
function OnInstanceReceived(instanceId)
    local instance = OrthancApiClient:GetInstance(instanceId)
    local study = OrthancApiClient:GetStudy(instance.ParentStudy)
    local patient = OrthancApiClient:GetPatient(study.ParentPatient)
    
    -- Get study details
    local modality = study.MainDicomTags.Modality
    local studyDate = study.MainDicomTags.StudyDate
    
    -- Rule: Emergency studies to mobile PACS
    if study.Tags.Priority == "E" then
        OrthancApiClient:ForwardToPACS(study.Id, "MOBILE-PACS")
        OrthancApiClient:Log("Emergency study forwarded to mobile PACS")
    end
    
    -- Rule: Cardiology studies to cardiology PACS
    if modality == "CG" or modality == "ECG" then
        OrthancApiClient:ForwardToPACS(study.Id, "CARDIO-PACS")
        OrthancApiClient:Log("Cardiology study forwarded")
    end
    
    -- Rule: Archive studies older than 5 years
    local studyYear = string.sub(studyDate, 1, 4)
    local currentYear = tonumber(os.date("%Y"))
    if currentYear - studyYear > 5 then
        OrthancApiClient:ArchiveStudy(study.Id)
        OrthancApiClient:Log("Old study archived")
    end
end
```

### Load Balancing Configuration
```json
{
  "LoadBalancing": {
    "Enabled": true,
    "Strategy": "round-robin",
    "Targets": [
      {
        "Aet": "PACS-1",
        "Weight": 1
      },
      {
        "Aet": "PACS-2",
        "Weight": 2
      }
    ],
    "HealthCheck": {
      "Interval": 30,
      "Timeout": 5,
      "Retries": 3
    }
  }
}
```

---

## 🔐 Security Configuration

### Authentication for DICOM
```json
{
  "DicomModalities": {
    "SECURE-PACS": {
      "Address": "secure-pacs.hospital.com",
      "Port": 4242,
      "AET": "PACS-SECURE",
      "Username": "admin",
      "Password": "secure123",
      "UseSsl": true,
      "CertificateFile": "/etc/ssl/certs/pacs.crt",
      "PrivateKeyFile": "/etc/ssl/private/pacs.key"
    }
  },
  "DicomAllowedAets": ["ORTHANC", "WORKSTATION-AET"],
  "DicomRejectedAets": ["EXTERNAL-AET"],
  "DicomMaximumNumberOfAssociations": 10,
  "DicomTimeout": 30
}
```

### DICOM Audit Logging
```json
{
  "Audit": {
    "Enabled": true,
    "LogLevel": "info",
    "LogEvents": [
      "C-STORE",
      "C-FIND",
      "C-MOVE",
      "C-GET",
      "C-ECHO"
    ],
    "LogFormat": "json",
    "LogFile": "/var/log/orthanc/dicom-audit.log"
  }
}
```

### Firewall Rules
```bash
# For UFW
sudo ufw allow 4242/tcp  # DICOM
sudo ufw allow 8042/tcp  # HTTP
sudo ufw allow 8443/tcp  # HTTPS

# For iptables
sudo iptables -A INPUT -p tcp --dport 4242 -j ACCEPT
sudo iptables -A INPUT -p tcp --dport 8042 -j ACCEPT
```

---

## 📈 Monitoring and Statistics

### DICOM Statistics
```bash
# Get DICOM statistics
curl http://localhost:8042/tools/statistics | jq '.Dicom'

# Get modalities statistics
curl http://localhost:8042/tools/statistics | jq '.Modalities'

# Monitor DICOM operations
curl http://localhost:8042/tools/performance | jq '.Dicom'
```

### Custom Monitoring Script
```bash
#!/bin/bash
# scripts/monitor-pacs.sh

LOG_FILE="/var/log/orthanc/pacs-monitor.log"
DATE=$(date '+%Y-%m-%d %H:%M:%S')

echo "=== PACS Monitor - $DATE ===" >> $LOG_FILE

# Check DICOM connections
DICOM_CONNECTIONS=$(curl -s http://localhost:8042/tools/statistics | jq '.Dicom.Connections // 0')
echo "DICOM Connections: $DICOM_CONNECTIONS" >> $LOG_FILE

# Check active modalities
ACTIVE_MODALITIES=$(curl -s http://localhost:8042/tools/statistics | jq '.Modalities | length')
echo "Active Modalities: $ACTIVE_MODALITIES" >> $LOG_FILE

# Check storage usage
STORAGE_USAGE=$(curl -s http://localhost:8042/tools/statistics | jq '.StorageUsage // 0')
echo "Storage Usage: $STORAGE_USAGE MB" >> $LOG_FILE

# Check performance
PERFORMANCE=$(curl -s http://localhost:8042/tools/performance | jq '.AverageResponseTime // 0')
echo "Average Response Time: $PERFORMANCE ms" >> $LOG_FILE

# Alert if too many connections
if [ $DICOM_CONNECTIONS -gt 100 ]; then
    echo "⚠ High DICOM connections: $DICOM_CONNECTIONS" >> $LOG_FILE
    # Send alert
    # /path/to/alert-script.sh "High DICOM connections"
fi

echo "=== End Monitor ===" >> $LOG_FILE
```

### Performance Tuning
```json
{
  "Performance": {
    "DicomTimeout": 30,
    "DicomMaximumPduSize": 16384,
    "DicomMaximumNumberOfOperations": 5,
    "DicomCompressionEnabled": true,
    "DicomCompressionRatio": 10
  }
}
```

---

## 🔍 Troubleshooting PACS

### Common Issues

#### Connection Refused
```bash
# Check if DICOM port is open
sudo netstat -tlnp | grep 4242

# Check if Orthanc is listening on DICOM port
curl -s http://localhost:8042/dicom-modes | jq '.Dicom.ListenPort'

# Test C-ECHO
dcmtk_path="/usr/bin"
$dcmtk_path/dcmcu -aec ORTHANC -aet ORTHANC localhost 4242
```

#### Association Rejected
```bash
# Check AET configuration
curl -s http://localhost:8042/system | jq '.DicomAet'

# Check allowed AETs
curl -s http://localhost:8042/system | jq '.DicomAllowedAets'

# Test with different AET
findscu -aec ORTHANC -aet ORTHANC -P "PatientName=*" localhost 4242
```

#### Data Not Forwarding
```bash
# Check routing configuration
curl -s http://localhost:8042/system | jq '.Routing'

# Check routing logs
tail -f /var/log/orthanc/orthanc.log | grep -i "route"

# Test manual forwarding
curl -X POST http://localhost:8042/tools/dicom-move \
  -H "Content-Type: application/json" \
  -d '{"StudyUID": "...", "TargetAet": "..."}'
```

### Debug Commands
```bash
# Enable DICOM debug logging
jq '.LogLevel = "debug"' orthanc.json > tmp.json && mv tmp.json orthanc.json
docker-compose restart orthanc

# Capture DICOM traffic
sudo tcpdump -i any -s 0 -w dicom.pcap 'port 4242'

# Analyze DICOM packets
wireshark dicom.pcap

# Check DICOM conformance
curl -s http://localhost:8042/tools/dicom-conformance | jq '.'
```

### Performance Issues
```bash
# Monitor DICOM performance
curl -s http://localhost:8042/tools/performance | jq '.Dicom'

# Check memory usage
docker stats orthanc-pacs

# Check CPU usage
top -p $(pgrep -f orthanc)

# Optimize DICOM timeouts
jq '.DicomTimeout = 20' orthanc.json > tmp.json && mv tmp.json orthanc.json
```

---

## 🛠️ Advanced Configuration

### Hot Standby Configuration
```json
{
  "HighAvailability": {
    "Enabled": true,
    "Mode": "hot-standby",
    "Primary": "orthanc-primary:8042",
    "Secondary": "orthanc-secondary:8042",
    "HeartbeatInterval": 5,
    "FailoverTimeout": 30
  }
}
```

### DICOM Compression
```json
{
  "DicomCompression": {
    "Enabled": true,
    "Lossless": false,
    "Quality": 90,
    "TransferSyntax": "1.2.840.10008.1.2.4.90",  // JPEG Lossless
    "SupportedSyntaxes": [
      "1.2.840.10008.1.2.1",  // Explicit VR Little Endian
      "1.2.840.10008.1.2.5",  // Explicit VR Big Endian
      "1.2.840.10008.1.2.4.90" // JPEG Lossless
    ]
  }
}
```

### Custom DICOM Tags
```json
{
  "CustomTags": {
    "HospitalName": "RS Example",
    "Department": "Radiology",
    "ReferringPhysician": "Dr. Smith",
    "StudyDescription": {
      "Type": "String",
      "Value": "Routine Checkup"
    }
  }
}
```

---

## 📋 Implementation Checklist

### Before Implementation
- [ ] Understand PACS workflow
- [ ] Map existing modalities
- [ ] Plan network topology
- [ ] Define routing rules
- [ ] Setup security measures

### During Implementation
- [ ] Install and configure Orthanc
- [ ] Configure DICOM ports
- [ ] Setup modalities
- [ ] Test C-ECHO connectivity
- [ ] Configure routing rules
- [ ] Test data flow

### After Implementation
- [ ] Monitor performance
- [ ] Test failover
- [ ] Audit security
- [ ] Train users
- [ ] Document procedures

---

## 🎯 Next Steps

1. **Test integrasi** dengan semua modalities
2. **Validate data flow** sesuai routing rules
3. **Setup monitoring** untuk PACS operations
4. **Create documentation** untuk tim IT
5. **Train users** penggunaan PACS features

---

**🎯 Selanjutnya**: [07-Konfigurasi Inti Orthanc](./07-Konfigurasi-Inti-Orthanc.md) - Pelajari konfigurasi utama dan pengaturan database Orthanc!# 07. Konfigurasi Inti Orthanc

## 📋 Apa yang akan Anda Pelajari

- Struktur file konfigurasi Orthanc
- Pengaturan esensial yang perlu dikonfigurasi
- Konfigurasi database dan storage
- Pengaturan network dan ports
- Konfigurasi authentication dan security
- Best practices untuk konfigurasi

---

## 📁 Struktur File Konfigurasi

### Lokasi File Konfigurasi
```bash
# Default locations:
# Linux/macOS: /etc/orthanc/orthanc.json
# Windows: C:\Orthanc\Orthanc.json
# Docker: Mount ke /etc/orthanc/orthanc.json
```

### Struktur Dasar orthanc.json
```json
{
  // 1. Basic Settings
  "Name": "My Orthanc",
  "Description": "Orthanc DICOM Server",
  
  // 2. Network Settings
  "HttpPort": 8042,
  "DicomPort": 4242,
  
  // 3. Authentication
  "AuthenticationEnabled": false,
  "UserName": "",
  "Password": "",
  
  // 4. Storage Settings
  "StorageDirectory": "OrthancStorage",
  "IndexDirectory": "OrthancStorage",
  
  // 5. Database Settings
  "Database": {
    "Type": "sqlite",
    "Path": "OrthancStorage/index"
  },
  
  // 6. DICOM Settings
  "DicomAet": "ORTHANC",
  "DicomTimeout": 30,
  
  // 7. Advanced Settings
  "HttpCompression": true,
  "StorageCompression": false,
  "MaximumStorageSize": 0
}
```

---

## ⚙️ Pengaturan Esensial

### 1. Pengaturan Dasar

#### Server Identity
```json
{
  "Name": "Orthanc Server",
  "Description": "DICOM Server for Medical Imaging",
  "OrthancId": "main"
}
```

**Penjelasan:**
- **Name**: Nama yang akan ditampilkan di web interface
- **Description**: Deskripsi tambahan
- **OrthancId**: ID unik untuk identification (opsional)

#### Network Ports
```json
{
  "HttpPort": 8042,
  "HttpsPort": 8443,
  "DicomPort": 4242,
  "DicomAet": "ORTHANC"
}
```

**Penjelasan:**
- **HttpPort**: Port untuk REST API dan web interface
- **HttpsPort**: Port untuk secure connections (jika diaktifkan)
- **DicomPort**: Port untuk komunikasi DICOM
- **DicomAet**: Application Entity Title untuk DICOM

### 2. Authentication Settings

#### Basic Authentication
```json
{
  "AuthenticationEnabled": true,
  "UserName": "admin",
  "Password": "your-secure-password",
  "AllowAnonymous": false,
  "SessionsTimeout": 3600,
  "EnableHttpSessions": true
}
```

**Penjelasan:**
- **AuthenticationEnabled**: Aktifkan/disable login
- **UserName/Password**: Kredensial untuk login
- **AllowAnonymous**: Izinkan akses tanpa login
- **SessionsTimeout**: Durasi session dalam detik
- **EnableHttpSessions**: Aktifkan session management

#### Advanced ACL Configuration
```json
{
  "AuthenticationEnabled": true,
  "RegisteredUsers": {
    "admin": {
      "Password": "admin-password",
      "IsReadOnly": false,
      "Permissions": ["Read", "Write", "Anonymize", "Delete"]
    },
    "viewer": {
      "Password": "viewer-password",
      "IsReadOnly": true,
      "Permissions": ["Read"]
    }
  }
}
```

### 3. Storage Settings

#### Basic Storage Configuration
```json
{
  "StorageDirectory": "/var/lib/orthanc/db",
  "IndexDirectory": "/var/lib/orthanc/db",
  "TemporaryDirectory": "/tmp/orthanc/"
}
```

**Penjelasan:**
- **StorageDirectory**: Lokasi penyimpanan file DICOM
- **IndexDirectory**: Lokasi database index
- **TemporaryDirectory**: Lokasi file temporary

#### Storage Compression
```json
{
  "StorageCompression": true,
  "DefaultLostResourceCompression": true,
  "JpegCompression": {
    "Enabled": true,
    "Quality": 85
  }
}
```

**Penjelasan:**
- **StorageCompression**: Aktifkan kompresi storage
- **DefaultLostResourceCompression**: Kompresi default
- **JpegCompression**: Kompresi JPEG dengan quality

#### Storage Limits
```json
{
  "MaximumStorageSize": 104857600,  // Dalam bytes (100GB)
  "MaximumPatientCount": 0,         // 0 = tidak ada limit
  "MaximumStorageCacheSize": 1024,   // Dalam MB
  "MaximumStorageCachedPatientCount": 0
}
```

**Penjelasan:**
- **MaximumStorageSize**: Maksimum ukuran storage
- **MaximumPatientCount**: Maksimum jumlah pasien
- **MaximumStorageCacheSize**: Maksimum cache size
- **MaximumStorageCachedPatientCount**: Maksimum patient di cache

### 4. Database Settings

#### SQLite Configuration (Default)
```json
{
  "Database": {
    "Type": "sqlite",
    "Path": "/var/lib/orthanc/db/index",
    "PageSize": 4096,
    "JournalMode": "WAL",
    "Synchronous": "NORMAL",
    "BusyTimeout": 30000
  }
}
```

**Penjelasan:**
- **Type**: Tipe database (sqlite/mysql/postgresql)
- **Path**: Lokasi database file
- **PageSize**: Ukuran halaman database
- **JournalMode**: Mode journal (WAL untuk performa)
- **Synchronous**: Level sinkronisasi database
- **BusyTimeout**: Timeout untuk database busy

#### MySQL Configuration
```json
{
  "Database": {
    "Type": "mysql",
    "Host": "localhost",
    "Port": 3306,
    "DatabaseName": "orthanc",
    "Username": "orthanc_user",
    "Password": "database_password",
    "PoolSize": 5
  }
}
```

#### PostgreSQL Configuration
```json
{
  "Database": {
    "Type": "postgresql",
    "Host": "localhost",
    "Port": 5432,
    "DatabaseName": "orthanc",
    "Username": "orthanc_user",
    "Password": "database_password",
    "PoolSize": 5,
    "ConnectionTimeout": 30
  }
}
```

### 5. DICOM Settings

#### Basic DICOM Configuration
```json
{
  "DicomAet": "ORTHANC",
  "DicomPort": 4242,
  "DicomTimeout": 30,
  "DicomMaximumPduSize": 16384,
  "DicomFindSCU": {
    "Aet": "ORTHANC-FIND",
    "CalledAet": "ANY-SCP",
    "Timeout": 30
  },
  "DicomMoveSCU": {
    "Aet": "ORTHANC-MOVE",
    "CalledAet": "ANY-SCP",
    "Timeout": 60
  }
}
```

**Penjelasan:**
- **DicomAet**: Application Entity Title
- **DicomPort**: Port untuk DICOM communication
- **DicomTimeout**: Timeout untuk DICOM operations
- **DicomMaximumPduSize**: Maksimum PDU size
- **DicomFindSCU**: Settings untuk DICOM FIND operations
- **DicomMoveSCU**: Settings untuk DICOM MOVE operations

#### DICOM Modalities
```json
{
  "DicomModalities": {
    "LOCAL-CT": {
      "Address": "192.168.1.100",
      "Port": 4242,
      "Aet": "CT-SCANNER"
    },
    "REMOTE-PACS": {
      "Address": "pacs.hospital.com",
      "Port": 104,
      "Aet": "PACS-SERVER",
      "Username": "user",
      "Password": "pass"
    }
  }
}
```

#### DICOM Security
```json
{
  "DicomTlsEnabled": true,
  "DicomTlsCertificateFile": "/etc/ssl/certs/orthanc.crt",
  "DicomTlsPrivateKeyFile": "/etc/ssl/private/orthanc.key",
  "DicomTlsVerifyPeers": false
}
```

### 6. Advanced Settings

#### HTTP Configuration
```json
{
  "HttpCompression": true,
  "HttpTimeout": 30,
  "HttpMaxConnections": 100,
  "HttpKeepAlive": true,
  "HttpKeepAliveTimeout": 300
}
```

**Penjelasan:**
- **HttpCompression**: Aktifkan HTTP compression
- **HttpTimeout**: Timeout untuk HTTP requests
- **HttpMaxConnections**: Maksimum connections
- **HttpKeepAlive**: Aktifkan keep-alive
- **HttpKeepAliveTimeout**: Timeout untuk keep-alive

#### Logging Configuration
```json
{
  "Logging": {
    "Level": "info",
    "File": "/var/log/orthanc/orthanc.log",
    "Rotate": true,
    "RotateSize": 10485760,
    "RotateCount": 5,
    "EnableHttpLogs": true,
    "EnableDicomLogs": true
  }
}
```

**Penjelasan:**
- **Level**: Log level (trace, debug, info, warning, error)
- **File**: Lokasi log file
- **Rotate**: Aktifkan log rotation
- **RotateSize**: Ukuran sebelum rotate (bytes)
- **RotateCount**: Jumlah log files yang disimpan
- **EnableHttpLogs**: Log HTTP requests
- **EnableDicomLogs**: Log DICOM operations

---

## 🔧 Konfigurasi Database

### SQLite Setup
```bash
# Create database directory
mkdir -p /var/lib/orthanc/db
chmod 755 /var/lib/orthanc/db

# Set permissions
chown orthanc:orthanc /var/lib/orthanc/db

# Initialize database
orthanc --config=/etc/orthanc/orthanc.json
```

### MySQL Setup
```bash
# Create database dan user
mysql -u root -p << 'EOF'
CREATE DATABASE orthanc CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
CREATE USER 'orthanc_user'@'localhost' IDENTIFIED BY 'strong_password';
GRANT ALL PRIVILEGES ON orthanc.* TO 'orthanc_user'@'localhost';
FLUSH PRIVILEGES;
EOF

# Import Orthanc schema
mysql -u orthanc_user -p orthanc < /path/to/orthanc/schema.sql
```

### PostgreSQL Setup
```bash
# Create database dan user
sudo -u postgres psql << 'EOF'
CREATE DATABASE orthanc;
CREATE USER orthanc_user WITH PASSWORD 'strong_password';
GRANT ALL PRIVILEGES ON DATABASE orthanc TO orthanc_user;
EOF

# Initialize database
psql -U orthanc_user -d orthanc < /path/to/orthanc/schema.sql
```

---

## 🚀 Konfigurasi Docker

### Basic Docker Compose
```yaml
version: '3.8'

services:
  orthanc:
    image: jodogne/orthanc-plugins:latest
    container_name: orthanc-server
    restart: unless-stopped
    ports:
      - "8042:8042"    # HTTP
      - "4242:4242"    # DICOM
    volumes:
      - ./orthanc-data:/var/lib/orthanc/db
      - ./orthanc.json:/etc/orthanc/orthanc.json
      - ./plugins:/usr/share/orthanc/plugins
      - ./logs:/var/log/orthanc
    environment:
      - ORTHANCPlugins=/usr/share/orthanc/plugins
      - ORTHANC_LOG_LEVEL=info
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:8042/system"]
      interval: 30s
      timeout: 10s
      retries: 3
```

### Advanced Docker Compose dengan Database
```yaml
version: '3.8'

services:
  orthanc:
    image: jodogne/orthanc-plugins:latest
    container_name: orthanc-server
    restart: unless-stopped
    ports:
      - "8042:8042"
      - "4242:4242"
    volumes:
      - ./orthanc-data:/var/lib/orthanc/db
      - ./orthanc.json:/etc/orthanc/orthanc.json
      - ./plugins:/usr/share/orthanc/plugins
      - ./logs:/var/log/orthanc
      - ./certs:/etc/ssl/certs
    environment:
      - ORTHANCPlugins=/usr/share/orthanc/plugins
      - ORTHANC_LOG_LEVEL=info
    depends_on:
      - postgres
      - redis
    networks:
      - orthanc-network

  postgres:
    image: postgres:14
    container_name: orthanc-postgres
    restart: unless-stopped
    environment:
      POSTGRES_DB: orthanc
      POSTGRES_USER: orthanc_user
      POSTGRES_PASSWORD: postgres_password
    volumes:
      - postgres-data:/var/lib/postgresql/data
    networks:
      - orthanc-network

  redis:
    image: redis:7
    container_name: orthanc-redis
    restart: unless-stopped
    volumes:
      - redis-data:/data
    networks:
      - orthanc-network

volumes:
  postgres-data:
  redis-data:

networks:
  orthanc-network:
    driver: bridge
```

---

## 🔐 Security Configuration

### HTTPS Configuration
```json
{
  "HttpsPort": 8443,
  "CertificateFile": "/etc/ssl/certs/orthanc.crt",
  "KeyFile": "/etc/ssl/private/orthanc.key",
  "SslEnabled": true,
  "SslVerifyPeers": false
}
```

### Generate Self-Signed Certificate
```bash
# Generate certificate
openssl req -x509 -newkey rsa:4096 -keyout orthanc.key \
  -out orthanc.crt -days 365 -nodes

# Copy to certificates directory
sudo cp orthanc.crt /etc/ssl/certs/
sudo cp orthanc.key /etc/ssl/private/

# Set permissions
sudo chmod 600 /etc/ssl/private/orthanc.key
```

### Firewall Configuration
```json
{
  "RemoteAccessAllowed": true,
  "RemoteAccessAllowedIPs": ["192.168.1.0/24"],
  "DicomMaximumNumberOfAssociations": 10,
  "HttpMaxConnections": 100
}
```

---

## 📊 Monitoring Configuration

### Metrics Configuration
```json
{
  "Metrics": {
    "Enabled": true,
    "Port": 9090,
    "CollectInterval": 60,
    "EnableDatabaseMetrics": true,
    "EnableDicomMetrics": true,
    "EnableHttpMetrics": true
  }
}
```

### Performance Monitoring
```json
{
  "Performance": {
    "EnableProfiling": false,
    "ProfilingInterval": 60,
    "ProfilingOutput": "/var/log/orthanc/profile.log"
  }
}
```

---

## 🛠️ Konfigurasi untuk Production

### Production-Ready Configuration
```json
{
  "Name": "Orthanc Production",
  "Description": "Production DICOM Server",
  
  // Network
  "HttpPort": 8042,
  "HttpsPort": 8443,
  "DicomPort": 4242,
  "DicomAet": "PROD-ORTHANC",
  
  // Authentication
  "AuthenticationEnabled": true,
  "RegisteredUsers": {
    "admin": {
      "Password": "secure-production-password",
      "IsReadOnly": false
    }
  },
  
  // Storage
  "StorageDirectory": "/data/orthanc/storage",
  "IndexDirectory": "/data/orthanc/index",
  "TemporaryDirectory": "/tmp/orthanc",
  
  // Database
  "Database": {
    "Type": "postgresql",
    "Host": "postgres",
    "Port": 5432,
    "DatabaseName": "orthanc",
    "Username": "orthanc_user",
    "Password": "database-password"
  },
  
  // Security
  "HttpCompression": true,
  "SslEnabled": true,
  "CertificateFile": "/etc/ssl/certs/orthanc.crt",
  "KeyFile": "/etc/ssl/private/orthanc.key",
  
  // Logging
  "Logging": {
    "Level": "info",
    "File": "/var/log/orthanc/orthanc.log",
    "Rotate": true,
    "RotateSize": 104857600,
    "RotateCount": 10
  },
  
  // Performance
  "MaximumStorageSize": 1073741824000,  // 1TB
  "MaximumPatientCount": 0,
  "DicomTimeout": 60,
  "HttpMaxConnections": 500
}
```

---

## 🔍 Validasi Konfigurasi

### JSON Validation
```bash
# Validate JSON syntax
jq . orthanc.json

# Check for errors
if [ $? -eq 0 ]; then
    echo "✓ JSON is valid"
else
    echo "✗ JSON has errors"
fi
```

### Configuration Testing
```bash
# Test configuration with dry run
orthanc --config=orthanc.json --dry-run

# Check for warnings
orthanc --config=orthanc.json --verbose 2>&1 | grep -i warning
```

### Database Connection Test
```bash
# Test SQLite connection
sqlite3 /var/lib/orthanc/db/index "SELECT * FROM sqlite_master LIMIT 1;"

# Test MySQL connection
mysql -u orthanc_user -p orthanc -e "SELECT 1;"

# Test PostgreSQL connection
psql -U orthanc_user -d orthanc -c "SELECT 1;"
```

---

## 📋 Konfigurasi Template

### Minimal Configuration
```json
{
  "Name": "Minimal Orthanc",
  "HttpPort": 8042,
  "DicomPort": 4242,
  "StorageDirectory": "OrthancStorage"
}
```

### Development Configuration
```json
{
  "Name": "Development Orthanc",
  "HttpPort": 8042,
  "DicomPort": 4242,
  "AuthenticationEnabled": false,
  "StorageDirectory": "OrthancStorage",
  "Logging": {
    "Level": "debug",
    "File": "/tmp/orthanc.log"
  }
}
```

### Testing Configuration
```json
{
  "Name": "Testing Orthanc",
  "HttpPort": 8042,
  "DicomPort": 4242,
  "AuthenticationEnabled": false,
  "StorageDirectory": "/tmp/orthanc-test",
  "IndexDirectory": "/tmp/orthanc-test",
  "Logging": {
    "Level": "trace",
    "File": "/tmp/orthanc-test.log"
  }
}
```

---

## 🔄 Konfigurasi Reloading

### Reload Configuration without Restart
```bash
# Signal Orthanc to reload
kill -HUP $(pidof Orthanc)

# Atau melalui API
curl -X PUT http://localhost:8042/system/reload
```

### Hot Reload Configuration
```json
{
  "AutoReload": true,
  "ReloadInterval": 60,
  "ConfigFile": "/etc/orthanc/orthanc.json",
  "WatchDirectory": "/etc/orthanc/"
}
```

---

## 📝 Tips Konfigurasi

### 1. Storage Planning
- Gunakan SSD untuk database dan active data
- Gunakan HDD untuk archive dan backup
- Pisahkan data dan sistem operasi
- Plan untuk 2-3x growth

### 2. Database Selection
- **SQLite**: Untuk skala kecil, sederhana
- **MySQL**: Untuk production, fitur lengkap
- **PostgreSQL**: Untuk performance dan skalabilitas

### 3. Network Configuration
- Gunakan dedicated port untuk DICOM
- Implementasi load balancing untuk high availability
- Configure timeout sesuai kebutuhan
- Monitor connection usage

### 4. Security Best Practices
- Aktifkan authentication untuk production
- Gunakan HTTPS untuk semua connections
- Implement rate limiting
- Regular security audits

---

## 📋 Checklist Konfigurasi

### Before Deployment
- [ ] Backup existing configuration
- [ ] Validate JSON syntax
- [ ] Test configuration locally
- [ ] Setup database connection
- [ ] Configure authentication

### After Configuration
- [ ] Test all endpoints
- [ ] Verify database connection
- [ ] Check logging configuration
- [ ] Test security settings
- [ ] Monitor performance

---

## 🎯 Next Steps

1. **Test konfigurasi** dengan berbagai skenario
2. **Backup konfigurasi** secara berkala
3. **Document semua custom settings**
4. **Monitor performance** dan adjust
5. **Update configuration** saat upgrade

---

**🎯 Selanjutnya**: [08-Akses Lokal](./08-Akses-Lokal.md) - Pelajari cara akses Orthanc secara lokal di jaringan Anda!
# 08. Cara Akses Orthanc Secara Lokal

## 📋 Apa yang akan Anda Pelajari

- Cara akses Orthanc di komputer yang sama
- Cara akses dari komputer lain di jaringan lokal
- Setup port forwarding di router
- Konfigurasi local DNS
- Troubleshooting masalah akses lokal
- Tips untuk performa lokal

---

## 🖥️ Konsep Akses Lokal

### Apa itu Local Access?
Local access berarti mengakses Orthanc tanpa melalui internet:

**Jenis Akses Lokal:**
1. **Localhost**: Akses dari komputer yang sama
2. **LAN Access**: Akses dari komputer lain di jaringan yang sama
3. **VPN Access**: Akses dari jarak jauh melalui VPN

### Network Diagram Local Access
```
[Komputer A] --- [Router] --- [Orthanc Server]
     |                              |
     +-- [Komputer B] --------------+
```

---

## 🏠 Akses Localhost (Komputer yang Sama)

### Akses Direct
```bash
# Cara paling simple
# Buka browser dan akses:
http://localhost:8042

# Atau gunakan IP loopback
http://127.0.0.1:8042
```

### Test dengan Command Line
```bash
# Test HTTP port
curl -I http://localhost:8042

# Test API
curl -s http://localhost:8042/system | jq '.Name'

# Test DICOM port
nc -zv localhost 4242

# Ping Orthanc
ping -c 3 127.0.0.1
```

### Create Shortcut (Windows)
```powershell
# PowerShell
$WshShell = New-Object -ComObject WScript.Shell
$Shortcut = $WshShell.CreateShortcut("$Home\Desktop\Orthanc.lnk")
$Shortcut.TargetPath = "http://localhost:8042"
$Shortcut.Description = "Orthanc DICOM Server"
$Shortcut.Save()
```

### Create Shortcut (macOS)
```bash
# Create shortcut
osascript -e 'tell application "System Events"
  make new internet location file at (path to desktop) with properties {name:"Orthanc", location:"http://localhost:8042"}
end tell'
```

---

## 🌐 Akses LAN (Dari Komputer Lain)

### 1. Cari IP Server

#### Linux
```bash
# Check network interfaces
ip addr show

# Atau dapatkan IP dengan cara simple
hostname -I | awk '{print $1}'
```

#### Windows
```powershell
# PowerShell
Get-NetIPAddress -AddressFamily IPv4 | 
  Where-Object { $_.IPAddress -ne "127.0.0.1" } | 
  Select-Object IPAddress, InterfaceAlias

# Command Prompt
ipconfig
```

#### macOS
```bash
# Check IP address
ifconfig | grep "inet " | grep -v 127.0.0.1
```

### 2. Akses dari Komputer Lain

#### Test Koneksi
```bash
# Ping ke server
ping 192.168.1.100

# Test HTTP connection
curl -I http://192.168.1.100:8042

# Test dari browser
# Buka: http://192.168.1.100:8042
```

#### Setup Hosts File (Opsional)
##### Windows
```batch
# Edit hosts file (Administrator)
notepad C:\Windows\System32\drivers\etc\hosts

# Tambahkan baris:
192.168.1.100 orthanc.local
```

##### Linux/macOS
```bash
# Edit hosts file
sudo nano /etc/hosts

# Tambahkan baris:
192.168.1.100 orthanc.local

# Test dengan nama host
curl http://orthanc.local:8042
```

---

## 🔌 Setup Port Forwarding

### 1. Router Configuration

#### Cek Router IP
```bash
# Linux/macOS
ip route show default | awk '{print $3}'

# Windows
ipconfig | findstr "Gateway"
```

#### Login ke Router
1. Buka browser
2. Akses `http://192.168.1.1` atau `http://192.168.0.1`
3. Login dengan username/password (default: admin/admin, admin/password)

#### Setup Port Forwarding
```yaml
# Konfigurasi Example
Service Name: Orthanc-HTTP
Protocol: TCP
External Port: 8042
Internal Port: 8042
Internal IP: 192.168.1.100
Enable: Yes

Service Name: Orthanc-DICOM
Protocol: TCP
External Port: 4242
Internal Port: 4242
Internal IP: 192.168.1.100
Enable: Yes
```

### 2. Test Port Forwarding
```bash
# Test dari luar jaringan
# (Diperlukan koneksi internet)
curl -I http://<public-ip>:8042

# Cek port status
# Gunakan website: canyouseeme.org
# Atau: nmap <public-ip> -p 8042
```

---

## 🏢 Setup Local Network

### 1. Static IP Configuration

#### Ubuntu/Debian
```bash
# Edit netplan
sudo nano /etc/netplan/01-netcfg.yaml

# Konfigurasi:
network:
  version: 2
  ethernets:
    eth0:  # Ganti dengan interface Anda
      dhcp4: no
      addresses: [192.168.1.100/24]
      gateway4: 192.168.1.1
      nameservers:
          addresses: [8.8.8.8, 1.1.1.1]

# Apply
sudo netplan apply
```

#### Windows
```powershell
# PowerShell (Administrator)
# Set static IP
New-NetIPAddress -InterfaceAlias "Ethernet" -IPAddress 192.168.1.100 -PrefixLength 24 -DefaultGateway 192.168.1.1

# Set DNS
Set-DnsClientServerAddress -InterfaceAlias "Ethernet" -ServerAddresses ("8.8.8.8","1.1.1.1")
```

### 2. Local DNS Setup

#### Install dnsmasq
```bash
# Ubuntu/Debian
sudo apt update
sudo apt install dnsmasq

# Configure dnsmasq
sudo nano /etc/dnsmasq.conf

# Tambahkan:
address=/orthanc.local/192.168.1.100

# Restart dnsmasq
sudo systemctl restart dnsmasq

# Test
ping orthanc.local
curl http://orthanc.local:8042
```

#### Windows DNS
```powershell
# PowerShell (Administrator)
# Add DNS record
Add-DnsServerResourceRecordA -Name orthanc.local -ZoneName local -IPv4Address 192.168.1.100
```

---

## 🔧 Network Configuration

### 1. Firewall Configuration

#### Ubuntu UFW
```bash
# Install UFW jika belum
sudo apt install ufw

# Allow Orthanc ports
sudo ufw allow 8042/tcp
sudo ufw allow 4242/tcp
sudo ufw allow 8443/tcp

# Check status
sudo ufw status

# Enable firewall
sudo ufw enable
```

#### Windows Firewall
```powershell
# PowerShell (Administrator)
# Allow Orthanc HTTP port
New-NetFirewallRule -DisplayName "Orthanc-HTTP" -Direction Inbound -Protocol TCP -LocalPort 8042 -Action Allow

# Allow Orthanc DICOM port
New-NetFirewallRule -DisplayName "Orthanc-DICOM" -Direction Inbound -Protocol TCP -LocalPort 4242 -Action Allow

# Check rules
Get-NetFirewallRule | Where-Object {$_.DisplayName -like "*Orthanc*"}
```

#### macOS Firewall
```bash
# Allow Orthanc through firewall
sudo /usr/libexec/ApplicationFirewall/socketfilterfw --add /usr/local/bin/orthanc

# Atau melalui GUI
# System Preferences > Security & Privacy > Firewall
```

### 2. Network Testing Tools

#### Network Diagnostics Script
```bash
#!/bin/bash
# scripts/network-test.sh

echo "=== Orthanc Network Test ==="

# Check IP addresses
echo -e "\n📍 IP Addresses:"
ip addr show | grep "inet " | grep -v 127.0.0.1

# Check ports
echo -e "\n🔌 Port Status:"
if netstat -tlnp 2>/dev/null | grep -q ":8042"; then
    echo "✓ HTTP port (8042) is listening"
else
    echo "✗ HTTP port (8042) is not listening"
fi

if netstat -tlnp 2>/dev/null | grep -q ":4242"; then
    echo "✓ DICOM port (4242) is listening"
else
    echo "✗ DICOM port (4242) is not listening"
fi

# Test localhost
echo -e "\n🏠 Localhost Access:"
if curl -s http://localhost:8042/system >/dev/null; then
    echo "✓ Orthanc accessible via localhost"
else
    echo "✗ Orthanc not accessible via localhost"
fi

# Test LAN access
echo -e "\n🌐 LAN Access:"
LOCAL_IP=$(ip addr show | grep "inet " | grep -v 127.0.0.1 | awk '{print $2}' | cut -d/ -f1 | head -1)
if curl -s "http://${LOCAL_IP}:8042/system" >/dev/null; then
    echo "✓ Orthanc accessible via LAN (${LOCAL_IP})"
else
    echo "✗ Orthanc not accessible via LAN (${LOCAL_IP})"
fi

# Check firewall
echo -e "\n🛡️ Firewall Status:"
if command -v ufw >/dev/null 2>&1; then
    sudo ufw status | grep "8042/tcp"
fi

echo -e "\n=== Test Complete ==="
```

---

## 📱 Multi-Device Access

### 1. Akses dari Mobile

#### Connect ke Local Network
```bash
# Connect mobile ke WiFi lokal
# Kemudian akses:
http://192.168.1.100:8042

# Atau gunakan hostname:
http://orthanc.local:8042
```

#### Bookmark pada Mobile
```javascript
// Buat bookmark dengan QR code
// Gunakan QR code generator untuk URL:
http://192.168.1.100:8042
```

### 2. Akses dari Tablet

#### Tablet Configuration
```bash
# Connect tablet ke WiFi lokal
# Pastikan tablet di jaringan yang sama dengan server
# Access Orthanc via browser
http://192.168.1.100:8042
```

---

## 🎨 Setup Interface untuk Local Access

### 1. Create Login Shortcut

#### Windows Shortcut dengan Auto-Login
```powershell
# Create shortcut with credentials
$username = "your-username"
$password = "your-password"
$url = "http://localhost:8042"

# Create browser shortcut
$shortcutPath = "$Home\Desktop\Orthanc.lnk"
$WshShell = New-Object -ComObject WScript.Shell
$shortcut = $WshShell.CreateShortcut($shortcutPath)
$shortcut.TargetPath = "http://${username}:${password}@${url}"
$shortcut.Save()
```

### 2. Create Desktop Widget (Advanced)

#### HTML Widget
```html
<!DOCTYPE html>
<html>
<head>
    <title>Orthanc Widget</title>
    <style>
        body {
            margin: 0;
            padding: 20px;
            font-family: Arial, sans-serif;
        }
        .widget {
            background: #f5f5f5;
            padding: 20px;
            border-radius: 8px;
        }
        button {
            padding: 10px 20px;
            margin: 5px;
            cursor: pointer;
        }
    </style>
</head>
<body>
    <div class="widget">
        <h2>Orthanc Server</h2>
        <button onclick="window.location.href='http://localhost:8042'">Local Access</button>
        <button onclick="window.location.href='http://192.168.1.100:8042'">LAN Access</button>
    </div>
</body>
</html>
```

---

## 🔍 Troubleshooting Akses Lokal

### 1. Masalah Koneksi

#### Port Tidak Dapat Diakses
```bash
# Check port status
sudo netstat -tlnp | grep 8042

# Check jika Orthanc berjalan
docker ps | grep orthanc
# Atau
systemctl status orthanc

# Restart Orthanc
sudo systemctl restart orthanc
# Atau
docker-compose restart orthanc
```

#### Connection Refused
```bash
# Check firewall status
sudo ufw status

# Check Orthanc logs
sudo tail -f /var/log/orthanc/orthanc.log

# Test dengan telnet
telnet localhost 8042
nc -zv localhost 8042
```

### 2. Masalah IP Address

#### IP Berubah (DHCP)
```bash
# Set static IP (lihat section di atas)
# Atau gunakan DHCP reservation di router

# Check IP saat ini
hostname -I

# Monitor IP changes
watch -n 5 hostname -I
```

#### Komputer Lain Tidak Bisa Akses
```bash
# Test ping dari komputer lain
ping 192.168.1.100

# Test connection
curl -I http://192.168.1.100:8042

# Check firewall
sudo ufw status
```

### 3. Masalah Router

#### Port Forwarding Tidak Berjalan
```bash
# Cek apakah port benar-benar terforward
# Gunakan canyouseeme.org

# Atau gunakan nmap
nmap -p 8042 <public-ip>

# Reset router jika perlu
# Login ke router > Advanced > Diagnostics > Factory Reset
```

#### Router Limitations
```bash
# Check router capabilities
# Beberapa router tidak support port forwarding

# Alternatif:
# 1. Gunakan DMZ (Demilitarized Zone)
# 2. Gunakan UPnP (Universal Plug and Play)
# 3. Ganti router dengan yang lebih baik
```

---

## 🚀 Optimasi Performa Lokal

### 1. Network Optimization
```bash
# Increase TCP window size
sudo sysctl -w net.core.rmem_max=16777216
sudo sysctl -w net.core.wmem_max=16777216

# Enable TCP fast open
sudo sysctl -w net.ipv4.tcp_fastopen=3

# Optimize TCP buffers
sudo sysctl -w net.ipv4.tcp_window_scaling=1
```

### 2. Caching untuk Local Access
```json
{
  "WebViewer": {
    "Enabled": true,
    "CacheDirectory": "/tmp/orthanc-viewer",
    "MaxCacheSize": 2000,
    "Compression": true
  },
  "HttpCompression": true,
  "HttpCache": true
}
```

### 3. Browser Optimization
```javascript
// Enable browser cache
// Use modern browser
// Disable unnecessary extensions
// Use hardware acceleration
```

---

## 📋 Checklist Akses Lokal

### Setup Awal
- [ ] Orthanc berjalan di server
- [ ] HTTP port (8042) listening
- [ ] DICOM port (4242) listening
- [ ] Firewall configured
- [ ] IP address known

### Localhost Access
- [ ] Dapat akses via localhost
- [ ] Dapat akses via 127.0.0.1
- [ ] Web interface load correctly
- [ ] API endpoints accessible

### LAN Access
- [ ] Dapat akses dari komputer lain
- [ ] Ping successful
- [ ] Port forwarding configured
- [ ] Firewall allow connections

### Testing
- [ ] Upload DICOM file
- [ ] View DICOM images
- [ ] Test API endpoints
- [ ] Check performance

---

## 🎯 Next Steps

Setelah akses lokal berhasil:
1. **Test semua fitur** yang tersedia
2. **Buat bookmark** untuk akses cepat
3. **Setup shortcut** di desktop/mobile
4. **Monitor performa** secara berkala
5. **Plan untuk akses remote** (langkah berikutnya)

---

**🎯 Selanjutnya**: [09-Akses Online/Remote](./09-Akses-Online-Remote.md) - Pelajari cara setup akses online dengan aman menggunakan Cloudflare Tunnel!# 09. Cara Akses Orthanc Online/Remote

## 📋 Apa yang akan Anda Pelajari

- Konsep akses remote dan security
- Setup Cloudflare Tunnel untuk akses aman
- Konfigurasi SSL/TLS
- Setup remote access dengan VPN
- Security best practices untuk akses online
- Troubleshooting masalah akses remote

---

## 🌐 Pengenalan Akses Remote

### Apa itu Remote Access?
Remote access berarti mengakses Orthanc dari luar jaringan lokal (internet):

**Jenis Akses Remote:**
1. **Cloudflare Tunnel**: Secure tanpa exposed port
2. **Port Forwarding**: Ekspos langsung ke internet
3. **VPN**: Access melalui virtual private network
4. **Reverse Proxy**: Akses melalui proxy server

### Security Considerations
```yaml
⚠️ Security Risks:
- Data interception
- Unauthorized access
- DDoS attacks
- Brute force attempts

✓ Security Measures:
- HTTPS/SSL certificates
- Strong authentication
- Rate limiting
- IP whitelisting
- Regular security audits
```

---

## ☁️ Setup Cloudflare Tunnel (Recommended)

### 1. Persiapan Cloudflare

#### Buat Cloudflare Account
1. Kunjungi [cloudflare.com](https://cloudflare.com)
2. Register atau login
3. Add domain Anda (bisa domain gratis seperti orthanc.abc.com)
4. Update nameserver ke Cloudflare

#### Install Cloudflared CLI
```bash
# Linux
wget https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-amd64.deb
sudo dpkg -i cloudflared-linux-amd64.deb

# Verify installation
cloudflared --version
```

### 2. Create Tunnel
```bash
# Login ke Cloudflare
cloudflared tunnel login

# Buka link yang muncul
# Login dengan Cloudflare account Anda

# Buat tunnel baru
cloudflared tunnel create orthanc-tunnel

# Output akan menampilkan:
# Tunnel credentials written to /home/user/.cloudflared/orthanc-tunnel.json
# Tunnel ID: xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx
```

### 3. Configuration Tunnel
```bash
# Buat directory untuk config
mkdir -p ~/.cloudflared

# Edit configuration
nano ~/.cloudflared/config.yml
```

#### Basic Configuration
```yaml
# ~/.cloudflared/config.yml
tunnel: orthanc-tunnel
credentials-file: /home/user/.cloudflared/orthanc-tunnel.json

ingress:
  # Main service
  - hostname: orthanc.yourdomain.com
    service: http://localhost:8042
  
  # DICOM service (opsional)
  - hostname: dicom.yourdomain.com
    service: http://localhost:4242
  
  # Fallback untuk request tidak dikenal
  - service: http_status:404
```

### 4. Setup DNS
```bash
# Update DNS dengan tunnel credentials
cloudflared tunnel route dns orthanc-tunnel orthanc.yourdomain.com

# Jika perlu DICOM service:
# cloudflared tunnel route dns orthanc-tunnel dicom.yourdomain.com

# Verify DNS
dig orthanc.yourdomain.com
nslookup orthanc.yourdomain.com
```

### 5. Create Systemd Service
```bash
# Create service file
sudo nano /etc/systemd/system/cloudflared.service
```

#### Service Configuration
```ini
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

# Check status
sudo systemctl status cloudflared

# Enable auto-start on boot
sudo systemctl enable cloudflared
```

### 7. Test Cloudflare Tunnel
```bash
# Check tunnel status
cloudflared tunnel info orthanc-tunnel

# Test DNS resolution
nslookup orthanc.yourdomain.com

# Test HTTP access
curl -I https://orthanc.yourdomain.com

# Test API
curl -s https://orthanc.yourdomain.com/system | jq '.Name'
```

---

## 🔐 SSL/TLS Configuration

### 1. Cloudflare SSL Settings

#### Login ke Cloudflare Dashboard
1. Pilih domain Anda
2. Menu SSL/TLS > Overview
3. Set mode ke **Full (strict)** untuk keamanan maksimal

#### SSL Modes Explanation
```yaml
Off:
- Tidak aman, semua traffic HTTP
- Tidak direkomendasikan

Flexible:
- HTTP ke Cloudflare, HTTP ke server
- Traffic dari Cloudflare ke server tidak dienkripsi
- Tidak aman untuk data sensitif

Full:
- HTTPS ke Cloudflare, HTTP ke server
- Membutuhkan self-signed certificate
- Lebih aman dari Flexible

Full (strict) - RECOMMENDED:
- HTTPS ke Cloudflare, HTTPS ke server
- Maksimum security
- Butuh valid certificate
```

### 2. Self-Signed Certificate untuk Local
```bash
# Generate self-signed certificate
openssl req -x509 -newkey rsa:4096 -keyout orthanc.key \
  -out orthanc.crt -days 365 -nodes

# Copy ke lokasi yang aman
sudo mkdir -p /etc/ssl/certs /etc/ssl/private
sudo cp orthanc.crt /etc/ssl/certs/
sudo cp orthanc.key /etc/ssl/private/

# Update permissions
sudo chmod 600 /etc/ssl/private/orthanc.key
```

### 3. Update Orthanc Configuration
```json
{
  "HttpsPort": 8443,
  "CertificateFile": "/etc/ssl/certs/orthanc.crt",
  "KeyFile": "/etc/ssl/private/orthanc.key"
}
```

### 4. Update Docker Compose
```yaml
# docker-compose.yml
services:
  orthanc:
    image: jodogne/orthanc-plugins:latest
    container_name: orthanc-server
    restart: unless-stopped
    ports:
      - "8042:8042"
      - "8443:8443"
    volumes:
      - ./orthanc-data:/var/lib/orthanc/db
      - /etc/ssl/certs/orthanc.crt:/etc/ssl/certs/orthanc.crt
      - /etc/ssl/private/orthanc.key:/etc/ssl/private/orthanc.key
```

---

## 🔌 Setup Port Forwarding (Alternative)

### 1. Router Configuration

#### Add Port Forwarding Rules
```yaml
# Orthanc HTTP
Service Name: Orthanc-HTTP
Protocol: TCP
External Port: 8042
Internal Port: 8042
Internal IP: 192.168.1.100
Enable: Yes

# Orthanc HTTPS
Service Name: Orthanc-HTTPS
Protocol: TCP
External Port: 8443
Internal Port: 8443
Internal IP: 192.168.1.100
Enable: Yes

# Orthanc DICOM
Service Name: Orthanc-DICOM
Protocol: TCP
External Port: 4242
Internal Port: 4242
Internal IP: 192.168.1.100
Enable: Yes
```

### 2. DDNS (Dynamic DNS)

#### Setup DDNS untuk IP yang Berubah
```bash
# Install ddclient
sudo apt install ddclient

# Configure ddclient
sudo nano /etc/ddclient.conf

# Konfigurasi example:
daemon=300
syslog=yes
mail=root
mail-failure=root
pid=/var/run/ddclient.pid
ssl=yes

protocol=cloudflare
use=web
web=https://www.cloudflare.com/cgi-bin/get_ip
zone=yourdomain.com
login=your-cloudflare-email
password=your-cloudflare-api-key
orthanc.yourdomain.com

# Start service
sudo systemctl start ddclient
sudo systemctl enable ddclient
```

### 3. Get Public IP
```bash
# Get public IP
curl ifconfig.me
# Atau
curl icanhazip.com

# Monitor IP changes
watch -n 300 'curl ifconfig.me'
```

---

## 🛡️ Security Configuration

### 1. Authentication
```json
{
  "AuthenticationEnabled": true,
  "UserName": "admin",
  "Password": "your-very-secure-password-123",
  "AllowAnonymous": false,
  "SessionsTimeout": 3600,
  "EnableHttpSessions": true
}
```

### 2. IP Whitelisting
```bash
# UFW configuration
sudo ufw allow from 192.168.1.0/24 to any port 8042
sudo ufw allow from office-ip-range to any port 8042

# Atau di Cloudflare:
# Access Policy > Create Policy
# Type: WAF > IP List
# Add allowed IPs
```

### 3. Rate Limiting
```bash
# Implement rate limiting di Cloudflare
# Security > WAF > Custom Rules > Create rule

# Rule example:
(field.http.request.uri.path eq "/api/*") and 
(ip.src ne 192.168.1.0/24)
{
  throttling_rate = 10  // 10 requests per minute
}
```

### 4. Fail2Ban Configuration
```bash
# Install fail2ban
sudo apt install fail2ban

# Configure fail2ban
sudo nano /etc/fail2ban/jail.local

# Add Orthanc configuration:
[orthanc]
enabled = true
port = 8042,4242
filter = orthanc
logpath = /var/log/orthanc/orthanc.log
maxretry = 3
findtime = 10m
bantime = 1h
ignoreip = 192.168.1.0/24

# Create filter
sudo nano /etc/fail2ban/filter.d/orthanc.conf

# Add filter:
[Definition]
failregex = ^.* authentication failed from <HOST>
ignoreregex =
```

---

## 🔌 Setup VPN Access

### 1. WireGuard VPN

#### Install WireGuard
```bash
# Server setup
sudo apt install wireguard

# Generate keys
wg genkey | sudo tee /etc/wireguard/privatekey | wg pubkey | sudo tee /etc/wireguard/publickey

# Create configuration
sudo nano /etc/wireguard/wg0.conf
```

#### Server Configuration
```ini
[Interface]
Address = 10.0.0.1/24
PrivateKey = <SERVER_PRIVATE_KEY>
ListenPort = 51820

[Peer]
PublicKey = <CLIENT_PUBLIC_KEY>
AllowedIPs = 10.0.0.2/32
Endpoint = <CLIENT_PUBLIC_IP>:51820
PersistentKeepalive = 25
```

#### Client Configuration
```ini
[Interface]
Address = 10.0.0.2/24
PrivateKey = <CLIENT_PRIVATE_KEY>
DNS = 1.1.1.1, 8.8.8.8

[Peer]
PublicKey = <SERVER_PUBLIC_KEY>
Endpoint = <SERVER_PUBLIC_IP>:51820
AllowedIPs = 10.0.0.0/24
PersistentKeepalive = 25
```

### 2. OpenVPN

#### Server Setup
```bash
# Install OpenVPN
sudo apt install openvpn easy-rsa

# Generate certificates
make-cadir ~/openvpn-ca
cd ~/openvpn-ca
source vars
./clean-all
./build-ca
./build-key-server server
./build-dh
./build-key client

# Create server configuration
sudo nano /etc/openvpn/server.conf
```

#### Server Configuration
```
port 1194
proto udp
dev tun
ca ca.crt
cert server.crt
key server.key
dh dh2048.pem
server 10.8.0.0 255.255.255.0
ifconfig-pool-persist ipp.txt
keepalive 10 120
comp-lzo
persist-key
persist-tun
status openvpn-status.log
```

---

## 📱 Setup Remote Access di Mobile

### 1. Mobile Apps Configuration

#### Access via Mobile Browser
```javascript
// Buka browser di mobile:
// Access: https://orthanc.yourdomain.com

// Save as bookmark
// Create home screen shortcut
```

#### Mobile App (Custom)
```bash
// Buat PWA (Progressive Web App)
// atau
// Buat native mobile app
```

### 2. Test Remote Access

#### Test Connection
```bash
# Test dari lokasi berbeda
curl -I https://orthanc.yourdomain.com

# Test API
curl -s https://orthanc.yourdomain.com/system | jq '.Name'

# Test dari mobile device
// Buka browser mobile
// Akses: https://orthanc.yourdomain.com
```

---

## 🔍 Monitoring Remote Access

### 1. Log Monitoring
```bash
# Monitor Cloudflare tunnel logs
sudo journalctl -u cloudflared -f

# Monitor Orthanc logs
sudo tail -f /var/log/orthanc/orthanc.log

# Monitor web access logs
tail -f /var/log/nginx/access.log
```

### 2. Performance Monitoring
```bash
# Check response time
curl -o /dev/null -s -w '%{time_total}\n' https://orthanc.yourdomain.com

# Check connection quality
ping -c 10 orthanc.yourdomain.com
```

### 3. Security Monitoring
```bash
# Monitor failed login attempts
grep "authentication failed" /var/log/orthanc/orthanc.log

# Check fail2ban status
sudo fail2ban-client status orthanc

# Monitor Cloudflare WAF logs
# Security > WAF > Events
```

---

## 🚨 Troubleshooting Remote Access

### 1. Cloudflare Tunnel Issues

#### Tunnel Tidak Berjalan
```bash
# Check tunnel status
cloudflared tunnel info orthanc-tunnel

# Check service status
sudo systemctl status cloudflared

# Check logs
sudo journalctl -u cloudflared -f

# Restart service
sudo systemctl restart cloudflared
```

#### DNS Tidak Resolve
```bash
# Check DNS configuration
dig orthanc.yourdomain.com
nslookup orthanc.yourdomain.com

# Check Cloudflare DNS settings
# Cloudflare Dashboard > DNS > Records

# Propagation delay
# Wait up to 24 hours for DNS propagation
```

### 2. SSL/TLS Issues

#### Certificate Error
```bash
# Check certificate validity
openssl s_client -connect orthanc.yourdomain.com:443 -servername orthanc.yourdomain.com

# Verify certificate
curl -v https://orthanc.yourdomain.com 2>&1 | grep -i "certificate"

# Clear browser cache
# Refresh page
```

#### Mixed Content Error
```html
<!-- Ensure all resources use HTTPS -->
<link rel="stylesheet" href="https://orthanc.yourdomain.com/style.css">
<script src="https://orthanc.yourdomain.com/script.js"></script>
```

### 3. Connection Issues

#### Slow Connection
```bash
# Check bandwidth
speedtest-cli

# Test connection quality
ping -c 10 orthanc.yourdomain.com

# Optimize image loading
// Enable compression
// Use CDN
// Optimize image sizes
```

#### Connection Timeout
```bash
# Check firewall
sudo ufw status
sudo iptables -L

# Check if port is open
nmap -p 8042 orthanc.yourdomain.com

# Increase timeout in configuration
jq '.HttpTimeout = 60' orthanc.json > tmp.json && mv tmp.json orthanc.json
```

---

## 📋 Remote Access Checklist

### Setup
- [ ] Cloudflare account created
- [ ] Tunnel created and configured
- [ ] DNS records updated
- [ ] SSL/TLS configured
- [ ] Authentication enabled
- [ ] Security measures implemented

### Testing
- [ ] Remote access successful
- [ ] SSL/TLS working
- [ ] Authentication functional
- [ ] Performance acceptable
- [ ] Monitoring configured

### Security
- [ ] Strong passwords set
- [ ] 2FA enabled (if available)
- [ ] IP whitelisting configured
- [ ] Rate limiting enabled
- [ ] Security monitoring active
- [ ] Backup procedures documented

---

## 🎯 Next Steps

Setelah akses remote berhasil:
1. **Test semua fitur** dari lokasi berbeda
2. **Monitor security logs** secara berkala
3. **Update security measures** sesuai kebutuhan
4. **Train users** untuk akses remote
5. **Plan backup dan disaster recovery**

---

**🎯 Selanjutnya**: [10-Troubleshooting](./10-Troubleshooting.md) - Pelajari solusi masalah umum dan langkah selanjutnya setelah deployment berhasil!# 10. Troubleshooting & Langkah Selanjutnya

## 📋 Apa yang akan Anda Pelajari

- Masalah umum Orthanc dan solusinya
- Debugging tools dan techniques
- Maintenance dan monitoring
- Security troubleshooting
- Performance optimization
- Langkah selanjutnya setelah deployment

---

## 🚨 Masalah Umum

### 1. Instalasi Issues

#### Docker Tidak Berjalan
**Masalah:** Container tidak dapat di-start

**Diagnosis:**
```bash
# Check Docker status
sudo systemctl status docker

# Check container status
docker ps -a

# Check logs
docker logs orthanc-server
```

**Solusi:**
```bash
# Start Docker service
sudo systemctl start docker

# Restart Docker daemon
sudo systemctl restart docker

# Check jika ada konflik port
sudo lsof -i :8042
sudo lsof -i :4242

# Kill process yang menggunakan port
sudo kill -9 <PID>
```

#### Container Start Gagal
**Masalah:** Error saat start container

**Diagnosis:**
```bash
# Check logs
docker-compose logs orthanc

# Cek error detail
docker inspect orthanc-server | jq '.[0].State.Error'
```

**Solusi:**
```bash
# Check konfigurasi
docker-compose config

# Rebuild container
docker-compose build --no-cache

# Start dengan debug mode
docker-compose up -d --no-deps --build orthanc
```

### 2. Network Issues

#### Port Already in Use
**Masalah:** Port 8042 atau 4242 sudah digunakan

**Diagnosis:**
```bash
# Cek port usage
sudo netstat -tlnp | grep 8042
sudo lsof -i :8042

# Cek process yang menggunakan port
sudo fuser 8042/tcp
```

**Solusi:**
```bash
# Kill process
sudo kill -9 <PID>

# Atau ubah port di docker-compose.yml
ports:
  - "8043:8042"
  - "4243:4242"

# Restart container
docker-compose restart orthanc
```

#### Connection Refused
**Masalah:** Tidak dapat connect ke Orthanc

**Diagnosis:**
```bash
# Test connection
curl -I http://localhost:8042

# Cek jika Orthanc berjalan
docker ps | grep orthanc

# Cek port listening
netstat -tlnp | grep 8042
```

**Solusi:**
```bash
# Restart Orthanc
docker-compose restart orthanc

# Cek firewall
sudo ufw status
sudo ufw allow 8042/tcp
sudo ufw allow 4242/tcp

# Restart firewall
sudo ufw reload
```

### 3. Database Issues

#### Database Corruption
**Masalah:** Database Orthanc corrupted

**Diagnosis:**
```bash
# Check database integrity
sqlite3 /var/lib/orthanc/db/index "PRAGMA integrity_check;"

# Check logs
tail -f /var/log/orthanc/orthanc.log | grep -i error
```

**Solusi:**
```bash
# Backup database
cp -r orthanc-data orthanc-data.backup

# Remove corrupted files
rm -f orthanc-data/index*
rm -f orthanc-data/journal/*

# Restart Orthanc (akan recreate database)
docker-compose restart orthanc
```

#### Database Size Too Large
**Masalah:** Database size growing uncontrolled

**Diagnosis:**
```bash
# Check database size
du -sh orthanc-data/index
du -sh orthanc-data/

# Check database statistics
sqlite3 /var/lib/orthanc/db/index "SELECT count(*) FROM Records;"
```

**Solusi:**
```bash
# Vacuum database
sqlite3 /var/lib/orthanc/db/index "VACUUM;"

# Optimize database
sqlite3 /var/lib/orthanc/db/index "PRAGMA optimize;"

# Setup database rotation
# Implementasi backup dan archive routine
```

### 4. Performance Issues

#### Slow Response Time
**Masalah:** Web interface dan API lambat

**Diagnosis:**
```bash
# Check system resources
htop
free -h
df -h

# Monitor Orthanc performance
curl -o /dev/null -s -w '%{time_total}\n' http://localhost:8042/system
```

**Solusi:**
```bash
# Enable HTTP compression
jq '.HttpCompression = true' orthanc.json > tmp.json && mv tmp.json orthanc.json

# Enable storage compression
jq '.StorageCompression = true' orthanc.json > tmp.json && mv tmp.json orthanc.json

# Restart Orthanc
docker-compose restart orthanc

# Check memory usage
docker stats orthanc-server
```

#### High Memory Usage
**Masalah:** Orthanc menggunakan terlalu banyak RAM

**Diagnosis:**
```bash
# Check memory usage
free -h

# Monitor Orthanc memory
docker stats orthanc-server

# Check for memory leaks
valgrind --leak-check=full Orthanc
```

**Solusi:**
```bash
# Limit memory di docker-compose.yml
services:
  orthanc:
    mem_limit: 2g
    memswap_limit: 2g

# Atau konfigurasi cache size
jq '.MaximumStorageCachedPatientCount = 100' orthanc.json > tmp.json && mv tmp.json orthanc.json
```

### 5. DICOM Issues

#### DICOM Connection Failed
**Masalah:** Tidak dapat connect ke PACS lain

**Diagnosis:**
```bash
# Test DICOM port
telnet pacs.hospital.com 4242
nc -zv pacs.hospital.com 4242

# Test DICOM echo
dcmcu -aec ORTHANC -aet PACS-AET pacs.hospital.com 4242
```

**Solusi:**
```bash
# Check DICOM configuration
curl -s http://localhost:8042/system | jq '.DicomModalities'

# Update DICOM timeout
jq '.DicomTimeout = 60' orthanc.json > tmp.json && mv tmp.json orthanc.json

# Check firewall
sudo ufw allow 4242/tcp

# Restart Orthanc
docker-compose restart orthanc
```

#### DICOM File Corrupted
**Masalah:** File DICOM tidak valid

**Diagnosis:**
```bash
# Validate DICOM file
dcmdump /path/to/file.dcm > /dev/null 2>&1
echo $?  # 0 = valid, non-zero = invalid

# Check header
hexdump -C /path/to/file.dcm | grep "44 49 43 4d"  # DICOM header
```

**Solusi:**
```bash
# Anonymize dan validate
curl -X POST http://localhost:8042/tools/validate \
  -H "Content-Type: application/json" \
  -d '{"Files": ["instance-1"], "CheckSyntax": true}'

# Reconstruct jika perlu
curl -X POST http://localhost:8042/series/<series-id>/reconstruct
```

---

## 🔍 Debugging Tools

### 1. Log Analysis

#### Orthanc Logs
```bash
# View logs
docker-compose logs orthanc

# Follow logs real-time
docker-compose logs -f orthanc

# Filter logs by level
docker-compose logs orthanc | grep -i "error"
docker-compose logs orthanc | grep -i "warning"

# Check logs di container
docker-compose exec orthanc cat /var/log/orthanc/orthanc.log
```

#### System Logs
```bash
# Kernel logs
dmesg | grep orthanc

# System logs
sudo journalctl -u orthanc -f

# Application logs
sudo tail -f /var/log/syslog | grep orthanc
```

### 2. Network Debugging

#### Packet Capture
```bash
# Capture DICOM traffic
sudo tcpdump -i any -s 0 -w dicom.pcap 'port 4242'

# Capture HTTP traffic
sudo tcpdump -i any -s 0 -w http.pcap 'port 8042'

# Analyze dengan Wireshark
wireshark dicom.pcap
```

#### Connection Testing
```bash
# Test connectivity
ping -c 10 orthanc.yourdomain.com

# Trace route
traceroute orthanc.yourdomain.com

# Check DNS
dig orthanc.yourdomain.com
nslookup orthanc.yourdomain.com

# Check SSL/TLS
openssl s_client -connect orthanc.yourdomain.com:443
```

### 3. Performance Profiling

#### Memory Profiling
```bash
# Monitor memory usage
while true; do
    free -h
    sleep 60
done > memory_log.txt &

# Analyze memory leaks
valgrind --leak-check=full --show-leak-kinds=all Orthanc
```

#### CPU Profiling
```bash
# Monitor CPU usage
top -p $(pgrep -f orthanc)

# CPU profiling
perf record -g Orthanc
perf report
```

---

## 🛠️ Maintenance Procedures

### 1. Daily Maintenance

```bash
#!/bin/bash
# scripts/daily-maintenance.sh

LOG_FILE="/var/log/orthanc/maintenance.log"
DATE=$(date '+%Y-%m-%d %H:%M:%S')

echo "=== Daily Maintenance - $DATE ===" >> $LOG_FILE

# Check service status
if systemctl is-active --quiet orthanc; then
    echo "✓ Orthanc service is running" >> $LOG_FILE
else
    echo "✗ Orthanc service is not running" >> $LOG_FILE
    systemctl start orthanc
    echo "✓ Orthanc service started" >> $LOG_FILE
fi

# Check disk space
DISK_USAGE=$(df -h | grep orthanc-data | awk '{print $5}' | sed 's/%//')
if [ $DISK_USAGE -gt 80 ]; then
    echo "⚠ Disk usage is ${DISK_USAGE}% - Consider cleanup" >> $LOG_FILE
fi

# Check logs
LOG_SIZE=$(du -sh /var/log/orthanc/ | cut -f1 | sed 's/G//')
echo "Log size: ${LOG_SIZE}GB" >> $LOG_FILE

# Backup database
cp /var/lib/orthanc/db/index /backup/orthanc/index-$(date +%Y%m%d)
echo "✓ Database backed up" >> $LOG_FILE

echo "=== End Daily Maintenance ===" >> $LOG_FILE
```

### 2. Weekly Maintenance

```bash
#!/bin/bash
# scripts/weekly-maintenance.sh

LOG_FILE="/var/log/orthanc/maintenance.log"
DATE=$(date '+%Y-%m-%d %H:%M:%S')

echo "=== Weekly Maintenance - $DATE ===" >> $LOG_FILE

# Update Orthanc
docker-compose pull
docker-compose up -d

# Optimize database
docker-compose exec orthanc sqlite3 /var/lib/orthanc/db/index "VACUUM;"

# Cleanup old logs
find /var/log/orthanc/ -name "*.log" -mtime +30 -delete

# Clean up temporary files
docker system prune -f

# Check security
sudo fail2ban-client status orthanc

echo "=== End Weekly Maintenance ===" >> $LOG_FILE
```

### 3. Monthly Maintenance

```bash
#!/bin/bash
# scripts/monthly-maintenance.sh

LOG_FILE="/var/log/orthanc/maintenance.log"
DATE=$(date '+%Y-%m-%d %H:%M:%S')

echo "=== Monthly Maintenance - $DATE ===" >> $LOG_FILE

# Full backup
tar -czf /backup/orthanc/monthly-$(date +%Y%m).tar.gz \
    orthanc-data/ \
    orthanc.json \
    docker-compose.yml

# Check system updates
sudo apt update && sudo apt upgrade -y

# Performance review
curl -s http://localhost:8042/tools/statistics | jq . >> $LOG_FILE

# Security audit
echo "=== Security Audit ===" >> $LOG_FILE
sudo ufw status verbose >> $LOG_FILE
sudo fail2ban-client status >> $LOG_FILE

# Storage analysis
echo "=== Storage Analysis ===" >> $LOG_FILE
du -sh orthanc-data/* >> $LOG_FILE
find orthanc-data/ -type f -size +100M >> $LOG_FILE

echo "=== End Monthly Maintenance ===" >> $LOG_FILE
```

---

## 🔐 Security Troubleshooting

### 1. Authentication Issues

#### Login Gagal
**Diagnosis:**
```bash
# Check authentication enabled
curl -s http://localhost:8042/system | jq '.AuthenticationEnabled'

# Check users
curl -s http://localhost:8042/system | jq '.RegisteredUsers'

# Check logs
grep "authentication" /var/log/orthanc/orthanc.log
```

**Solusi:**
```bash
# Reset password
jq '.RegisteredUsers.admin.Password = "new-password"' orthanc.json > tmp.json
mv tmp.json orthanc.json

# Atau disable authentication sementara
jq '.AuthenticationEnabled = false' orthanc.json > tmp.json
mv tmp.json orthanc.json

# Restart Orthanc
docker-compose restart orthanc
```

### 2. SSL/TLS Issues

#### Certificate Error
**Diagnosis:**
```bash
# Check certificate validity
openssl x509 -in /etc/ssl/certs/orthanc.crt -text -noout

# Check certificate expiration
openssl x509 -in /etc/ssl/certs/orthanc.crt -noout -dates

# Test HTTPS connection
curl -v https://orthanc.yourdomain.com 2>&1 | grep -i "certificate"
```

**Solusi:**
```bash
# Generate new certificate
openssl req -x509 -newkey rsa:4096 -keyout orthanc.key \
  -out orthanc.crt -days 365 -nodes

# Update certificate
sudo cp orthanc.crt /etc/ssl/certs/
sudo cp orthanc.key /etc/ssl/private/

# Restart Orthanc
docker-compose restart orthanc
```

---

## 🚀 Performance Optimization

### 1. Database Optimization

```bash
# Vacuum database
docker-compose exec orthanc sqlite3 /var/lib/orthanc/db/index "VACUUM;"

# Reindex database
docker-compose exec orthanc sqlite3 /var/lib/orthanc/db/index "REINDEX;"

# Analyze database
docker-compose exec orthanc sqlite3 /var/lib/orthanc/db/index "ANALYZE;"
```

### 2. Storage Optimization

```bash
# Enable compression
jq '.StorageCompression = true' orthanc.json > tmp.json
mv tmp.json orthanc.json

# Set storage limit
jq '.MaximumStorageSize = 1048576000' orthanc.json > tmp.json
mv tmp.json orthanc.json

# Cleanup old data
curl -X POST http://localhost:8042/tools/cleanup-old-data \
  -H "Content-Type: application/json" \
  -d '{"MaxAge": 30, "Unit": "days"}'
```

### 3. Network Optimization

```bash
# Enable HTTP compression
jq '.HttpCompression = true' orthanc.json > tmp.json
mv tmp.json orthanc.json

# Increase timeout
jq '.HttpTimeout = 60' orthanc.json > tmp.json
mv tmp.json orthanc.json

# Enable keepalive
jq '.HttpKeepAlive = true' orthanc.json > tmp.json
mv tmp.json orthanc.json

# Restart Orthanc
docker-compose restart orthanc
```

---

## 📊 Monitoring dan Alerting

### 1. System Monitoring

```bash
#!/bin/bash
# scripts/monitor-system.sh

# Monitor system resources
htop

# Monitor Orthanc
docker stats orthanc-server

# Monitor disk usage
watch -n 60 'df -h | grep orthanc-data'

# Monitor network
iftop -i eth0
```

### 2. Health Check Script

```bash
#!/bin/bash
# scripts/health-check.sh

# Check Orthanc status
if curl -s http://localhost:8042/system >/dev/null 2>&1; then
    echo "✓ Orthanc is running"
else
    echo "✗ Orthanc is down"
    docker-compose restart orthanc
fi

# Check DICOM port
if nc -zv localhost 4242 >/dev/null 2>&1; then
    echo "✓ DICOM port is listening"
else
    echo "✗ DICOM port is not listening"
fi

# Check disk space
DISK_USAGE=$(df -h | grep orthanc-data | awk '{print $5}' | sed 's/%//')
if [ $DISK_USAGE -gt 80 ]; then
    echo "⚠ Disk usage is ${DISK_USAGE}%"
fi

# Check memory
MEM_USAGE=$(free | grep Mem | awk '{print $3/$2 * 100.0}')
if (( $(echo "$MEM_USAGE > 80" | bc -l) )); then
    echo "⚠ Memory usage is ${MEM_USAGE}%"
fi
```

---

## 🎯 Langkah Selanjutnya Setelah Deployment

### 1. Training dan Documentation

#### User Training
```bash
# Create user training materials
mkdir -p documentation/user-guide

# Create quick start guide
cat > documentation/user-guide/quick-start.md << 'EOF'
# Orthanc Quick Start Guide

## Accessing Orthanc
- URL: https://orthanc.yourdomain.com
- Username: your-username
- Password: your-password

## Basic Operations
- Upload DICOM: Drag & drop to web interface
- View Studies: Click on Patients tab
- Download: Click Download button on any study

## Common Tasks
1. Login to Orthanc
2. Upload DICOM file
3. View images
4. Download if needed
EOF
```

#### Create Operation Manual
```bash
# Create comprehensive manual
cat > documentation/operation-manual.md << 'EOF'
# Orthanc Operation Manual

## System Overview
Orthanc is a DICOM server for medical imaging...

## Login Procedure
1. Open browser
2. Navigate to https://orthanc.yourdomain.com
3. Enter username and password
4. Click Login

## Daily Operations
...

## Troubleshooting
...
EOF
```

### 2. Backup dan Disaster Recovery

#### Backup Strategy
```bash
#!/bin/bash
# scripts/backup-strategy.sh

# 3-2-1 Backup Strategy
# - 3 copies of data
# - 2 different media types
# - 1 offsite backup

# Local backup
cp -r orthanc-data /backup/orthanc/local/

# Remote backup
rsync -avz orthanc-data/ user@backup-server:/backup/orthanc/

# Cloud backup
rclone sync orthanc-data remote:orthanc-backup/
```

#### Disaster Recovery Plan
```markdown
# Disaster Recovery Plan

## Recovery Steps

1. Stop all services
2. Restore from latest backup
3. Verify database integrity
4. Restart services
5. Test all functionality

## Rollback Procedure
1. Stop Orthanc
2. Restore previous version
3. Restart Orthanc
4. Verify data integrity

## Emergency Contacts
- IT Support: +62-XXX-XXXX-XXXX
- System Admin: +62-XXX-XXXX-XXXX
```

### 3. Security Hardening

#### Security Checklist
```bash
#!/bin/bash
# scripts/security-check.sh

echo "=== Security Check ==="

# Check authentication
AUTH_ENABLED=$(curl -s http://localhost:8042/system | jq '.AuthenticationEnabled')
if [ "$AUTH_ENABLED" = "true" ]; then
    echo "✓ Authentication enabled"
else
    echo "✗ Authentication disabled"
fi

# Check SSL/TLS
SSL_ENABLED=$(curl -s http://localhost:8042/system | jq '.HttpsPort')
if [ "$SSL_ENABLED" != "null" ]; then
    echo "✓ SSL/TLS configured"
else
    echo "✗ SSL/TLS not configured"
fi

# Check firewall
FW_STATUS=$(sudo ufw status | grep "Status")
echo "Firewall: $FW_STATUS"

# Check fail2ban
FB_STATUS=$(sudo fail2ban-client status | grep "Status")
echo "Fail2ban: $FB_STATUS"
```

### 4. Scalability Planning

#### Growth Plan
```markdown
# Scalability Plan

## Current Capacity
- Patients: 100
- Storage: 100GB
- Users: 10

## Growth Projections
- Month 1-3: 50% increase
- Month 4-6: 100% increase
- Month 7-12: 200% increase

## Resource Requirements
- Memory: Upgrade to 16GB
- Storage: Add 1TB
- Network: 1Gbps connection

## Timeline
- Month 3: First upgrade
- Month 6: Second upgrade
- Month 12: Full scaling
```

---

## 📋 Post-Deployment Checklist

### 1. Functional Testing
- [ ] Web interface accessible
- [ ] Authentication working
- [ ] Upload DICOM successful
- [ ] View images working
- [ ] Download functional
- [ ] API endpoints accessible
- [ ] DICOM operations working

### 2. Performance Testing
- [ ] Page load time < 3s
- [ ] API response time < 1s
- [ ] DICOM transfer working
- [ ] Memory usage stable
- [ ] CPU usage acceptable

### 3. Security Testing
- [ ] SSL/TLS working
- [ ] Authentication secure
- [ ] Firewall configured
- [ ] Fail2ban enabled
- [ ] Rate limiting active

### 4. Backup Testing
- [ ] Backup routine setup
- [ ] Backup tested
- [ ] Restore tested
- [ ] Offsite backup verified

### 5. Documentation
- [ ] User guide created
- [ ] Admin guide created
- [ ] Operation manual created
- [ ] Troubleshooting guide created

---

## 🎯 Kesimpulan

### Setup Complete!
Selamat! Anda telah berhasil deploy Orthanc DICOM server dengan akses lokal dan online.

### What You Can Do Now:
1. ✅ Access Orthanc dari mana saja
2. ✅ Upload dan manage DICOM files
3. ✅ Integrate dengan sistem lain
4. ✅ Monitor dan maintain sistem
5. ✅ Scale sesuai kebutuhan

### Next Steps:
1. **Train users** pada sistem
2. **Monitor performance** secara berkala
3. **Update security** dengan patch terbaru
4. **Plan future upgrades** untuk skala
5. **Share knowledge** dengan tim lain

---

## 📞 Support dan Resources

### Official Documentation
- [Orthanc Book](https://orthanc.uclouvain.be/book/)
- [DICOM Standard](https://medical.nema.org/)
- [Cloudflare Documentation](https://developers.cloudflare.com/)

### Community Support
- [Orthanc Forum](https://www.orthanc-server.com/forum/)
- [Docker Community](https://forums.docker.com/)
- [Stack Overflow](https://stackoverflow.com/questions/tagged/orthanc)

### Emergency Contacts
- IT Support: +62-XXX-XXXX-XXXX
- System Admin: +62-XXX-XXXX-XXXX
- Security Team: +62-XXX-XXXX-XXXX

---

**🎉 Selamat! Anda telah menyelesaikan panduan lengkap setup Orthanc. Sistem Anda siap untuk produksi!**# Dokumentasi Lengkap Orthanc DICOM Server

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

**Catatan**: Dokumentasi ini dibuat untuk Orthanc dengan jodogne/orthanc-plugins image. Konfigurasi mungkin berbeda dengan versi atau image lainnya.# Orthanc Cheat Sheet - Quick Reference

## Commands Quick Reference

### Docker Commands
```bash
# Start Orthanc
docker-compose up -d

# Stop Orthanc
docker-compose down

# View logs
docker-compose logs orthanc

# Enter container
docker-compose exec orthanc bash

# Restart container
docker-compose restart orthanc
```

### Podman Commands
```bash
# Start Orthanc
podman-compose up -d

# Stop Orthanc
podman-compose down

# View logs
podman logs server-orthanc

# Enter container
podman exec -it server-orthanc bash

# Restart container
podman restart server-orthanc
```

### Check Status
```bash
# Check if Orthanc is running
curl -s http://localhost:8042 | head -1

# Check API response
curl -X GET http://localhost:8042/system

# Check DICOM port
netstat -tlnp | grep 4242

# Check HTTP port
netstat -tlnp | grep 8042
```

## API Endpoints

### System
```bash
# System info
GET /system

# Changes
GET /changes

# Statistics
GET /tools/statistics

# Performance
GET /tools/performance
```

### Patients
```bash
# Get all patients
GET /patients

# Get specific patient
GET /patients/{id}

# Get patient studies
GET /patients/{id}/studies

# Find patient
GET /patients?expand=true&limit=100
```

### Studies
```bash
# Get all studies
GET /studies

# Get specific study
GET /studies/{id}

# Get study series
GET /studies/{id}/series

# Export study
POST /studies/{id}/archive

# Anonymize study
POST /studies/{id}/anonymize
```

### Series
```bash
# Get all series
GET /series

# Get specific series
GET /series/{id}

# Get series instances
GET /series/{id}/instances

# Reconstruct series
POST /series/{id}/reconstruct

# Export series
POST /series/{id}/archive
```

### Instances
```bash
# Get all instances
GET /instances

# Get specific instance
GET /instances/{id}

# Get instance file
GET /instances/{id}/file

# Get instance metadata
GET /instances/{id}/metadata

# Delete instance
DELETE /instances/{id}
```

## Common Operations

### Upload DICOM
```bash
# Upload single file
curl -X POST -T file.dcm http://localhost:8042/studies

# Upload via cURL
curl -X POST -T DICOM_SAMPLES/MR000000.dcm http://localhost:8042/studies
```

### Search
```bash
# Search by patient name
curl "http://localhost:8042/patients?expand=true&limit=100" | jq '.[] | select(.MainDicomTags.PatientName | contains("John"))'

# Search by study date
curl "http://localhost:8042/studies?date=20240101-20240131"

# Search by modality
curl "http://localhost:8042/studies?modality=CT"
```

### Export
```bash
# Export as ZIP
curl -X POST http://localhost:8042/studies/{id}/archive \
  -H "Content-Type: application/json" \
  -d '{"Format": "zip"}'

# Export to directory
curl -X POST http://localhost:8042/studies/{id}/archive \
  -H "Content-Type: application/json" \
  -d '{"Format": "dir"}'
```

### Anonymize
```bash
# Anonymize instance
curl -X POST http://localhost:8042/instances/{id}/anonymize

# Anonymize with custom tags
curl -X POST http://localhost:8042/instances/{id}/anonymize \
  -H "Content-Type: application/json" \
  -d '{"ReplaceTags": {"PatientName": "ANONYMOUS"}}'
```

## Plugin Commands

### Lua Scripting
```bash
# Execute Lua script
curl -X POST http://localhost:8042/scripts/execute \
  -H "Content-Type: application/json" \
  -d '{"script": "return OrthancApiClient:GetSystem()"}'
```

### PDF Export
```bash
# Export study to PDF
curl -X POST http://localhost:8042/studies/{id}/pdf \
  -H "Content-Type: application/json" \
  -d '{"Format": "A4", "Quality": "high"}'
```

### Web Viewer
```bash
# Get viewer data for series
GET /series/{id}/viewer

# Get image for instance
GET /instances/{id}/file
```

## Configuration

### Basic orthanc.json
```json
{
  "Name": "Orthanc (DICOM Server)",
  "HttpPort": 8042,
  "DicomPort": 4242,
  "AuthenticationEnabled": false,
  "StorageDirectory": "/var/lib/orthanc/db",
  "IndexDirectory": "/var/lib/orthanc/db"
}
```

### With Plugins
```json
{
  "Name": "Orthanc with Plugins",
  "HttpPort": 8042,
  "DicomPort": 4242,
  "AuthenticationEnabled": false,
  "StorageDirectory": "/var/lib/orthanc/db",
  "LuaScripts": {
    "Enabled": true,
    "Directory": "/etc/orthanc/scripts"
  },
  "WebViewer": {
    "Enabled": true,
    "CacheDirectory": "/tmp/orthanc-viewer"
  }
}
```

### HTTPS Setup
```json
{
  "Name": "Secure Orthanc",
  "HttpPort": 8042,
  "HttpsPort": 8443,
  "CertificateFile": "/etc/ssl/certs/orthanc.crt",
  "KeyFile": "/etc/ssl/private/orthanc.key",
  "AuthenticationEnabled": true,
  "Username": "admin",
  "Password": "securePassword123"
}
```

## File Locations

### Default Locations
```bash
# Configuration file
/etc/orthanc/orthanc.json

# Plugin directory
/usr/share/orthanc/plugins/

# Data directory
/var/lib/orthanc/db/

# SQLite database
/var/lib/orthanc/db/index

# Log file
/var/log/orthanc/orthanc.log

# Temporary files
/tmp/orthanc/
```

### Docker Specific
```bash
# Mount configuration
./orthanc.json:/etc/orthanc/orthanc.json

# Mount plugins
./plugins:/usr/share/orthanc/plugins

# Mount data
./orthanc-data:/var/lib/orthanc/db
```

## Common Issues

### Port Already in Use
```bash
# Check port usage
sudo lsof -i :8042
sudo lsof -i :4242

# Kill process
sudo kill -9 <PID>
```

### Permission Issues
```bash
# Fix permissions
sudo chown -R $USER:$USER orthanc-data
sudo chmod -R 755 orthanc-data
```

### Database Corruption
```bash
# Stop service
docker-compose down

# Backup database
cp -r orthanc-data orthanc-data.backup

# Remove database
rm -f orthanc-data/index*
rm -f orthanc-data/journal*

# Restart
docker-compose up -d
```

## Quick Scripts

### Check DICOM File
```bash
#!/bin/bash
# check_dicom.sh FILE
FILE=$1
echo "File size: $(stat -c%s $FILE) bytes"
hexdump -C $FILE | grep -q "44 49 43 4d" && echo "DICOM: VALID" || echo "DICOM: INVALID"
```

### Backup Orthanc
```bash
#!/bin/bash
# backup_orthanc.sh
DATE=$(date +%Y%m%d_%H%M%S)
mkdir -p backup/$DATE
cp orthanc.json backup/$Date/config.json
cp -r orthanc-data backup/$Date/db
echo "Backup complete: backup/$Date"
```

### Monitor Orthanc
```bash
#!/bin/bash
# monitor_orthanc.sh
while true; do
    echo "$(date): Checking Orthanc..."
    if curl -s http://localhost:8042 > /dev/null; then
        echo "✓ Orthanc running"
    else
        echo "✗ Orthanc down"
    fi
    sleep 60
done
```

## URLs

### Main URLs
```
Main Interface: http://localhost:8042
API Explorer: http://localhost:8042/apidocs
System Info: http://localhost:8042/system
Patients: http://localhost:8042/patients
Studies: http://localhost:8042/studies
Series: http://localhost:8042/series
Instances: http://localhost:8042/instances
```

### Plugin URLs (if installed)
```
Web Viewer: http://localhost:8042/viewer
Lua Console: http://localhost:8042/lua
PDF Export: http://localhost:8042/pdf
```

## Glossary

- **DICOM**: Digital Imaging and Communications in Medicine
- **PACS**: Picture Archiving and Communication System
- **SCP**: Service Class Provider
- **SCU**: Service Class User
- **AET**: Application Entity Title
- **UID**: Unique Identifier
- **REST**: Representational State Transfer
- **SQLite**: Lightweight database engine
- **JPEG**: Joint Photographic Experts Group
- **PNG**: Portable Network Graphics

---

*Note: This cheat sheet provides quick reference commands and configurations. Always refer to official documentation for complete information.*# Dokumentasi Lengkap Plugin Orthanc

## Daftar Isi
1. [Pengenalan Plugin Orthanc](#pengenalan-plugin-orthanc)
2. [Jenis Plugin dan Fungsinya](#jenis-plugin-dan-fungsinya)
3. [Instalasi Plugin](#instalasi-plugin)
4. [Konfigurasi Plugin](#konfigurasi-plugin)
5. [Plugin Populer](#plugin-populer)
6. [Tutorial Penggunaan Aplikasi Web](#tutorial-penggunaan-aplikasi-web)
7. [API Plugin](#api-plugin)
8. [Konfigurasi Lanjutan](#konfigurasi-lanjutan)
9. [Optimasi Performa](#optimasi-performa)
10. [Debugging dan Troubleshooting](#debugging-dan-troubleshooting)

---

## Pengenalan Plugin Orthanc

Orthanc menggunakan sistem modular di mana fungsionalitas dapat diperluas melalui **plugins**. Plugin adalah library dinamis (DLL di Windows, .so di Linux) yang memungkinkan:

- **Ekstensi fungsionalitas** ke inti Orthanc
- **Integrasi dengan sistem eksternal** (PACS, databases)
- **Pemrosesan gambar medis** advanced
- **Format file konversi**
- **Authentication dan authorization** kustom
- **Automasi workflows**

### Keuntungan Menggunakan Plugin:
1. **Modular** - Tambahkan fitur tanpa mengubah core
2. **Performa** - Dijalankan dalam proses yang sama
3. **Kompatibilitas** - Bekerja dengan versi Orthanc yang berbeda
4. **Ekosistem** - Banyak plugin tersedia di repository resmi

---

## Jenis Plugin dan Fungsinya

### 1. **Lua Scripting Plugin**
Membuat skripting untuk otomasi dan custom workflows.

**Fitur:**
- Execute Lua scripts
- Automasi workflows
- Custom validation
- Event handlers

**Installation:**
```json
{
  "LuaScripts": {
    "Enabled": true,
    "Directory": "/etc/orthanc/scripts"
  }
}
```

**Contoh Script (`validate_study.lua`):**
```lua
function OnIncomingInstance(instanceId)
    -- Get study details
    local study = OrthancApiClient:GetStudy(instanceId)
    
    -- Validate DICOM tags
    if not study.PatientName then
        OrthancApiClient:DeleteInstance(instanceId)
        return false, "Missing patient name"
    end
    
    return true, "Valid study"
end
```

### 2. **JPEG-2000 Plugin**
Support untuk format kompresi JPEG-2000.

**Fitur:**
- Read/write JPEG-2000 DICOM
- Lossless compression
- Quality control
- GPU acceleration (optional)

**Konfigurasi:**
```json
{
  "Jpeg2000Compression": {
    "Enabled": true,
    "Quality": 0.8,
    "Lossless": true
  }
}
```

### 3. **Web Viewer Plugin**
DICOM viewer web yang powerful.

**Fitur:**
- Cornerstone.js integration
- Multi-planar reconstruction
- Measurement tools
- Annotation support

**Konfigurasi:**
```json
{
  "WebViewer": {
    "Enabled": true,
    "CacheDirectory": "/tmp/orthanc-webviewer",
    "MaxCacheSize": 1000
  }
}
```

### 4. **PDF Plugin**
Export DICOM ke PDF.

**Fitur:**
- Multi-page PDF
- Custom layouts
- DICOM overlay
- Watermarks

**Konfigurasi:**
```json
{
  "PdfExport": {
    "Enabled": true,
    "Template": "default",
    "Dpi": 300,
    "Compression": "jpeg"
  }
}
```

### 5. **Video Plugin**
Support untuk video medical.

**Fitur:**
- DICOM video support
- Format conversion
- Streaming
- Annotations

### 6. **Scripting Plugin (JavaScript/Python)**
Support untuk bahasa scripting modern.

**Fitur:**
- Execute JS/Python scripts
- API integration
- Data transformation
- Workflow automation

### 7. **DICOM Structured Reporting**
Support untuk structured reporting.

**Fitur:**
- SR template handling
- Report generation
- Export to HL7
- Custom fields

---

## Instalasi Plugin

### 1. Plugin Resmi dari Jodogne

#### Download Plugin
```bash
# Download dari official repository
wget https://bitbucket.org/sjodogne/orthanc-plugins/downloads/OrthancPlugins-1.12.0.tar.gz
tar -xvzf OrthancPlugins-1.12.0.tar.gz
cd OrthancPlugins-1.12.0

# Build plugin
mkdir build
cd build
cmake .. -DCMAKE_BUILD_TYPE=Release
make -j4
```

#### Install Plugin
```bash
# Linux
sudo cp Core/Lua/*.so /usr/share/orthanc/plugins/

# Docker (ke dalam container)
# Tambahkan ke docker-compose.yml
volumes:
  - ./plugins:/usr/share/orthanc/plugins
```

### 2. Plugin Third-Party

#### Dari OrthancExplorer
```bash
# Download dari Orthanc Explorer
wget https://orthanc.uclouvain.be/downloads/plugin-name.zip
unzip plugin-name.zip
# Pindahkan ke plugins directory
```

### 3. Plugin Management via Docker

#### Docker Compose dengan Plugin
```yaml
version: '3.8'

services:
  orthanc:
    image: jodogne/orthanc-plugins:latest
    container_name: server-orthanc
    ports:
      - "8042:8042"
    volumes:
      - ./orthanc-data:/var/lib/orthanc/db
      - ./plugins:/usr/share/orthanc/plugins
      - ./orthanc.json:/etc/orthanc/orthanc.json
    restart: unless-stopped
```

### 4. Verifikasi Plugin
```bash
# Cek plugin yang terinstall
curl -X GET "http://localhost:8042/system" | grep -i plugins

# Atau melalui web interface
# -> System -> Plugins
```

---

## Konfigurasi Plugin

### 1. Konfigurasi Global

#### Tambahkan ke orthanc.json
```json
{
  "Plugins": {
    "Enabled": true,
    "Directory": "/usr/share/orthanc/plugins",
    "LoadAll": true
  },
  
  "LuaScripts": {
    "Enabled": true,
    "Directory": "/etc/orthanc/scripts",
    "AutoExecute": true
  },
  
  "WebViewer": {
    "Enabled": true,
    "CacheDirectory": "/tmp/orthanc-viewer",
    "MaxCacheSize": 500
  }
}
```

### 2. Konfigurasi per Plugin

#### JSON Configuration per Plugin
```json
{
  "PdfExport": {
    "Enabled": true,
    "DefaultDpi": 300,
    "CompressionLevel": 9,
    "Watermark": "CONFIDENTIAL",
    "OutputFormat": "A4"
  },
  
  "Jpeg2000": {
    "Enabled": true,
    "Quality": 0.9,
    "Lossless": false,
    "CompressionRatio": 10
  },
  
  "Video": {
    "Enabled": true,
    "Format": "mp4",
    "Codec": "h264",
    "Quality": "high"
  }
}
```

### 3. Environment Variables untuk Plugin

```bash
# Di docker-compose.yml
environment:
  - ORTHANC_PLUGIN_DIRECTORY=/usr/share/orthanc/plugins
  - ORTHANC_LUA_SCRIPTS=/etc/orthanc/scripts
  - ORTHANC_CACHE_SIZE=1000
```

### 4. Plugin Priority

```json
{
  "PluginPriority": [
    "libOrthancWebViewer.so",
    "libOrthancPdf.so",
    "libOrthancLua.so"
  ]
}
```

---

## Plugin Populer

### 1. **Orthanc Web Viewer**
DICOM viewer web modern dengan fitur lengkap.

**Fitur:**
- Cornerstone.js
- Multi-planar views
- Measurements
- Annotations
- 3D reconstruction
- DICOM SR support

**Konfigurasi:**
```json
{
  "WebViewer": {
    "Enabled": true,
    "CacheDirectory": "/tmp/orthanc-webviewer",
    "MaxCacheSize": 1000,
    "Compression": true,
    "TileSize": 512,
    "MaxConcurrency": 10
  }
}
```

### 2. **PDF Export Plugin**
Export DICOM ke PDF dengan format professional.

**Features:**
- Multi-studies per PDF
- Custom layouts
- DICOM headers
- Watermarks
- Digital signatures

**API Usage:**
```bash
# Export study ke PDF
curl -X POST "http://localhost:8042/studies/<study-id>/pdf" \
  -H "Content-Type: application/json" \
  -d '{
    "Format": "A4",
    "Quality": "high",
    "IncludeAnnotations": true,
    "Watermark": "MEDICAL REPORT"
  }'
```

### 3. **Lua Scripting Plugin**
Automation dan custom workflows dengan Lua.

**Examples:**
```lua
-- Auto-delete anonymized studies after 30 days
function OnChange(change)
    if change.resourceType == "Study" then
        local study = OrthancApiClient:GetStudy(change.id)
        if study.Tags.AnonymizationTime then
            local daysSinceAnonymization = (os.time() - study.Tags.AnonymizationTime) / 86400
            if daysSinceAnonymization > 30 then
                OrthancApiClient:DeleteStudy(change.id)
            end
        end
    end
end

-- Email notification on new study
function OnIncomingStudy(studyId)
    local study = OrthancApiClient:GetStudy(studyId)
    local patientName = study.PatientName
    
    -- Send email
    local email = {
        to = "radiologist@hospital.com",
        subject = "New Study: " .. patientName,
        body = "New study received for " .. patientName .. "\nStudy ID: " .. studyId
    }
    
    OrthancApiClient:SendEmail(email)
end
```

### 4. **Video Plugin**
Support untuk video medical.

**Usage:**
```bash
# Upload video DICOM
curl -X POST -T video.dcm http://localhost:8042/studies

# Convert video format
curl -X POST "http://localhost:8042/instances/<instance-id>/convert" \
  -H "Content-Type: application/json" \
  -d '{"Format": "mp4", "Quality": "high"}'
```

### 5. **DICOM Structured Reporting**
Generate dan manipulasi structured reports.

**Example Workflow:**
```json
{
  "SRGeneration": {
    "Template": "RadReport",
    "Fields": {
      "Technique": "CT Scan",
      "Findings": "Normal",
      "Recommendations": "Continue follow-up"
    }
  }
}
```

---

## Tutorial Penggunaan Aplikasi Web

### 1. Akses Web Interface

```
URL: http://localhost:8042
```

### 2. Navigation Overview

#### Dashboard
- System statistics
- Memory usage
- Storage information
- Active connections

#### Patients Tab
- Search patients
- View patient list
- Patient demographics
- Patient studies

#### Studies Tab
- Grouped by patient
- Study metadata
- Series information
- Export options

#### Series Tab
- Series preview
- Number of images
- Series metadata
- Reconstruction tools

#### Instances Tab
- Individual DICOM instances
- Metadata viewer
- Export options
- Delete instances

### 3. Advanced Features

#### Multi-Planar Reconstruction
1. Open series viewer
2. Enable MPR mode
3. Adjust window/level
4. Create measurements
5. Export measurements

#### 3D Reconstruction
1. Select multiple series
2. Choose "Reconstruct" option
3. Select reconstruction type
4. Adjust parameters
5. Export 3D model

#### DICOM SR Viewer
1. Open structured reports
2. Navigate sections
3. View measurements
4. Add annotations
5. Export report

### 4. Search and Filter

#### Advanced Search
```javascript
// Search by multiple criteria
const searchCriteria = {
  PatientName: "John*",
  StudyDate: "2024-01-01:2024-12-31",
  Modality: "CT",
  AccessionNumber: "*12345*"
};

// API search
fetch('/studies', {
  method: 'POST',
  headers: {'Content-Type': 'application/json'},
  body: JSON.stringify(searchCriteria)
});
```

#### Save Search Queries
1. Create custom search
2. Save as template
3. Apply to future searches
4. Schedule automatic searches

### 5. Bulk Operations

#### Batch Export
```bash
# Export multiple studies
curl -X POST "http://localhost:8042/tools/batch-export" \
  -H "Content-Type: application/json" \
  -d '{
    "Resources": ["study-1", "study-2"],
    "Format": "dicom",
    "Compression": "zip"
  }'
```

#### Batch Anonymization
```bash
# Anonymize multiple studies
curl -X POST "http://localhost:8042/tools/batch-anonymize" \
  -H "Content-Type: application/json" \
  -d '{
    "Resources": ["study-1", "study-2"],
    "RemoveTags": ["PatientName", "PatientID"],
    "AddTags": {
      "PatientName": "ANONYMOUS",
      "PatientID": "ANON_001"
    }
  }'
```

---

## API Plugin

### 1. REST API Basics

#### Authentication
```bash
# Jika authentication diaktifkan
curl -X POST "http://localhost:8042/login" \
  -H "Content-Type: application/json" \
  -d '{"username": "admin", "password": "password"}'
```

#### Response Format
```json
{
  "ID": "instance-123",
  "Type": "Instance",
  "MainDicomTags": {
    "PatientName": "John Doe",
    "StudyDate": "20240101"
  },
  "Uri": "/instances/instance-123"
}
```

### 2. Plugin-Specific Endpoints

#### Lua Scripting API
```javascript
// Execute Lua script
POST /scripts/execute
Content-Type: application/json

{
  "script": "return OrthancApiClient:GetSystem()",
  "context": {
    "instanceId": "instance-123"
  }
}
```

#### Web Viewer API
```javascript
// Get image viewer data
GET /series/<series-id>/viewer

Response:
{
  "Metadata": {
    "Rows": 512,
    "Columns": 512,
    "BitsAllocated": 16
  },
  "ImageUris": [
    "/instances/instance-1/file",
    "/instances/instance-2/file"
  ]
}
```

#### PDF Export API
```javascript
// Generate PDF from study
POST /studies/<study-id>/pdf
Content-Type: application/json

{
  "Format": "A4",
  "Dpi": 300,
  "IncludeSeries": true,
  "Watermark": "CONFIDENTIAL"
}

Response:
{
  "Uri": "/exports/pdf-123.pdf",
  "Size": 2457600,
  "MimeType": "application/pdf"
}
```

### 3. WebSocket Integration

#### Real-time Updates
```javascript
// Connect to WebSocket for live updates
const socket = new WebSocket('ws://localhost:8042/ws');

socket.onmessage = function(event) {
  const change = JSON.parse(event.data);
  console.log('Change detected:', change);
  
  if (change.changeType === 'NewInstance') {
    updateUI(change.resource);
  }
};
```

#### Custom WebSocket Handlers
```lua
-- Lua script for WebSocket events
function OnWebSocketConnection(client)
    client:Send("Welcome to Orthanc WebSocket")
end

function OnWebSocketMessage(client, message)
    local data = json.decode(message)
    -- Process custom commands
    client:Send("Processed: " .. data.command)
end
```

### 4. Plugin Development API

#### Creating Custom Plugin
```c
// Example C plugin
#include <orthanc/OrthancCPlugin.h
  
ORTHANC_PLUGIN_ENTRY(OrthancPluginService)
{
  OrthancPluginSetDescription(service, "Custom plugin for orthanc");
  
  // Register callback
  OrthancPluginRegisterCallback(
    service,
    OrthancPluginCallback_OnChange,
    OnChangeCallback,
    NULL
  );
}
```

#### Plugin Communication
```javascript
// Plugin-to-plugin communication
function SendNotification(plugin, message, data) {
  fetch('/plugins/' + plugin + '/notify', {
    method: 'POST',
    headers: {'Content-Type': 'application/json'},
    body: JSON.stringify({
      message: message,
      data: data
    })
  });
}
```

---

## Konfigurasi Lanjutan

### 1. Performance Tuning

#### Memory Optimization
```json
{
  "GlobalConfiguration": {
    "MaximumMemoryUsage": 4096,
    "ChunkSize": 64,
    "StorageCompression": true,
    "IndexCacheSize": 1000
  }
}
```

#### Database Optimization
```json
{
  "Database": {
    "TransactionSize": 100,
    "MaxJournalSize": 104857600,
    "Sync": "NORMAL",
    "CacheSize": 1000000
  }
}
```

#### Network Optimization
```json
{
  "HttpCompression": true,
  "DicomTimeout": 30,
  "MaxHttpConnections": 100,
  "KeepAliveTimeout": 300
}
```

### 2. Security Configuration

#### Authentication Setup
```json
{
  "AuthenticationEnabled": true,
  "UserName": "admin",
  "Password": "securePassword123",
  "AllowAnonymous": false,
  "SessionsTimeout": 3600
}
```

#### ACL Configuration
```json
{
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
  "KeyFile": "/etc/ssl/private/orthanc.key",
  "TrustedCertificates": ["/etc/ssl/certs/ca.crt"]
}
```

### 3. Integration Configuration

#### PACS Integration
```json
{
  "DicomModalities": {
    "MY-PACS": {
      "Address": "192.168.1.100",
      "Port": 4242,
      "Aet": "PACS-AET",
      "Username": "user",
      "Password": "pass"
    }
  },
  
  "DicomFindSCU": {
    "Timeout": 30,
    "CalledAET": "ANY-SCP"
  }
}
```

#### Database Integration
```json
{
  "Database": {
    "Connection": "postgresql://user:pass@localhost/orthanc",
    "Tables": {
      "Patients": "orthanc_patients",
      "Studies": "orthanc_studies"
    }
  }
}
```

#### Cloud Storage
```json
{
  "CloudStorage": {
    "Provider": "AWS",
    "Bucket": "orthanc-backup",
    "AccessKey": "AKI...",
    "SecretKey": "secret...",
    "Region": "us-east-1"
  }
}
```

### 4. Monitoring and Logging

#### Logging Configuration
```json
{
  "Logging": {
    "Level": "info",
    "File": "/var/log/orthanc/orthanc.log",
    "RotateSize": 10485760,
    "RotateCount": 5,
    "EnableHttpLogs": true
  }
}
```

#### Monitoring Endpoints
```bash
# System statistics
curl http://localhost:8042/tools/statistics

# Performance metrics
curl http://localhost:8042/tools/performance

# Memory usage
curl http://localhost:8042/tools/memory
```

---

## Optimasi Performa

### 1. Storage Optimization

#### Compression Settings
```json
{
  "StorageCompression": true,
  "DefaultLostResourceCompression": true,
  "JpegCompression": {
    "Quality": 85,
    "Enabled": true
  },
  "Jpeg2000Compression": {
    "Quality": 0.9,
    "Lossless": false
  }
}
```

#### Filesystem Optimization
```bash
# Use SSD for database
# Mount options for database
UUID=1234-5678 /var/lib/orthanc/db ext4 noatime,nodiratime,discard

# Use separate volume for DICOM storage
UUID=5678-9012 /var/lib/orthanc/storage ext4 noatime
```

### 2. Cache Optimization

#### Memory Cache
```json
{
  "Cache": {
    "Size": 1024,  // MB
    "Directory": "/var/cache/orthanc",
    "Type": "memory"
  },
  
  "IndexCache": {
    "Size": 500000,  // entries
    "Type": "memory"
  }
}
```

#### Web Cache
```json
{
  "WebViewer": {
    "CacheDirectory": "/tmp/orthanc-cache",
    "MaxCacheSize": 2000,
    "Compression": true,
    "CacheTtl": 3600
  }
}
```

### 3. Network Optimization

#### Connection Pooling
```json
{
  "Http": {
    "KeepAlive": true,
    "MaxConnections": 100,
    "Timeout": 30,
    "Compression": true
  },
  
  "Dicom": {
    "Timeout": 30,
    "MaxPduLength": 16384,
    "MaxAssociations": 10
  }
}
```

#### Load Balancing
```yaml
# docker-compose.yml untuk load balancing
version: '3.8'
services:
  orthanc1:
    image: jodogne/orthanc-plugins
    ports:
      - "8042:8042"
    volumes:
      - ./data1:/var/lib/orthanc/db
  orthanc2:
    image: jodogne/orthanc-plugins
    ports:
      - "8043:8042"
    volumes:
      - ./data2:/var/lib/orthanc/db
```

---

## Debugging dan Troubleshooting

### 1. Common Plugin Issues

#### Plugin Not Loading
```bash
# Check plugin logs
docker-compose logs orthanc | grep plugin

# Check plugin directory
ls -la /usr/share/orthanc/plugins/

# Check plugin compatibility
curl -X GET "http://localhost:8042/system" | grep plugins
```

#### Memory Issues
```json
{
  "Debug": {
    "MemoryTracking": true,
    "MemoryLimit": 2048,  // MB
    "VerboseMemory": true
  }
}
```

#### Performance Issues
```bash
# Monitor memory usage
docker stats --no-stream orthanc

# Check database size
sqlite3 /var/lib/orthanc/db/index "PRAGMA page_count;"
sqlite3 /var/lib/orthanc/db/index "PRAGMA index_list('Records');"
```

### 2. Debug Tools

#### Orthanc Debugger
```bash
# Start with debug mode
docker run -e ORTHANC_DEBUG=1 jodogne/orthanc-plugins

# Enable debug logs
curl -X POST "http://localhost:8042/tools/debug" \
  -H "Content-Type: application/json" \
  -d '{"enable": true}'
```

#### Packet Capture
```bash
# Capture DICOM traffic
tcpdump -i any -s 0 -w dicom.pcap port 4242

# Analyze with Wireshark
wireshark dicom.pcap
```

### 3. Error Handling

#### Lua Error Handling
```lua
function SafeExecute(script, params)
    local status, result = pcall(function()
        return load(script)(params)
    end)
    
    if not status then
        OrthancApiClient:LogError("Script error: " .. tostring(result))
        return false, result
    end
    
    return true, result
end
```

#### Plugin Error Handling
```c
// C plugin error handling
OrthancPluginErrorCode code = OrthancPluginCreateInstance(...);
if (code != OrthancPluginErrorCode_Success) {
    OrthancPluginLogError(service, "Failed to create instance: %d", code);
    return code;
}
```

### 4. Recovery Procedures

#### Database Recovery
```bash
# Stop orthanc
docker-compose down

# Backup database
cp -r orthanc-data orthanc-data.backup

# Remove index files
rm -f orthanc-data/index*
rm -f orthanc-data/journal/*

# Restart orthanc
docker-compose up -d
```

#### Plugin Recovery
```bash
# Remove problematic plugin
mv /usr/share/orthanc/plugins/libProblematic.so /tmp/

# Restart orthanc
docker-compose restart orthanc

# Test without plugin
curl -X GET "http://localhost:8042/system"
```

### 5. Backup Strategy

#### Automated Backup Script
```bash
#!/bin/bash
# backup-orthanc.sh

DATE=$(date +%Y%m%d_%H%M%S)
BACKUP_DIR="/backup/orthanc"

# Create backup
mkdir -p $BACKUP_DIR/$DATE

# Backup database
cp -r orthanc-data $BACKUP_DIR/$DATE/db

# Backup configuration
cp orthanc.json $BACKUP_DIR/$Date/config.json

# Backup plugins
cp -r plugins $BACKUP_DIR/$Date/plugins

# Compress backup
cd $BACKUP_DIR
tar -czf orthanc-$DATE.tar.gz $DATE

# Clean old backups
find $BACKUP_DIR -name "orthanc-*.tar.gz" -mtime +30 -delete
```

#### Scheduled Backup
```bash
# Add to crontab
0 2 * * * /path/to/backup-orthanc.sh >> /var/log/orthanc-backup.log 2>&1
```

---

## Resources

### Official Resources
- [Orthanc Plugin SDK](https://orthanc.uclouvain.be/book/developers/sdk/)
- [Orthanc Documentation](https://orthanc.uclouvain.be/book/)
- [Plugin Repository](https://orthanc.uclouvain.be/plugins/)
- [Community Forum](https://www.orthanc-server.com/forum/)

### Development Tools
- [Orthanc Explorer](https://orthanc.uclouvain.be/downloads/)
- [DICOM Toolkit](https://www.dcm4che.org/)
- [DICOM Anonymizer](https://github.com/microsoft/ML-for-Health-on-Azure/tree/main/Anonymize-DICOM)

### Learning Resources
- [DICOM Standard](https://medical.nema.org/)
- [HL7 Standards](https://www.hl7.org/)
- [Medical Imaging Tutorials](https://dicom.nema.org/medical/dicom/current/output/html/part01.html)

---

**Note**: Dokumentasi ini mencakup berbagai aspek dari penggunaan plugin Orthanc. Pastikan untuk merujuk ke dokumentasi resmi untuk versi terbaru dan informasi spesifik tentang setiap plugin.# Tutorial Penggunaan Aplikasi Web Orthanc Lengkap

## Daftar Isi
1. [Pengenalan Aplikasi Web](#pengenalan-aplikasi-web)
2. [Dashboard dan Overview](#dashboard-dan-overview)
3. [Navigasi Interface](#navigasi-interface)
4. [Mengelola Pasien](#mengelola-pasien)
5. [Studi dan Series](#studi-dan-series)
6. [Viewer Gambar DICOM](#viewer-gambar-dicom)
7. [Export dan Sharing](#export-dan-sharing)
8. [Search dan Filter](#search-dan-filter)
9. [Tools Utilities](#tools-utilities)
10. [Workflows Otomatis](#workflows-otomatis)
11. [Tips dan Best Practices](#tips-dan-best-practices)

---

## Pengenalan Aplikasi Web

Orthanc web interface adalah GUI yang intuitif untuk mengelola server DICOM. Interface ini dibangun dengan teknologi modern dan menyediakan fitur-fitur lengkap untuk:

- Visualisasi data medis
- Manajemen DICOM files
- Interaksi dengan PACS lain
- Export dan sharing data
- Analytics reporting

### Cara Akses
```
URL: http://localhost:8042
Browser: Chrome, Firefox, Safari, Edge
```

### Requirements Sistem
- JavaScript enabled
- HTML5 support
- Minimal 4GB RAM untuk performa optimal
- Koneksi stabil untuk streaming gambar

---

## Dashboard dan Overview

### 1. Dashboard Utama

#### Informasi Sistem
- **Orthanc Version**: Versi server yang berjalan
- **Memory Usage**: Penggunaan RAM
- **Storage**: Total dan free space
- **Database**: Ukuran dan status
- **Active Connections**: Jumlah koneksi aktif

#### Statistik Real-time
- Total Patients
- Total Studies
- Total Series
- Total Instances
- Incoming studies (24h)
- Exported files

### 2. Monitoring Tools

#### Live Statistics
```javascript
// Update setiap 5 detik
setInterval(() => {
    fetch('/tools/statistics')
        .then(response => response.json())
        .then(data => updateDashboard(data));
}, 5000);
```

#### Performance Metrics
- Response time
- Throughput
- Error rates
- Resource utilization

### 3. Quick Actions
- Refresh all data
- Export statistics
- View logs
- System settings

---

## Navigasi Interface

### 1. Menu Bar

#### Main Navigation
- **Home**: Dashboard
- **Patients**: Daftar pasien
- **Studies**: Studi radiologi
- **Series**: Series gambar
- **Instances**: File DICOM individual
- **Plugins**: Manajemen plugin
- **Tools**: Utilities dan tools

#### Search Bar
- Cepat cari resource
- Filter berdasar kriteria
- Auto-complete support

### 2. Breadcrumb Navigation

```
Home > Patients > John Doe (ID: 123) > Studies > CT Chest (20240101)
```

- Navigasi cepat antar level
- Back button historis
- Direct link access

### 3. View Options

#### Layout Options
- Grid view (default)
- List view
- Table view
- Tree view

#### Display Options
- Thumbnail size
- Sorting options
- Column selection
- Grouping options

---

## Mengelola Pasien

### 1. Patients List

#### View Patients
```javascript
// Menampilkan daftar patients
fetch('/patients')
    .then(response => response.json())
    .then(data => renderPatientsList(data));

// Format response:
{
    "Total": 150,
    "Patients": [
        {
            "ID": "patient-123",
            "MainDicomTags": {
                "PatientName": "John Doe",
                "PatientID": "P001234",
                "BirthDate": "19700101"
            },
            "StudyCount": 5
        }
    ]
}
```

#### Search Patients
- **Patient Name**: John*
- **Patient ID**: P001*
- **Birth Date**: Range picker
- **Gender**: Male/Female
- **Accession Number**: *

### 2. Patient Details

#### Patient Information
```javascript
// Detail patient
fetch('/patients/{patient-id}')
    .then(response => response.json())
    .then(data => showPatientDetails(data));
```

**Informasi Tampil:**
- Demographics
- Clinical data
- Study history
- Related series

#### Actions on Patient
- View studies
- Export data
- Anonymize
- Delete patient
- Share patient

### 3. Bulk Patient Operations

#### Select Multiple Patients
- Checkbox selection
- Range selection
- Filter selection

#### Batch Actions
```javascript
// Anonymize multiple patients
const selectedPatients = ['patient-1', 'patient-2'];

fetch('/tools/batch-anonymize', {
    method: 'POST',
    headers: {'Content-Type': 'application/json'},
    body: JSON.stringify({
        'Resources': selectedPatients,
        'Type': 'Patient'
    })
});
```

---

## Studi dan Series

### 1. Studies Management

#### Studies Overview
- Grouped by patient
- Date range filter
- Modality filter
- Status indicators

#### Study Details
```javascript
// Study metadata
fetch('/studies/{study-id}')
    .then(response => response.json())
    .then(data => renderStudyDetails(data));
```

**Study Information:**
- Study UID
- Study Date/Time
- Accession Number
- Referring Physician
- Study Description
- Modality

#### Study Operations
- View series
- Export study
- Anonymize study
- Delete study
- Add to PACS

### 2. Series Management

#### Series List
```javascript
// Get series for study
fetch('/studies/{study-id}/series')
    .then(response => response.json())
    .then(data => renderSeriesList(data));
```

**Series Information:**
- Series UID
- Series Description
- Modality
- Number of instances
- Acquisition date
- Body part

#### Series Actions
- Open viewer
- Export series
- Anonymize series
- Delete series
- Reconstruct series

### 3. Instance Management

#### Instances List
- Thumbnail preview
- Instance metadata
- File size
- Image dimensions

#### Instance Actions
- View instance
- Export instance
- Delete instance
- Anonymize instance
- Convert format

---

## Viewer Gambar DICOM

### 1. DICOM Viewer Interface

#### Layout Options
1. **Single View**: Gambar tunggal
2. **Dual View**: 2 gambar sekaligus
3. **Quad View**: 4 gambar sekaligus
4. **Stack View**: Multiple slices
5. **3D View**: Rekonstruksi 3D

#### View Controls
```javascript
// Basic viewer controls
const viewer = new OrthancViewer({
    element: '#viewer-container',
    studyId: 'study-123',
    
    // View options
    layout: 'dual',
    synchronize: true,
    
    // Display options
    windowWidth: 400,
    windowLevel: 40,
    invert: false,
    
    // Tools
    tools: ['zoom', 'pan', 'measure', 'roi']
});
```

### 2. Image Manipulation

#### Window/Level Adjustment
```javascript
// Window/Level presets
const presets = {
    'lung': { width: 1500, level: -600 },
    'bone': { width: 2000, level: 400 },
    'brain': { width: 80, level: 40 },
    'abdomen': { width: 400, level: 60 }
};

// Apply preset
viewer.applyWindowLevel(presets.brain);
```

#### Measurement Tools
1. **Distance**: Measure distance between points
2. **Angle**: Measure angles
3. **ROI**: Region of Interest area
4. **Calibration**: Real measurements

```javascript
// Add measurement
const measurement = viewer.addMeasurement({
    type: 'distance',
    points: [{x: 100, y: 100}, {x: 200, y: 100}],
    color: 'red',
    label: 'Lesion size'
});
```

#### Annotation Tools
- Arrow annotation
- Text annotation
- Freehand drawing
- Shape annotation
- Stamp tool

### 3. Advanced Features

#### Multi-Planar Reconstruction (MPR)
```javascript
// MPR setup
const mprViewer = new OrthancMPRViewer({
    axial: viewer1,
    coronal: viewer2,
    sagittal: viewer3,
    
    // Synchronize navigation
    synchronize: true,
    
    // Crosshair
    crosshair: {
        color: 'yellow',
        width: 2
    }
});
```

#### 3D Reconstruction
```javascript
// Create 3D volume
const volume3D = viewer.create3D({
    type: 'volume',
    series: ['series-1', 'series-2'],
    
    // Rendering options
    renderMode: 'maximum',
    threshold: 100,
    
    // Post-processing
    smoothing: true,
    isosurface: true
});
```

#### Movie Playback
```javascript
// Play movie
const moviePlayer = viewer.playMovie({
    frames: 100,
    fps: 30,
    loop: true,
    direction: 'forward'
});

// Control playback
moviePlayer.play();
moviePlayer.pause();
moviePlayer.seek(50); // Go to frame 50
```

---

## Export dan Sharing

### 1. Export Formats

#### DICOM Export
```javascript
// Export DICOM
const exportOptions = {
    format: 'dicom',
    compression: 'none',
    anonymize: false,
    includeMetadata: true
};

fetch('/studies/{study-id}/export', {
    method: 'POST',
    headers: {'Content-Type': 'application/json'},
    body: JSON.stringify(exportOptions)
});
```

#### Common Formats
- **DICOM**: Standar medical format
- **JPEG**: Web display
- **PNG**: Lossless compression
- **TIFF**: High quality
- **BMP**: Windows bitmap
- **NIFTI**: Neuroimaging

#### Archive Formats
- **ZIP**: Compressed archive
- **TAR**: Unix archive
- **RAR**: WinRAR format

### 2. Media Creation

#### CD/DVD Burning
```javascript
// Create DICOM-CD
fetch('/studies/{study-id}/media', {
    method: 'POST',
    headers: {'Content-Type': 'application/json'},
    body: JSON.stringify({
        type: 'dicom-cd',
        format: 'iso',
        includeViewer: true
    })
});
```

#### USB Drive Creation
```javascript
// Create DICOM-USB
const usbExport = {
    studies: ['study-1', 'study-2'],
    format: 'dicom-usb',
    viewer: 'orthanc-viewer',
    metadata: true
};
```

### 3. Sharing Options

#### Email Export
```javascript
// Export via email
const emailExport = {
    to: 'doctor@hospital.com',
    subject: 'Patient Study - John Doe',
    body: 'Please find attached the requested study',
    studies: ['study-123'],
    format: 'dicom-zip'
};

fetch('/tools/email-export', {
    method: 'POST',
    headers: {'Content-Type': 'application/json'},
    body: JSON.stringify(emailExport)
});
```

#### Cloud Storage
```javascript
// Upload to cloud
const cloudUpload = {
    provider: 'aws',
    bucket: 'orthanc-storage',
    studies: ['study-123'],
    acl: 'private'
};

fetch('/tools/cloud-upload', {
    method: 'POST',
    headers: {'Content-Type': 'application/json'},
    body: JSON.stringify(cloudUpload)
});
```

#### PACS Transfer
```javascript
// Transfer to PACS
const pacsTransfer = {
    aet: 'REMOTE-PACS',
    studies: ['study-123'],
    priority: 'normal',
    compress: true
};

fetch('/tools/pacs-transfer', {
    method: 'POST',
    headers: {'Content-Type': 'application/json'},
    body: JSON.stringify(pacsTransfer)
});
```

---

## Search dan Filter

### 1. Advanced Search

#### Search Interface
```javascript
// Search builder
const searchBuilder = new SearchBuilder({
    // Available fields
    fields: [
        'PatientName',
        'PatientID',
        'StudyDate',
        'StudyDescription',
        'Modality',
        'AccessionNumber'
    ],
    
    // Operators
    operators: [
        'equals',
        'contains',
        'starts-with',
        'ends-with',
        'greater-than',
        'less-than',
        'between'
    ],
    
    // Logical operators
    logical: ['AND', 'OR', 'NOT']
});
```

#### Search Examples

##### Simple Search
```javascript
// Patient name search
const criteria = {
    field: 'PatientName',
    operator: 'contains',
    value: 'John'
};
```

##### Complex Search
```javascript
// Multiple criteria
const searchQuery = {
    logical: 'AND',
    conditions: [
        {
            field: 'PatientName',
            operator: 'contains',
            value: 'John'
        },
        {
            logical: 'OR',
            conditions: [
                {
                    field: 'Modality',
                    operator: 'equals',
                    value: 'CT'
                },
                {
                    field: 'Modality',
                    operator: 'equals',
                    value: 'MRI'
                }
            ]
        }
    ]
};
```

### 2. Saved Searches

#### Create Saved Search
```javascript
// Save search template
const savedSearch = {
    name: 'Emergency CT Scans',
    description: 'All CT scans from emergency department',
    criteria: {
        // Search criteria here
    },
    shared: true,
    schedule: {
        enabled: true,
        frequency: 'daily',
        recipients: ['radiologist@hospital.com']
    }
};

fetch('/tools/saved-searches', {
    method: 'POST',
    headers: {'Content-Type': 'application/json'},
    body: JSON.stringify(savedSearch)
});
```

#### Apply Saved Search
```javascript
// Execute saved search
fetch('/tools/saved-searches/emergency-ct/run')
    .then(response => response.json())
    .then(data => displayResults(data));
```

### 3. Filter Interface

#### Quick Filters
- **Date Range**: Today, Last 7 days, Last 30 days
- **Modality**: All, CT, MRI, X-Ray, Ultrasound
- **Status**: All, New, Reviewed, Archived
- **Priority**: Normal, Urgent, STAT

#### Custom Filters
```javascript
// Create custom filter
const customFilter = {
    name: 'Cardiac Studies',
    icon: 'heart',
    conditions: {
        StudyDescription: 'Cardiac*',
        Modality: ['CT', 'MR'],
        StudyDate: {
            from: '2024-01-01',
            to: '2024-12-31'
        }
    }
};
```

---

## Tools Utilities

### 1. DICOM Utilities

#### DICOM Anonymizer
```javascript
// Anonymize study
const anonymizationOptions = {
    removeTags: [
        'PatientName',
        'PatientID',
        'StudyInstanceUID',
        'SeriesInstanceUID'
    ],
    replaceTags: {
        'PatientName': 'ANONYMOUS',
        'PatientID': 'ANON_' + Math.random().toString(36).substr(2, 9),
        'AccessionNumber': 'ACC_' + Date.now()
    },
    keepUIDs: false
};

fetch('/tools/anonymize', {
    method: 'POST',
    headers: {'Content-Type': 'application/json'},
    body: JSON.stringify({
        resources: ['study-123'],
        options: anonymizationOptions
    })
});
```

#### DICOM Validator
```javascript
// Validate DICOM files
const validationOptions = {
    checkSyntax: true,
    checkHeaders: true,
    checkPixelData: true,
    strictMode: false
};

fetch('/tools/validate', {
    method: 'POST',
    headers: {'Content-Type': 'application/json'},
    body: JSON.stringify({
        files: ['instance-1', 'instance-2'],
        options: validationOptions
    })
});
```

### 2. Reconstruction Tools

#### Series Reconstruction
```javascript
// Reconstruct series
const reconstructionOptions = {
    type: 'corrected',
    method: 'slice-by-slice',
    interpolation: 'cubic',
    smoothing: true,
    autoOrient: true
};

fetch('/series/{series-id}/reconstruct', {
    method: 'POST',
    headers: {'Content-Type': 'application/json'},
    body: JSON.stringify(reconstructionOptions)
});
```

#### MIP/MPR Reconstruction
```javascript
// Create MIP
const mipOptions = {
    method: 'maximum',
    threshold: -1000,
    resolution: 'original'
};

fetch('/series/{series-id}/mip', {
    method: 'POST',
    headers: {'Content-Type': 'application/json'},
    body: JSON.stringify(mipOptions)
});
```

### 3. Reporting Tools

#### Structured Reporting
```javascript
// Generate SR report
const srTemplate = {
    type: 'StructuredReport',
    template: 'RadiologyReport',
    data: {
        findings: 'Normal chest X-ray',
        impression: 'No acute abnormality',
        recommendations: 'Follow up in 1 year'
    },
    author: 'Dr. Smith',
    date: new Date().toISOString()
};

fetch('/tools/generate-sr', {
    method: 'POST',
    headers: {'Content-Type': 'application/json'},
    body: JSON.stringify(srTemplate)
});
```

#### Report Export
```javascript
// Export report
const reportExport = {
    format: 'pdf',
    includeImages: true,
    template: 'professional',
    watermark: 'CONFIDENTIAL'
};

fetch('/tools/export-report', {
    method: 'POST',
    headers: {'Content-Type': 'application/json'},
    body: JSON.stringify(reportExport)
});
```

---

## Workflows Otomatis

### 1. Lua Scripting

#### Simple Workflow
```lua
-- Auto-anonymize incoming studies
function OnIncomingStudy(studyId)
    -- Get study details
    local study = OrthancApiClient:GetStudy(studyId)
    
    -- Check if study needs anonymization
    if study.Tags.PatientID:find("^P") then
        -- Anonymize the study
        OrthancApiClient:AnonymizeStudy(studyId)
        
        -- Log the action
        OrthancApiClient:Log("Anonymized study: " .. studyId)
        
        -- Notify radiologist
        OrthancApiClient:SendEmail({
            to = "radiologist@hospital.com",
            subject = "New anonymized study",
            body = "Study " .. studyId .. " has been anonymized"
        })
    end
end
```

#### Complex Workflow
```lua
-- Patient registration workflow
function OnInstanceReceived(instanceId)
    local instance = OrthancApiClient:GetInstance(instanceId)
    local study = OrthancApiClient:GetStudy(instance.ParentStudy)
    
    -- Check if patient exists
    local patient = OrthancApiClient:FindPatient({
        PatientID = instance.Tags.PatientID
    })
    
    if not patient then
        -- Create new patient
        patient = OrthancApiClient:CreatePatient({
            PatientName = instance.Tags.PatientName,
            PatientID = instance.Tags.PatientID,
            BirthDate = instance.Tags.BirthDate
        })
        
        -- Assign to study
        OrthancApiClient:SetStudyPatient(study.Id, patient.Id)
        
        -- Create patient record in EMR
        OrthancApiClient:CreateEMRRecord(patient.Id)
    end
    
    -- Assign study to radiologist
    OrthancApiClient:AssignStudy(study.Id, "radiologist@hospital.com")
    
    -- Add to PACS queue
    OrthancApiClient:AddToPACSQueue(study.Id)
end
```

### 2. Event Handlers

#### Change Events
```javascript
// Listen for changes
const socket = new WebSocket('ws://localhost:8042/ws');

socket.onmessage = function(event) {
    const change = JSON.parse(event.data);
    
    switch(change.changeType) {
        case 'NewInstance':
            handleNewInstance(change.resource);
            break;
        case 'StableStudy':
            handleStableStudy(change.resource);
            break;
        case 'DeletedResource':
            handleDeletedResource(change.resource);
            break;
    }
};
```

#### Custom Events
```javascript
// Trigger custom event
function triggerCustomEvent(eventType, data) {
    fetch('/events', {
        method: 'POST',
        headers: {'Content-Type': 'application/json'},
        body: JSON.stringify({
            type: eventType,
            data: data,
            timestamp: new Date().toISOString()
        })
    });
}
```

### 3. Scheduled Tasks

#### Scheduled Reports
```javascript
// Create scheduled report
const scheduledReport = {
    name: 'Daily Summary',
    schedule: {
        type: 'cron',
        expression: '0 8 * * *'  // Every day at 8 AM
    },
    report: {
        type: 'statistics',
        format: 'pdf'
    },
    recipients: ['admin@hospital.com']
};

fetch('/tools/schedule', {
    method: 'POST',
    headers: {'Content-Type': 'application/json'},
    body: JSON.stringify(scheduledReport)
});
```

#### Cleanup Tasks
```javascript
// Schedule cleanup
const cleanupTask = {
    name: 'Cleanup Old Studies',
    schedule: {
        type: 'daily',
        time: '02:00'
    },
    action: {
        type: 'delete',
        criteria: {
            StudyDate: {
                before: '2023-01-01',
                modality: ['XRAY', 'MG']
            }
        }
    }
};
```

---

## Tips dan Best Practices

### 1. Performance Tips

#### Caching Strategy
- Enable browser caching
- Use CDN for static resources
- Implement lazy loading
- Optimize image compression

```javascript
// Enable viewer caching
const viewer = new OrthancViewer({
    cache: true,
    cacheSize: 1000,
    preload: true
});
```

#### Network Optimization
- Use HTTP/2
- Implement compression
- Minimize API calls
- Use Web Workers

```javascript
// Batch API calls
async function batchFetch(ids) {
    const promises = ids.map(id => 
        fetch(`/instances/${id}`).then(r => r.json())
    );
    return Promise.all(promises);
}
```

### 2. Security Best Practices

#### Authentication
```javascript
// Implement token refresh
let authToken = localStorage.getItem('authToken');

async function refreshToken() {
    const response = await fetch('/refresh-token', {
        method: 'POST',
        headers: {
            'Authorization': `Bearer ${authToken}`
        }
    });
    
    const data = await response.json();
    authToken = data.token;
    localStorage.setItem('authToken', authToken);
}
```

#### Input Validation
```javascript
// Validate search input
function validateSearchInput(value) {
    if (!value || value.length < 3) {
        throw new Error('Search term must be at least 3 characters');
    }
    
    // DICOM tag validation
    if (value.includes('\\')) {
        // Contains escape sequences
        value = value.replace(/\\/g, '\\\\');
    }
    
    return value;
}
```

### 3. Accessibility

#### Screen Reader Support
```html
<!-- Accessible viewer controls -->
<button 
    aria-label="Increase window width"
    onclick="adjustWindowWidth(10)"
    title="Increase window width">
    +
</button>
```

#### Keyboard Navigation
```javascript
// Keyboard shortcuts
document.addEventListener('keydown', (e) => {
    switch(e.key) {
        case 'ArrowUp':
            adjustWindowLevel(10);
            break;
        case 'ArrowDown':
            adjustWindowLevel(-10);
            break;
        case 'ArrowLeft':
            adjustWindowWidth(-10);
            break;
        case 'ArrowRight':
            adjustWindowWidth(10);
            break;
    }
});
```

### 4. Error Handling

#### User-Friendly Errors
```javascript
// Error handling
async function loadResource(id) {
    try {
        const response = await fetch(`/resources/${id}`);
        
        if (!response.ok) {
            throw new Error(`HTTP error! status: ${response.status}`);
        }
        
        return await response.json();
    } catch (error) {
        showError(`Failed to load resource: ${error.message}`);
        // Fallback or retry
        return loadFallbackResource(id);
    }
}
```

#### Logging
```javascript
// Implement logging
const logger = {
    info: (message) => console.log('[INFO]', message),
    warn: (message) => console.warn('[WARN]', message),
    error: (error) => console.error('[ERROR]', error),
    
    // Structured logging
    logEvent: (event) => {
        const log = {
            timestamp: new Date().toISOString(),
            level: event.level,
            message: event.message,
            data: event.data
        };
        sendToLogServer(log);
    }
};
```

### 5. Integration Patterns

#### PACS Integration
```javascript
// Integrate with PACS
const pacsIntegration = {
    // Connect to PACS
    connect: async () => {
        const response = await fetch('/pacs/connect', {
            method: 'POST',
            body: JSON.stringify({
                aet: 'ORTHANC',
                address: '192.168.1.100',
                port: 4242
            })
        });
        return await response.json();
    },
    
    // Query PACS
    query: async (criteria) => {
        const response = await fetch('/pacs/query', {
            method: 'POST',
            body: JSON.stringify(criteria)
        });
        return await response.json();
    }
};
```

#### EMR Integration
```javascript
// EMR integration
const emrIntegration = {
    // Send study to EMR
    sendStudy: async (studyId, patientData) => {
        const response = await fetch('/emr/study', {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json',
                'Authorization': `Bearer ${getAuthToken()}`
            },
            body: JSON.stringify({
                studyId: studyId,
                patient: patientData
            })
        });
        return await response.json();
    },
    
    // Get EMR data
    getEMRData: async (patientId) => {
        const response = await fetch(`/emr/patient/${patientId}`);
        return await response.json();
    }
};
```

### 6. Development Tips

#### Modular Architecture
```javascript
// Modular viewer components
const OrthancViewer = {
    // Core functionality
    core: {
        loadStudy: loadStudy,
        renderImage: renderImage,
        applyWindowLevel: applyWindowLevel
    },
    
    // Extensions
    extensions: {
        measurements: MeasurementExtension,
        annotations: AnnotationExtension,
        tools: ToolsExtension
    },
    
    // Initialize
    init: function(config) {
        // Initialize core
        this.core.init(config);
        
        // Load extensions
        Object.keys(this.extensions).forEach(ext => {
            if (config.extensions && config.extensions.includes(ext)) {
                this.extensions[ext].init(this.core);
            }
        });
    }
};
```

#### Testing
```javascript
// Unit tests
describe('OrthancViewer', () => {
    beforeEach(() => {
        viewer = new OrthancViewer({
            element: document.createElement('div')
        });
    });
    
    test('should load study', async () => {
        const studyId = 'study-123';
        await viewer.loadStudy(studyId);
        expect(viewer.currentStudy).toBe(studyId);
    });
    
    test('should apply window level', () => {
        viewer.applyWindowLevel({width: 400, level: 40});
        expect(viewer.windowWidth).toBe(400);
        expect(viewer.windowLevel).toBe(40);
    });
});
```

---

## Resources

### Documentation
- [Orthanc Documentation](https://orthanc.uclouvain.be/book/)
- [DICOM Standard](https://medical.nema.org/)
- [Web Viewer Documentation](https://orthanc.uclouvain.be/book/users/web viewer.html)

### Tools
- [DICOM Toolkit](https://www.dcm4che.org/)
- [Cornerstone.js](https://cornerstonejs.org/)
- [DICOM Anonymizer](https://github.com/microsoft/ML-for-Health-on-Azure/tree/main/Anonymize-DICOM)

### Community
- [Orthanc Forum](https://www.orthanc-server.com/forum/)
- [GitHub Repository](https://github.com/jodogne/orthanc-server)
- [Stack Overflow](https://stackoverflow.com/questions/tagged/orthanc)

---

**Note**: Tutorial ini mencakup penggunaan lengkap aplikasi web Orthanc. Pastikan untuk selalu merujuk ke dokumentasi resmi untuk versi terbaru dan informasi terkini.# Panduan Lengkap Orthanc untuk Pemula: Dari Perencanaan hingga Deployment Online

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
---

## 🎉 Kesimpulan

Selamat! Anda telah mencapai akhir dari panduan lengkap Orthanc. Dokumentasi ini dirancang untuk membantu Anda dari awal hingga berhasil mengoperasikan Orthanc server, baik secara lokal maupun online.

### 🎯 Apa yang Telah Dibahas

✅ **Perencanaan Sistem** - Hardware, software, dan resource requirements  
✅ **Setup Dasar** - Docker, konfigurasi, dan persiapan lingkungan  
✅ **Jaringan** - Konfigurasi lokal, Cloudflare Tunnel, dan keamanan  
✅ **API** - REST API lengkap dengan contoh penggunaan  
✅ **Plugin** - Cara memasang, mengkonfigurasi, dan mengelola plugin  
✅ **PACS** - Integrasi dengan sistem PACS dan DICOM networking  
✅ **Konfigurasi Inti** - Pengaturan esensial Orthanc dan database  
✅ **Akses Lokal** - Cara mengakses Orthanc di jaringan lokal  
✅ **Akses Online** - Setup akses remote dengan aman dan terjamin  
✅ **Troubleshooting** - Solusi masalah umum dan tips pemecahan  
✅ **Referensi** - Dokumentasi detail, cheat sheet, dan panduan lanjutan  
✅ **Web Interface** - Tutorial lengkap penggunaan aplikasi web  
✅ **Overview Pemula** - Ringkasan lengkap untuk pemula  

### 📊 Statistik Dokumentasi

- **Total Bagian**: 15 panduan terstruktur
- **Total Baris**: ~11,800+
- **Contoh Kode**: 100+ contoh praktis
- **Perintah Terminal**: 200+ command siap pakai
- **Konfigurasi**: 50+ contoh konfigurasi
- **Bahasa**: Bahasa Indonesia penuh
- **Target**: Pemula hingga administrator sistem

### 🚀 Langkah Selanjutnya Setelah Membaca Panduan Ini

#### Untuk Pemula
1. **Review persyaratan sistem** - Pastikan memenuhi requirements
2. **Siapkan semua tools** - Install Docker dan software pendukung
3. **Ikuti urutan setup** - Mulai dari 01 dan lanjutkan secara berurutan
4. **Test setiap langkah** - Verifikasi berhasil sebelum lanjut
5. **Tanya bila bingung** - Jangan ragu mencari bantuan

#### Untuk Administrator
1. **Planning deployment** - Tentukan skala dan kebutuhan produksi
2. **Setup monitoring** - Implementasi monitoring dan alerting
3. **Konfigurasi security** - Aktifkan semua keamanan yang disarankan
4. **Document changes** - Catat semua perubahan dari default
5. **Plan maintenance** - Jadwalkan backup dan maintenance rutin

#### Untuk Developer
1. **Eksplorasi API** - Coba semua endpoint dan fungsionalitas
2. **Pelajari plugin** - Kembangkan custom plugin sesuai kebutuhan
3. **Integrasikan sistem** - Hubungkan Orthanc dengan aplikasi lain
4. **Optimasi performa** - Tuning dan optimization sesuai workload
5. **Contribute** - Berkontribusi ke komunitas Orthanc

---

## 📞 Sumber Tambahan & Dukungan

### Dokumentasi Resmi
- **Orthanc Book**: https://orthanc.uclouvain.be/book/
- **Plugin Repository**: https://orthanc.uclouvain.be/plugins/
- **API Documentation**: https://orthanc.uclouvain.be/book/users/rest.html

### Komunitas & Forum
- **Orthanc Forum**: https://www.orthanc-server.com/forum/
- **GitHub Issues**: https://github.com/jodogne/orthanc-server/issues
- **Stack Overflow**: Tag `orthanc` dan `dicom`

### Resources Tambahan
- **DICOM Standard**: https://medical.nema.org/
- **DICOM conformance**: https://www.dclunie.com/
- **Medical Imaging**: https://radiopaedia.org/

---

## 🔗 Referensi Cepat

### Perintah Penting
```bash
# Start Orthanc
docker-compose up -d

# Check status
docker-compose ps

# View logs
docker-compose logs -f orthanc

# Test API
curl -s http://localhost:8042/system

# Upload DICOM
curl -X POST -T file.dcm http://localhost:8042/studies
```

### Port Default
- **HTTP/REST API**: 8042
- **DICOM**: 4242
- **HTTPS**: 8443

### File Lokasi Penting
- **Docker Compose**: ./docker-compose.yml
- **Konfigurasi**: ./orthanc.json
- **Data**: ./orthanc-data/
- **Logs**: /var/log/orthanc/ (default)

---

## 🛡️ Checklist Sebelum Produksi

- [ ] Semua requirements sistem terpenuhi
- [ ] Docker dan Docker Compose terinstall
- [ ] Konfigurasi jaringan selesai
- [ ] Firewall terkonfigurasi dengan benar
- [ ] Authentication diaktifkan
- [ ] SSL/TLS dikonfigurasi untuk produksi
- [ ] Backup strategy diimplementasi
- [ ] Monitoring diatur
- [ ] Semua fitur utama diuji
- [ ] Dokumentasi user guide dibuat
- [ ] Tim terlatih menggunakan sistem
- [ ] Maintenance schedule ditetapkan
- [ ] Disaster recovery plan disiapkan

---

## 🎊 Selamat Menggunakan Orthanc!

Anda sekarang memiliki panduan lengkap untuk:
- ✅ Install dan konfigurasi Orthanc
- ✅ Akses Orthanc dari mana saja
- ✅ Integrasi dengan sistem lain
- ✅ Mengelola data medis dengan efisien
- ✅ Memastikan keamanan dan ketersediaan
- ✅ Troubleshoot masalah yang muncul

Terima kasih telah menggunakan panduan ini. Semoga bermanfaat untuk perjalanan Anda dalam mengelola dan menggunakan Orthanc DICOM Server!

---

**Dokumentasi ini dibuat untuk membantu pemula hingga administrator sistem menguasai Orthanc dari awal hingga menjadi ahli.**

**Versi**: 1.0  
**Tanggal**: 13 April 2024  
**Bahasa**: Bahasa Indonesia  
**Lisensi**: Dokumentasi ini dapat digunakan dan dimodifikasi sesuai kebutuhan.

