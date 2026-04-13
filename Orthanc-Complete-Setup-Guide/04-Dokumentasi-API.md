# 04. Dokumentasi API Orthanc

## 📋 Apa yang akan Anda Pelajari

- Pengenalan REST API Orthanc
- Format dan struktur response
- Authentication dan authorization
- Endpoints untuk patients, studies, series, instances
- Contoh penggunaan curl dan JavaScript
- Error handling dan debugging

---

## 📡 Pengenalan REST API

### What is REST API?
REST (Representational State Transfer) API adalah arsitektur web untuk komunikasi antar aplikasi. Orthanc menggunakan REST API untuk:

- **Retrieve data** (Get)
- **Create data** (Post)
- **Update data** (Put/Patch)
- **Delete data** (Delete)

### Base URLs
```yaml
Local: http://localhost:8042
Remote: https://orthanc.yourdomain.com
API Explorer: http://localhost:8042/apidocs
```

### Format Response
- **JSON**: Default format untuk API response
- **XML**: Tersedia dengan menambahkan `.xml` ke URL
- **Raw**: Dapatkan file mentah (DICOM)

---

## 🔐 Authentication

### Basic Authentication (Disabled by default)
```bash
curl -u admin:password http://localhost:8042/system
```

### Token-based Authentication
```json
// Login (jika authentication diaktifkan)
curl -X POST http://localhost:8042/login \
  -H "Content-Type: application/json" \
  -d '{"username": "admin", "password": "password"}'

// Response:
{
  "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "expires": "2024-12-31T23:59:59Z"
}
```

### Using Auth Token
```bash
curl -H "Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..." \
  http://localhost:8042/system
```

---

## 📊 System API

### Get System Information
```bash
# Basic system info
curl http://localhost:8042/system

# Specific field
curl http://localhost:8042/system | jq '.Name'
curl http://localhost:8042/system | jq '.Version'
```

### Response Format
```json
{
  "Name": "Orthanc (DICOM Server)",
  "Version": "1.12.0",
  "ApiVersion": 14,
  "GlobalProperty": false,
  "OrthancId": "main",
  "DefaultEncoding": "ExplicitVRLittleEndian",
  "StorageDirectory": "/var/lib/orthanc/db",
  "IndexDirectory": "/var/lib/orthanc/db"
}
```

### Changes API
```bash
# Get recent changes
curl "http://localhost:8042/changes?since=0&limit=100"

# Filter by change type
curl "http://localhost:8042/changes?since=0&limit=100&filter=NewInstance"

# Format options
curl "http://localhost:8042/changes?expand=true"
```

### Statistics API
```bash
# Get statistics
curl http://localhost:8042/tools/statistics

# Specific time range
curl "http://localhost:8042/tools/statistics?since=2024-01-01&until=2024-12-31"

# Format as JSON
curl -H "Accept: application/json" http://localhost:8042/tools/statistics
```

---

## 👥 Patients API

### List All Patients
```bash
# Basic list
curl http://localhost:8042/patients

# With pagination
curl "http://localhost:8042/patients?limit=10&skip=0"

# Expand patient info
curl "http://localhost:8042/patients?expand=true&limit=100"

# Search by ID
curl "http://localhost:8042/patients?expand=true&limit=100" | \
  jq '.[] | select(.ID | contains("PatientID"))'
```

### Get Specific Patient
```bash
curl http://localhost:8042/patients/<patient-id>

# Get patient with metadata
curl http://localhost:8042/patients/<patient-id>?expand=true

# JSON output example:
{
  "ID": "patient-123",
  "Path": "/patients/patient-123",
  "IsStable": true,
  "MainDicomTags": {
    "PatientName": "John Doe",
    "PatientID": "P001234",
    "BirthDate": "19700101",
    "Sex": "M"
  }
}
```

### Get Patient Studies
```bash
curl http://localhost:8042/patients/<patient-id>/studies

# Count studies for patient
curl http://localhost:8042/patients/<patient-id>/studies | jq 'length'
```

