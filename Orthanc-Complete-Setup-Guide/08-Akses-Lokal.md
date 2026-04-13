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

**🎯 Selanjutnya**: [09-Akses Online/Remote](./09-Akses-Online-Remote.md) - Pelajari cara setup akses online dengan aman menggunakan Cloudflare Tunnel!