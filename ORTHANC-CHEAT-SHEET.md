# Orthanc Cheat Sheet - Quick Reference

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

*Note: This cheat sheet provides quick reference commands and configurations. Always refer to official documentation for complete information.*