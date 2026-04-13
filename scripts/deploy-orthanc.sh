#!/bin/bash

# ==================================
# deploy-orthanc.sh
# ==================================
# Script untuk deploy Orthanc ke server produksi
# Usage: ./deploy-orthanc.sh [command]
# Examples:
#   ./deploy-orthanc.sh backup        # Backup current installation
#   ./deploy-orthanc.sh deploy         # Deploy to production
#   ./deploy-orthanc.sh rollback      # Rollback deployment
#   ./deploy-orthanc.sh check          # Check deployment status
#   ./deploy-orthanc.sh config         # Show configuration

set -e

# ==================================
# KONFIGURASI
# ==================================

# ==================================
# Lokasi instalasi
# ==================================

# Directory proyek
PROJECT_DIR="/opt/orthanc"
DATA_DIR="${PROJECT_DIR}/data"
CONFIG_DIR="${PROJECT_DIR}/config"
LOG_DIR="${PROJECT_DIR}/logs"

# Server produksi
SERVER_HOST="192.168.1.100"  # Ganti dengan IP server produksi
SERVER_USER="orthanc"         # Username di server produksi
SERVER_USER_PASS="secure_pass"    # Password untuk SSH

# Repository
REMOTE_URL="https://github.com/adptra01/belajar-orthanc.git"

# ==================================
# FUNGSI UTAMA
# ==================================
# Logging
log_info() { echo "[$(date '+%Y-%m-%d %H:%M:%S')] ℹ INFO: $*"; }
log_warn() { echo "[$(date '+%Y-%m-%d %H:%M:%S')] ⚠  WARNING: $*"; }
log_error() { echo "[$(date '+%Y-%m-%d %H:%M:%S')] ❌ ERROR: $*"; }

check_root() {
    if [ "$EUID" -ne 0 ]; then
        log_error "Script harus dijalankan sebagai root"
        return 1
    fi
}

# ==================================
# BACKUP FUNCTIONS
# ==================================
backup_database() {
    log_info "Starting database backup..."

    if [ ! -f "$DATA_DIR/index" ]; then
        log_error "Database file not found: $DATA_DIR/index"
        return 1
    fi

    # Backup database
    DB_SIZE=$(du -sh "$DATA_DIR/index" | cut -f1)
    DB_SIZE_MB=$((DB_SIZE / 1024 / 1024))

    # Create backup directory
    BACKUP_DIR="${PROJECT_DIR}/backups/database/$(date +%Y%m%d_%H%M%S)"
    mkdir -p "$BACKUP_DIR"

    # Copy database to backup location
    DB_BACKUP="${BACKUP_DIR}/index-backup-$(date +%Y%m%d_%H%M%S).db"
    cp "$DATA_DIR/index" "$DB_BACKUP"

    if [ -f "$DB_BACKUP" ]; then
        NEW_SIZE=$((DB_SIZE / 1024 / 1024))
        log_info "Database backed up to: $DB_BACKUP ($NEW_SIZE MB)"
    else
        log_error "Database backup failed!"
        return 1
    fi
}

# ==================================
# DEPLOYMENT FUNCTIONS
# ==================================
check_docker() {
    log_info "Checking Docker installation..."

    if command -v docker >/dev/null; then
        log_info "Docker is installed"
        return 0
    else
        log_error "Docker is not installed"
        return 1
    fi
}

check_docker_compose() {
    log_info "Checking Docker Compose..."

    if command -v docker-compose >/dev/null; then
        log_info "Docker Compose is installed"
        return 0
    else
        log_error "Docker Compose is not installed"
        return 1
    fi
}

check_server() {
    log_info "Checking server connection..."

    if ping -c 2 -W 5 "$SERVER_HOST"; then
        log_info "Server is reachable: $SERVER_HOST"
        return 0
    else
        log_error "Server not reachable: $SERVER_HOST"
        return 1
    fi
}

check_ssh() {
    log_info "Checking SSH connection..."

    if ssh -o ConnectTimeout=5 "$SERVER_USER@$SERVER_HOST" exit; then
        log_info "SSH connection successful"
        return 0
    else
        log_error "SSH connection failed to $SERVER_USER@$SERVER_HOST"
        return 1
    fi
}

