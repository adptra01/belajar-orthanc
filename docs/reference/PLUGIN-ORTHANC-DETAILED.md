# Dokumentasi Lengkap Plugin Orthanc

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

> **Tutorial web interface yang lebih lengkap** (termasuk dashboard, navigasi, manajemen pasien/studi/series, viewer DICOM, export/sharing, search, workflows) ada di [TUTORIAL-ORTHANC-WEB.md](TUTORIAL-ORTHANC-WEB.md).

Berikut fitur plugin-specific yang bisa diakses via web interface:

### Advanced Features via Plugin

#### Multi-Planar Reconstruction (via Web Viewer plugin)
1. Open series viewer
2. Enable MPR mode
3. Adjust window/level
4. Create measurements
5. Export measurements

#### 3D Reconstruction (via Web Viewer plugin)
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

### Bulk Operations (via Plugin API)

#### Batch Export
```bash
curl -X POST "http://localhost:8042/tools/batch-export" \
  -H "Content-Type: application/json" \
  -d '{"Resources": ["study-1", "study-2"], "Format": "dicom", "Compression": "zip"}'
```

#### Batch Anonymization
```bash
curl -X POST "http://localhost:8042/tools/batch-anonymize" \
  -H "Content-Type: application/json" \
  -d '{"Resources": ["study-1", "study-2"], "RemoveTags": ["PatientName", "PatientID"], "AddTags": {"PatientName": "ANONYMOUS"}}'
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

**Note**: Dokumentasi ini mencakup berbagai aspek dari penggunaan plugin Orthanc. Pastikan untuk merujuk ke dokumentasi resmi untuk versi terbaru dan informasi spesifik tentang setiap plugin.