#!/bin/bash

# Script untuk memeriksa file DICOM
# Usage: ./check_dicom.sh <dicom-file>

if [ $# -eq 0 ]; then
    echo "Usage: $0 <dicom-file>"
    echo "Example: $0 DICOM_SAMPLES/MR000000.dcm"
    exit 1
fi

DICOM_FILE=$1

# Cek apakah file ada
if [ ! -f "$DICOM_FILE" ]; then
    echo "Error: File '$DICOM_FILE' not found!"
    exit 1
fi

echo "==============================================="
echo "Checking DICOM file: $DICOM_FILE"
echo "==============================================="
echo

# Cek ukuran file
FILE_SIZE=$(stat -c%s "$DICOM_FILE" 2>/dev/null || stat -f%z "$DICOM_FILE")
echo "File size: $FILE_SIZE bytes"

# Cek apakah file memiliki header DICOM yang valid
echo -n "DICOM header: "
if hexdump -C "$DICOM_FILE" | grep -q "44 49 43 4d"; then
    echo "✓ VALID"
else
    echo "✗ INVALID"
    echo "Note: This might be a compressed DICOM file (ZIP, etc.)"
fi

# Tampilkan informasi dasar DICOM jika ada dcmdump
echo
if command -v dcmdump >/dev/null 2>&1; then
    echo "Basic DICOM information:"
    dcmdump +P "0010,0010" +P "0010,0020" +P "0008,0020" "$DICOM_FILE" | grep -v "doesn't exist"
else
    echo "Install DCMTK for more DICOM info:"
    echo "  sudo apt-get install dcmtk"
fi

# Coba konversi ke format lain untuk di-upload ulang
echo
echo "==============================================="
echo "DICOM Conversion Options"
echo "==============================================="

# Jika tersedia gdcmconv
if command -v gdcmconv >/dev/null 2>&1; then
    echo "Found gdcmconv, checking conversion tools..."
    gdcmconv --version 2>/dev/null
    BASENAME=$(basename "$DICOM_FILE" .dcm)
    OUTPUT_FILE="${BASENAME}_converted.dcm"

    echo "Creating anonymized version..."
    gdcmconv --strip-private "$DICOM_FILE" "$OUTPUT_FILE" 2>/dev/null
    if [ -f "$OUTPUT_FILE" ]; then
        echo "✓ Conversion successful: $OUTPUT_FILE"
        echo "  File size: $(stat -c%s "$OUTPUT_FILE" 2>/dev/null || stat -f%z "$OUTPUT_FILE") bytes"
    else
        echo "✗ Conversion failed"
    fi
elif command -v dcm2pnm >/dev/null 2>&1; then
    echo "Found DCMTK tools"
    echo "Available commands:"
    echo "  - dcm2pnm +ex -w $DICOM_FILE  # Convert to PNG"
    echo "  - dcm2pnm +ex $DICOM_FILE     # Convert to PNM"
    echo "  - dcmdump $DICOM_FILE         # View DICOM headers"
else
    echo "No DICOM conversion tools found"
    echo "Install gdcm or DCMTK for DICOM processing:"
    echo "  - Ubuntu/Debian: sudo apt-get install gdcm-tools"
    echo "  - Fedora: sudo dnf install gdcm-tools"
    echo "  - macOS: brew install gdcm"
    echo "  - Windows: Download from https://support.dcmtk.org/wiki/dcmktk"
fi

# Upload ke Orthanc jika berjalan
echo
echo "==============================================="
echo "Orthanc Upload"
echo "==============================================="
if curl -s http://localhost:8042 >/dev/null 2>&1; then
    echo "Orthanc server is running at localhost:8042"

    # Upload original file
    echo "Uploading $DICOM_FILE..."
    if curl -X POST -T "$DICOM_FILE" http://localhost:8042/studies >/dev/null 2>&1; then
        echo "✓ Upload successful!"
    else
        echo "✗ Upload failed. Check Orthanc server status."
    fi
else
    echo "Orthanc server not running at localhost:8042"
    echo "Start with: docker-compose up -d"
fi