# 06. Konfigurasi PACS Integration

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

**🎯 Selanjutnya**: [07-Konfigurasi Inti Orthanc](./07-Konfigurasi-Inti-Orthanc.md) - Pelajari konfigurasi utama dan pengaturan database Orthanc!