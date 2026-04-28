# 02. Alat dan Perlengkapan Checklist

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

**🎯 Selanjutnya**: [03-Konfigurasi Jaringan](./03-Konfigurasi-Jaringan.md) - Setup jaringan dan konfigurasi akses remote dengan Cloudflare Tunnel!