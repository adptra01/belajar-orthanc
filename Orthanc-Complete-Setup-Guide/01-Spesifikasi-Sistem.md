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

**🎯 Selanjutnya**: [02-Alat dan Perlengkapan](./02-Alat-dan-Perlengkapan.md) - Siapkan semua tools yang dibutuhkan untuk instalasi Orthanc!