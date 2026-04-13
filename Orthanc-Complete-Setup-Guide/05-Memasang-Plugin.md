#!/bin/bash

# ==========================================
# deploy-orthanc.sh
# Script untuk deploy Orthanc ke server
# ==========================================

# ==========================================
# KONFIGURASI
# ==========================================

set -e

# Lokasi instalasi produksi
DEPLOY_DIR="/opt/orthanc"
DATA_DIR="${DEPLOY_DIR}/data"
CONFIG_DIR="${DEPLOY_DIR}/config"
BACKUP_DIR="${DEPLOY_DIR}/backups"
LOG_DIR="${DEPLOY_DIR}/logs"

# Server informasi
SERVER_HOST="192.168.1.100"
SERVER_USER="orthanc"
SERVER_PASS="securepassword123"

# Repository informasi
REMOTE_URL="https://github.com/adptra01/belajar-orthanc.git"
REMOTE_NAME="origin"
BRANCH="main"

# Docker image
IMAGE_NAME="jodogne/orthanc-plugins:latest"
CONTAINER_NAME="server-orthanc"

# ==========================================
# FUNGSI LOGGING
# ==========================================

GREEN='\033[0;32m'
RED='\033[1;31m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

log_info() {
    echo -e "${GREEN}[INFO]${NC} $(date '+%Y-%m-%d %H:%M:%S') $*" | tee -a "$LOG_DIR/deploy-orthanc.log"
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $(date '+%Y-%m-%d %H:%M:%S') $*" | tee -a "$LOG_DIR/deploy-orthanc.log"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $(date '+%Y-%m-%d %H:%M:%S') $*" | tee -a "$LOG_DIR/deploy-orthanc.log"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $(date '+%Y-%m-%d %H:%M:%S') $*"
}

# ==========================================
# FUNGSI UTAMA
# ==========================================

print_usage() {
    echo -e "${BLUE}Usage: ${NC}$0 <command>"
    echo ""
    echo "COMMANDS:"
    echo "  ${YELLOW}backup${NC}     - Backup data Orthanc"
    echo "  ${YELLOW}deploy${NC}    - Deploy Orthanc ke server produksi"
    ${YELLOW}restore${NC}   - Restore dari backup tertentu"
    ${YELLOW}rollback${NC}  - Rollback ke backup terbaru"
    ${YELLOW}check${NC}     - Cek status server"
    ${YELLOW}restart${NC}   - Restart Orthanc container"
    ${YELLOW}stop${NC}     - Stop Orthanc container"
    ${YELLOW}start${NC}    # Start Orthanc container"
    "${YELLOW}show-config${NC}  - Tampilkan konfigurasi"
    ${YELLOW}check-db${NC}  # Cek database"
    "${YELLOW}cleanup${NC}       # Cleanup data lama
    "${YELLOW}dry-run${NC}     # Test deployment tanpa perubahan"
    "${YELLOW}help${NC}        # Tampilkan bantuan"

    echo ""
    echo "EXAMPLES:"
    echo "  ./deploy-orthanc.sh backup"
    echo "  ./deploy-orthanc.sh deploy"
    echo "  ./deploy-orthanc.sh check"
    ""
    echo "OPTIONS:"
    echo "  --dry-run    : Test deployment tanpa perubahan"
    "  --force       : Paksa tanyakan konfirmasi"
    "  --skip-check  : Lewati prasayarat"
    "  --verbose    : Tampilkan detail proses"
    --help        : Tampilkan pesan bantuan"
}

    echo ""
    echo "ENVIRONMENT VARIABLES:"
    echo "  DEPLOY_DIR=$DEPLOY_DIR"
    echo "  DATA_DIR=$DATA_DIR"
    echo "  SERVER=$SERVER_HOST"
    echo "  SERVER_USER=$SERVER_USER"
    ""

    echo "EXAMPLES:"
    echo "  ./deploy-orthanc.sh deploy --dry-run  # Test tanpa deploy"
    echo "  ./deploy-orthanc.sh backup --force   # Backup paksa"
    echo "  ./deploy-orthanc.sh check --verbose  # Detail output"
}

    exit 0
}

# ==========================================
# FUNGSI UTAMA
# ==========================================

check_root() {
    if [ "$EUID" -ne 0 ]; then
        log_error "Script harus dijalankan sebagai root!"
        exit 1
    fi

    log_info "Checking root privileges... OK"
}

# ==========================================
# FUNGSI BACKUP
# ==========================================

