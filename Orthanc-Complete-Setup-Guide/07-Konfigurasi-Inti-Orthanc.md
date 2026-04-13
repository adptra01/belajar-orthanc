# 07. Konfigurasi Inti Orthanc

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
