# 09. Cara Akses Orthanc Online/Remote

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

**🎯 Selanjutnya**: [10-Troubleshooting](./10-Troubleshooting.md) - Pelajari solusi masalah umum dan langkah selanjutnya setelah deployment berhasil!