backup_database() {
    log_info "================================"
    log_info "BACKUP DATABASE"
    echo "================================"

    if [ ! -d "$DATA_DIR" ]; then
        mkdir -p "$DATA_DIR"
        log_info "Created data directory: $DATA_DIR"
    fi

    if [ ! -d "$BACKUP_DIR" ]; then
        mkdir -p "$BACKUP_DIR"
        mkdir -p "$BACKUP_DIR/database"
        mkdir -p "$BACKUP_DIR/dicom-files"
        mkdir -p "$BACKUP_DIR/configs"
        log_info "Created backup directory: $BACKUP_DIR"
    else
        log_warn "Backup directory already exists: $BACKUP_DIR"
    fi

    # Backup SQLite database
    DB_FILE="$DATA_DIR/index"
    BACKUP_DB="${BACKUP_DIR}/database/index-backup-$(date +%Y%m%d_%H%M%S).db"

    if [ -f "$DB_FILE" ]; then
        DB_SIZE=$(du -sh "$DB_FILE" | cut -f1)
        log_info "Database size: $DB_SIZE bytes"

        mkdir -p "$BACKUP_DIR/database"

        # Copy database
        cp "$DB_FILE" "$BACKUP_DIR/database/"

        NEW_SIZE=$(du -sh "$BACKUP_DIR/database/index" | cut -f1)
        NEW_SIZE_MB=$((NEW_SIZE / 1024 / 1024))

        if [ $NEW_SIZE_MB -gt 100 ]; then
            log_warn "Database size > 100MB, pertimbangkan backup ke server"
        fi

        log_info "Database backed up: $BACKUP_DB"
    else
        log_warn "Database file not found: $DB_FILE"
        return 1
    fi

    # Backup WAL file
    WAL_FILE="$DATA_DIR/index-wal"
    BACKUP_WAL="${BACKUP_DIR}/database/index-wal-$(date +%Y%m%d_%H%M%S).wal"

    if [ -f "$WAL_FILE" ]; then
        cp "$WAL_FILE" "$BACKUP_DATABASE/"
        log_info "WAL backed up: $BACKUP_WAL"
    else
        log_warn "WAL file not found: $WAL_FILE"
    fi

    return 0
}

backup_dicom_files() {
    log_info "================================"
    log_info "BACKUP DICOM FILES"
    echo "================================"

    DICOM_COUNT=$(find "$DATA_DIR" -maxdepth 1 -name "*.dcm" -type f | wc -l)
    BACKUP_DIR="${BACKUP_DIR}/dicom-files"
    mkdir -p "$BACKUP_DIR"

    if [ "$DICOM_COUNT" -eq 0 ]; then
        log_warn "No DICOM files found"
        return 0
    fi

    BACKUP_HEX="${BACKUP_DIR}/hex-fol"
    BACKUP_COUNT=0
    TOTAL_SIZE=0

    # Create hex folder structure
    find "$DATA_DIR" -maxdepth 1 -type d -name "[0-9a-f]" | print0 -exec dirname {} \; | while read hex_folder; do
        [ -n "$hex_folder" ] && [ -d "$hex_folder" ] || continue

        HEX_BACKUP="${BACKUP_HEX}"

        if [ -d "$HEX_BACKUP" ]; then
            mkdir -p "$HEX_BACKUP"

            # Copy files
            find "$HEX_BACKUP" -maxdepth 1 -name "*.dcm" -type f -exec cp {} "$HEX_BACKUP/" \; 2>/dev/null
            FILE_COUNT=$(find "$HEX_BACKUP" -maxdepth 1 -name "*.dcm" -type f | wc -l)

            if [ "$FILE_COUNT" -gt 0 ]; then
                TOTAL_COUNT=$((TOTAL_COUNT + FILE_COUNT))
                log_info "Backed up $FILE_COUNT files from $(basename "$HEX_BACKUP")"
            fi
        fi
    done

    rm /tmp/dicom_folders.txt

    log_info "Total DICOM files backed up: $TOTAL_COUNT"
    return 0
}

