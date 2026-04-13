# Tutorial Penggunaan Aplikasi Web Orthanc Lengkap

## Daftar Isi
1. [Pengenalan Aplikasi Web](#pengenalan-aplikasi-web)
2. [Dashboard dan Overview](#dashboard-dan-overview)
3. [Navigasi Interface](#navigasi-interface)
4. [Mengelola Pasien](#mengelola-pasien)
5. [Studi dan Series](#studi-dan-series)
6. [Viewer Gambar DICOM](#viewer-gambar-dicom)
7. [Export dan Sharing](#export-dan-sharing)
8. [Search dan Filter](#search-dan-filter)
9. [Tools Utilities](#tools-utilities)
10. [Workflows Otomatis](#workflows-otomatis)
11. [Tips dan Best Practices](#tips-dan-best-practices)

---

## Pengenalan Aplikasi Web

Orthanc web interface adalah GUI yang intuitif untuk mengelola server DICOM. Interface ini dibangun dengan teknologi modern dan menyediakan fitur-fitur lengkap untuk:

- Visualisasi data medis
- Manajemen DICOM files
- Interaksi dengan PACS lain
- Export dan sharing data
- Analytics reporting

### Cara Akses
```
URL: http://localhost:8042
Browser: Chrome, Firefox, Safari, Edge
```

### Requirements Sistem
- JavaScript enabled
- HTML5 support
- Minimal 4GB RAM untuk performa optimal
- Koneksi stabil untuk streaming gambar

---

## Dashboard dan Overview

### 1. Dashboard Utama

#### Informasi Sistem
- **Orthanc Version**: Versi server yang berjalan
- **Memory Usage**: Penggunaan RAM
- **Storage**: Total dan free space
- **Database**: Ukuran dan status
- **Active Connections**: Jumlah koneksi aktif

#### Statistik Real-time
- Total Patients
- Total Studies
- Total Series
- Total Instances
- Incoming studies (24h)
- Exported files

### 2. Monitoring Tools

#### Live Statistics
```javascript
// Update setiap 5 detik
setInterval(() => {
    fetch('/tools/statistics')
        .then(response => response.json())
        .then(data => updateDashboard(data));
}, 5000);
```

#### Performance Metrics
- Response time
- Throughput
- Error rates
- Resource utilization

### 3. Quick Actions
- Refresh all data
- Export statistics
- View logs
- System settings

---

## Navigasi Interface

### 1. Menu Bar

#### Main Navigation
- **Home**: Dashboard
- **Patients**: Daftar pasien
- **Studies**: Studi radiologi
- **Series**: Series gambar
- **Instances**: File DICOM individual
- **Plugins**: Manajemen plugin
- **Tools**: Utilities dan tools

#### Search Bar
- Cepat cari resource
- Filter berdasar kriteria
- Auto-complete support

### 2. Breadcrumb Navigation

```
Home > Patients > John Doe (ID: 123) > Studies > CT Chest (20240101)
```

- Navigasi cepat antar level
- Back button historis
- Direct link access

### 3. View Options

#### Layout Options
- Grid view (default)
- List view
- Table view
- Tree view

#### Display Options
- Thumbnail size
- Sorting options
- Column selection
- Grouping options

---

## Mengelola Pasien

### 1. Patients List

#### View Patients
```javascript
// Menampilkan daftar patients
fetch('/patients')
    .then(response => response.json())
    .then(data => renderPatientsList(data));

// Format response:
{
    "Total": 150,
    "Patients": [
        {
            "ID": "patient-123",
            "MainDicomTags": {
                "PatientName": "John Doe",
                "PatientID": "P001234",
                "BirthDate": "19700101"
            },
            "StudyCount": 5
        }
    ]
}
```

#### Search Patients
- **Patient Name**: John*
- **Patient ID**: P001*
- **Birth Date**: Range picker
- **Gender**: Male/Female
- **Accession Number**: *

### 2. Patient Details

#### Patient Information
```javascript
// Detail patient
fetch('/patients/{patient-id}')
    .then(response => response.json())
    .then(data => showPatientDetails(data));
```

**Informasi Tampil:**
- Demographics
- Clinical data
- Study history
- Related series

#### Actions on Patient
- View studies
- Export data
- Anonymize
- Delete patient
- Share patient

### 3. Bulk Patient Operations

#### Select Multiple Patients
- Checkbox selection
- Range selection
- Filter selection

#### Batch Actions
```javascript
// Anonymize multiple patients
const selectedPatients = ['patient-1', 'patient-2'];

fetch('/tools/batch-anonymize', {
    method: 'POST',
    headers: {'Content-Type': 'application/json'},
    body: JSON.stringify({
        'Resources': selectedPatients,
        'Type': 'Patient'
    })
});
```

---

## Studi dan Series

### 1. Studies Management

#### Studies Overview
- Grouped by patient
- Date range filter
- Modality filter
- Status indicators

#### Study Details
```javascript
// Study metadata
fetch('/studies/{study-id}')
    .then(response => response.json())
    .then(data => renderStudyDetails(data));
```

**Study Information:**
- Study UID
- Study Date/Time
- Accession Number
- Referring Physician
- Study Description
- Modality

#### Study Operations
- View series
- Export study
- Anonymize study
- Delete study
- Add to PACS

### 2. Series Management

#### Series List
```javascript
// Get series for study
fetch('/studies/{study-id}/series')
    .then(response => response.json())
    .then(data => renderSeriesList(data));
```

**Series Information:**
- Series UID
- Series Description
- Modality
- Number of instances
- Acquisition date
- Body part

#### Series Actions
- Open viewer
- Export series
- Anonymize series
- Delete series
- Reconstruct series

### 3. Instance Management

#### Instances List
- Thumbnail preview
- Instance metadata
- File size
- Image dimensions

#### Instance Actions
- View instance
- Export instance
- Delete instance
- Anonymize instance
- Convert format

---

## Viewer Gambar DICOM

### 1. DICOM Viewer Interface

#### Layout Options
1. **Single View**: Gambar tunggal
2. **Dual View**: 2 gambar sekaligus
3. **Quad View**: 4 gambar sekaligus
4. **Stack View**: Multiple slices
5. **3D View**: Rekonstruksi 3D

#### View Controls
```javascript
// Basic viewer controls
const viewer = new OrthancViewer({
    element: '#viewer-container',
    studyId: 'study-123',
    
    // View options
    layout: 'dual',
    synchronize: true,
    
    // Display options
    windowWidth: 400,
    windowLevel: 40,
    invert: false,
    
    // Tools
    tools: ['zoom', 'pan', 'measure', 'roi']
});
```

### 2. Image Manipulation

#### Window/Level Adjustment
```javascript
// Window/Level presets
const presets = {
    'lung': { width: 1500, level: -600 },
    'bone': { width: 2000, level: 400 },
    'brain': { width: 80, level: 40 },
    'abdomen': { width: 400, level: 60 }
};

// Apply preset
viewer.applyWindowLevel(presets.brain);
```

#### Measurement Tools
1. **Distance**: Measure distance between points
2. **Angle**: Measure angles
3. **ROI**: Region of Interest area
4. **Calibration**: Real measurements

```javascript
// Add measurement
const measurement = viewer.addMeasurement({
    type: 'distance',
    points: [{x: 100, y: 100}, {x: 200, y: 100}],
    color: 'red',
    label: 'Lesion size'
});
```

#### Annotation Tools
- Arrow annotation
- Text annotation
- Freehand drawing
- Shape annotation
- Stamp tool

### 3. Advanced Features

#### Multi-Planar Reconstruction (MPR)
```javascript
// MPR setup
const mprViewer = new OrthancMPRViewer({
    axial: viewer1,
    coronal: viewer2,
    sagittal: viewer3,
    
    // Synchronize navigation
    synchronize: true,
    
    // Crosshair
    crosshair: {
        color: 'yellow',
        width: 2
    }
});
```

#### 3D Reconstruction
```javascript
// Create 3D volume
const volume3D = viewer.create3D({
    type: 'volume',
    series: ['series-1', 'series-2'],
    
    // Rendering options
    renderMode: 'maximum',
    threshold: 100,
    
    // Post-processing
    smoothing: true,
    isosurface: true
});
```

#### Movie Playback
```javascript
// Play movie
const moviePlayer = viewer.playMovie({
    frames: 100,
    fps: 30,
    loop: true,
    direction: 'forward'
});

// Control playback
moviePlayer.play();
moviePlayer.pause();
moviePlayer.seek(50); // Go to frame 50
```

---

## Export dan Sharing

### 1. Export Formats

#### DICOM Export
```javascript
// Export DICOM
const exportOptions = {
    format: 'dicom',
    compression: 'none',
    anonymize: false,
    includeMetadata: true
};

fetch('/studies/{study-id}/export', {
    method: 'POST',
    headers: {'Content-Type': 'application/json'},
    body: JSON.stringify(exportOptions)
});
```

#### Common Formats
- **DICOM**: Standar medical format
- **JPEG**: Web display
- **PNG**: Lossless compression
- **TIFF**: High quality
- **BMP**: Windows bitmap
- **NIFTI**: Neuroimaging

#### Archive Formats
- **ZIP**: Compressed archive
- **TAR**: Unix archive
- **RAR**: WinRAR format

### 2. Media Creation

#### CD/DVD Burning
```javascript
// Create DICOM-CD
fetch('/studies/{study-id}/media', {
    method: 'POST',
    headers: {'Content-Type': 'application/json'},
    body: JSON.stringify({
        type: 'dicom-cd',
        format: 'iso',
        includeViewer: true
    })
});
```

#### USB Drive Creation
```javascript
// Create DICOM-USB
const usbExport = {
    studies: ['study-1', 'study-2'],
    format: 'dicom-usb',
    viewer: 'orthanc-viewer',
    metadata: true
};
```

### 3. Sharing Options

#### Email Export
```javascript
// Export via email
const emailExport = {
    to: 'doctor@hospital.com',
    subject: 'Patient Study - John Doe',
    body: 'Please find attached the requested study',
    studies: ['study-123'],
    format: 'dicom-zip'
};

fetch('/tools/email-export', {
    method: 'POST',
    headers: {'Content-Type': 'application/json'},
    body: JSON.stringify(emailExport)
});
```

#### Cloud Storage
```javascript
// Upload to cloud
const cloudUpload = {
    provider: 'aws',
    bucket: 'orthanc-storage',
    studies: ['study-123'],
    acl: 'private'
};

fetch('/tools/cloud-upload', {
    method: 'POST',
    headers: {'Content-Type': 'application/json'},
    body: JSON.stringify(cloudUpload)
});
```

#### PACS Transfer
```javascript
// Transfer to PACS
const pacsTransfer = {
    aet: 'REMOTE-PACS',
    studies: ['study-123'],
    priority: 'normal',
    compress: true
};

fetch('/tools/pacs-transfer', {
    method: 'POST',
    headers: {'Content-Type': 'application/json'},
    body: JSON.stringify(pacsTransfer)
});
```

---

## Search dan Filter

### 1. Advanced Search

#### Search Interface
```javascript
// Search builder
const searchBuilder = new SearchBuilder({
    // Available fields
    fields: [
        'PatientName',
        'PatientID',
        'StudyDate',
        'StudyDescription',
        'Modality',
        'AccessionNumber'
    ],
    
    // Operators
    operators: [
        'equals',
        'contains',
        'starts-with',
        'ends-with',
        'greater-than',
        'less-than',
        'between'
    ],
    
    // Logical operators
    logical: ['AND', 'OR', 'NOT']
});
```

#### Search Examples

##### Simple Search
```javascript
// Patient name search
const criteria = {
    field: 'PatientName',
    operator: 'contains',
    value: 'John'
};
```

##### Complex Search
```javascript
// Multiple criteria
const searchQuery = {
    logical: 'AND',
    conditions: [
        {
            field: 'PatientName',
            operator: 'contains',
            value: 'John'
        },
        {
            logical: 'OR',
            conditions: [
                {
                    field: 'Modality',
                    operator: 'equals',
                    value: 'CT'
                },
                {
                    field: 'Modality',
                    operator: 'equals',
                    value: 'MRI'
                }
            ]
        }
    ]
};
```

### 2. Saved Searches

#### Create Saved Search
```javascript
// Save search template
const savedSearch = {
    name: 'Emergency CT Scans',
    description: 'All CT scans from emergency department',
    criteria: {
        // Search criteria here
    },
    shared: true,
    schedule: {
        enabled: true,
        frequency: 'daily',
        recipients: ['radiologist@hospital.com']
    }
};

fetch('/tools/saved-searches', {
    method: 'POST',
    headers: {'Content-Type': 'application/json'},
    body: JSON.stringify(savedSearch)
});
```

#### Apply Saved Search
```javascript
// Execute saved search
fetch('/tools/saved-searches/emergency-ct/run')
    .then(response => response.json())
    .then(data => displayResults(data));
```

### 3. Filter Interface

#### Quick Filters
- **Date Range**: Today, Last 7 days, Last 30 days
- **Modality**: All, CT, MRI, X-Ray, Ultrasound
- **Status**: All, New, Reviewed, Archived
- **Priority**: Normal, Urgent, STAT

#### Custom Filters
```javascript
// Create custom filter
const customFilter = {
    name: 'Cardiac Studies',
    icon: 'heart',
    conditions: {
        StudyDescription: 'Cardiac*',
        Modality: ['CT', 'MR'],
        StudyDate: {
            from: '2024-01-01',
            to: '2024-12-31'
        }
    }
};
```

---

## Tools Utilities

### 1. DICOM Utilities

#### DICOM Anonymizer
```javascript
// Anonymize study
const anonymizationOptions = {
    removeTags: [
        'PatientName',
        'PatientID',
        'StudyInstanceUID',
        'SeriesInstanceUID'
    ],
    replaceTags: {
        'PatientName': 'ANONYMOUS',
        'PatientID': 'ANON_' + Math.random().toString(36).substr(2, 9),
        'AccessionNumber': 'ACC_' + Date.now()
    },
    keepUIDs: false
};

fetch('/tools/anonymize', {
    method: 'POST',
    headers: {'Content-Type': 'application/json'},
    body: JSON.stringify({
        resources: ['study-123'],
        options: anonymizationOptions
    })
});
```

#### DICOM Validator
```javascript
// Validate DICOM files
const validationOptions = {
    checkSyntax: true,
    checkHeaders: true,
    checkPixelData: true,
    strictMode: false
};

fetch('/tools/validate', {
    method: 'POST',
    headers: {'Content-Type': 'application/json'},
    body: JSON.stringify({
        files: ['instance-1', 'instance-2'],
        options: validationOptions
    })
});
```

### 2. Reconstruction Tools

#### Series Reconstruction
```javascript
// Reconstruct series
const reconstructionOptions = {
    type: 'corrected',
    method: 'slice-by-slice',
    interpolation: 'cubic',
    smoothing: true,
    autoOrient: true
};

fetch('/series/{series-id}/reconstruct', {
    method: 'POST',
    headers: {'Content-Type': 'application/json'},
    body: JSON.stringify(reconstructionOptions)
});
```

#### MIP/MPR Reconstruction
```javascript
// Create MIP
const mipOptions = {
    method: 'maximum',
    threshold: -1000,
    resolution: 'original'
};

fetch('/series/{series-id}/mip', {
    method: 'POST',
    headers: {'Content-Type': 'application/json'},
    body: JSON.stringify(mipOptions)
});
```

### 3. Reporting Tools

#### Structured Reporting
```javascript
// Generate SR report
const srTemplate = {
    type: 'StructuredReport',
    template: 'RadiologyReport',
    data: {
        findings: 'Normal chest X-ray',
        impression: 'No acute abnormality',
        recommendations: 'Follow up in 1 year'
    },
    author: 'Dr. Smith',
    date: new Date().toISOString()
};

fetch('/tools/generate-sr', {
    method: 'POST',
    headers: {'Content-Type': 'application/json'},
    body: JSON.stringify(srTemplate)
});
```

#### Report Export
```javascript
// Export report
const reportExport = {
    format: 'pdf',
    includeImages: true,
    template: 'professional',
    watermark: 'CONFIDENTIAL'
};

fetch('/tools/export-report', {
    method: 'POST',
    headers: {'Content-Type': 'application/json'},
    body: JSON.stringify(reportExport)
});
```

---

## Workflows Otomatis

### 1. Lua Scripting

#### Simple Workflow
```lua
-- Auto-anonymize incoming studies
function OnIncomingStudy(studyId)
    -- Get study details
    local study = OrthancApiClient:GetStudy(studyId)
    
    -- Check if study needs anonymization
    if study.Tags.PatientID:find("^P") then
        -- Anonymize the study
        OrthancApiClient:AnonymizeStudy(studyId)
        
        -- Log the action
        OrthancApiClient:Log("Anonymized study: " .. studyId)
        
        -- Notify radiologist
        OrthancApiClient:SendEmail({
            to = "radiologist@hospital.com",
            subject = "New anonymized study",
            body = "Study " .. studyId .. " has been anonymized"
        })
    end
end
```

#### Complex Workflow
```lua
-- Patient registration workflow
function OnInstanceReceived(instanceId)
    local instance = OrthancApiClient:GetInstance(instanceId)
    local study = OrthancApiClient:GetStudy(instance.ParentStudy)
    
    -- Check if patient exists
    local patient = OrthancApiClient:FindPatient({
        PatientID = instance.Tags.PatientID
    })
    
    if not patient then
        -- Create new patient
        patient = OrthancApiClient:CreatePatient({
            PatientName = instance.Tags.PatientName,
            PatientID = instance.Tags.PatientID,
            BirthDate = instance.Tags.BirthDate
        })
        
        -- Assign to study
        OrthancApiClient:SetStudyPatient(study.Id, patient.Id)
        
        -- Create patient record in EMR
        OrthancApiClient:CreateEMRRecord(patient.Id)
    end
    
    -- Assign study to radiologist
    OrthancApiClient:AssignStudy(study.Id, "radiologist@hospital.com")
    
    -- Add to PACS queue
    OrthancApiClient:AddToPACSQueue(study.Id)
end
```

### 2. Event Handlers

#### Change Events
```javascript
// Listen for changes
const socket = new WebSocket('ws://localhost:8042/ws');

socket.onmessage = function(event) {
    const change = JSON.parse(event.data);
    
    switch(change.changeType) {
        case 'NewInstance':
            handleNewInstance(change.resource);
            break;
        case 'StableStudy':
            handleStableStudy(change.resource);
            break;
        case 'DeletedResource':
            handleDeletedResource(change.resource);
            break;
    }
};
```

#### Custom Events
```javascript
// Trigger custom event
function triggerCustomEvent(eventType, data) {
    fetch('/events', {
        method: 'POST',
        headers: {'Content-Type': 'application/json'},
        body: JSON.stringify({
            type: eventType,
            data: data,
            timestamp: new Date().toISOString()
        })
    });
}
```

### 3. Scheduled Tasks

#### Scheduled Reports
```javascript
// Create scheduled report
const scheduledReport = {
    name: 'Daily Summary',
    schedule: {
        type: 'cron',
        expression: '0 8 * * *'  // Every day at 8 AM
    },
    report: {
        type: 'statistics',
        format: 'pdf'
    },
    recipients: ['admin@hospital.com']
};

fetch('/tools/schedule', {
    method: 'POST',
    headers: {'Content-Type': 'application/json'},
    body: JSON.stringify(scheduledReport)
});
```

#### Cleanup Tasks
```javascript
// Schedule cleanup
const cleanupTask = {
    name: 'Cleanup Old Studies',
    schedule: {
        type: 'daily',
        time: '02:00'
    },
    action: {
        type: 'delete',
        criteria: {
            StudyDate: {
                before: '2023-01-01',
                modality: ['XRAY', 'MG']
            }
        }
    }
};
```

---

## Tips dan Best Practices

### 1. Performance Tips

#### Caching Strategy
- Enable browser caching
- Use CDN for static resources
- Implement lazy loading
- Optimize image compression

```javascript
// Enable viewer caching
const viewer = new OrthancViewer({
    cache: true,
    cacheSize: 1000,
    preload: true
});
```

#### Network Optimization
- Use HTTP/2
- Implement compression
- Minimize API calls
- Use Web Workers

```javascript
// Batch API calls
async function batchFetch(ids) {
    const promises = ids.map(id => 
        fetch(`/instances/${id}`).then(r => r.json())
    );
    return Promise.all(promises);
}
```

### 2. Security Best Practices

#### Authentication
```javascript
// Implement token refresh
let authToken = localStorage.getItem('authToken');

async function refreshToken() {
    const response = await fetch('/refresh-token', {
        method: 'POST',
        headers: {
            'Authorization': `Bearer ${authToken}`
        }
    });
    
    const data = await response.json();
    authToken = data.token;
    localStorage.setItem('authToken', authToken);
}
```

#### Input Validation
```javascript
// Validate search input
function validateSearchInput(value) {
    if (!value || value.length < 3) {
        throw new Error('Search term must be at least 3 characters');
    }
    
    // DICOM tag validation
    if (value.includes('\\')) {
        // Contains escape sequences
        value = value.replace(/\\/g, '\\\\');
    }
    
    return value;
}
```

### 3. Accessibility

#### Screen Reader Support
```html
<!-- Accessible viewer controls -->
<button 
    aria-label="Increase window width"
    onclick="adjustWindowWidth(10)"
    title="Increase window width">
    +
</button>
```

#### Keyboard Navigation
```javascript
// Keyboard shortcuts
document.addEventListener('keydown', (e) => {
    switch(e.key) {
        case 'ArrowUp':
            adjustWindowLevel(10);
            break;
        case 'ArrowDown':
            adjustWindowLevel(-10);
            break;
        case 'ArrowLeft':
            adjustWindowWidth(-10);
            break;
        case 'ArrowRight':
            adjustWindowWidth(10);
            break;
    }
});
```

### 4. Error Handling

#### User-Friendly Errors
```javascript
// Error handling
async function loadResource(id) {
    try {
        const response = await fetch(`/resources/${id}`);
        
        if (!response.ok) {
            throw new Error(`HTTP error! status: ${response.status}`);
        }
        
        return await response.json();
    } catch (error) {
        showError(`Failed to load resource: ${error.message}`);
        // Fallback or retry
        return loadFallbackResource(id);
    }
}
```

#### Logging
```javascript
// Implement logging
const logger = {
    info: (message) => console.log('[INFO]', message),
    warn: (message) => console.warn('[WARN]', message),
    error: (error) => console.error('[ERROR]', error),
    
    // Structured logging
    logEvent: (event) => {
        const log = {
            timestamp: new Date().toISOString(),
            level: event.level,
            message: event.message,
            data: event.data
        };
        sendToLogServer(log);
    }
};
```

### 5. Integration Patterns

#### PACS Integration
```javascript
// Integrate with PACS
const pacsIntegration = {
    // Connect to PACS
    connect: async () => {
        const response = await fetch('/pacs/connect', {
            method: 'POST',
            body: JSON.stringify({
                aet: 'ORTHANC',
                address: '192.168.1.100',
                port: 4242
            })
        });
        return await response.json();
    },
    
    // Query PACS
    query: async (criteria) => {
        const response = await fetch('/pacs/query', {
            method: 'POST',
            body: JSON.stringify(criteria)
        });
        return await response.json();
    }
};
```

#### EMR Integration
```javascript
// EMR integration
const emrIntegration = {
    // Send study to EMR
    sendStudy: async (studyId, patientData) => {
        const response = await fetch('/emr/study', {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json',
                'Authorization': `Bearer ${getAuthToken()}`
            },
            body: JSON.stringify({
                studyId: studyId,
                patient: patientData
            })
        });
        return await response.json();
    },
    
    // Get EMR data
    getEMRData: async (patientId) => {
        const response = await fetch(`/emr/patient/${patientId}`);
        return await response.json();
    }
};
```

### 6. Development Tips

#### Modular Architecture
```javascript
// Modular viewer components
const OrthancViewer = {
    // Core functionality
    core: {
        loadStudy: loadStudy,
        renderImage: renderImage,
        applyWindowLevel: applyWindowLevel
    },
    
    // Extensions
    extensions: {
        measurements: MeasurementExtension,
        annotations: AnnotationExtension,
        tools: ToolsExtension
    },
    
    // Initialize
    init: function(config) {
        // Initialize core
        this.core.init(config);
        
        // Load extensions
        Object.keys(this.extensions).forEach(ext => {
            if (config.extensions && config.extensions.includes(ext)) {
                this.extensions[ext].init(this.core);
            }
        });
    }
};
```

#### Testing
```javascript
// Unit tests
describe('OrthancViewer', () => {
    beforeEach(() => {
        viewer = new OrthancViewer({
            element: document.createElement('div')
        });
    });
    
    test('should load study', async () => {
        const studyId = 'study-123';
        await viewer.loadStudy(studyId);
        expect(viewer.currentStudy).toBe(studyId);
    });
    
    test('should apply window level', () => {
        viewer.applyWindowLevel({width: 400, level: 40});
        expect(viewer.windowWidth).toBe(400);
        expect(viewer.windowLevel).toBe(40);
    });
});
```

---

## Resources

### Documentation
- [Orthanc Documentation](https://orthanc.uclouvain.be/book/)
- [DICOM Standard](https://medical.nema.org/)
- [Web Viewer Documentation](https://orthanc.uclouvain.be/book/users/web viewer.html)

### Tools
- [DICOM Toolkit](https://www.dcm4che.org/)
- [Cornerstone.js](https://cornerstonejs.org/)
- [DICOM Anonymizer](https://github.com/microsoft/ML-for-Health-on-Azure/tree/main/Anonymize-DICOM)

### Community
- [Orthanc Forum](https://www.orthanc-server.com/forum/)
- [GitHub Repository](https://github.com/jodogne/orthanc-server)
- [Stack Overflow](https://stackoverflow.com/questions/tagged/orthanc)

---

**Note**: Tutorial ini mencakup penggunaan lengkap aplikasi web Orthanc. Pastikan untuk selalu merujuk ke dokumentasi resmi untuk versi terbaru dan informasi terkini.