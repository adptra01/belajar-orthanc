# Integration Plan: Orthanc + Custom Website

> **Tujuan:** Panduan lengkap untuk mengintegrasikan Orthanc DICOM Server dengan website kustom — baik sebagai backend API, viewer embed, maupun sistem PACS terintegrasi.

---

## Daftar Isi

1. [Arsitektur Integrasi](#1-arsitektur-integrasi)
2. [Persiapan Server Orthanc](#2-persiapan-server-orthanc)
3. [CORS Configuration](#3-cors-configuration)
4. [Authentication & Authorization](#4-authentication--authorization)
5. [REST API Integration Patterns](#5-rest-api-integration-patterns)
6. [Embedded DICOM Viewer](#6-embedded-dicom-viewer)
7. [Real-time Updates & Webhooks](#7-real-time-updates--webhooks)
8. [Security Checklist](#8-security-checklist)
9. [Deployment Topology](#9-deployment-topology)
10. [Monitoring & Logging](#10-monitoring--logging)
11. [Implementation Roadmap](#11-implementation-roadmap)

---

## 1. Arsitektur Integrasi

### Pilihan Arsitektur

| Arsitektur | Kelebihan | Kekurangan | Recommended Untuk |
|------------|-----------|------------|-------------------|
| **A: Direct REST API** | Simple, latency minimal | Ekspose Orthanc langsung, CORS perlu diatur | Internal tools, LAN |
| **B: Reverse Proxy (Nginx/Caddy)** | Security layer, SSL termination, rate limiting | Satu hop tambahan | Production, public-facing |
| **C: Backend Middleware** | Full kontrol, business logic, auth kustom | Lebih kompleks, latency tambahan | Aplikasi dengan logic kompleks |
| **D: Microservices** | Scalable, isolation | Sangat kompleks | Enterprise, multi-tenant |

### Diagram Arsitektur

```
A) Direct REST API
   [Browser] ──CORS──▶ [Orthanc:8042]

B) Reverse Proxy
   [Browser] ──HTTPS──▶ [Nginx:443] ──HTTP──▶ [Orthanc:8042]

C) Backend Middleware (Recommended)
   [Browser] ──▶ [Backend API] ──▶ [Orthanc:8042]
                      │
                      ▼
               [Database App]
               [Business Logic]
               [Auth Service]

D) Microservices
   [Browser] ──▶ [API Gateway] ──▶ [Auth Service]
                        │──▶ [Orthanc Service] ──▶ [Orthanc:8042]
                        │──▶ [Viewer Service] ──▶ [OHIF:3000]
                        │──▶ [Export Service]
```

### Rekomendasi: Arsitektur B + C (Hybrid)

Untuk production website, gunakan **Reverse Proxy + Backend Middleware**:

```
[Internet] ──HTTPS──▶ [Cloudflare/CDN]
                          │
                    [Nginx Reverse Proxy]
                     ↙               ↘
           [Orthanc:8042]        [Backend API:8080]
                                     │
                              [App Database]
```

**Alasan:**
- Cloudflare untuk SSL, DDoS protection, caching
- Nginx untuk routing, rate limiting, CORS
- Backend API untuk autentikasi pengguna, business logic, audit trail
- Orthanc tetap terisolasi di internal network

---

## 2. Persiapan Server Orthanc

### Konfigurasi Dasar untuk Web

```json
{
  "Name": "Orthanc Production",
  "HttpPort": 8042,
  "AuthenticationEnabled": true,
  "RegisteredUsers": {
    "orthanc": "orthanc",
    "api-service": "secure-token-here"
  },
  "HttpThreadsCount": 50,
  "KeepAlive": true,
  "KeepAliveTimeout": 60,
  "HttpCompression": true,
  "MaximumStorageSize": 0,
  "MaximumPatientCount": 0
}
```

### Docker Compose untuk Production

```yaml
version: '3.8'

services:
  orthanc:
    image: jodogne/orthanc-plugins:latest
    container_name: orthanc-server
    ports:
      - "127.0.0.1:8042:8042"   # Hanya localhost (proxy yg akses)
      - "4242:4242"
    volumes:
      - ./data/orthanc:/var/lib/orthanc/db
      - ./config/orthanc.json:/etc/orthanc/orthanc.json
    environment:
      - ORTHANC__AUTHENTICATION_ENABLED=true
      - ORTHANC__HTTP_PORT=8042
    restart: unless-stopped
    networks:
      - internal

  backend:
    build: ./backend
    ports:
      - "127.0.0.1:8080:8080"
    environment:
      - ORTHANC_URL=http://orthanc:8042
      - ORTHANC_USERNAME=api-service
      - ORTHANC_PASSWORD=secure-token-here
    depends_on:
      - orthanc
    networks:
      - internal

  nginx:
    image: nginx:alpine
    ports:
      - "443:443"
      - "80:80"
    volumes:
      - ./nginx.conf:/etc/nginx/nginx.conf
      - ./ssl:/etc/nginx/ssl
    depends_on:
      - orthanc
      - backend
    networks:
      - internal
      - external

networks:
  internal:
  external:
```

---

## 3. CORS Configuration

### Mengapa CORS Diperlukan

Browser memblokir request dari domain berbeda. Jika website Anda di `https://app.example.com` dan Orthanc di `http://localhost:8042` (atau domain berbeda), CORS harus dikonfigurasi.

### Opsi 1: Konfigurasi CORS di Orthanc (jika didukung plugin)

Beberapa plugin menyediakan konfigurasi CORS. Jika tidak, gunakan reverse proxy.

### Opsi 2: Reverse Proxy (Nginx) — **RECOMMENDED**

```nginx
server {
    listen 443 ssl;
    server_name orthanc-api.example.com;

    ssl_certificate /etc/nginx/ssl/cert.pem;
    ssl_certificate_key /etc/nginx/ssl/key.pem;

    location / {
        proxy_pass http://orthanc:8042;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;

        # CORS Headers
        add_header 'Access-Control-Allow-Origin' 'https://app.example.com' always;
        add_header 'Access-Control-Allow-Methods' 'GET, POST, PUT, DELETE, OPTIONS' always;
        add_header 'Access-Control-Allow-Headers' 'Authorization, Content-Type, Accept' always;
        add_header 'Access-Control-Allow-Credentials' 'true' always;
        add_header 'Access-Control-Max-Age' '86400' always;

        # Handle preflight
        if ($request_method = 'OPTIONS') {
            add_header 'Access-Control-Allow-Origin' 'https://app.example.com';
            add_header 'Access-Control-Allow-Methods' 'GET, POST, PUT, DELETE, OPTIONS';
            add_header 'Access-Control-Allow-Headers' 'Authorization, Content-Type, Accept';
            add_header 'Access-Control-Allow-Credentials' 'true';
            add_header 'Access-Control-Max-Age' '86400';
            add_header 'Content-Type' 'text/plain charset=UTF-8';
            add_header 'Content-Length' '0';
            return 204;
        }
    }
}
```

### Opsi 3: CORS via Backend Middleware

```javascript
// Express.js middleware example
app.use((req, res, next) => {
  const allowedOrigins = [
    'https://app.example.com',
    'http://localhost:3000'
  ];

  const origin = req.headers.origin;
  if (allowedOrigins.includes(origin)) {
    res.setHeader('Access-Control-Allow-Origin', origin);
  }

  res.setHeader('Access-Control-Allow-Methods', 'GET, POST, PUT, DELETE, OPTIONS');
  res.setHeader('Access-Control-Allow-Headers', 'Authorization, Content-Type');
  res.setHeader('Access-Control-Allow-Credentials', 'true');

  if (req.method === 'OPTIONS') {
    return res.sendStatus(204);
  }

  next();
});
```

---

## 4. Authentication & Authorization

### Strategi Autentikasi

#### Level 1: Basic Auth (Sederhana)

Orthanc mendukung **HTTP Basic Auth** bawaan:

```javascript
// Frontend JavaScript
const response = await fetch('https://orthanc-api.example.com/patients', {
  headers: {
    'Authorization': 'Basic ' + btoa('orthanc:orthanc')
  }
});
```

**Kelemahan:** Credentials terlihat di frontend. Hanya untuk development.

#### Level 2: Token-Based Auth via Backend (RECOMMENDED)

Backend menyimpan kredensial Orthanc, frontend hanya mendapat token session:

```javascript
// Backend (Node.js/Express) — proxy ke Orthanc
app.get('/api/patients', async (req, res) => {
  // Verify user token
  const user = await auth.verifyToken(req.headers.authorization);

  // Forward to Orthanc with service credentials
  const response = await fetch('http://orthanc:8042/patients', {
    headers: {
      'Authorization': 'Basic ' + Buffer.from('api-service:password').toString('base64')
    }
  });

  const data = await response.json();
  res.json({ data, meta: { user: user.id } });
});
```

#### Level 3: JWT + Backend Proxy (Production)

```javascript
// Backend — JWT auth + Orthanc proxy
const express = require('express');
const jwt = require('jsonwebtoken');

const ORTHANC_URL = process.env.ORTHANC_URL;
const ORTHANC_AUTH = Buffer.from(
  `${process.env.ORTHANC_USER}:${process.env.ORTHANC_PASS}`
).toString('base64');

const app = express();

// Auth middleware
function authenticate(req, res, next) {
  const token = req.headers.authorization?.replace('Bearer ', '');
  if (!token) return res.status(401).json({ error: 'Unauthorized' });

  try {
    req.user = jwt.verify(token, process.env.JWT_SECRET);
    next();
  } catch (e) {
    return res.status(401).json({ error: 'Invalid token' });
  }
}

// Proxy endpoint
app.get('/api/orthanc/:endpoint(*)', authenticate, async (req, res) => {
  try {
    const orthancRes = await fetch(
      `${ORTHANC_URL}/${req.params.endpoint}${req.url.includes('?') ? req.url.substring(req.url.indexOf('?')) : ''}`,
      {
        headers: {
          'Authorization': `Basic ${ORTHANC_AUTH}`
        }
      }
    );

    const data = await orthancRes.json();
    res.json(data);
  } catch (err) {
    res.status(502).json({ error: 'Orthanc unavailable' });
  }
});

// Login endpoint
app.post('/api/login', async (req, res) => {
  const { username, password } = req.body;

  // Verify against Orthanc
  const orthancRes = await fetch(`${ORTHANC_URL}/system`, {
    headers: {
      'Authorization': 'Basic ' + Buffer.from(`${username}:${password}`).toString('base64')
    }
  });

  if (!orthancRes.ok) {
    return res.status(401).json({ error: 'Invalid credentials' });
  }

  // Generate JWT
  const token = jwt.sign(
    { username, role: 'radiologist' },
    process.env.JWT_SECRET,
    { expiresIn: '8h' }
  );

  res.json({ token, expiresIn: '8h' });
});

app.listen(8080);
```

### Perbandingan Metode Autentikasi

| Metode | Keamanan | Kompleksitas | Use Case |
|--------|----------|--------------|----------|
| Basic Auth (langsung) | Rendah | Sangat Mudah | Development, internal tools |
| API Key via Header | Sedang | Mudah | Server-to-server |
| Backend Proxy + Session | Tinggi | Sedang | Web apps with login |
| Backend Proxy + JWT | Tinggi | Sedang | SPA, mobile apps |
| OAuth2 / SSO | Sangat Tinggi | Kompleks | Enterprise, multiple apps |

---

## 5. REST API Integration Patterns

### Pattern 1: Proxy All Endpoints

Backend menyediakan endpoint wildcard yang memforward semua request ke Orthanc.

```javascript
// GET /api/orthanc/patients
// GET /api/orthanc/studies/{id}
// POST /api/orthanc/tools/find
app.all('/api/orthanc/*', authenticate, async (req, res) => {
  const path = req.params[0];
  const options = {
    method: req.method,
    headers: { 'Authorization': `Basic ${ORTHANC_AUTH}` }
  };

  if (req.body && Object.keys(req.body).length) {
    options.body = JSON.stringify(req.body);
    options.headers['Content-Type'] = 'application/json';
  }

  const response = await fetch(`${ORTHANC_URL}/${path}${req.queryString}`, options);
  const data = await response.json();
  res.status(response.status).json(data);
});
```

### Pattern 2: Business Logic Layer

Backend menyediakan endpoint bisnis spesifik, bukan proxy mentah.

```javascript
// GET /api/dashboard/stats — Dashboard statistics
app.get('/api/dashboard/stats', authenticate, async (req, res) => {
  const [patients, studies, system] = await Promise.all([
    orthanc.get('/patients'),
    orthanc.get('/studies'),
    orthanc.get('/system')
  ]);

  res.json({
    totalPatients: patients.length,
    totalStudies: studies.length,
    serverVersion: system.Version,
    storageSize: system.MaximumStorageSize
  });
});

// GET /api/patients/search — Pencarian dengan format response
app.get('/api/patients/search', authenticate, async (req, res) => {
  const { name, limit = 20 } = req.query;

  const results = await orthanc.post('/tools/find', {
    Level: 'Patient',
    Query: { PatientName: `*${name || ''}*` },
    Limit: limit
  });

  // Ambil detail setiap pasien
  const patients = await Promise.all(
    results.map(id => orthanc.get(`/patients/${id}`))
  );

  res.json({
    data: patients.map(p => ({
      id: p.ID,
      name: p.MainDicomTags.PatientName,
      birthDate: p.MainDicomTags.PatientBirthDate,
      sex: p.MainDicomTags.PatientSex,
      studies: p.Studies.length
    })),
    total: patients.length
  });
});
```

### Pattern 3: Upload dengan Progress

```javascript
// Upload DICOM file dengan progress tracking
async function uploadDicom(file, onProgress) {
  const formData = new FormData();
  formData.append('file', file);

  const response = await fetch('/api/orthanc/studies', {
    method: 'POST',
    headers: {
      'Authorization': `Bearer ${token}`
    },
    body: file, // Send raw DICOM file
    // Note: Gunakan XMLHttpRequest untuk progress tracking
  });

  return response.json();
}

// Dengan XMLHttpRequest (progress tracking)
function uploadWithProgress(file) {
  return new Promise((resolve, reject) => {
    const xhr = new XMLHttpRequest();
    xhr.open('POST', '/api/orthanc/studies');
    xhr.setRequestHeader('Authorization', `Bearer ${token}`);
    xhr.setRequestHeader('Content-Type', 'application/dicom');

    xhr.upload.onprogress = (e) => {
      if (e.lengthComputable) {
        const percent = Math.round((e.loaded / e.total) * 100);
        console.log(`Upload: ${percent}%`);
      }
    };

    xhr.onload = () => resolve(JSON.parse(xhr.response));
    xhr.onerror = () => reject(new Error('Upload failed'));
    xhr.send(file);
  });
}
```

---

## 6. Embedded DICOM Viewer

### Opsi Viewer

| Viewer | Integrasi | Fitur | Lisensi |
|--------|-----------|-------|---------|
| **OHIF Viewer** | `/ohif/` route | Lengkap (MPR, 3D, measurements) | MIT |
| **Orthanc Web Viewer** | Plugin | Dasar (view, window/level) | AGPL |
| **Cornerstone.js** | Library | Kustomisasi penuh | MIT |
| **OpenLayers** | Library | Grid pasien/studi | BSD |

### Opsi 1: Embed OHIF Viewer di Iframe

Cara termudah — embed halaman OHIF yang sudah ada:

```html
<iframe
  src="https://orthanc-api.example.com/ohif/"
  style="width: 100%; height: 800px; border: none;"
  allow="cross-origin-isolated"
>
</iframe>
```

**Dengan parameter studi spesifik:**

```html
<iframe
  src="https://orthanc-api.example.com/ohif/viewer/?studyInstanceUIDs=1.3.6.1.4.1.19179.1.11045202249120203.1.16724.28725"
  style="width: 100%; height: 800px; border: none;"
>
</iframe>
```

### Opsi 2: OHIF Standalone (Self-hosted)

Untuk kustomisasi lebih lanjut, deploy OHIF standalone:

```bash
# Clone OHIF Viewer
git clone https://github.com/OHIF/Viewers.git
cd Viewers/platform/viewer

# Konfigurasi
echo "REACT_APP_ORTHANC_URL=https://orthanc-api.example.com" > .env

# Build
yarn install && yarn build

# Deploy ke web server
cp -r build/* /var/www/html/ohif/
```

### Opsi 3: Cornerstone.js untuk Kustomisasi Penuh

Integrasi langsung dengan library Cornerstone.js:

```html
<!DOCTYPE html>
<html>
<head>
  <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/cornerstone-core/dist/cornerstone.css" />
</head>
<body>
  <div id="dicomViewer" style="width: 512px; height: 512px;"></div>

  <script src="https://cdn.jsdelivr.net/npm/dicom-parser"></script>
  <script src="https://cdn.jsdelivr.net/npm/cornerstone-core"></script>
  <script src="https://cdn.jsdelivr.net/npm/cornerstone-tools"></script>
  <script src="https://cdn.jsdelivr.net/npm/cornerstone-wado-image-loader"></script>

  <script>
    // Inisialisasi Cornerstone
    cornerstoneWADOImageLoader.external.cornerstone = cornerstone;
    cornerstoneWADOImageLoader.external.dicomParser = dicomParser;

    const element = document.getElementById('dicomViewer');
    cornerstone.enable(element);

    // Load DICOM dari Orthanc API
    const imageId = 'wadouri:https://orthanc-api.example.com/instances/{id}/file';

    cornerstone.loadImage(imageId).then(image => {
      cornerstone.displayImage(element, image);
      cornerstone.fitToWindow(element);
    });

    // Tool: Window/Level
    cornerstoneTools.mouseInputCallback = cornerstoneTools.mouseInputCallback;
    cornerstoneTools.addTool(cornerstoneTools.WwwcTool);
    cornerstoneTools.setToolActive('Wwwc', { mouseButtonMask: 1 });
  </script>
</body>
</html>
```

### Opsi 4: Custom Viewer dengan OHIF + Backend Integration

Integrasi OHIF dengan backend sendiri untuk akses kontrol:

```javascript
// Backend — Proxy untuk OHIF
app.get('/viewer/:studyId', authenticate, async (req, res) => {
  const { studyId } = req.params;

  // Verifikasi user punya akses ke studi ini
  const hasAccess = await verifyAccess(req.user, studyId);
  if (!hasAccess) {
    return res.status(403).json({ error: 'Forbidden' });
  }

  // Render halaman OHIF dengan token embedded
  res.send(`
    <!DOCTYPE html>
    <html>
    <head>
      <title>DICOM Viewer</title>
      <style>
        body, html { margin: 0; padding: 0; height: 100%; }
        iframe { width: 100%; height: 100%; border: none; }
      </style>
    </head>
    <body>
      <iframe src="/ohif/viewer/?studyInstanceUIDs=${studyUid}"></iframe>
    </body>
    </html>
  `);
});
```

---

## 7. Real-time Updates & Webhooks

### Polling dengan /changes

Cara paling sederhana untuk mendapatkan update:

```javascript
// Frontend — Polling perubahan
let lastSeq = 0;

async function pollChanges() {
  const response = await fetch('/api/orthanc/changes?limit=50', {
    headers: { 'Authorization': `Bearer ${token}` }
  });
  const data = await response.json();

  if (data.Changes && data.Changes.length > 0) {
    data.Changes.forEach(change => {
      console.log(`Change: ${change.ChangeType} — ${change.ResourceType}`);
      handleChange(change);
    });
    lastSeq = data.Last;
  }

  setTimeout(pollChanges, 5000); // Poll setiap 5 detik
}

function handleChange(change) {
  switch (change.ChangeType) {
    case 'NewInstance':
      updateStudyList();
      notifyUser(`New image received: ${change.ResourceType}`);
      break;
    case 'StableStudy':
      updateDashboard();
      break;
    case 'NewPatient':
      refreshPatientList();
      break;
  }
}

pollChanges();
```

### Webhook via Backend

Backend menerima notifikasi dan mengirimkannya ke client via WebSocket:

```javascript
// Backend — WebSocket + Orthanc polling
const WebSocket = require('ws');
const wss = new WebSocket.Server({ port: 8081 });

let lastSeq = 0;

// Poll Orthanc untuk perubahan
setInterval(async () => {
  try {
    const response = await fetch(`${ORTHANC_URL}/changes?since=${lastSeq}`, {
      headers: { 'Authorization': `Basic ${ORTHANC_AUTH}` }
    });
    const data = await response.json();

    data.Changes?.forEach(change => {
      const message = JSON.stringify({
        type: 'orthanc-change',
        changeType: change.ChangeType,
        resourceType: change.ResourceType,
        id: change.ID,
        path: change.Path,
        timestamp: change.Date
      });

      // Broadcast ke semua client WebSocket
      wss.clients.forEach(client => {
        if (client.readyState === WebSocket.OPEN) {
          client.send(message);
        }
      });
    });

    lastSeq = data.Last;
  } catch (err) {
    console.error('Polling error:', err.message);
  }
}, 5000);
```

```javascript
// Frontend — WebSocket client
const ws = new WebSocket('wss://api.example.com/ws');

ws.onmessage = (event) => {
  const change = JSON.parse(event.data);
  console.log('Real-time update:', change);

  switch (change.changeType) {
    case 'NewInstance':
      showNotification('New DICOM image received');
      refreshViewer();
      break;
    case 'StableStudy':
      updateStudyTable();
      break;
  }
};

ws.onclose = () => {
  console.log('WebSocket disconnected, reconnecting...');
  setTimeout(() => { /* reconnect logic */ }, 3000);
};
```

---

## 8. Security Checklist

### Konfigurasi Wajib untuk Production

- [ ] **Aktifkan autentikasi Orthanc**: `AuthenticationEnabled: true`
- [ ] **Ganti kredensial default**: Jangan gunakan `orthanc:orthanc`
- [ ] **HTTPS everywhere**: Gunakan SSL/TLS untuk semua endpoint
- [ ] **CORS terbatas**: Hanya allow origin spesifik, jangan `*`
- [ ] **Rate limiting**: Batasi request per IP/user
- [ ] **Jangan ekspose Orthanc langsung ke internet**: Selalu gunakan reverse proxy

### Nginx Security Headers

```nginx
# Tambahkan di blok server
add_header X-Frame-Options "SAMEORIGIN" always;
add_header X-Content-Type-Options "nosniff" always;
add_header X-XSS-Protection "1; mode=block" always;
add_header Referrer-Policy "strict-origin-when-cross-origin" always;
add_header Content-Security-Policy "default-src 'self'; script-src 'self' 'unsafe-inline'; style-src 'self' 'unsafe-inline'; img-src 'self' data:;" always;
```

### Network Security

```yaml
# Docker network — Orthanc di internal network
networks:
  internal:   # Backend + Orthanc + Database
    driver: bridge
    internal: true  # Tidak bisa diakses dari luar
  external:   # Nginx + Backend
    driver: bridge
```

### Authentication Checklist

- [ ] Backend proxy memvalidasi semua request ke Orthanc
- [ ] Credentials Orthanc hanya disimpan di backend (environment variables)
- [ ] Token JWT memiliki expiry (recommended: 1-8 jam)
- [ ] Rate limiting pada endpoint login
- [ ] Log semua akses ke Orthanc (audit trail)
- [ ] Rotasi credentials secara berkala

### DICOM Data Security

- [ ] Anonimisasi otomatis untuk data riset/pelatihan
- [ ] Enkripsi storage DICOM (disk encryption)
- [ ] Backup rutin dengan enkripsi
- [ ] Access control per studi/pasien (jika multi-tenant)
- [ ] Log semua akses ke data DICOM

---

## 9. Deployment Topology

### Development

```
[Local Dev Machine]
    ├── Orthanc (Docker) — localhost:8042
    ├── Backend API — localhost:8080
    └── Frontend — localhost:3000
```

### Staging

```
[VPS / Cloud VM]
    ├── Nginx — :443 (SSL)
    ├── Orthanc (Docker) — internal:8042
    ├── Backend API (Docker) — internal:8080
    └── PostgreSQL — internal:5432
```

### Production (High Availability)

```
[Cloudflare]
    │
[Load Balancer]
    │
    ├── [Web Server 1]
    │   ├── Nginx
    │   ├── Orthanc
    │   ├── Backend API
    │   └── Orthanc Storage (NFS/EFS)
    │
    ├── [Web Server 2]
    │   ├── Nginx
    │   ├── Orthanc
    │   ├── Backend API
    │   └── Orthanc Storage (NFS/EFS)
    │
    └── [Database]
        └── PostgreSQL (Primary/Replica)
```

### Contoh Nginx Full Configuration

```nginx
upstream orthanc_backend {
    server backend:8080;
    keepalive 32;
}

server {
    listen 443 ssl http2;
    server_name orthanc-api.example.com;

    ssl_certificate /etc/nginx/ssl/cert.pem;
    ssl_certificate_key /etc/nginx/ssl/key.pem;
    ssl_protocols TLSv1.2 TLSv1.3;
    ssl_ciphers HIGH:!aNULL:!MD5;

    # Rate limiting
    limit_req_zone $binary_remote_addr zone=api:10m rate=30r/s;
    limit_req zone=api burst=50 nodelay;

    # Security headers
    add_header X-Frame-Options "SAMEORIGIN" always;
    add_header X-Content-Type-Options "nosniff" always;
    add_header X-XSS-Protection "1; mode=block" always;
    add_header Strict-Transport-Security "max-age=31536000; includeSubDomains" always;

    # Proxy ke backend
    location /api/ {
        proxy_pass http://orthanc_backend;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;

        # CORS
        add_header Access-Control-Allow-Origin "https://app.example.com" always;
        add_header Access-Control-Allow-Methods "GET, POST, PUT, DELETE, OPTIONS" always;
        add_header Access-Control-Allow-Headers "Authorization, Content-Type" always;

        if ($request_method = 'OPTIONS') {
            return 204;
        }
    }

    # OHIF viewer proxy
    location /ohif/ {
        proxy_pass http://orthanc_backend;
        proxy_set_header Host $host;
        proxy_buffering off;
    }

    # Static files
    location / {
        root /var/www/frontend;
        try_files $uri $uri/ /index.html;
        expires 1y;
        add_header Cache-Control "public, immutable";
    }

    # Large upload (DICOM files can be 100MB+)
    location /api/orthanc/studies {
        client_max_body_size 500M;
        proxy_request_buffering off;
        proxy_pass http://orthanc_backend;
    }
}

# Redirect HTTP to HTTPS
server {
    listen 80;
    server_name orthanc-api.example.com;
    return 301 https://$host$request_uri;
}
```

---

## 10. Monitoring & Logging

### Health Check Endpoint

```bash
# Script monitoring sederhana
#!/bin/bash
ORTHANC_URL="https://orthanc-api.example.com/api/orthanc/system"
TOKEN="your-jwt-token"

response=$(curl -s -o /dev/null -w "%{http_code}" -H "Authorization: Bearer $TOKEN" $ORTHANC_URL)

if [ "$response" = "200" ]; then
  echo "✅ Orthanc is healthy"
else
  echo "❌ Orthanc returned HTTP $response"
  # Trigger alert (email, Slack, etc.)
fi
```

### Prometheus Metrics

```bash
# Via backend proxy
curl -H "Authorization: Bearer $TOKEN" https://orthanc-api.example.com/api/orthanc/tools/metrics-prometheus
```

**Key metrics untuk dimonitor:**

| Metric | Threshold | Action |
|--------|-----------|--------|
| `orthanc_up_time_s` | < 300 | Server baru restart |
| `orthanc_disk_size_mb` | > 80% storage | Perlu cleanup/upgrade |
| `orthanc_rest_api_active_requests` | > 40 | Load tinggi, perlu scaling |
| `orthanc_available_dicom_threads` | = 0 | Semua thread DICOM terpakai |
| `orthanc_available_http_threads_count` | < 10 | HTTP thread pool habis |

### Logging

```bash
# Akses log Orthanc via Docker
docker logs orthanc-server --tail 100

# Filter error
docker logs orthanc-server 2>&1 | grep -i error

# Stream log
docker logs -f orthanc-server
```

---

## 11. Implementation Roadmap

### Phase 1: Foundation (Week 1)

- [x] Orthanc server running di Docker
- [x] REST API berfungsi dan teruji
- [x] Dokumentasi API reference selesai
- [ ] Deploy dengan reverse proxy (Nginx)
- [ ] Konfigurasi HTTPS (SSL certificate)
- [ ] Setup autentikasi dasar

### Phase 2: Backend API (Week 2)

- [ ] Buat backend service (Node.js/Python)
- [ ] Implementasi JWT authentication
- [ ] Proxy endpoints untuk frontend
- [ ] Implementasi CORS terbatas
- [ ] Upload DICOM via backend

### Phase 3: Frontend Integration (Week 3)

- [ ] Integrasi OHIF Viewer (iframe atau standalone)
- [ ] Dashboard pasien/studi
- [ ] Form upload DICOM
- [ ] Search & filter UI
- [ ] Real-time updates (WebSocket)

### Phase 4: Production Hardening (Week 4)

- [ ] Rate limiting
- [ ] Monitoring & alerting
- [ ] Backup automation
- [ ] Security audit
- [ ] Load testing
- [ ] Documentation final

### Arsitektur Final Target

```
[User Browser]
     │
     ▼
[Cloudflare CDN]
     │
     ▼
[Nginx Reverse Proxy] ──▶ [Prometheus + Grafana]
     │
     ├──▶ [Orthanc Server] ──▶ [DICOM Storage]
     │
     ├──▶ [Backend API (Node.js)]
     │       │
     │       ├──▶ [PostgreSQL (App)]
     │       └──▶ [Redis (Session)]
     │
     └──▶ [OHIF Viewer]
```

---

## Referensi

- [Orthanc REST API Reference](../reference/ORTHANC-API-REFERENCE.md) — Dokumentasi API lengkap
- [Orthanc Book](https://orthanc.uclouvain.be/book/) — Dokumentasi resmi Orthanc
- [OHIF Viewer](https://docs.ohif.org/) — Dokumentasi OHIF
- [Cornerstone.js](https://github.com/cornerstonejs/cornerstone) — DICOM viewer library
- [Nginx CORS Guide](https://enable-cors.org/server_nginx.html) — Konfigurasi CORS Nginx
- [JWT Best Practices](https://datatracker.ietf.org/doc/html/rfc7519) — Standar JWT

---

> **Dokumen ini adalah bagian dari proyek Belajar Orthanc.**
> Lihat [README.md](../../README.md) untuk informasi proyek lebih lanjut.
