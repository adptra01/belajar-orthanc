# 05. Memasang & Menggunakan Plugin Orthanc

## 📋 Apa yang akan Anda Pelajari

- Pengenalan sistem plugin Orthanc
- Cara mencari dan download plugin
- Install plugin manual dan via Docker
- Konfigurasi plugin settings
- Plugin popular dan fungsinya
- Troubleshooting plugin issues

---

## 🎯 Pengenalan Plugin

### Apa itu Plugin?
Plugin adalah komponen ekstensi yang memperluas fungsi Orthanc tanpa mengubah kode inti. Plugin memungkinkan:

- **Fitur tambahan** (viewer, export, automation)
- **Format file support** baru
- **Integrasi** dengan sistem lain
- **Custom workflows** dan automation

### Jenis Plugin
```yaml
Core Plugins (Built-in):
- Web Viewer: Tampilan gambar DICOM
- Lua Scripting: Automation dan scripting
- PDF Export: Export ke PDF
- Video Support: Video medical

Third-party Plugins:
- PACS Integration: Koneksi ke PACS lain
- DICOM Structured Reporting: SR support
- Compression: Lossless compression
- Custom Auth: Authentication kustom
```

---

## 📦 Mencari & Download Plugin

### Official Plugin Repository
**URL**: [https://orthanc.uclouvain.be/plugins/](https://orthanc.uclouvain.be/plugins/)

### Plugin Categories
```markdown
1. **Image Processing**
   - Web Viewer
   - JPEG2000 Support
   - 3D Reconstruction
   
2. **Export & Sharing**
   - PDF Export
   - Video Export
   - DICOM-CD Creator
   
3. **Automation**
   - Lua Scripts
   - JavaScript Support
   - Workflow Engine
   
4. **Integration**
   - PACS Connectors
   - Database Connectors
   - EMR Integration
   
5. **Security**
   - Authentication Plugins
   - Encryption Plugins
   - Audit Logs
```

### Download Plugin
```bash
# Download plugin terbaru
wget https://orthanc.uclouvain.be/downloads/plugin-name.zip

# Atau menggunakan curl
curl -L -o plugin-name.zip https://orthanc.uclouvain.be/downloads/plugin-name.zip

# Extract plugin
unzip plugin-name.zip
cd plugin-name
```

---

## 🔧 Install Plugin

### Method 1: Manual Installation

#### Linux
```bash
# Create plugin directory
sudo mkdir -p /usr/share/orthanc/plugins

# Copy plugin
sudo cp libPluginName.so /usr/share/orthanc/plugins/

# Set permissions
sudo chmod 755 /usr/share/orthanc/plugins/libPluginName.so

# Restart Orthanc
sudo systemctl restart orthanc
```

#### Windows
```batch
# Create plugins directory
mkdir C:\Orthanc\plugins

# Copy plugin
copy plugin-name.dll C:\Orthanc\plugins\

# Restart Orthanc service
net stop orthanc
net start orthanc
```

#### macOS
```bash
# Create plugins directory
sudo mkdir -p /usr/local/share/orthanc/plugins

# Copy plugin
sudo cp libPluginName.dylib /usr/local/share/orthanc/plugins/

# Restart Orthanc
brew services restart orthanc
```

### Method 2: Docker Installation

#### Option A: Volume Mount
```yaml
# docker-compose.yml
services:
  orthanc:
    image: jodogne/orthanc-plugins:latest
    container_name: orthanc-server
    volumes:
      - ./plugins:/usr/share/orthanc/plugins
      - ./orthanc-data:/var/lib/orthanc/db
      - ./orthanc.json:/etc/orthanc/orthanc.json
```

#### Option B: Build Custom Image
```dockerfile
# Dockerfile
FROM jodogne/orthanc-plugins:latest

# Copy plugins
COPY plugins/ /usr/share/orthanc/plugins/

# Install additional dependencies if needed
RUN apt-get update && apt-get install -y \
    python3 \
    && rm -rf /var/lib/apt/lists/*

# Configure Orthanc
COPY orthanc.json /etc/orthanc/orthanc.json

CMD ["Orthanc"]
```

#### Build and Run
```bash
# Build custom image
docker build -t orthanc-with-plugins .

# Run with custom image
docker run -d \
  -p 8042:8042 \
  -p 4242:4242 \
  -v $(pwd)/orthanc-data:/var/lib/orthanc/db \
  orthanc-with-plugins
```

### Method 3: Plugin Manager (Advanced)

#### Create Plugin Manager Script
```bash
#!/bin/bash
# scripts/plugin-manager.sh

PLUGINS_DIR="./plugins"
ORTHANC_DIR="/usr/share/orthanc/plugins"
CONFIG_FILE="./orthanc.json"

# Install plugin
install_plugin() {
    local plugin_name=$1
    local plugin_url=$2
    
    echo "Installing $plugin_name..."
    
    # Download
    wget -O "$plugin_name.zip" "$plugin_url"
    
    # Extract
    unzip -o "$plugin_name.zip"
    local plugin_dir=$(find . -maxdepth 1 -type d -name "$plugin_name*")
    
    if [ -d "$plugin_dir" ]; then
        # Find plugin file
        local plugin_file=$(find "$plugin_dir" -name "*.so" -o -name "*.dll" -o -name "*.dylib")
        
        if [ -n "$plugin_file" ]; then
            # Copy to plugins directory
            cp "$plugin_file" "$PLUGINS_DIR/"
            echo "✓ Plugin $plugin_name installed successfully"
        else
            echo "✗ Plugin file not found in $plugin_dir"
        fi
    else
        echo "✗ Plugin directory not found"
    fi
    
    # Cleanup
    rm -f "$plugin_name.zip"
    rm -rf "$plugin_dir"
}

# List installed plugins
list_plugins() {
    echo "Installed Plugins:"
    ls -la $PLUGINS_DIR/ | grep -E '\.(so|dll|dylib)$'
}

# Update plugin configuration
update_config() {
    local plugin_name=$1
    local config=$2
    
    # Add to orthanc.json
    jq --arg plugin "$plugin_name" --argjson config "$config" '
    .Plugins[$plugin] = $config | 
    .LuaScripts.Enabled = true |
    .WebViewer.Enabled = true
    ' orthanc.json > tmp.json && mv tmp.json orthanc.json
    
    echo "Configuration updated for $plugin_name"
}

# Usage
case "$1" in
    install)
        install_plugin "$2" "$3"
        ;;
    list)
        list_plugins
        ;;
    config)
        update_config "$2" "$3"
        ;;
    *)
        echo "Usage: $0 {install|list|config} [args]"
        echo "  install <plugin-name> <download-url>"
        echo "  list"
        echo "  config <plugin-name> <json-config>"
        ;;
esac
```

---

## ⚙️ Konfigurasi Plugin

### Basic Configuration
```json
// orthanc.json
{
  "Name": "Orthanc with Plugins",
  "HttpPort": 8042,
  "DicomPort": 4242,
  "Plugins": {
    "Enabled": true,
    "Directory": "/usr/share/orthanc/plugins"
  },
  "LuaScripts": {
    "Enabled": true,
    "Directory": "/etc/orthanc/scripts",
    "AutoExecute": true
  },
  "WebViewer": {
    "Enabled": true,
    "CacheDirectory": "/tmp/orthanc-viewer",
    "MaxCacheSize": 1000
  }
}
```

### Plugin-Specific Configuration

#### Web Viewer Configuration
```json
{
  "WebViewer": {
    "Enabled": true,
    "CacheDirectory": "/tmp/orthanc-viewer",
    "MaxCacheSize": 2000,
    "TileSize": 512,
    "MaxConcurrency": 10,
    "Compression": true,
    "EnableMeasurements": true,
    "EnableAnnotations": true,
    "Enable3D": true,
    "EnableMPR": true
  }
}
```

#### PDF Export Configuration
```json
{
  "PdfExport": {
    "Enabled": true,
    "Template": "default",
    "Dpi": 300,
    "Compression": "jpeg",
    "Watermark": "CONFIDENTIAL",
    "IncludeImages": true,
    "IncludeMetadata": true,
    "OutputFormat": "A4"
  }
}
```

#### Lua Scripting Configuration
```json
{
  "LuaScripts": {
    "Enabled": true,
    "Directory": "/etc/orthanc/scripts",
    "AutoExecute": true,
    "GlobalVariables": {
      "hospital_name": "RS Example",
      "max_file_size": 104857600
    }
  }
}
```

#### PACS Integration Configuration
```json
{
  "PACSIntegration": {
    "Enabled": true,
    "Modalities": {
      "REMOTE-PACS": {
        "Address": "192.168.1.100",
        "Port": 4242,
        "AET": "PACS-AET",
        "Timeout": 30
      }
    },
    "FindSCU": {
      "AET": "ORTHANC-FIND",
      "CalledAET": "ANY-SCP",
      "Timeout": 30
    },
    "StoreSCU": {
      "AET": "ORTHANC-STORE",
      "CalledAET": "PACS-AET",
      "Timeout": 60
    }
  }
}
```

---

## 📦 Plugin Popular dan Cara Install

### 1. Web Viewer Plugin

#### Install
```bash
# Download Web Viewer plugin
wget https://orthanc.uclouvain.be/downloads/OrthancWebViewer.zip

# Extract
unzip OrthancWebViewer.zip
cd OrthancWebViewer/Linux/

# Copy plugin
sudo cp libOrthancWebViewer.so /usr/share/orthanc/plugins/

# Update configuration
jq '.WebViewer.Enabled = true' orthanc.json > tmp.json && mv tmp.json orthanc.json
```

#### Configuration
```json
{
  "WebViewer": {
    "Enabled": true,
    "CacheDirectory": "/tmp/orthanc-webviewer",
    "MaxCacheSize": 500,
    "TileSize": 256,
    "MaxConcurrency": 5
  }
}
```

#### Usage
1. Restart Orthanc
2. Akses `http://localhost:8042/viewer`
3. Pilih series untuk ditampilkan
4. Gunakan tools measurements, annotations, dll.

### 2. Lua Scripting Plugin

#### Install
```bash
# Lua scripting biasanya included dengan Orthanc plugins
# Cek apakah sudah ada
ls /usr/share/orthanc/plugins/ | grep -i lua

# Jika tidak ada, download
wget https://orthanc.uclouvain.be/downloads/OrthancLuaScripting.zip
unzip OrthancLuaScripting.zip
sudo cp libOrthancLua.so /usr/share/orthanc/plugins/
```

#### Create Sample Script
```bash
# Create scripts directory
mkdir -p /etc/orthanc/scripts

# Create sample script
cat > /etc/orthanc/scripts/hello.lua << 'EOF'
function OnChange(change)
    -- Log semua perubahan
    OrthancApiClient:Log("Change detected: " .. change.changeType)
    
    -- Contoh: Auto-anonymize instance baru
    if change.changeType == "NewInstance" then
        local instanceId = change.resource.id
        OrthancApiClient:AnonymizeInstance(instanceId)
        OrthancApiClient:Log("Instance " .. instanceId .. " anonymized")
    end
end
EOF

# Set permissions
chmod 755 /etc/orthanc/scripts/hello.lua
```

#### Configuration
```json
{
  "LuaScripts": {
    "Enabled": true,
    "Directory": "/etc/orthanc/scripts",
    "AutoExecute": ["hello.lua"]
  }
}
```

### 3. PDF Export Plugin

#### Install
```bash
# Download PDF Export plugin
wget https://orthanc.uclouvain.be/downloads/OrthancPdf.zip

# Extract
unzip OrthancPdf.zip
cd OrthancPdf/Linux/

# Copy plugin
sudo cp libOrthancPdf.so /usr/share/orthanc/plugins/

# Update configuration
jq '.PdfExport.Enabled = true' orthanc.json > tmp.json && mv tmp.json orthanc.json
```

#### Usage via API
```bash
# Export study as PDF
curl -X POST http://localhost:8042/studies/<study-id>/pdf \
  -H "Content-Type: application/json" \
  -d '{
    "Format": "A4",
    "Quality": "high",
    "IncludeImages": true,
    "Watermark": "MEDICAL REPORT"
  }'
```

### 4. Video Plugin

#### Install
```bash
# Download Video plugin
wget https://orthanc.uclouvain.be/downloads/OrthancVideo.zip

# Extract dan install
unzip OrthancVideo.zip
sudo cp libOrthancVideo.so /usr/share/orthanc/plugins/
```

#### Configuration
```json
{
  "Video": {
    "Enabled": true,
    "Format": "mp4",
    "Codec": "h264",
    "Quality": "high",
    "FrameRate": 30
  }
}
```

---

## 🛠️ Plugin Development

### Create Simple Plugin
```c
// simple-plugin.c
#include <orthanc/OrthancCPlugin.h>

ORTHANC_PLUGIN_ENTRY(OrthancPluginService)
{
  OrthancPluginSetDescription(service, "Simple plugin example");
  
  // Register callback
  OrthancPluginRegisterCallback(
    service,
    OrthancPluginCallback_OnChange,
    OnChangeCallback,
    NULL
  );
  
  return 0;
}

static OrthancPluginErrorCode OnChangeCallback(
  OrthancPluginService* service,
  OrthancPluginChangeType changeType,
  const char* resourceType,
  OrthancPluginResource* resource,
  void* userData)
{
  // Log changes
  OrthancPluginLogInfo(service, "Change detected: %d", changeType);
  
  return OrthancPluginErrorCode_Success;
}
```

### Build Plugin
```bash
# Install build tools
sudo apt install build-essential cmake

# Create build directory
mkdir build
cd build

# Build
cmake .. -DCMAKE_BUILD_TYPE=Release
make -j4

# Result: libSimplePlugin.so
```

---

## 🔍 Troubleshooting Plugin

### Common Issues

#### Plugin Not Loading
```bash
# Check plugin directory
ls -la /usr/share/orthanc/plugins/

# Check Orthanc logs
tail -f /var/log/orthanc/orthanc.log | grep -i plugin

# Check plugin dependencies
ldd /usr/share/orthanc/plugins/libPluginName.so
```

#### Plugin Configuration Issues
```bash
# Validate JSON configuration
jq . orthanc.json

# Check plugin-specific settings
curl http://localhost:8042/system | jq '.Plugins'

# Test individual plugin
curl -X POST http://localhost:8042/scripts/execute \
  -H "Content-Type: application/json" \
  -d '{"script": "return OrthancApiClient:GetSystem()"}'
```

#### Performance Issues
```bash
# Monitor plugin performance
curl http://localhost:8042/tools/performance

# Check memory usage
docker stats orthanc-server

# Enable debug logging
jq '.LogLevel = "debug"' orthanc.json > tmp.json && mv tmp.json orthanc.json
```

### Debug Commands
```bash
# Enable plugin debug mode
export ORTHANC_DEBUG=1
docker-compose restart orthanc

# Check plugin versions
curl http://localhost:8042/system | jq '.Plugins[]'

# Test plugin API
curl -X GET http://localhost:8042/tools | jq '.'
```

### Plugin Recovery
```bash
# Backup current plugins
cp -r /usr/share/orthanc/plugins /backup/plugins-$(date +%Y%m%d)

# Remove problematic plugin
mv /usr/share/orthanc/plugins/libProblematic.so /tmp/

# Restart Orthanc
docker-compose restart orthanc

# Test without plugin
curl -X GET http://localhost:8042/system
```

---

## 📋 Plugin Management Script

### Complete Plugin Manager
```bash
#!/bin/bash
# scripts/plugin-manager.sh

set -e

PLUGINS_DIR="./plugins"
BACKUP_DIR="./backups/plugins"
CONFIG_FILE="./orthanc.json"

# Color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

log() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Install plugin
install_plugin() {
    local plugin_name=$1
    local plugin_url=$2
    
    log "Installing plugin: $plugin_name"
    
    # Create directories
    mkdir -p $PLUGINS_DIR $BACKUP_DIR
    
    # Download
    if [ ! -f "$plugin_name.zip" ]; then
        log "Downloading plugin..."
        wget -O "$plugin_name.zip" "$plugin_url" || {
            error "Failed to download plugin"
            exit 1
        }
    fi
    
    # Extract
    local plugin_dir=$(find . -maxdepth 1 -type d -name "$plugin_name*" | head -1)
    if [ -z "$plugin_dir" ]; then
        log "Extracting plugin..."
        unzip -o "$plugin_name.zip"
        plugin_dir=$(find . -maxdepth 1 -type d -name "$plugin_name*" | head -1)
    fi
    
    if [ ! -d "$plugin_dir" ]; then
        error "Plugin directory not found"
        exit 1
    fi
    
    # Find plugin file
    local plugin_file=$(find "$plugin_dir" -name "*.so" -o -name "*.dll" -o -name "*.dylib" | head -1)
    if [ -z "$plugin_file" ]; then
        error "Plugin file not found"
        exit 1
    fi
    
    # Backup old version
    local plugin_basename=$(basename "$plugin_file")
    if [ -f "$PLUGINS_DIR/$plugin_basename" ]; then
        log "Backing up old version..."
        cp "$PLUGINS_DIR/$plugin_basename" "$BACKUP_DIR/$plugin_basename-$(date +%Y%m%d_%H%M%S)"
    fi
    
    # Install
    log "Installing plugin file..."
    cp "$plugin_file" "$PLUGINS_DIR/"
    
    # Cleanup
    rm -f "$plugin_name.zip"
    rm -rf "$plugin_dir"
    
    log "Plugin $plugin_name installed successfully"
}

# List installed plugins
list_plugins() {
    log "Installed Plugins:"
    echo "----------------------------------------"
    ls -la $PLUGINS_DIR/ | grep -E '\.(so|dll|dylib)$' | while read line; do
        local plugin=$(echo $line | awk '{print $9}')
        local size=$(du -h "$PLUGINS_DIR/$plugin" | cut -f1)
        echo "• $plugin ($size)"
    done
    echo "----------------------------------------"
}

# Update plugin configuration
update_config() {
    local plugin_name=$1
    local config=$2
    
    log "Updating configuration for $plugin_name"
    
    # Validate JSON
    echo "$config" | jq . > /dev/null 2>&1 || {
        error "Invalid JSON configuration"
        exit 1
    }
    
    # Update orthanc.json
    jq --arg plugin "$plugin_name" --argjson config "$config" '
    .Plugins[$plugin] = $config' "$CONFIG_FILE" > tmp.json && mv tmp.json "$CONFIG_FILE"
    
    log "Configuration updated for $plugin_name"
}

# Remove plugin
remove_plugin() {
    local plugin_name=$1
    
    local plugin_file=$(find $PLUGINS_DIR -name "*$plugin_name*" | head -1)
    if [ -z "$plugin_file" ]; then
        warn "Plugin $plugin_name not found"
        return
    fi
    
    log "Removing plugin: $plugin_name"
    mv "$plugin_file" "$BACKUP_DIR/"
    log "Plugin $plugin_name removed"
}

# Check plugin health
check_plugins() {
    log "Checking plugin health..."
    
    # Restart Orthanc to load plugins
    docker-compose restart orthanc
    sleep 5
    
    # Check system info
    if curl -s http://localhost:8042/system > /dev/null; then
        log "Orthanc is running"
        
        # List plugins
        local plugins=$(curl -s http://localhost:8042/system | jq '.Plugins // empty')
        if [ "$plugins" != "null" ] && [ "$plugins" != "" ]; then
            log "Plugins loaded:"
            echo "$plugins" | jq -r '.[]'
        else
            warn "No plugins loaded"
        fi
    else
        error "Orthanc is not responding"
    fi
}

# Main menu
show_menu() {
    echo "========================================"
    echo "     Plugin Management System"
    echo "========================================"
    echo "1. Install Plugin"
    echo "2. List Plugins"
    echo "3. Remove Plugin"
    echo "4. Update Configuration"
    echo "5. Check Plugin Health"
    echo "6. Backup All Plugins"
    echo "7. Exit"
    echo "========================================"
}

# Main loop
main() {
    while true; do
        show_menu
        read -p "Enter your choice [1-7]: " choice
        
        case $choice in
            1)
                read -p "Plugin name: " plugin_name
                read -p "Download URL: " plugin_url
                install_plugin "$plugin_name" "$plugin_url"
                ;;
            2)
                list_plugins
                ;;
            3)
                list_plugins
                read -p "Plugin to remove: " plugin_name
                remove_plugin "$plugin_name"
                ;;
            4)
                read -p "Plugin name: " plugin_name
                read -p "JSON configuration: " config
                update_config "$plugin_name" "$config"
                ;;
            5)
                check_plugins
                ;;
            6)
                log "Backing up all plugins..."
                cp -r $PLUGINS_DIR $BACKUP_DIR/plugins-$(date +%Y%m%d_%H%M%S)
                log "Backup completed"
                ;;
            7)
                log "Exiting..."
                exit 0
                ;;
            *)
                error "Invalid choice"
                ;;
        esac
        
        echo ""
        read -p "Press Enter to continue..."
    done
}

# Run main menu
main
```

---

## 📊 Best Practices

### 1. Plugin Management
- [ ] Backup plugin sebelum update
- [ ] Test plugin di staging environment
- [ ] Update satu plugin sekali
- [ ] Monitor performance setelah install

### 2. Security
- [ ] Download plugin dari official source
- [ ] Scan plugin untuk malware
- [ ] Restrict plugin permissions
- [ ] Audit plugin secara berkala

### 3. Performance
- [ ] Monitor memory usage
- [ ] Enable caching jika available
- [ ] Balance plugin features vs performance
- [ ] Remove unused plugins

### 4. Documentation
- [ ] Document semua plugin yang terinstall
- [ ] Simpan script configuration
- [ ] Create troubleshooting guide
- [ ] Update documentation saat update

---

## 🎯 Next Steps

Setelah menginstall plugin:
1. **Test semua fitur** yang baru tersedia
2. **Update dokumentasi** dengan fitur baru
3. **Train users** penggunaan plugin
4. **Monitor performa** secara berkala
5. **Plan future upgrades** untuk plugin

---

**🎯 Selanjutnya**: [06-Konfigurasi PACS](./06-Konfigurasi-PACS.md) - Pelajari cara mengintegrasikan Orthanc dengan PACS dan sistem lainnya!