### Find Patient
```bash
# Find by patient ID
curl "http://localhost:8042/patients?expand=true" | \
  jq '.[] | select(.MainDicomTags.PatientID == "P001234")'

# Find by patient name
curl "http://localhost:8042/patients?expand=true" | \
  jq '.[] | select(.MainDicomTags.PatientName | contains("John"))'

# Advanced search
curl -X POST http://localhost:8042/patients/lookup \
  -H "Content-Type: application/json" \
  -d '{"Level": "Patient", "Query": {"PatientName": "John*"}}'
```

---

## 🏥 Studies API

### List All Studies
```bash
# Basic list
curl http://localhost:8042/studies

# With pagination
curl "http://localhost:8042/studies?limit=20&skip=0"

# With metadata
curl "http://localhost:8042/studies?expand=true"

# Filter by date
curl "http://localhost:8042/studies?date=20240101-20241231"

# Filter by modality
curl "http://localhost:8042/studies?modality=CT"
```

### Get Specific Study
```bash
curl http://localhost:8042/studies/<study-id>

# With metadata
curl http://localhost:8042/studies/<study-id>?expand=true

# Response format:
{
  "ID": "study-456",
  "Path": "/studies/study-456",
  "ParentPatient": "patient-123",
  "IsStable": true,
  "MainDicomTags": {
    "StudyDate": "20240101",
    "StudyTime": "120000",
    "StudyDescription": "CT CHEST",
    "AccessionNumber": "ACC123",
    "ReferringPhysicianName": "Dr. Smith"
  },
  "Resources": {
    "Series": ["series-1", "series-2"]
  }
}
```

### Get Study Series
```bash
curl http://localhost:8042/studies/<study-id>/series

# Get series count
curl http://localhost:8042/studies/<study-id>/series | jq 'length'
```

### Study Operations
```bash
# Export study as ZIP
curl -X POST http://localhost:8042/studies/<study-id>/archive \
  -H "Content-Type: application/json" \
  -d '{"Format": "zip"}'

# Export study as directory
curl -X POST http://localhost:8042/studies/<study-id>/archive \
  -H "Content-Type: application/json" \
  -d '{"Format": "dir"}'

# Anonymize study
curl -X POST http://localhost:8042/studies/<study-id>/anonymize \
  -H "Content-Type: application/json" \
  -d '{"ReplaceTags": {"PatientName": "ANONYMOUS"}}'

# Delete study
curl -X DELETE http://localhost:8042/studies/<study-id>
```

---

## 🔬 Series API

### List All Series
```bash
# Basic list
curl http://localhost:8042/series

# With pagination
curl "http://localhost:8042/series?limit=50&skip=0"

# With metadata
curl "http://localhost:8042/series?expand=true"

# Filter by modality
curl "http://localhost:8042/series?modality=MRI"

# Filter by body part
curl "http://localhost:8042/series?body-part-exam=CHEST"
```

### Get Specific Series
```bash
curl http://localhost:8042/series/<series-id>

# With full metadata
curl http://localhost:8042/series/<series-id>?expand=true

# Response:
{
  "ID": "series-789",
  "Path": "/series/series-789",
  "ParentStudy": "study-456",
  "IsStable": true,
  "MainDicomTags": {
    "SeriesDescription": "AXIAL T1",
    "Modality": "MR",
    "SeriesNumber": "1",
    "NumberOfSeriesInstances": "20"
  },
  "Instances": ["instance-1", "instance-2", ...]
}
```

### Get Series Instances
```bash
curl http://localhost:8042/series/<series-id>/instances

# Get instance count
curl http://localhost:8042/series/<series-id>/instances | jq 'length'
```

