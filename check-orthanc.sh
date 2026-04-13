#!/bin/bash

# Script untuk memeriksa status Orthanc server

echo "==============================================="
echo "Orthanc Server Status Check"
echo "==============================================="
echo

# Cek container status
if command -v docker >/dev/null 2>&1; then
    echo "Using Docker:"
    docker ps --filter "name=server-orthanc" --format "table {{.Status}}\t{{.Ports}}" | grep server-orthanc || echo "✗ Container not running"
elif command -v podman >/dev/null 2>&1; then
    echo "Using Podman:"
    podman ps --filter "name=server-orthanc" --format "table {{.Status}}\t{{.Ports}}" | grep server-orthanc || echo "✗ Container not running"
fi

echo

# Cek port
echo "Port Status:"
if netstat -tlnp 2>/dev/null | grep -q ":8042"; then
    echo "✓ HTTP/REST API (8042): OPEN"
else
    echo "✗ HTTP/REST API (8042): CLOSED"
fi

if netstat -tlnp 2>/dev/null | grep -q ":4242"; then
    echo "✓ DICOM (4242): OPEN"
else
    echo "✗ DICOM (4242): CLOSED"
fi

echo

# Cek Orthanc web interface
echo "Web Interface Test:"
if curl -s -o /dev/null -w "%{http_code}" http://localhost:8042 | grep -q "200\|302"; then
    echo "✓ Orthanc web interface accessible"
    echo "  URL: http://localhost:8042"
else
    echo "✗ Orthanc web interface not accessible"
fi

echo

# Cek Orthanc API
echo "REST API Test:"
if curl -s -o /dev/null -w "%{http_code}" http://localhost:8042/system | grep -q "200"; then
    echo "✓ REST API responding"
    echo "  API Endpoint: http://localhost:8042"
else
    echo "✗ REST API not responding"
fi

echo

# Cek data storage
echo "Data Storage:"
if [ -d "orthanc-data" ]; then
    echo "✓ Data directory exists: orthanc-data/"
    if [ -f "orthanc-data/index" ]; then
        echo "✓ Database file exists"
        DB_SIZE=$(stat -c%s "orthanc-data/index" 2>/dev/null || stat -f%z "orthanc-data/index")
        echo "  Database size: $DB_SIZE bytes"
    else
        echo "! Database file not found (container may not be configured)"
    fi

    # Count DICOM series folders
    SERIES_COUNT=$(find orthanc-data -name "series-*" -type d | wc -l)
    echo "  DICOM series folders: $SERIES_COUNT"
else
    echo "✗ Data directory not found"
fi

echo

# Cek backup
echo "Backup Status:"
if [ -d "BACKUPS" ]; then
    echo "✓ Backup directory exists: BACKUPS/"
    BACKUP_COUNT=$(ls -1 BACKUPS/*.backup 2>/dev/null | wc -l)
    echo "  Configuration backups: $BACKUP_COUNT"
else
    echo "! Backup directory not found"
fi

echo
echo "==============================================="
echo "Tips"
echo "==============================================="
echo "- Start container: docker-compose up -d"
echo "- View logs: docker-compose logs orthanc"
echo "- Stop container: docker-compose down"
echo "- Check DICOM files: ./check_dicom.sh DICOM_SAMPLES/*.dcm"