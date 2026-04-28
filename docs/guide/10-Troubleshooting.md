# 10. Troubleshooting & Langkah Selanjutnya

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

**🎉 Selamat! Anda telah menyelesaikan panduan lengkap setup Orthanc. Sistem Anda siap untuk produksi!**