backup_config() {
    log_info "================================"
    log_info "BACKUP CONFIG"
    echo "================================"

    CONFIG_FILE="$DATA_DIR/orthanc.json"

    if [ -f "$CONFIG_FILE" ]; then
        mkdir -p "$BACKUP_DIR/configs"
        cp "$CONFIG_FILE" "$BACKUP_DIR/configs/orthanc-$(date +%Y%m%d_%H%M%S).json"
        BACKUP_CONFIG="${BACKUP_DIR}/configs/orthanc-backup-$(date +%Y%m%d_%H%M%S).json"

        if [ -f "$BACKUP_CONFIG" ]; then
            BACKUP_SIZE=$(du -sh "$BACKUP_CONFIG" | cut -f1)
            BACKUP_SIZE_MB=$((BACKUP_SIZE / 1024 / 1024))
            log_info "Configuration backed up: $BACKUP_CONFIG ($BACKUP_SIZE_MB MB)"
        else
            log_warn "Configuration file not found: $CONFIG_FILE"
        fi
    else
        log_warn "Configuration file not found!"
        return 1
    fi
}

backup_scripts() {
    log_info "================================"
    log_info "BACKUP SCRIPTS"
    echo "================================"

    SCRIPTS_DIR="$DATA_DIR/scripts"
    BACKUP_SCRIPTS_DIR="${BACKUP_DIR}/scripts"

    if [ -d "$SCRIPTS_DIR" ]; then
        mkdir -p "$BACKUP_SCRIPTS_DIR"

        # Copy all shell scripts
        find "$SCRIPTS_DIR" -maxdepth 1 -name "*.sh" -type f -exec cp {} "$BACKUP_SCRIPTS/" \; 2>/dev/null
        SCRIPT_COUNT=$(find "$SCRIPTS_DIR" -maxdepth 1 -name "*.sh" -type f | wc -l)

        log_info "Backed up $SCRIPT_COUNT scripts"
    else
        log_info "No scripts directory found"
    fi

    return 0
}

backup_all() {
    log_info "================================"
    log_info "STARTING FULL BACKUP"
    echo "================================"

    START_TIME=$(date +%s)

    # Create backup directory
    mkdir -p "$BACKUP_DIR/full-backup-$(date +%Y%m%d_%H%M%S)"

    # Run all backup functions
    backup_database
    [ $? -eq 0 ] && backup_dicom_files
    [ $? -eq 0 ] && backup_config
    [ $? -eq 0 ] && backup_scripts

    # Compress backup
    if [ $? -eq 0 ]; then
        COMPRESS_DIR="${BACKUP_DIR}/compressed"
        mkdir -p "$COMPRESS_DIR"
        mkdir -p "$COMPRESS_DIR/database"
        mkdir -p "$COMPRESS_DIR/dicom"

        cd "$BACKUP_DIR/full-backup$(date +%Y%m%d_%H%M%S)"
        tar -czf "$BACKUP_DIR/compressed/full-backup-$(date +%Y%m%d_%H%M%S).tar.gz" \
            --exclude="*.log" \
            --exclude="*.pid" \
            --exclude="*.tmp" \
            --exclude="*" \
            orthanc-data/

        if [ -f "$BACKUP_DIR/compressed/full-backup-$(date +%Y%m%d_%H%M%S).tar.gz" ]; then
            TOTAL_SIZE=$(du -sh "$BACKUP_DIR/compressed" | cut -f1)
            TOTAL_SIZE_MB=$((TOTAL_SIZE / 1024 / 1024))
            log_info "Backup compressed: $BACKUP_DIR/compressed/full-backup-$(date +%Y%m%d_%H%M%S).tar.gz ($TOTAL_SIZE_MB MB)"
        else
            log_error "Backup compression failed!"
            return 1
        fi
    fi

    END_TIME=$(date +%s)
    DURATION=$((END_TIME - START_TIME))

    log_info "================================"
    echo "BACKUP SELESAI!"
    echo "Lokasi: $BACKUP_DIR/"
    echo "Ukuran: $TOTAL_SIZE_MB MB"
    echo "Waktu: ${DURATION} detik"
    echo "Backup akan dihapus yang lebih lama dari $RETENTION_HARIAN_KEHAPAN"
    echo "Lihat README untuk informasi retensi"
    echo ""
    "========================================"

    return 0
}

# ==========================================
# FUNGSI RESTORE
# ==========================================