### Series Operations
```bash
# Reconstruct series (MPR, 3D, etc.)
curl -X POST http://localhost:8042/series/<series-id>/reconstruct \
  -H "Content-Type: application/json" \
  -d '{"Type": "corrected"}'

# Export series
curl -X POST http://localhost:8042/series/<series-id>/archive \
  -H "Content-Type: application/json" \
  -d '{"Format": "zip"}'

# Anonymize series
curl -X POST http://localhost:8042/series/<series-id>/anonymize

# Delete series
curl -X DELETE http://localhost:8042/series/<series-id>
```

---

## 🖼️ Instances API

### List All Instances
```bash
# Basic list
curl http://localhost:8042/instances

# With pagination
curl "http://localhost:8042/instances?limit=100&skip=0"

# With metadata
curl "http://localhost:8042/instances?expand=true"

# Filter by date
curl "http://localhost:8042/instances?date=20240101-20241231"
```

### Get Specific Instance
```bash
curl http://localhost:8042/instances/<instance-id>

# With full metadata
curl http://localhost:8042/instances/<instance-id>?expand=true

# Response:
{
  "ID": "instance-999",
  "Path": "/instances/instance-999",
  "ParentSeries": "series-789",
  "ParentStudy": "study-456",
  "ParentPatient": "patient-123",
  "IsStable": true,
  "MainDicomTags": {
    "SOPClassUID": "1.2.840.10008.5.1.4.1.1.2",
    "SOPInstanceUID": "1.2.3.4.5.6.7.8.9.0",
    "InstanceNumber": "1",
    "ImageType": "ORIGINAL\\PRIMARY\\AXIAL"
  }
}
```

### Get Instance File
```bash
# Get DICOM file
curl http://localhost:8042/instances/<instance-id>/file -o dicom_file.dcm

# Get file info
curl -I http://localhost:8042/instances/<instance-id>/file

# Get as PNG
curl http://localhost:8042/instances/<instance-id>/file?export=png
```

### Get Instance Metadata
```bash
# Get all metadata
curl http://localhost:8042/instances/<instance-id>/metadata

# Get specific tag
curl http://localhost:8042/instances/<instance-id>/metadata/0010,0010

# DICOM tag format:
# Group,Element (e.g., 0010,0010 = Patient Name)
```

### Instance Operations
```bash
# Anonymize instance
curl -X POST http://localhost:8042/instances/<instance-id>/anonymize \
  -H "Content-Type: application/json" \
  -d '{"RemoveTags": ["0010,0010"], "ReplaceTags": {"PatientName": "ANONYMOUS"}}'

# Delete instance
curl -X DELETE http://localhost:8042/instances/<instance-id>

# Convert instance
curl -X POST http://localhost:8042/instances/<instance-id>/convert \
  -H "Content-Type: application/json" \
  -d '{"Format": "png"}'
```

---

## 📤 Upload Operations

### Upload Single DICOM File
```bash
# Upload via curl
curl -X POST -T /path/to/file.dcm http://localhost:8042/studies

# Upload with progress
curl -X POST -T /path/to/large_file.dcm http://localhost:8042/studies
```

### Upload Multiple Files
```bash
#!/bin/bash
# upload-multiple.sh

STUDY_ID="study-123"
SERVER="http://localhost:8042"

for file in /path/to/dicom_files/*.dcm; do
    if [ -f "$file" ]; then
        echo "Uploading $file..."
        curl -X POST -T "$file" "$SERVER/studies"
        echo ""
    fi
done
```

### Upload from URL
```bash
# Download and upload in one command
curl -L https://example.com/file.dcm | \
  curl -X POST -T - http://localhost:8042/studies
```

---

## 🔍 Search API

### Simple Search
```bash
# Search patients
curl "http://localhost:8042/patients?expand=true" | \
  jq '.[] | select(.MainDicomTags.PatientName | test("John"))'

# Search studies
curl "http://localhost:8042/studies?expand=true" | \
  jq '.[] | select(.MainDicomTags.Modality == "CT")'

# Search by date range
curl "http://localhost:8042/studies?date=20240101-20240131"
```