# ==================================
# DEPLOYMENT STEPS
# ==================================
backup_current_installation() {
    log_info "Backing up current installation..."

    # Backup database
    backup_database

    # Backup configuration
    CONFIG_FILE="${PROJECT_DIR}/orthanc.json"
    if [ -f "$CONFIG_FILE" ]; then
        mkdir -p "${PROJECT_DIR}/backups/config"
        cp "$CONFIG_FILE" "${PROJECT_DIR}/backups/config/orthanc.json"
    fi

    # Backup scripts
    SCRIPTS_DIR="${PROJECT_DIR}/scripts"
    if [ -d "$SCRIPTS_DIR" ]; then
        mkdir -p "${PROJECT_DIR}/backups/scripts"
        cp -r "$SCRIPTS_DIR" "${PROJECT_DIR}/backups/scripts/"
    fi

    log_info "Current installation backed up"
}

check_prerequisites() {
    log_info "Checking prerequisites..."

    if ! check_docker; then
        log_warn "Docker not installed!"
    fi

    if ! check_docker_compose; then
        log_warn "Docker Compose not installed!"
    fi

    if ! check_server; then
        log_warn "Server not reachable: $SERVER_HOST"
        log_warn "Please check server connectivity!"
    fi

    return 0
}

upload_code() {
    log_info "Uploading code to server..."

    # Copy code to server
    rsync -avz --progress "${PROJECT_DIR}/" "${SERVER_USER}@${SERVER_HOST}:/opt/orthanc/" | \
        --exclude='node_modules/ || true' >> "$LOG_FILE"

    if [ $? -eq 0 ]; then
        log_info "Code uploaded successfully"
        return 0
    else
        log_error "Code upload failed!"
        return 1
    fi
}

start_container() {
    log_info "Starting Orthanc container on server..."

    # SSH to server and start
    ssh "$SERVER_USER@$SERVER_HOST" << 'EOF'
# Start Orthanc container
cd /opt/orthanc

# Pull latest image
docker-compose -u jodogne/orthanc-plugins:latest

# Start container
docker-compose up -d

# Wait for container to be ready
sleep 10

# Check if container is running
if docker ps | grep -q "server-orthanc"; then
    log_info "Orthanc container is running!"
else
    log_error "Failed to start Orthanc container"
    return 1
fi

EOF
}

restart_container() {
    log_info "Restarting Orthanc container..."

    ssh "$SERVER_USER@$SERVER_HOST" << 'EOF'
cd /opt/orthanc

# Restart container
docker-compose restart

# Wait for container to be ready
sleep 5

# Wait for service to be ready
sleep 10

if docker ps | grep -q "server-orthanc"; then
    log_info "Orthanc container restarted!"
else
    log_error "Failed to restart Orthanc container"
    return 1
fi
EOF
}

stop_container() {
    log_info "Stopping Orthanc container..."

    ssh "$SERVER_USER@$SERVER_HOST" << 'EOF'
cd /opt/orthanc

# Stop container
docker-compose down
EOF

    if [ $? -eq 0 ]; then
        log_info "Orthanc container stopped"
    else
        log_error "Failed to stop Orthanc container"
        return 1
    fi
}

check_container_status() {
    log_info "Checking Orthanc container status..."

    ssh "$SERVER_USER@$SERVER_HOST" << 'EOF'
cd /opt/orthanc

# Check container status
if docker ps | grep -q "server-orthanc"; then
    log_info "Container is running"
    echo -e "\nContainer status:"
    docker ps --format "table {{.Names}}\t{{.Status}}"

    # Check orthanc status
    curl -s http://localhost:8042/system 2>/dev/null || echo "Container not responding"
else
    echo "Container is stopped"
fi
EOF
}