restore() {
    local BACKUP_DIR="$1"

    if [ -z "$BACKUP_DIR" ]; then
        echo "Error: Backup directory harus dispesikan!"
        return 1
    fi

    echo "================================"
    echo "RESTORE FROM BACKUP DIR"
    echo "================================"

    echo ""
    read -p "Masukkan backup directory: " BACKUP_DIR
    echo ""

    # Backup directories list
    find "$BACKUP_DIR" -type d -maxdepth 1 -name "*backup*" | head -10
    echo ""

    read -p "Pilih backup yang ingin direstore (isi nama direktori): " BACKUP_DIR
    echo ""

    read -p "Konfirmasi restore? (yes/no): " CONFIRM_RESTORE

    if [ "$CONFIRM_RESTORE" != "yes" ]; then
        echo "Restore dibatalkan"
        exit 0
    fi

    # Find latest backup
    echo ""
    echo "========================================"
    echo "LATEST BACKUP INFO"
    echo "========================================"
    echo ""

    # Find latest database backup
    LATEST_DB=$(find "$BACKUP_DIR/database" -name "*.db" -mtime +%s | tail -1)

    if [ -z "$LATEST_DB" ]; then
        BACKUP_PATH="${BACKUP_DIR}/database/$LATEST_DB"
        echo "Menggunakan database backup terbaru: $LATEST_DB"
        echo ""
        read -p "Mulai restore? (yes/no): " CONFIRM_DB_RESTORE

        if [ "$CONFIRM_DB_RESTORE" == "yes" ]; then
            echo "Melakukan restore..."
            echo ""

            # Backup database sebelumnya
            if [ -f "$DATA_DIR/index" ]; then
                cp "$DATA_DIR/index" "$DATA_DIR/index.backup"
                if [ -f "$DATA_DIR/index.backup" ]; then
                    echo "Database backed up di $DATA_DIR/index.backup"
                else
                    echo "Tidak ada file backup"
                fi
            fi

            # Restore database
            cp "$BACKUP_PATH" "$DATA_DIR/index"

            if [ -f "$DATA_DIR/index" ]; then
                NEW_SIZE=$(du -sh "$DATA_DIR/index" | cut -f1)
                NEW_SIZE_MB=$((NEW_SIZE / 1024 / 1024))
                echo "Database restore selesai (UKURAN: $NEW_SIZE KB)"
                echo ""
                echo "Database integrity:"
                sqlite3 "$DATA_DIR/index" "PRAGMA integrity_check;"
            else
                echo "Database file tidak ditemukan setelah restore!"
            fi

        else
            echo "Database backup tidak ditemukan di: $BACKUP_DIR/database/"
            echo "Pilih directory backup yang benar!"
        fi
    else
        echo "========================================"
        echo "Tidak ada backup database di: $BACKUP_DIR/database/"
fi

    return 0
}

# ==========================================
# FUNGSI DEPLOYMENT
# ==========================================

check_prerequisites() {
    log_info "================================="
    echo "CEK PRASYARATAN"
    echo "================================="

    # Check Docker
    check_docker

    # Check network
    check_network

    # Check server connection
    check_server
}

    if [ $? -eq 0 ]; then
        log_info "================================="
        echo "CEK PRASYARATAN"
        echo "================================="
        echo ""

        echo "✓ Docker: $(docker --version)"
        echo "✓ Docker Compose: $(docker-compose --version)"
        echo ""

        echo "✓ Docker service: $(systemctl is-active docker && [ $? -eq 0 ] && [ -n "$CONTAINER_NAME" == "running" ])"
        echo "✓ Network: $(ping -c 3 google.com && echo 'internet ok')"
        echo "✓ Storage: $AVAILABLE_SPACE_MB MB free ($(df -h "$DATA_DIR" | awk '{print $4}' | sed 's/$/ //')"

        # Check SSH connection
        if ssh -o ConnectTimeout=5 "$SERVER_USER@$SERVER_HOST" exit; then
            log_info "SSH connection: OK"
        else
            log_warn "SSH connection failed: $SERVER_USER@$SERVER_HOST"
        fi

        # Check Orthanc
        if curl -s http://$SERVER_HOST:8042/system >/dev/null 2>/dev/null; then
            log_info "Orthanc server is accessible at http://$SERVER_HOST:8042/system"
        else
            log_error "Orthanc server tidak dapat diakses!"
        fi
    else
        log_error "Satu atau lebih dari satu prasyarat gagal!"
        return 1
    fi
}

