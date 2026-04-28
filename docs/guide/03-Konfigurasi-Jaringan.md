# 03. Konfigurasi Jaringan

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

**🎯 Selanjutnya**: [04-Dokumentasi API](./04-Dokumentasi-API.md) - Pelajari cara menggunakan REST API Orthanc untuk operasi data dan integrasi!