rollback_deployment() {
    log_info "Rolling back deployment..."

    # Get previous backup
    LATEST_BACKUP=$(ssh "$SERVER_USER@$SERVER_HOST" ls -t "${PROJECT_DIR}/backups/database/" 2>/dev/null | grep -E "^[0-9]{4}" | sort -r | tail -1)
    BACKUP_DIR="${PROJECT_DIR}/backups/${LATEST_BACKUP}"

    if [ -z "$BACKUP_DIR" ]; then
        log_error "No backup found to restore!"
        return 1
    fi

    # Stop current container
    stop_container

    # Restore from backup
    log_info "Restoring from $BACKUP_DIR"

    ssh "$SERVER_USER@$SERVER_HOST" << 'EOF'
cd /opt/orthanc

# Stop current container
docker-compose down

# Restore database
if [ -f "$BACKUP_DIR/index" ]; then
    cp "$BACKUP_DIR/index" "${PROJECT_DIR}/data/index"
fi

# Start container
docker-compose up -d
EOF

    if [ $? -eq 0 ]; then
        log_info "Rolled back to backup from $BACKUP_DIR"
    else
        log_error "Rollback failed!"
        return 1
    fi
}

# ==================================
# HELP
# ==================================
show_help() {
    cat << 'HELP'
========================================
Orthanc Deployment Script
========================================

PENGUNGAN:
  deploy          - Deploy Orthanc ke server produksi
  backup          - Backup current installation
  rollback        - Rollback ke backup terbaru
  rollback_all      - Rollback ke semua backup
  check          - Cek status deployment
  check-server     - Cek koneksi ke server
  backup-database  - Backup database Orthanc
  backup-all        - Backup semua data (database + scripts + config)
  config          - Tampilkan konfigurasi
  help            - Tampilkan pesan ini

CONTOH:
  - PASTIKAN "backup" sebelum menjalankan "deploy"
  - PASTIKAN "rollback" hanya saat diperlukan
  - Pastikan server tersedia dan dapat diakses
  - Backup data penting sebelum deployment
  - Test deployment di staging dulu

CONTOH:
  - Gunakan "check" untuk memastikan status deployment
  - Gunakan "rollback" dengan bijak jika terjadi masalah
  - Monitor deployment dengan "check" dan "check-server"

NOTES:
  - Jangan deploy ke produksi tanpa testing di staging
  - Jangan mengabaikan backup
  - Jangan hapus database produksi

========================================
HELP
}

# ==================================
# MAIN SCRIPT
# ==================================
main() {
    COMMAND=$1
    check_root

    case $COMMAND in
        backup)
            backup_database
            backup_all
            ;;

        deploy)
            check_prerequisites
            upload_code
            start_container
            ;;

        rollback)
            check_prerequisites
            rollback_deployment
            ;;

        rollback_all)
            echo "Are you sure? This will restore from the latest backup!"
            read -p "Continue? (yes/no): " CONFIRM_BACKUP
            if [ "$CONFIRM_BACKUP" = "yes" ]; then
                LATEST_BACKUP=$(ssh "$SERVER_USER@$SERVER_HOST" ls -t "${PROJECT_DIR}/backups/database/" 2>/dev/null | grep -E "^[0-9]{4}" | sort -r | tail -1)
                BACKUP_DIR="${PROJECT_DIR}/backups/${LATEST_BACKUP}"

                if [ -z "$BACKUP_DIR" ]; then
                    log_error "No backup found to restore!"
                    exit 1
                fi

                # Stop container and restore
                rollback_deployment
            else
                echo "Rollback cancelled"
            fi
            ;;

        check)
            check_prerequisites
            check_docker
            check_docker_compose
            check_server
            check_ssh
            ;;

        restart)
            check_docker
            restart_container
            ;;

        stop)
            stop_container
            ;;

        start)
            check_docker
            start_container
            ;;

        check-status)
            check_docker
            check_server
            check_container_status
            ;;

        config)
            cat "${PROJECT_DIR}/orthanc.json" 2>/dev/null || echo "Configuration file not found at ${PROJECT_DIR}/orthanc.json"
            ;;

        show-help)
            show_help
            ;;

        *)
            show_help
            ;;
    esac
}

log_success "Script completed!"
}

# ==================================
# EOF