### Advanced Search with POST
```bash
# Search studies with criteria
curl -X POST http://localhost:8042/studies/lookup \
  -H "Content-Type: application/json" \
  -d '{
    "Level": "Study",
    "Query": {
      "StudyDate": "20240101",
      "ModalitiesInStudy": ["CT", "MR"]
    }
  }'

# Find instances
curl -X POST http://localhost:8042/instances/lookup \
  -H "Content-Type: application/json" \
  -d '{
    "Level": "Instance",
    "Query": {
      "PatientName": "Doe*",
      "StudyDescription": "Chest*"
    }
  }'
```

### Search Templates
```json
// saved-search.json
{
  "name": "Emergency Studies",
  "query": {
    "Level": "Study",
    "Query": {
      "Priority": "E"
    }
  }
}

# Use saved template
curl -X POST http://localhost:8042/tools/saved-searches \
  -H "Content-Type: application/json" \
  -d @saved-search.json
```

---

## ⚙️ Configuration API

### Get Configuration
```bash
# Get all configuration
curl http://localhost:8042/system

# Get specific setting
curl http://localhost:8042/system | jq '.HttpPort'
```

### Update Configuration
```bash
# Update HTTP port
curl -X PUT http://localhost:8042/system \
  -H "Content-Type: application/json" \
  -d '{"HttpPort": 8043}'

# Enable compression
curl -X PUT http://localhost:8042/system \
  -H "Content-Type: application/json" \
  -d '{"HttpCompression": true}'
```

### Plugin Configuration
```bash
# Get plugin information
curl http://localhost:8042/system | jq '.Plugins'

# Enable/disable plugin
curl -X PUT http://localhost:8042/system \
  -H "Content-Type: application/json" \
  -d '{"LuaScripts": {"Enabled": true}}'
```

---

## 🛠️ Tools API

### DICOM Validation
```bash
# Validate DICOM file
curl -X POST http://localhost:8042/tools/validate \
  -H "Content-Type: application/json" \
  -d '{"Files": ["instance-1"], "CheckSyntax": true}'

# Response:
{
  "Valid": true,
  "Warnings": [],
  "Errors": []
}
```

### Statistics Tools
```bash
# Get storage statistics
curl http://localhost:8042/tools/statistics

# Get patient counts
curl http://localhost:8042/tools/statistics | jq '.Patients'

# Get modality distribution
curl http://localhost:8042/tools/statistics | jq '.Modalities'
```

### Export Tools
```bash
# Export as PDF
curl -X POST http://localhost:8042/tools/export-pdf \
  -H "Content-Type: application/json" \
  -d '{"Studies": ["study-1"], "Format": "A4"}'

# Create DICOM CD
curl -X POST http://localhost:8042/tools/create-media \
  -H "Content-Type: application/json" \
  -d '{"Type": "dicom-cd", "Studies": ["study-1"]}'
```

### Batch Operations
```bash
# Batch anonymize
curl -X POST http://localhost:8042/tools/batch-anonymize \
  -H "Content-Type: application/json" \
  -d '{"Resources": ["instance-1", "instance-2"], "ReplaceTags": {"PatientName": "ANONYMOUS"}}'

# Batch delete
curl -X POST http://localhost:8042/tools/batch-delete \
  -H "Content-Type: application/json" \
  -d '{"Resources": ["study-1", "study-2"]}'
```

---

## 💻 JavaScript API Examples

