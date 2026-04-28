# Orthanc REST API Reference

> Dokumentasi lengkap REST API Orthanc DICOM Server — hasil eksplorasi dan pengujian langsung.
>
> **Versi API:** 29 | **Server:** mainline | **Base URL:** `http://localhost:8042`

---

## Daftar Isi

1. [Overview](#1-overview)
2. [Getting Started](#2-getting-started)
3. [API Reference](#3-api-reference)
   - [System](#31-system)
   - [Patients](#32-patients)
   - [Studies](#33-studies)
   - [Series](#34-series)
   - [Instances](#35-instances)
   - [Tools & Utilities](#36-tools--utilities)
   - [Changes & Jobs](#37-changes--jobs)
   - [Modalities & Peers](#38-modalities--peers)
   - [Plugin & DICOMweb API](#39-plugin--dicomweb-api)
4. [Error Handling](#4-error-handling)
5. [Best Practices](#5-best-practices)
6. [Troubleshooting](#6-troubleshooting)
7. [Codebase Documentation Standards](#7-codebase-documentation-standards)

---

## 1. Overview

### Apa itu Orthanc?

Orthanc adalah server DICOM ringan yang menyediakan **RESTful API** untuk mengelola data pencitraan medis (DICOM). API ini memungkinkan integrasi dengan sistem informasi rumah sakit, aplikasi web, dan alat analisis.

### Arsitektur API

```
┌──────────────┐     ┌──────────────┐     ┌──────────────┐
│  Aplikasi    │────▶│  Orthanc     │────▶│  Database    │
│  Eksternal   │◀────│  REST API    │◀────│  SQLite      │
└──────────────┘     └──────┬───────┘     └──────────────┘
                            │
                    ┌───────▼────────┐
                    │  DICOM Storage │
                    │  (Filesystem)  │
                    └────────────────┘
```

### Hierarki Data

```
Patient (Pasien)
  └── Study (Studi/Pemeriksaan)
        └── Series (Seri Gambar)
              └── Instance (Gambar Individual)
```

### Use Case Umum

| Use Case | Endpoint Terkait |
|----------|-----------------|
| Upload gambar DICOM baru | `POST /studies`, `POST /instances` |
| Cari pasien berdasarkan nama | `POST /tools/find` |
| Ambil data pasien lengkap | `GET /patients/{id}`, `GET /patients/{id}/studies` |
| Download gambar | `GET /instances/{id}/file` |
| Export studi sebagai ZIP | `POST /studies/{id}/archive` |
| Anonimisasi data | `POST /patients/{id}/anonymize` |
| Hapus data | `DELETE /patients/{id}` |
| Monitor kesehatan server | `GET /system`, `GET /tools/metrics-prometheus` |

---

## 2. Getting Started

### Prasyarat

- Orthanc server berjalan (lokal: `http://localhost:8042`)
- `curl` atau HTTP client (Postman, Insomnia, dll)

### Autentikasi

Jika autentikasi diaktifkan, gunakan **HTTP Basic Auth**:

```bash
# Default credentials (jika belum diubah)
curl -u orthanc:orthanc http://localhost:8042/system
```

Header yang dikirim:

```
Authorization: Basic b3J0aGFuYzpvcnRoYW5j
```

Response jika tidak ada autentikasi:

```
HTTP/1.1 401 Unauthorized
WWW-Authenticate: Basic realm="Orthanc Secure Area"
```

### Request Pertama

```bash
# Cek status server
curl -u orthanc:orthanc http://localhost:8042/system
```

Response:

```json
{
  "ApiVersion": 29,
  "DatabaseVersion": 6,
  "DicomAet": "ORTHANC",
  "DicomPort": 4242,
  "HttpPort": 8042,
  "Name": "Orthanc inside Docker",
  "Version": "mainline",
  "ReadOnly": false,
  "PluginsEnabled": true
}
```

### Format Request/Response

| Aspek | Standard |
|-------|----------|
| Base URL | `http://{host}:8042` |
| Encoding | UTF-8 |
| Request Body | JSON (`Content-Type: application/json`) |
| Response Body | JSON (kecuali download file) |
| Autentikasi | HTTP Basic Auth |
| Date Format | ISO string atau `YYYYMMDDThhmmss` |

---

## 3. API Reference

### 3.1 System

#### GET /system — Informasi Server

Mengembalikan informasi detail tentang server Orthanc, termasuk versi, konfigurasi, dan kapasitas.

**Request:**
```bash
curl -u orthanc:orthanc http://localhost:8042/system
```

**Response (200 OK):**
```json
{
  "ApiVersion": 29,
  "Capabilities": {
    "HasExtendedChanges": true,
    "HasExtendedFind": true,
    "HasKeyValueStores": true,
    "HasQueues": true,
    "HasReserveQueueValue": true
  },
  "DatabaseVersion": 6,
  "DatabaseServerIdentifier": "99e1165d-50fcf113-2bd83d16-ca9b7597-11b06cf3",
  "DicomAet": "ORTHANC",
  "DicomPort": 4242,
  "HttpPort": 8042,
  "IsHttpServerSecure": false,
  "MaximumPatientCount": 0,
  "MaximumStorageMode": "Recycle",
  "MaximumStorageSize": 0,
  "Name": "Orthanc inside Docker",
  "OverwriteInstances": false,
  "PluginsEnabled": true,
  "ReadOnly": false,
  "StorageCompression": false,
  "Version": "mainline"
}
```

**Field Penting:**

| Field | Tipe | Deskripsi |
|-------|------|-----------|
| `Version` | string | Versi Orthanc |
| `ApiVersion` | integer | Versi REST API |
| `DicomAet` | string | Application Entity Title untuk DICOM |
| `DicomPort` | integer | Port DICOM listener |
| `HttpPort` | integer | Port HTTP API |
| `ReadOnly` | boolean | Apakah server dalam mode read-only |
| `PluginsEnabled` | boolean | Apakah plugin diaktifkan |
| `MaximumStorageSize` | integer | Batas penyimpanan dalam MB (0 = tidak terbatas) |
| `StorageCompression` | boolean | Apakah kompresi storage diaktifkan |

---

### 3.2 Patients

#### GET /patients — Daftar Semua Pasien

Mengembalikan daftar ID semua pasien dalam database.

**Request:**
```bash
curl -u orthanc:orthanc http://localhost:8042/patients
```

**Response (200 OK):**
```json
[
  "b751523b-985c8066-ba65a368-1d5b8e38-0c9a383a"
]
```

**Query Parameters:**

| Parameter | Tipe | Default | Deskripsi |
|-----------|------|---------|-----------|
| `expand` | bool | `false` | Jika `true`, kembalikan objek lengkap (bukan hanya ID) |
| `limit` | integer | - | Batasi jumlah hasil |
| `since` | string | - | Mulai dari ID tertentu (pagination) |

**Dengan expand:**
```bash
curl -u orthanc:orthanc "http://localhost:8042/patients?expand=true"
```

```json
[
  {
    "ID": "b751523b-985c8066-ba65a368-1d5b8e38-0c9a383a",
    "IsProtected": false,
    "IsStable": true,
    "Labels": [],
    "LastUpdate": "20260427T093214",
    "MainDicomTags": {
      "PatientBirthDate": "19720606",
      "PatientID": "00006547",
      "PatientName": "SARIYANI ^NY^^^",
      "PatientSex": "F"
    },
    "Studies": ["510afe71-0e79f66c-752af439-38a5369e-b7e43d6e"],
    "Type": "Patient"
  }
]
```

---

#### GET /patients/{id} — Detail Pasien

**Request:**
```bash
curl -u orthanc:orthanc http://localhost:8042/patients/b751523b-985c8066-ba65a368-1d5b8e38-0c9a383a
```

**Response (200 OK):**
```json
{
  "ID": "b751523b-985c8066-ba65a368-1d5b8e38-0c9a383a",
  "IsProtected": false,
  "IsStable": true,
  "Labels": [],
  "LastUpdate": "20260427T093214",
  "MainDicomTags": {
    "OtherPatientIDs": "",
    "PatientBirthDate": "19720606",
    "PatientID": "00006547",
    "PatientName": "SARIYANI ^NY^^^",
    "PatientSex": "F"
  },
  "Studies": ["510afe71-0e79f66c-752af439-38a5369e-b7e43d6e"],
  "Type": "Patient"
}
```

---

#### GET /patients/{id}/studies — Studi Pasien

Mengembalikan semua studi milik pasien tertentu.

**Request:**
```bash
curl -u orthanc:orthanc http://localhost:8042/patients/b751523b-985c8066-ba65a368-1d5b8e38-0c9a383a/studies
```

**Response (200 OK):**
```json
[
  {
    "ID": "510afe71-0e79f66c-752af439-38a5369e-b7e43d6e",
    "IsStable": true,
    "Labels": [],
    "LastUpdate": "20260427T093214",
    "MainDicomTags": {
      "AccessionNumber": "1666",
      "InstitutionName": "RSUD H Abdul Manap",
      "StudyDate": "20260427",
      "StudyDescription": "",
      "StudyID": "61087",
      "StudyInstanceUID": "1.3.6.1.4.1.19179.1.11045202249120203.1.16724.28725"
    },
    "ParentPatient": "b751523b-985c8066-ba65a368-1d5b8e38-0c9a383a",
    "PatientMainDicomTags": {
      "PatientID": "00006547",
      "PatientName": "SARIYANI ^NY^^^",
      "PatientSex": "F"
    },
    "Series": ["fe209f68-53c826a9-dc5b7cc8-d6554837-2409f8b7"],
    "Type": "Study"
  }
]
```

---

#### POST /patients/{id}/anonymize — Anonimisasi Pasien

Membuat salinan pasien dengan data identitas dihapus/diganti.

**Request:**
```bash
curl -u orthanc:orthanc -X POST http://localhost:8042/patients/{id}/anonymize \
  -H "Content-Type: application/json" \
  -d '{
    "Replace": {
      "PatientName": "ANONYMIZED",
      "PatientID": "ANON001"
    }
  }'
```

**Response (200 OK):**
```json
{
  "ID": "new-anonymized-id-here",
  "PatientName": "ANONYMIZED",
  "Type": "Patient"
}
```

---

#### DELETE /patients/{id} — Hapus Pasien

Menghapus pasien beserta semua studi, series, dan instancenya.

**Request:**
```bash
curl -u orthanc:orthanc -X DELETE http://localhost:8042/patients/b751523b-985c8066-ba65a368-1d5b8e38-0c9a383a
```

**Response:** `200 OK` dengan body konfirmasi:
```json
{
  "Description": "Deleting patient",
  "ID": "b751523b-..."
}
```

---

#### POST /patients/{id}/protected — Proteksi/Unproteksi Pasien

Mencegah penghapusan tidak sengaja.

**Request:**
```bash
# Proteksi (set to true)
curl -u orthanc:orthanc -X POST http://localhost:8042/patients/{id}/protected \
  -H "Content-Type: application/json" \
  -d 'true'

# Unproteksi (set to false)
curl -u orthanc:orthanc -X POST http://localhost:8042/patients/{id}/protected \
  -H "Content-Type: application/json" \
  -d 'false'
```

---

### 3.3 Studies

#### GET /studies — Daftar Semua Studi

```bash
curl -u orthanc:orthanc http://localhost:8042/studies
```

**Response (200 OK):**
```json
["510afe71-0e79f66c-752af439-38a5369e-b7e43d6e"]
```

---

#### GET /studies/{id} — Detail Studi

```bash
curl -u orthanc:orthanc http://localhost:8042/studies/510afe71-0e79f66c-752af439-38a5369e-b7e43d6e
```

**Response (200 OK):**
```json
{
  "ID": "510afe71-0e79f66c-752af439-38a5369e-b7e43d6e",
  "IsStable": true,
  "Labels": [],
  "LastUpdate": "20260427T093214",
  "MainDicomTags": {
    "AccessionNumber": "1666",
    "InstitutionName": "RSUD H Abdul Manap",
    "StudyDate": "20260427",
    "StudyDescription": "",
    "StudyID": "61087",
    "StudyInstanceUID": "1.3.6.1.4.1.19179.1.11045202249120203.1.16724.28725",
    "StudyTime": "161052"
  },
  "ParentPatient": "b751523b-985c8066-ba65a368-1d5b8e38-0c9a383a",
  "PatientMainDicomTags": {
    "PatientBirthDate": "19720606",
    "PatientID": "00006547",
    "PatientName": "SARIYANI ^NY^^^",
    "PatientSex": "F"
  },
  "Series": ["fe209f68-53c826a9-dc5b7cc8-d6554837-2409f8b7"],
  "Type": "Study"
}
```

---

#### GET /studies/{id}/series — Series dalam Studi

```bash
curl -u orthanc:orthanc http://localhost:8042/studies/510afe71-0e79f66c-752af439-38a5369e-b7e43d6e/series
```

**Response (200 OK):**
```json
[
  {
    "ID": "fe209f68-53c826a9-dc5b7cc8-d6554837-2409f8b7",
    "Instances": ["54d949de-f7d2757b-01d05707-6e5b13ee-f1e84451"],
    "IsStable": true,
    "MainDicomTags": {
      "Modality": "DX",
      "SeriesNumber": "1",
      "ProtocolName": "CHEST"
    },
    "ParentStudy": "510afe71-...",
    "Status": "Unknown",
    "Type": "Series"
  }
]
```

---

#### POST /studies/{id}/archive — Export Studi sebagai ZIP

Membuat archive ZIP dari seluruh studi. Endpoint ini **asynchronous** — mengembalikan job ID yang bisa dipantau.

**Request:**
```bash
curl -u orthanc:orthanc -X POST http://localhost:8042/studies/{id}/archive \
  -H "Content-Type: application/json" \
  -d '{}'
```

**Response (201 Created):**
```json
{
  "Description": "Archive creation",
  "ID": "job-id-here"
}
```

Untuk download archive setelah selesai:
```bash
# Cek status job
curl -u orthanc:orthanc http://localhost:8042/jobs/{job-id}

# Download hasil
curl -u orthanc:orthanc http://localhost:8042/studies/{id}/archive -o study.zip
```

---

#### POST /studies/{id}/anonymize — Anonimisasi Studi

```bash
curl -u orthanc:orthanc -X POST http://localhost:8042/studies/{id}/anonymize \
  -H "Content-Type: application/json" \
  -d '{"Replace":{"PatientName":"ANONYMIZED"}}'
```

---

#### DELETE /studies/{id} — Hapus Studi

```bash
curl -u orthanc:orthanc -X DELETE http://localhost:8042/studies/{id}
```

---

#### POST /studies — Upload File DICOM

Endpoint untuk meng-upload satu atau lebih file DICOM.

**Request:**
```bash
# Upload file DICOM tunggal
curl -u orthanc:orthanc -X POST http://localhost:8042/studies \
  -H "Content-Type: application/dicom" \
  --data-binary @file.dcm
```

**Response (200 OK):**
```json
{
  "ID": "new-study-id",
  "Path": "/studies/new-study-id",
  "PatientID": "PATIENT001",
  "StudyDescription": "..."
}
```

> **Catatan:** File DICOM dikirim sebagai **binary**, bukan JSON. Gunakan `--data-binary` atau `-T` flag di curl.

---

### 3.4 Series

#### GET /series — Daftar Semua Series

```bash
curl -u orthanc:orthanc http://localhost:8042/series
```

**Response (200 OK):**
```json
["fe209f68-53c826a9-dc5b7cc8-d6554837-2409f8b7"]
```

---

#### GET /series/{id} — Detail Series

```bash
curl -u orthanc:orthanc http://localhost:8042/series/fe209f68-53c826a9-dc5b7cc8-d6554837-2409f8b7
```

**Response (200 OK):**
```json
{
  "ExpectedNumberOfInstances": null,
  "ID": "fe209f68-53c826a9-dc5b7cc8-d6554837-2409f8b7",
  "Instances": ["54d949de-f7d2757b-01d05707-6e5b13ee-f1e84451"],
  "IsStable": true,
  "Labels": [],
  "LastUpdate": "20260427T093214",
  "MainDicomTags": {
    "BodyPartExamined": "CHEST",
    "Manufacturer": "DK",
    "Modality": "DX",
    "ProtocolName": "CHEST",
    "SeriesDate": "20260427",
    "SeriesInstanceUID": "1.3.6.1.4.1.19179.1.11045202249120203.2.17204.28726",
    "SeriesNumber": "1",
    "SeriesTime": "161319"
  },
  "ParentStudy": "510afe71-0e79f66c-752af439-38a5369e-b7e43d6e",
  "Status": "Unknown",
  "Type": "Series"
}
```

---

#### GET /series/{id}/instances — Instances dalam Series

```bash
curl -u orthanc:orthanc http://localhost:8042/series/fe209f68-53c826a9-dc5b7cc8-d6554837-2409f8b7/instances
```

**Response (200 OK):**
```json
[
  {
    "FileSize": 9114974,
    "FileUuid": "356d8958-...",
    "ID": "54d949de-f7d2757b-01d05707-6e5b13ee-f1e84451",
    "IndexInSeries": 2,
    "MainDicomTags": {
      "InstanceNumber": "2",
      "NumberOfFrames": "1",
      "SOPInstanceUID": "1.3.6.1.4.1.19179.1.11045202249120203.3.17387.28728"
    },
    "ParentSeries": "fe209f68-...",
    "Type": "Instance"
  }
]
```

---

### 3.5 Instances

#### GET /instances — Daftar Semua Instances

```bash
curl -u orthanc:orthanc http://localhost:8042/instances
```

**Response (200 OK):**
```json
["54d949de-f7d2757b-01d05707-6e5b13ee-f1e84451"]
```

---

#### GET /instances/{id} — Detail Instance

```bash
curl -u orthanc:orthanc http://localhost:8042/instances/54d949de-f7d2757b-01d05707-6e5b13ee-f1e84451
```

**Response (200 OK):**
```json
{
  "FileSize": 9114974,
  "FileUuid": "356d8958-0179-4095-b78d-440ca7019a67",
  "ID": "54d949de-f7d2757b-01d05707-6e5b13ee-f1e84451",
  "IndexInSeries": 2,
  "Labels": [],
  "MainDicomTags": {
    "InstanceNumber": "2",
    "NumberOfFrames": "1",
    "SOPInstanceUID": "1.3.6.1.4.1.19179.1.11045202249120203.3.17387.28728"
  },
  "ParentSeries": "fe209f68-53c826a9-dc5b7cc8-d6554837-2409f8b7",
  "Type": "Instance"
}
```

---

#### GET /instances/{id}/file — Download File DICOM

Mendownload file DICOM asli dalam format binary/dicom.

**Request:**
```bash
# Download sebagai file
curl -u orthanc:orthanc http://localhost:8042/instances/{id}/file -o image.dcm

# Lihat metadata (hanya header)
curl -s -u orthanc:orthanc http://localhost:8042/instances/{id}/file -o /dev/null -w "HTTP %{http_code}, Size: %{size_download} bytes"
```

**Response:** `200 OK` — Content-Type: `application/dicom`, body berisi raw DICOM file.

---

#### GET /instances/{id}/metadata — Metadata Instance

Informasi teknis tentang instance (bukan DICOM tags, melainkan metadata Orthanc).

**Request:**
```bash
curl -u orthanc:orthanc http://localhost:8042/instances/{id}/metadata
```

**Response (200 OK):**
```json
[
  "IndexInSeries",
  "ReceptionDate",
  "RemoteAET",
  "Origin",
  "TransferSyntax",
  "SopClassUid",
  "RemoteIP",
  "HttpUsername",
  "PixelDataOffset",
  "MainDicomTagsSignature"
]
```

Untuk mendapatkan nilai metadata tertentu:

```bash
# Nilai metadata tertentu (contoh: TransferSyntax)
curl -u orthanc:orthanc http://localhost:8042/instances/{id}/metadata/TransferSyntax
```

---

#### GET /instances/{id}/preview — Preview Gambar (PNG)

Mendapatkan preview gambar dalam format PNG (jika tersedia).

**Request:**
```bash
curl -u orthanc:orthanc http://localhost:8042/instances/{id}/preview -o preview.png
```

**Response:** `200 OK` — Content-Type: `image/png`

---

#### GET /instances/{id}/simplified-tags — DICOM Tags (Simplified)

Mengembalikan semua DICOM tags dalam format JSON yang mudah dibaca.

**Request:**
```bash
curl -u orthanc:orthanc http://localhost:8042/instances/{id}/simplified-tags
```

**Response (200 OK):**
```json
{
  "BodyPartExamined": "CHEST",
  "InstitutionName": "RSUD H Abdul Manap",
  "Manufacturer": "DK",
  "Modality": "DX",
  "PatientBirthDate": "19720606",
  "PatientID": "00006547",
  "PatientName": "SARIYANI ^NY^^^",
  "PatientSex": "F",
  "ProtocolName": "CHEST",
  "SeriesNumber": "1",
  "StudyDate": "20260427",
  "StudyTime": "161052"
}
```

---

### 3.6 Tools & Utilities

#### POST /tools/find — Pencarian DICOM

Endpoint paling penting untuk pencarian. Mendukung pencarian di level Patient, Study, Series, atau Instance.

**Request:**
```bash
# Cari pasien
curl -u orthanc:orthanc -X POST http://localhost:8042/tools/find \
  -H "Content-Type: application/json" \
  -d '{
    "Level": "Patient",
    "Query": {
      "PatientName": "*"
    }
  }'
```

**Response (200 OK):**
```json
["b751523b-985c8066-ba65a368-1d5b8e38-0c9a383a"]
```

**Parameter:**

| Field | Tipe | Wajib | Deskripsi |
|-------|------|-------|-----------|
| `Level` | string | Ya | Level pencarian: `Patient`, `Study`, `Series`, `Instance` |
| `Query` | object | Ya | Key-value pairs DICOM tags untuk difilter |
| `Limit` | integer | Tidak | Batasi jumlah hasil |
| `CaseSensitive` | bool | Tidak | Case-sensitive search (default: false) |

**Query Examples:**

```bash
# Cari studi berdasarkan tanggal
curl -u orthanc:orthanc -X POST http://localhost:8042/tools/find \
  -H "Content-Type: application/json" \
  -d '{
    "Level": "Study",
    "Query": {
      "StudyDate": "20260427"
    }
  }'

# Cari series berdasarkan modalitas
curl -u orthanc:orthanc -X POST http://localhost:8042/tools/find \
  -H "Content-Type: application/json" \
  -d '{
    "Level": "Series",
    "Query": {
      "Modality": "DX"
    }
  }'

# Cari instance spesifik
curl -u orthanc:orthanc -X POST http://localhost:8042/tools/find \
  -H "Content-Type: application/json" \
  -d '{
    "Level": "Instance",
    "Query": {
      "PatientName": "SARIYANI*"
    }
  }'
```

**Wildcard:** Gunakan `*` sebagai wildcard — `PatientName: "*"` mencari semua pasien.

---

#### GET /tools/now — Server Waktu (UTC)

```bash
curl -u orthanc:orthanc http://localhost:8042/tools/now
```

**Response:**
```
20260428T170610
```

Format: `YYYYMMDDThhmmss` (UTC)

---

#### GET /tools/now-local — Server Waktu (Lokal)

```bash
curl -u orthanc:orthanc http://localhost:8042/tools/now-local
```

**Response:**
```
20260428T170611
```

---

#### GET /tools/generate-uid — Generate DICOM UID

Menghasilkan UID unik untuk digunakan pada objek DICOM baru.

```bash
curl -u orthanc:orthanc http://localhost:8042/tools/generate-uid
```

**Response:**
```
1.3.6.1.4.1.19179.1.11045202249120203.1.99999.99999
```

---

#### GET /tools/metrics-prometheus — Metrics (Prometheus)

Endpoint monitoring dalam format Prometheus.

```bash
curl -u orthanc:orthanc http://localhost:8042/tools/metrics-prometheus
```

**Response:**
```
orthanc_count_instances 1 1777395984193
orthanc_count_patients 1 1777395984193
orthanc_count_series 1 1777395984193
orthanc_count_studies 1 1777395984193
orthanc_disk_size_mb 8.69406128 1777395984193
orthanc_up_time_s 2155 1777395984193
orthanc_available_dicom_threads 4 1777393829217
orthanc_available_http_threads_count 49 1777395980631
orthanc_rest_api_active_requests 1 1777395980631
orthanc_storage_read_duration_ms 1 1777395957029
```

**Key Metrics:**

| Metric | Deskripsi |
|--------|-----------|
| `orthanc_count_patients` | Jumlah pasien |
| `orthanc_count_studies` | Jumlah studi |
| `orthanc_count_series` | Jumlah series |
| `orthanc_count_instances` | Jumlah instances |
| `orthanc_disk_size_mb` | Ukuran storage (MB) |
| `orthanc_up_time_s` | Uptime server (detik) |

---

#### GET /tools/dicom-conformance — DICOM Conformance Statement

Mengembalikan daftar lengkap SOP Classes yang didukung Orthanc untuk C-Store SCP.

```bash
curl -u orthanc:orthanc http://localhost:8042/tools/dicom-conformance
```

**Response:** Teks, bukan JSON. Berisi tabel SOP Classes yang didukung (CT, MR, DX, US, SR, dll).

---

#### GET /tools/lookup — Lookup Resource by UID

Mencari resource berdasarkan DICOM UID.

**Request:**
```bash
# Cari berdasarkan UID
curl -u orthanc:orthanc "http://localhost:8042/tools/lookup?uid=1.3.6.1.4.1.19179.1.11045202249120203.3.17387.28728"

# Cari berdasarkan patient name
curl -u orthanc:orthanc "http://localhost:8042/tools/lookup?patient=SARIYANI"
```

---

#### GET /tools/default-encoding — Default Encoding

```bash
curl -u orthanc:orthanc http://localhost:8042/tools/default-encoding
```

**Response:**
```
Latin1
```

---

#### POST /tools/create-dicom — Buat DICOM Sintetis

Membuat file DICOM baru dari data JSON. Berguna untuk testing.

**Request:**
```bash
curl -u orthanc:orthanc -X POST http://localhost:8042/tools/create-dicom \
  -H "Content-Type: application/json" \
  -d '{
    "PatientName": "Test^Patient",
    "PatientID": "TEST001",
    "StudyDescription": "Test Study",
    "SeriesDescription": "Test Series"
  }'
```

---

#### POST /tools/reconstruct — Rekonstruksi Indeks

Memaksa Orthanc untuk membaca ulang file DICOM dan memperbarui indeks.

```bash
curl -u orthanc:orthanc -X POST http://localhost:8042/tools/reconstruct
```

---

#### GET /tools/accepted-sop-classes — SOP Classes

```bash
curl -u orthanc:orthanc http://localhost:8042/tools/accepted-sop-classes
```

---

### 3.7 Changes & Jobs

#### GET /changes — Riwayat Perubahan

Mengembalikan riwayat perubahan database secara kronologis.

```bash
curl -u orthanc:orthanc http://localhost:8042/changes
```

**Response (200 OK):**
```json
{
  "Changes": [
    {
      "ChangeType": "NewInstance",
      "Date": "20260427T093214",
      "ID": "54d949de-...",
      "Path": "/instances/54d949de-...",
      "ResourceType": "Instance",
      "Seq": 135
    },
    {
      "ChangeType": "NewSeries",
      "Date": "20260427T093214",
      "ID": "fe209f68-...",
      "Path": "/series/fe209f68-...",
      "ResourceType": "Series",
      "Seq": 136
    },
    {
      "ChangeType": "StableStudy",
      "Date": "20260427T093315",
      "ID": "510afe71-...",
      "Path": "/studies/510afe71-...",
      "ResourceType": "Study",
      "Seq": 140
    }
  ],
  "Done": true,
  "First": 135,
  "Last": 142
}
```

**Change Types:**

| Tipe | Deskripsi |
|------|-----------|
| `NewInstance` | Instance baru ditambahkan |
| `NewSeries` | Series baru dibuat |
| `NewStudy` | Studi baru dibuat |
| `NewPatient` | Pasien baru ditambahkan |
| `StableSeries` | Series selesai diterima |
| `StableStudy` | Studi selesai diterima |
| `StablePatient` | Pasien selesai diterima |
| `UpdatedAttachment` | Attachment diperbarui |

---

#### GET /changes/{seq} — Perubahan Spesifik

```bash
curl -u orthanc:orthanc http://localhost:8042/changes/135
```

---

### 3.8 Modalities & Peers

#### GET /modalities — Daftar Modalities DICOM

Modalities adalah perangkat DICOM lain yang terhubung (CT scanner, MRI, dll).

```bash
curl -u orthanc:orthanc http://localhost:8042/modalities
```

**Response:**
```json
[]
```

*Kosong jika belum ada modalities yang dikonfigurasi.*

---

#### POST /modalities/{name}/store — Kirim DICOM ke Modality

Mengirim instance DICOM ke modality eksternal melalui C-Store.

```bash
curl -u orthanc:orthanc -X POST http://localhost:8042/modalities/MY-PACS/store \
  -H "Content-Type: application/json" \
  -d '{
    "Resources": ["b751523b-..."]
  }'
```

---

#### POST /modalities/{name}/echo — Uji Koneksi DICOM

```bash
curl -u orthanc:orthanc -X POST http://localhost:8042/modalities/MY-PACS/echo
```

---

#### POST /modalities/{name}/query — Cari di Modality Remote

```bash
curl -u orthanc:orthanc -X POST http://localhost:8042/modalities/MY-PACS/query \
  -H "Content-Type: application/json" \
  -d '{
    "Level": "Patient",
    "Query": {
      "PatientName": "*"
    }
  }'
```

---

#### GET /peers — Daftar Peers Orthanc

Peers adalah server Orthanc lain yang terhubung.

```bash
curl -u orthanc:orthanc http://localhost:8042/peers
```

---

### 3.9 Plugin & DICOMweb API

> **Plugin System:** Server ini menggunakan image `jodogne/orthanc-plugins` dengan **29 plugin** terinstall. Field `PluginsEnabled: true` di `/system` mengonfirmasi plugin aktif.

#### Daftar Plugin Terinstall

```
explorer.js, AWS S3 Storage, authorization, connectivity-checks,
delayed-deletion, dicom-web, education, gdcm, housekeeper,
indexer, multitenant-dicom, mysql-index, mysql-storage, neuro,
odbc-index, odbc-storage, ohif, orthanc-explorer-2,
postgresql-index, postgresql-storage, serve-folders, stl,
stone-rtviewer, stone-webviewer, tcia, transfers, volview,
web-viewer, worklists, wsi
```

---

#### 3.9.1 DICOMweb (STOW-RS / WADO-RS)

Mengakses data DICOM menggunakan standar **DICOMweb** (DICOM via HTTP). Response menggunakan format JSON dengan DICOM tags dalam format tag-based (bukan `simplified-tags`).

##### GET /dicom-web/studies — Daftar Studi (WADO-RS)

**Request:**
```bash
curl -u orthanc:orthanc "http://localhost:8042/dicom-web/studies"
```

**Response (200 OK):**
```json
[{
  "00080005": { "Value": ["ISO_IR 192"], "vr": "CS" },
  "00080020": { "Value": ["20260427"], "vr": "DA" },
  "00080050": { "Value": ["1666"], "vr": "SH" },
  "00080061": { "Value": ["DX"], "vr": "CS" },
  "00081190": {
    "Value": ["http://localhost:8042/dicom-web/studies/1.3.6.1.4.1.19179.1.11045202249120203.1.16724.28725"],
    "vr": "UR"
  },
  "00100010": { "Value": [{"Alphabetic": "SARIYANI ^NY^^^"}], "vr": "PN" },
  "00100020": { "Value": ["00006547"], "vr": "LO" },
  "00100030": { "Value": ["19720606"], "vr": "DA" },
  "00100040": { "Value": ["F"], "vr": "CS" },
  "0020000D": { "Value": ["1.3.6.1.4.1.19179.1.11045202249120203.1.16724.28725"], "vr": "UI" }
}]
```

**Field Penting dalam Tag DICOMweb:**

| Tag | Field | Deskripsi |
|-----|-------|-----------|
| `00081190` | `retrieveURL` | URL lengkap untuk mengambil studi |
| `00100010` | `PatientName` | Nama pasien |
| `00100020` | `PatientID` | ID pasien |
| `0020000D` | `StudyInstanceUID` | UID studi (untuk request selanjutnya) |

> **Catatan:** DICOMweb menggunakan format DICOM JSON (tag numerik + vr), bukan simplified tags. Untuk response yang lebih mudah dibaca, gunakan endpoint `/studies` standar.

##### POST /dicom-web/studies — Upload Studi (STOW-RS)

Upload file DICOM menggunakan standar DICOMweb.

**Request:**
```bash
curl -u orthanc:orthanc -X POST "http://localhost:8042/dicom-web/studies" \
  -H "Content-Type: application/dicom" \
  --data-binary @file.dcm
```

**Response:** `200 OK` dengan UUID studi yang di-upload.

---

#### 3.9.2 OHIF Viewer

**OHIF (Open Health Imaging Foundation)** adalah viewer DICOM berbasis web modern dengan fitur pengukuran, annotation, dan MPR.

##### GET /ohif/ — OHIF Viewer

Akses OHIF Viewer melalui browser atau API.

**Browser:** Buka `http://localhost:8042/ohif/` di browser.

**Cek ketersediaan:**
```bash
curl -s -o /dev/null -w "HTTP %{http_code}, Size: %{size_download} bytes" \
  -u orthanc:orthanc http://localhost:8042/ohif/
```

**Response:** HTML page dengan OHIF Viewer (Content-Type: `text/html`).

> **Use Case:** OHIF Viewer digunakan untuk visualisasi DICOM lanjutan — window/level, zoom, pan, measurement tools, dan dukungan multimodalitas (CT, MR, DX, US).

---

#### 3.9.3 Bulk Operations

Operasi massal untuk memproses banyak resource sekaligus.

##### POST /tools/bulk-content — Ambil Konten Massal

Mengembalikan detail lengkap dari beberapa resource dalam satu request.

**Request:**
```bash
curl -u orthanc:orthanc -X POST http://localhost:8042/tools/bulk-content \
  -H "Content-Type: application/json" \
  -d '{
    "Level": "patient",
    "Resources": ["b751523b-985c8066-ba65a368-1d5b8e38-0c9a383a"]
  }'
```

**Parameter:**

| Field | Tipe | Wajib | Deskripsi |
|-------|------|-------|-----------|
| `Level` | string | Ya | Level resource: `patient`, `study`, `series`, `instance` |
| `Resources` | array | Ya | Array ID resource |

**Response (200 OK):**
```json
[{
  "ID": "b751523b-...",
  "IsProtected": false,
  "IsStable": true,
  "MainDicomTags": {
    "PatientBirthDate": "19720606",
    "PatientID": "00006547",
    "PatientName": "SARIYANI ^NY^^^",
    "PatientSex": "F"
  },
  "Studies": ["510afe71-..."],
  "Type": "Patient"
}]
```

##### POST /tools/bulk-delete — Hapus Massal

Menghapus banyak resource sekaligus.

**Request:**
```bash
curl -u orthanc:orthanc -X POST http://localhost:8042/tools/bulk-delete \
  -H "Content-Type: application/json" \
  -d '{
    "Resources": ["patient-id-1", "study-id-2"]
  }'
```

**Response:** `200 OK`

##### POST /tools/bulk-modify — Modifikasi Massal

Memodifikasi tags DICOM pada banyak resource.

**Request:**
```bash
curl -u orthanc:orthanc -X POST http://localhost:8042/tools/bulk-modify \
  -H "Content-Type: application/json" \
  -d '{
    "Resources": ["study-id-1", "study-id-2"],
    "Replace": {
      "PatientName": "UPDATED_NAME"
    }
  }'
```

##### POST /tools/bulk-anonymize — Anonimisasi Massal

Anonimisasi banyak resource sekaligus.

**Request:**
```bash
curl -u orthanc:orthanc -X POST http://localhost:8042/tools/bulk-anonymize \
  -H "Content-Type: application/json" \
  -d '{
    "Resources": ["b751523b-..."],
    "Replace": {
      "PatientName": "ANONYMIZED",
      "PatientID": "ANON001"
    }
  }'
```

---

#### 3.9.4 Lua Scripting

Menjalankan script Lua di server Orthanc. Berguna untuk automasi workflow dan validasi kustom.

##### POST /tools/execute-script — Eksekusi Lua Script

**Request:**
```bash
curl -u orthanc:orthanc -X POST http://localhost:8042/tools/execute-script \
  -H "Content-Type: application/json" \
  -d '{
    "Script": "return OrthancApiClient:GetSystem()"
  }'
```

**Response (200 OK):**
```json
{
  "Result": "...output dari script..."
}
```

**Error Response (403):**
```json
{
  "HttpError": "Forbidden",
  "HttpStatus": 403,
  "Message": "The Lua engine is not available"
}
```

> **Catatan:** Endpoint ini memerlukan **Lua plugin** yang dikonfigurasi di `orthanc.json`:
> ```json
> { "LuaScripts": { "Enabled": true, "Directory": "/etc/orthanc/scripts" } }
> ```

**Contoh Aplikasi Lua Script:**
```lua
-- Validasi instance masuk
function OnIncomingInstance(instanceId)
    local instance = OrthancApiClient:GetInstance(instanceId)
    if instance.PatientName == nil then
        OrthancApiClient:DeleteInstance(instanceId)
        return false, "PatientName is required"
    end
    return true
end

-- Auto-anonimisasi studi baru
function OnStableStudy(studyId)
    local study = OrthancApiClient:GetStudy(studyId)
    OrthancApiClient:AnonymizeStudy(studyId)
end
```

---

#### 3.9.5 Create Media (DICOMDIR)

Membuat media DICOM untuk export ke CD/DVD (termasuk file DICOMDIR).

##### POST /tools/create-media — Buat Media DICOM

**Request:**
```bash
curl -u orthanc:orthanc -X POST http://localhost:8042/tools/create-media \
  -H "Content-Type: application/json" \
  -d '{
    "Resources": ["b751523b-985c8066-ba65a368-1d5b8e38-0c9a383a"]
  }'
```

**Response:** `200 OK` — ZIP file berisi DICOM files + DICOMDIR.

---

#### 3.9.6 Log Level Management

Mengontrol level logging Orthanc secara dynamic tanpa restart.

##### GET /tools/log-level — Lihat Log Level Saat Ini

```bash
curl -u orthanc:orthanc http://localhost:8042/tools/log-level
```

**Response:** `default`

##### Endpoint Log Level per Komponen

| Endpoint | Fungsi |
|----------|--------|
| `GET/POST /tools/log-level` | Generic log level |
| `GET/POST /tools/log-level-dicom` | DICOM protocol logging |
| `GET/POST /tools/log-level-http` | HTTP request logging |
| `GET/POST /tools/log-level-jobs` | Jobs logging |
| `GET/POST /tools/log-level-lua` | Lua scripting logging |
| `GET/POST /tools/log-level-plugins` | Plugin system logging |
| `GET/POST /tools/log-level-sqlite` | Database logging |
| `GET/POST /tools/log-level-generic` | Generic component logging |

**Request (set level):**
```bash
curl -u orthanc:orthanc -X POST http://localhost:8042/tools/log-level-http \
  -H "Content-Type: application/json" \
  -d '"verbose"'
```

**Valid values:** `default`, `verbose`, `trace`, `warning`, `error`

---

#### 3.9.7 System Tools

Endpoint tambahan untuk manajemen server.

##### GET /tools/metrics — Metrics Cepat

```bash
curl -u orthanc:orthanc http://localhost:8042/tools/metrics
```

**Response:** Jumlah total instances (angka integer).

##### GET /tools/accepted-transfer-syntaxes — Transfer Syntaxes

```bash
curl -u orthanc:orthanc http://localhost:8042/tools/accepted-transfer-syntaxes
```

**Response:** Daftar Transfer Syntax yang didukung.

##### GET /tools/unknown-sop-class-accepted — Cek Unknown SOP Class

```bash
curl -u orthanc:orthanc http://localhost:8042/tools/unknown-sop-class-accepted
```

**Response:** `true` atau `false`.

##### POST /tools/invalidate-tags — Invalidasi Cache Tags

Memaksa Orthanc untuk membaca ulang DICOM tags dari file (berguna setelah modifikasi manual).

```bash
curl -u orthanc:orthanc -X POST http://localhost:8042/tools/invalidate-tags
```

##### POST /tools/reset — Reset Server

```bash
curl -u orthanc:orthanc -X POST http://localhost:8042/tools/reset
```

##### POST /tools/shutdown — Matikan Server

```bash
curl -u orthanc:orthanc -X POST http://localhost:8042/tools/shutdown
```

---

#### 3.9.8 Jobs Queue

##### GET /jobs — Daftar Jobs

```bash
curl -u orthanc:orthanc http://localhost:8042/jobs
```

**Response:**
```json
["4e25380b-4073-4356-a571-63aee7f782a8"]
```

##### GET /jobs/{id} — Detail Job

```bash
curl -u orthanc:orthanc http://localhost:8042/jobs/4e25380b-4073-4356-a571-63aee7f782a8
```

**Response (200 OK):**
```json
{
  "CompletionTime": "20260428T171716.126324",
  "Content": {
    "Description": "REST API",
    "FailedInstancesCount": 0,
    "InstancesCount": 1,
    "IsAnonymization": true,
    "ParentResources": ["b751523b-..."]
  },
  "CreationTime": "20260428T171716.117242",
  "EffectiveRuntime": 0.006,
  "ErrorCode": 2006,
  "ErrorDescription": "The specified path does not point to a regular file",
  "State": "Failure",
  "Type": "ResourceModification"
}
```

**Job States:**

| State | Deskripsi |
|-------|-----------|
| `Pending` | Job dalam antrian, belum diproses |
| `Running` | Job sedang diproses |
| `Success` | Job selesai berhasil |
| `Failure` | Job gagal (cek `ErrorCode` dan `ErrorDescription`) |
| `Paused` | Job dihentikan sementara |

**Error Codes pada Jobs:**

| Code | Deskripsi |
|------|-----------|
| 2006 | File tidak ditemukan di storage (path corrupt) |
| 15 | Bad file format |

---

## 4. Error Handling

### HTTP Status Codes

| Status | Arti | Penyebab Umum |
|--------|------|---------------|
| `200 OK` | Sukses | Request berhasil diproses |
| `201 Created` | Resource baru | POST berhasil membuat resource |
| `400 Bad Request` | Input tidak valid | Format JSON salah, parameter tidak dikenal |
| `401 Unauthorized` | Autentikasi gagal | Tidak ada/tidak valid Basic Auth |
| `404 Not Found` | Resource tidak ditemukan | ID salah, endpoint tidak dikenal |
| `500 Internal Server Error` | Error server | File corrupt, storage bermasalah |

### Format Error Response

Orthanc menggunakan format error JSON yang konsisten:

```json
{
  "HttpError": "Bad Request",
  "HttpStatus": 400,
  "Message": "Deskripsi error yang jelas",
  "Method": "POST",
  "OrthancError": "Error code internal",
  "OrthancStatus": 15,
  "Uri": "/endpoint/yang-diminta"
}
```

### Error Codes

| OrthancStatus | Deskripsi |
|---------------|-----------|
| 15 | Bad file format — file bukan DICOM valid |
| 17 | Unknown resource — endpoint/ID tidak dikenal |
| 2000 | I/O error — masalah filesystem |
| 2006 | File tidak ditemukan — path tidak valid |

### Common Errors & Solusi

**401 Unauthorized:**
```
Cause: Missing or invalid credentials
Solution: Tambahkan header Authorization atau gunakan -u flag
```

**400 Bad Request:**
```
Cause: File DICOM tidak valid saat upload
Solution: Verifikasi file dengan tools/check-dicom.sh
```

**404 Not Found:**
```
Cause: ID resource tidak valid
Solution: Verifikasi ID dari GET /patients atau GET /studies
```

**500 Internal Server Error dengan "Bad file format":**
```
Cause: File DICOM corrupt atau storage bermasalah
Solution: 
1. Cek integritas storage
2. Jalankan POST /tools/reconstruct
3. Periksa log Orthanc
```

---

## 5. Best Practices

### 5.1 Pola Request yang Efisien

**Gunakan `expand` hanya saat perlu:**
```bash
# BURUK: Ambil semua lalu filter
curl -u orthanc:orthanc "http://localhost:8042/patients?expand=true"

# BAIK: Dapatkan ID dulu, lalu detail spesifik
curl -u orthanc:orthanc http://localhost:8042/patients
curl -u orthanc:orthanc http://localhost:8042/patients/{id}
```

**Gunakan `/tools/find` untuk pencarian:**
```bash
# BURUK: Ambil semua pasien lalu filter manual
# BAIK: Cari langsung di server
curl -u orthanc:orthanc -X POST http://localhost:8042/tools/find \
  -H "Content-Type: application/json" \
  -d '{"Level":"Patient","Query":{"PatientName":"SARIYANI*"}}'
```

### 5.2 Pagination

Untuk dataset besar, gunakan parameter `limit` dan `since`:

```bash
# Halaman 1: 100 item
curl -u orthanc:orthanc "http://localhost:8042/patients?limit=100"

# Halaman 2: 100 item, mulai dari ID terakhir halaman 1
curl -u orthanc:orthanc "http://localhost:8042/patients?limit=100&since=b751523b-..."
```

### 5.3 Upload File DICOM

```bash
# Gunakan --data-binary (bukan -d) untuk file binary
curl -u orthanc:orthanc -X POST http://localhost:8042/studies \
  -H "Content-Type: application/dicom" \
  --data-binary @file.dcm

# Upload multiple files
for f in *.dcm; do
  curl -u orthanc:orthanc -X POST http://localhost:8042/studies \
    -H "Content-Type: application/dicom" \
    --data-binary @"$f"
done
```

### 5.4 Error Handling Strategy

```bash
# Script retry dengan exponential backoff
upload_dicom() {
  local file=$1
  local max_retries=3
  local attempt=1

  while [ $attempt -le $max_retries ]; do
    if curl -s -u orthanc:orthanc -X POST http://localhost:8042/studies \
      -H "Content-Type: application/dicom" \
      --data-binary @"$file" > /dev/null 2>&1; then
      echo "✓ $file uploaded (attempt $attempt)"
      return 0
    fi
    echo "✗ $file failed (attempt $attempt), retrying in $((attempt * 2))s..."
    sleep $((attempt * 2))
    attempt=$((attempt + 1))
  done

  echo "✗ $file failed after $max_retries attempts"
  return 1
}
```

### 5.5 Backup & Monitoring

```bash
# Backup reguler via API
curl -u orthanc:orthanc -X POST http://localhost:8042/studies/{id}/archive -o backup_$(date +%Y%m%d).zip

# Monitor via Prometheus metrics
curl -s -u orthanc:orthanc http://localhost:8042/tools/metrics-prometheus | grep orthanc_up_time

# Cek jumlah resource
curl -s -u orthanc:orthanc http://localhost:8042/tools/count-resources
```

---

## 6. Troubleshooting

### Server Tidak Respon

| Kemungkinan | Solusi |
|------------|--------|
| Container tidak running | `podman start server-orthanc` atau `docker start server-orthanc` |
| Port berbeda | Cek konfigurasi: `podman port server-orthanc` |
| Firewall | Pastikan port 8042 terbuka |

### Autentikasi Gagal

```bash
# Test dengan kredensial
curl -u orthanc:orthanc http://localhost:8042/system

# Jika kredensial default tidak work:
# Cek apakah ada konfigurasi custom:
podman exec server-orthanc cat /etc/orthanc/orthanc.json
```

### Upload File Gagal

```bash
# Verifikasi file adalah DICOM valid
./scripts/check-dicom.sh file.dcm

# Cek ukuran file
ls -lh file.dcm

# Pastikan Orthanc tidak read-only
curl -s -u orthanc:orthanc http://localhost:8042/system | grep ReadOnly
```

### Storage Corrupt atau "Bad file format"

Jika endpoint mengembalikan error "Bad file format" pada resource yang sudah ada:

```bash
# 1. Coba rekonstruksi indeks
curl -u orthanc:orthanc -X POST http://localhost:8042/tools/reconstruct

# 2. Cek log
podman logs server-orthanc

# 3. Restart container
podman restart server-orthanc
```

---

## 7. Codebase Documentation Standards

### 7.1 Format Inline Comments

**Untuk function/endpoint handler:**

```python
def get_patient(patient_id: str) -> dict:
    """
    Get patient details by ID.

    Args:
        patient_id: Orthanc internal ID (UUID format)

    Returns:
        dict: Patient data with MainDicomTags

    Raises:
        NotFoundError: If patient_id doesn't exist
    """
    pass
```

```javascript
/**
 * Get patient details by ID.
 * @param {string} patientId - Orthanc internal ID
 * @returns {Promise<Object>} Patient data with MainDicomTags
 * @throws {NotFoundError} If patient doesn't exist
 */
async function getPatient(patientId) { }
```

### 7.2 Template Dokumentasi Endpoint Baru

```markdown
#### {METHOD} /path/{parameter} — Judul Endpoint

Deskripsi satu-dua kalimat tentang apa yang dilakukan endpoint ini.

**Request:**
\`\`\`bash
curl -u orthanc:orthanc -X {METHOD} http://localhost:8042/path/{parameter} \
  -H "Content-Type: application/json" \
  -d '{
    "field": "value"
  }'
\`\`\`

**Parameter:**

| Parameter | Tipe | Wajib | Lokasi | Deskripsi |
|-----------|------|-------|--------|-----------|
| `id` | string | Ya | Path | ID resource |

**Request Body:**

| Field | Tipe | Wajib | Deskripsi |
|-------|------|-------|-----------|
| `field` | string | Ya | Deskripsi field |

**Response (200 OK):**
\`\`\`json
{
  "id": "abc-123",
  "result": true
}
\`\`\`
```

### 7.3 Standar Naming

| Aspek | Standar |
|-------|---------|
| Endpoint paths | `kebab-case` (`/tools/generate-uid`) |
| JSON fields | `PascalCase` (mengikuti konvensi DICOM) |
| Query params | `camelCase` (`?expand=true`) |
| Environment vars | `UPPER_SNAKE_CASE` (`ORTHANC_URL`) |

### 7.4 Pre-Deployment Checklist

- [ ] Semua endpoint telah di-test dengan server live
- [ ] Contoh curl sudah diuji dan berfungsi
- [ ] Response JSON tervalidasi (tidak ada placeholder palsu)
- [ ] Error codes dan solusi didokumentasikan
- [ ] Kredensial default diganti untuk produksi
- [ ] Rate limiting dan timeout tercantum

### 7.5 Tools Rekomendasi

| Tool | Kegunaan |
|------|----------|
| **curl** | Testing CLI cepat |
| **Postman** | GUI untuk eksplorasi API |
| **Insomnia** | Alternatif Postman open-source |
| **OpenAPI/Swagger** | Dokumentasi API otomatis |
| **Prometheus** | Monitoring metrics |
| **Grafana** | Dashboard metrics |

### 7.6 Tips Dokumentasi Efektif

1. **Contoh nyata**: Selalu gunakan response dari server asli, bukan buatan
2. **Satu endpoint per section**: Mudah dicari dan direferensi
3. **Error scenarios**: Dokumentasikan apa yang SALAH, bukan hanya yang benar
4. **Update berkala**: API berubah — dokumentasi harus mengikuti
5. **Bahasa konsisten**: Pilih satu bahasa (Inggris/Indonesia) dan patuhi

---

> **Referensi:**
> - [DOKUMENTASI-ORTHANC.md](./DOKUMENTASI-ORTHANC.md) — Dokumentasi umum server
> - [ORTHANC-CHEAT-SHEET.md](./ORTHANC-CHEAT-SHEET.md) — Cheat sheet perintah cepat
> - [Official Orthanc Book](https://orthanc.uclouvain.be/book/)
> - [Orthanc REST API](https://orthanc.uclouvain.be/api/)