deploy() {
    log_info "================================="
    echo "DEPLOY ORTHANC KE SERVER"
    echo "================================="

    check_prerequisites

    if [ $? -eq 0 ]; then
        log_info "Semua prasyarat terpenuhi"
    else
        log_error "Ada prasyarat gagal!"
        return 1
    fi

    echo "========================================="
    echo "INFO: Memulai deployment..."
    echo ""

    # Show summary
    echo "  Server: $SERVER_HOST:8042"
    "  User: $SERVER_USER"
    "  Data: $DATA_DIR/"
    "  Container: $CONTAINER_NAME"

    # Step-by-step deployment
    log_info "================================="
    echo "LANGKAH 1: BACKUP"
    echo "================================="

    # 1. Backup current installation
    log_info "Backing up current installation..."

    if [ "$1" -eq "1" ]; then
        backup_all
        if [ $? -ne 0 ]; then
            log_error "Backup gagal!"
            echo ""
            echo "Continue deployment..."
        else
            log_success "Backup berhasil!"
        fi
    fi

    echo ""
    echo "========================================="
    echo "LANGKAH 2: DEPLOY"
    echo "================================="

    if [ "$1" -eq "2" ]; then
        upload_code
    if [ $? -ne 0 ]; then
            log_error "Upload kode gagal!"
            echo ""
            echo "Continue deployment..."
        else
            log_success "Upload berhasil!"

        # Stop existing container
        log_info "Stoping existing container..."
        echo ""

        # Create data directory
        ssh "$SERVER_USER@$SERVER_HOST" << 'EOF'
if [ -d "/opt/orthanc" ]; then
    echo "Data directory already exists"
else
    echo "Creating data directory: /opt/orthanc"
fi
cd /opt/orthanc

# Backup current data
mkdir -p /backup/old-data
mv /opt/old-data/* ./old-data/
rm -rf /opt/old-data/*
rmdir /opt/old-data

echo "Current data backed up to /backup/current-data/"

# Deploy code
echo "Copying code to server..."
rsync -av --delete \
    --filter='+ *.sh -- *.md -- *.yml -- *.json' \
    --exclude '*.log' \
    --exclude 'node_modules/' \
    --exclude '*.pid' \
    --exclude '.git/' \
    --exclude '.idea/' \
    --exclude 'build/' \
    --exclude 'node_modules/' \
    --exclude '.git' \
    ./ \
    "$SERVER_USER@$SERVER_HOST:/opt/orthanc/code/"

if [ $? -eq 0 ]; then
    LOG_SUCCESS=1
else
    echo "Upload gagal!"
fi

echo "Code upload selesai: $LOG_SUCCESS"
else
    echo "Upload gagal atau tidak ada file code yang tersimpan"
fi

# Stop dan update container
echo ""
echo "Stop current container..."
ssh "$SERVER_USER@$SERVER_USER@SERVER_HOST" << 'EOF'
cd /opt/orthanc

# Stop dan backup
if [ -d "server-orthanc" ]; then
    echo "Stopping server-orthanc"
    docker stop server-orthanc

# Pull latest image
echo "Pulling latest image..."
docker pull "$IMAGE_NAME"

# Update docker-compose
echo "Updating docker-compose.yml..."
curl -s https://github.com/adptra01/belajar-orthanc/raw/main/docker-compose.yml > /opt/orthanc/docker-compose.yml

# Update configuration
echo "Updating orthanc.json..."
curl -s https://github.com/adptra01/belajar-orthanc/raw/main/orthanc.json > /opt/orthanc/orthanc.json

# Start container
echo "Starting container..."
docker-compose up -d

# Wait for container
sleep 10

# Check if container is running
if [ docker ps | grep -q "server-orthanc" > /dev/null ]; then
    echo "Container is running"
else
    echo "Container belum berjalan!"
fi
else
    echo "Container sudah berjalan: $SERVER_USER@$SERVER_HOST"
fi

if [ $? -eq 0 ]; then
    LOG_SUCCESS=1
else
    LOG_SUCCESS=0
fi

if [ "$LOG_SUCCESS" = "1" ]; then
    log_info "Deployment berhasil!"
    echo ""
else
    echo "Deployment gagal!"
    echo ""
    return 1
fi
fi

# ==========================================
# ROLLBACK
# ==========================================

rollback() {
    log_info "================================="
    echo "ROLLBACK"
    echo "================================="

    if [ -z "$1" ]; then
        log_error "Masukkan backup directory!"
        exit 1
    fi

    # List backups
    echo ""
    echo "Available backups:"
    echo ""
    find "$BACKUP_DIR" -maxdepth 2 -type d -name "*backup*" -o -name | while read dir; do
        DIR_SIZE=$(du -sh "$BACKUP_DIR/$dir" -s | cut -f1)
        DIR_SIZE_MB=$((DIR_SIZE /1024 / 1024))
        echo "  $dir ($DIR_SIZE MB)"
    done < /tmp/backup_list.txt"
    rm /tmp/backup_list.txt

    read -p "Pilih backup yang ingin dirollback: " BACKUP_DIR
    ""

    read -p "Konfirmasi rollback? (semua data akan DIHAPUS!): " CONFIRM

    if [ "$CONFIRM" != "ya" ]; then
        echo "Rollback dibatalkan..."
        echo ""

        # Restore dari backup
        restore
        LOG_SUCCESS=""

        echo "========================================"
        echo ""
        echo "Mengembal semua data akan diganti dengan backup!"
        echo "========================================"
        echo "Data yang diganti:"
        echo ""

        # Hapus current data
        "$SERVER_USER@$SERVER_HOST@$SERVER_HOST" 'EOF'
cd /opt/orthanc
rm -rf ./*

        if [ $? -eq 0 ]; then
            LOG_SUCCESS=1
        else
            echo "Gagal menghapus data"
            LOG_SUCCESS=0
        fi

        # Copy dari backup
        BACKUP_DIR="${BACKUP_DIR}/$BACKUP"

        # Restore dari backup
        "$SERVER_USER@$SERVER@$SERVER_HOST" 'EOF'
cd /opt/orthanc

        if [ -f "$BACKUP_DIR/index" ]; then
            cp -r "$BACKUP/"* /opt/orthanc/
            LOG_SUCCESS="true"
        else
            echo "Tidak ada index di: $BACKUP/"
            LOG_SUCCESS="false"
        fi

        if [ "$LOG_SUCCESS" = "true" ]; then
            echo "Data berhasil direstore dari $BACKUP/"
            echo ""
            echo ""
            # Verifikasi database
            sqlite3 "/opt/orthanc/index" "PRAGMA integrity_check;"
        else
            echo ""
            echo "Database tidak ditemukan setelah restore"
        fi
    fi

    if [ "$LOG_SUCCESS" = "true" ]; then
        log_info "Rollback berhasil!"
        echo ""
        echo "Data sudah berhasil direstore"
    else
        log_error "Rollback gagal!"
    else
        echo "Rollback dibatalkan"
    fi
else
    log_error "Rollback dibatalkan!"
    fi
}

# ==========================================
# FUNGSI HELP
# ==========================================

show_help() {
    cat << 'HELP
========================================
DEPLOYMENT SCRIPT
========================================

PENGGUNAN:
  deploy        - Deployment lengkap (backup -> upload -> stop -> deploy -> start)
  rollback     - Rollback ke backup terbaru
  check        - Cek status Orthanc server
  backup        - Backup data dan database
  start          - Start Orthanc
  stop           - Stop Orthanc container
  show-config     - Tampilkan konfigurasi
  check-db         - Cek database
  clean-old       - Hapus data lama
  rollback      - Rollback ke backup
  show-help       - Tampilkan bantuan ini

CONTOH:
  --dry-run       - Test deployment tanpa perubahan
  --force         - Paksa konfirmasi semua
  --verbose       - Tampilkan detail proses
  --help          - Tampilkan pesan ini

EXAMPLES:
  # Deployment normal
  ./deploy-orthanc.sh deploy

  # Test deployment
  ./deploy-orthanc.sh --dry-run

  # Rollback ke backup tertentu
  ./deploy-orthanc.sh rollback backup/20240412_120000

  # Hapus data lama
  ./deploy-orthanc.sh clean-old --dry-run

  # Check status
  ./deploy-orthanc.sh check

  # Tampilkan config
  ./deploy-orthanc.sh show-config

HELP
EOF
}

# ==========================================
# FUNGSI UTAMA
# ==========================================

case "$@" in
    backup)
        backup_all
        ;;

    deploy)
        check_prerequisites
        upload_code
        start_container

        if [ $? -eq 0 ]; then
            log_success "Deployment berhasil!"
        fi
        ;;

    rollback)
        rollback
        ;;

    check)
        check_root
        ;;

    restart)
        ;;

    stop)
        ;;

    start)
        ;;

    show-config)
        ;;

    check-db)
        check_root
        ;;

    clean-old)
        ;;

    dry-run)
        show-help
        ;;

    *)
        show-help
        ;;

    check)
        check_root
        ;;

    clean-old)
        ;;

    check-db)
        check_root
        ;;

    show-config)
        ;;

    show-help
        ;;

    check)
        check_root
        ;;

    restart)
        ;;

    start)
        ;;

    stop)
        ;;

    show-help
        ;

    clean-old)
        ;;

    show-help
        ;

    *)
        show-help
        ;;
esac