### Basic API Client
```javascript
// orthanc-client.js
class OrthancClient {
  constructor(baseUrl, token = null) {
    this.baseUrl = baseUrl;
    this.token = token;
  }

  async request(endpoint, options = {}) {
    const url = `${this.baseUrl}${endpoint}`;
    const headers = {
      'Content-Type': 'application/json',
      ...options.headers
    };

    if (this.token) {
      headers['Authorization'] = `Bearer ${this.token}`;
    }

    const response = await fetch(url, {
      ...options,
      headers
    });

    if (!response.ok) {
      throw new Error(`HTTP ${response.status}: ${response.statusText}`);
    }

    return response.json();
  }

  // Get system info
  async getSystem() {
    return this.request('/system');
  }

  // Get patients
  async getPatients(options = {}) {
    const params = new URLSearchParams(options);
    return this.request(`/patients?${params}`);
  }

  // Get patient studies
  async getPatientStudies(patientId) {
    return this.request(`/patients/${patientId}/studies`);
  }

  // Upload file
  async uploadFile(file, studyId) {
    const formData = new FormData();
    formData.append('file', file);

    const response = await fetch(`${this.baseUrl}/studies`, {
      method: 'POST',
      body: formData
    });

    return response.json();
  }
}

// Usage example
const client = new OrthancClient('http://localhost:8042');

// Get system info
client.getSystem().then(system => {
  console.log('System:', system.Name);
});

// Get patients
client.getPatients({expand: true, limit: 10}).then(patients => {
  console.log('Patients:', patients);
});
```

### React Component Example
```jsx
// OrthancViewer.jsx
import React, { useState, useEffect } from 'react';

const OrthancViewer = ({ baseUrl }) => {
  const [patients, setPatients] = useState([]);
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState(null);

  useEffect(() => {
    fetchPatients();
  }, [baseUrl]);

  const fetchPatients = async () => {
    setLoading(true);
    try {
      const response = await fetch(`${baseUrl}/patients?expand=true&limit=100`);
      const data = await response.json();
      setPatients(data);
    } catch (err) {
      setError(err.message);
    } finally {
      setLoading(false);
    }
  };

  const uploadFile = async (file) => {
    const formData = new FormData();
    formData.append('file', file);

    try {
      const response = await fetch(`${baseUrl}/studies`, {
        method: 'POST',
        body: formData
      });
      return await response.json();
    } catch (err) {
      throw err;
    }
  };

  return (
    <div>
      <h1>Orthanc Viewer</h1>
      
      {loading && <p>Loading...</p>}
      {error && <p>Error: {error}</p>}
      
      <div>
        <h2>Upload DICOM</h2>
        <input type="file" accept=".dcm" onChange={(e) => {
          if (e.target.files[0]) {
            uploadFile(e.target.files[0])
              .then(() => fetchPatients())
              .catch(err => setError(err.message));
          }
        }} />
      </div>

      <div>
        <h2>Patients ({patients.length})</h2>
        <ul>
          {patients.map(patient => (
            <li key={patient.ID}>
              {patient.MainDicomTags.PatientName} 
              ({patient.MainDicomTags.PatientID})
            </li>
          ))}
        </ul>
      </div>
    </div>
  );
};

export default OrthancViewer;
```

---

## 🔧 Error Handling

### Common HTTP Status Codes
```yaml
200 OK - Request successful
201 Created - Resource created
400 Bad Request - Invalid request
401 Unauthorized - Authentication required
403 Forbidden - Access denied
404 Not Found - Resource not found
500 Internal Server Error - Server error
503 Service Unavailable - Service down
```

### Error Response Format
```json
{
  "StatusCode": 400,
  "Status": "Bad Request",
  "Method": "GET",
  "URI": "/patients/invalid-id",
  "Details": "Unknown resource"
}
```

### Error Handling in JavaScript
```javascript
// Error handling wrapper
async function safeApiCall(endpoint, options = {}) {
  try {
    const response = await fetch(endpoint, options);
    
    if (!response.ok) {
      const error = await response.json();
      throw new Error(`[${error.StatusCode}] ${error.Status}: ${error.Details}`);
    }
    
    return await response.json();
  } catch (error) {
    console.error('API Error:', error);
    
    // User-friendly message
    let message = 'An error occurred';
    if (error.message.includes('401')) {
      message = 'Please login first';
    } else if (error.message.includes('404')) {
      message = 'Resource not found';
    }
    
    // Show to user
    alert(message);
    throw error;
  }
}

// Usage
safeApiCall('/patients')
  .then(data => console.log(data))
  .catch(error => console.error('Failed:', error));
```

### Retry Logic
```javascript
// Retry with exponential backoff
async function fetchWithRetry(url, options = {}, retries = 3) {
  const delay = (attempt) => Math.pow(2, attempt) * 1000;
  
  for (let attempt = 0; attempt < retries; attempt++) {
    try {
      const response = await fetch(url, options);
      if (!response.ok) throw new Error(`HTTP ${response.status}`);
      return await response.json();
    } catch (error) {
      if (attempt === retries - 1) throw error;
      console.log(`Retry ${attempt + 1}/${retries}...`);
      await new Promise(resolve => setTimeout(resolve, delay(attempt)));
    }
  }
}

// Usage
fetchWithRetry('/system')
  .then(system => console.log(system))
  .catch(error => console.error('Failed after retries:', error));
```

---

## 🔄 WebSockets (Real-time Updates)

### WebSocket Connection
```javascript
// Connect to Orthanc WebSocket
const ws = new WebSocket('ws://localhost:8042/ws');

ws.onopen = () => {
  console.log('Connected to Orthanc WebSocket');
};

ws.onmessage = (event) => {
  const change = JSON.parse(event.data);
  console.log('Change detected:', change);
  
  // Handle different change types
  switch (change.changeType) {
    case 'NewInstance':
      handleNewInstance(change.resource);
      break;
    case 'StableStudy':
      handleStableStudy(change.resource);
      break;
  }
};

ws.onerror = (error) => {
  console.error('WebSocket error:', error);
};

ws.onclose = () => {
  console.log('WebSocket closed');
};

// Close connection
// ws.close();
```

### WebSocket Event Types
```json
{
  "changeType": "NewInstance",
  "resourceType": "Instance",
  "resource": {
    "ID": "instance-123",
    "Path": "/instances/instance-123"
  },
  "date": "2024-01-01T12:00:00Z"
}
```

---

## 📊 API Rate Limiting

### Check Rate Limits
```bash
# Check current rate limit status
curl -I http://localhost:8042/system

# Look for headers like:
# X-RateLimit-Limit: 100
# X-RateLimit-Remaining: 95
# X-RateLimit-Reset: 1640995200
```

### Handle Rate Limits
```javascript
// Rate limiting helper
class RateLimiter {
  constructor(limit, windowMs) {
    this.limit = limit;
    this.windowMs = windowMs;
    this.requests = [];
  }

  async execute(fn) {
    const now = Date.now();
    
    // Remove old requests
    this.requests = this.requests.filter(time => now - time < this.windowMs);
    
    // Check if limit exceeded
    if (this.requests.length >= this.limit) {
      const waitTime = this.windowMs - (now - this.requests[0]);
      await new Promise(resolve => setTimeout(resolve, waitTime));
    }
    
    // Execute request
    const result = await fn();
    this.requests.push(now);
    
    return result;
  }
}

// Usage
const limiter = new RateLimiter(10, 1000); // 10 requests per second

limiter.execute(() => fetch('/patients'))
  .then(data => console.log(data));
```

---

## 📋 API Testing Checklist

### Before Making API Calls
- [ ] Test with curl first (simple)
- [ ] Check authentication requirements
- [ ] Verify endpoint exists
- [ ] Test with sample data

### After API Integration
- [ ] Implement proper error handling
- [ ] Add loading states
- [ ] Include retry logic
- [ ] Monitor API performance
- [ ] Document any custom endpoints

### Production Considerations
- [ ] Implement proper authentication
- [ ] Use HTTPS in production
- [ ] Add rate limiting
- [ ] Monitor API usage
- [ ] Implement logging

---

**🎯 Selanjutnya**: [05-Memasang Plugin](./05-Memasang-Plugin.md) - Pelajari cara memasang dan mengkonfigurasi plugin untuk meningkatkan fungsionalitas Orthanc!