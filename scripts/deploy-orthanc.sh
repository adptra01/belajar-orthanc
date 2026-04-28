#!/bin/bash

# ==================================
# deploy-orthanc.sh
# Script untuk deploy Orthanc ke server produksi
# ==================================
# Usage: ./deploy-orthanc.sh [command]
# Examples:
#   ./deploy-orthanc.sh backup        # Backup current installation
#   ./deploy-orthanc.sh deploy         # Deploy to production
#   ./deploy-orthanc.sh rollback      # Rollback deployment
#   ./deploy-orthanc.sh check          # Check deployment status

set -euo pipefail

# ==================================
# KONFIGURASI
# ==================================

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="/opt/orthanc"
DATA_DIR="${PROJECT_DIR}/data"
CONFIG_DIR="${PROJECT_DIR}/config"
LOG_DIR="${PROJECT_DIR}/logs"
BACKUP_DIR="${PROJECT_DIR}/backups"
LOG_FILE="${LOG_DIR}/deploy-orthanc.log"

# Server produksi (ubah sesuai environment)
SERVER_HOST="192.168.1.100"
SERVER_USER="orthanc"

# Repository
REMOTE_URL="https://github.com/adptra01/belajar-orthanc.git"

mkdir -p "$LOG_DIR" "$BACKUP_DIR"

# ==================================
# FUNGSI UTAMA
# ==================================

log_info()    { echo "[$(date '+%Y-%m-%d %H:%M:%S')] INFO: $*" | tee -a "$LOG_FILE"; }
log_warn()    { echo "[$(date '+%Y-%m-%d %H:%M:%S')] WARNING: $*" | tee -a "$LOG_FILE"; }
log_error()   { echo "[$(date '+%Y-%m-%d %H:%M:%S')] ERROR: $*" | tee -a "$LOG_FILE"; }
log_success() { echo "[$(date '+%Y-%m-%d %H:%M:%S')] SUCCESS: $*" | tee -a "$LOG_FILE"; }

# ==================================
# BACKUP
# ==================================

backup_database() {
    log_info "Starting database backup..."

    if [ ! -f "$DATA_DIR/index" ]; then
        log_error "Database file not found: $DATA_DIR/index"
        return 1
    fi

    local backup_path="${BACKUP_DIR}/database/$(date +%Y%m%d_%H%M%S)"
    mkdir -p "$backup_path"

    cp "$DATA_DIR/index" "$backup_path/index-backup-$(date +%Y%m%d_%H%M%S).db"
    log_info "Database backed up to: $backup_path"
}

backup_all() {
    log_info "Backing up current installation..."

    backup_database

    # Backup configuration
    if [ -f "${PROJECT_DIR}/orthanc.json" ]; then
        mkdir -p "${BACKUP_DIR}/config"
        cp "${PROJECT_DIR}/orthanc.json" "${BACKUP_DIR}/config/orthanc.json"
    fi

    # Backup scripts
    if [ -d "${SCRIPT_DIR}" ]; then
        mkdir -p "${BACKUP_DIR}/scripts"
        cp -r "${SCRIPT_DIR}" "${BACKUP_DIR}/scripts/"
    fi

    log_success "Backup completed"
}

# ==================================
# DEPLOYMENT
# ==================================

check_docker() {
    if command -v docker >/dev/null 2>&1; then
        log_info "Docker is installed"
        return 0
    else
        log_warn "Docker is not installed"
        return 1
    fi
}

check_server() {
    if ping -c 2 -W 5 "$SERVER_HOST" >/dev/null 2>&1; then
        log_info "Server is reachable: $SERVER_HOST"
        return 0
    else
        log_warn "Server not reachable: $SERVER_HOST"
        return 1
    fi
}

check_prerequisites() {
    check_docker || true
    check_server || true
}

upload_code() {
    log_info "Uploading code to server..."

    if rsync -avz --progress "${PROJECT_DIR}/" "${SERVER_USER}@${SERVER_HOST}:/opt/orthanc/" \
        --exclude='node_modules' --exclude='.git' >> "$LOG_FILE" 2>&1; then
        log_info "Code uploaded successfully"
    else
        log_error "Code upload failed!"
        return 1
    fi
}

start_container() {
    log_info "Starting Orthanc container on server..."

    ssh "$SERVER_USER@$SERVER_HOST" bash -s << 'REMOTE_SCRIPT'
cd /opt/orthanc
docker-compose pull
docker-compose up -d
sleep 10

if docker ps | grep -q "server-orthanc"; then
    echo "Container is running"
else
    echo "Failed to start container"
    exit 1
fi
REMOTE_SCRIPT
}

stop_container() {
    log_info "Stopping Orthanc container..."

    ssh "$SERVER_USER@$SERVER_HOST" bash -s << 'REMOTE_SCRIPT'
cd /opt/orthanc && docker-compose down
REMOTE_SCRIPT

    log_info "Container stopped"
}

restart_container() {
    log_info "Restarting Orthanc container..."

    ssh "$SERVER_USER@$SERVER_HOST" bash -s << 'REMOTE_SCRIPT'
cd /opt/orthanc
docker-compose restart
sleep 15

if docker ps | grep -q "server-orthanc"; then
    echo "Container restarted"
else
    echo "Failed to restart container"
    exit 1
fi
REMOTE_SCRIPT
}

check_container_status() {
    log_info "Checking container status..."

    ssh "$SERVER_USER@$SERVER_HOST" bash -s << 'REMOTE_SCRIPT'
cd /opt/orthanc
if docker ps | grep -q "server-orthanc"; then
    echo "Container is running"
    docker ps --format "table {{.Names}}\t{{.Status}}"
    curl -sf http://localhost:8042/system 2>/dev/null | jq -r '"Version: \(.Version)"' 2>/dev/null || echo "API not responding"
else
    echo "Container is stopped"
fi
REMOTE_SCRIPT
}

rollback_deployment() {
    log_info "Rolling back deployment..."

    local latest_backup
    latest_backup=$(ls -td "${BACKUP_DIR}/database"/*/ 2>/dev/null | head -1)

    if [ -z "$latest_backup" ]; then
        log_error "No backup found to restore!"
        return 1
    fi

    log_info "Restoring from $latest_backup"

    ssh "$SERVER_USER@$SERVER_HOST" bash -s << REMOTE_SCRIPT
cd /opt/orthanc
docker-compose down

# Restore database
if [ -f "${latest_backup}/index" ]; then
    cp "${latest_backup}/index" "${PROJECT_DIR}/data/index"
fi

docker-compose up -d
REMOTE_SCRIPT

    log_success "Rolled back to $latest_backup"
}

# ==================================
# HELP
# ==================================

show_help() {
    cat << 'HELP'
========================================
Orthanc Deployment Script
========================================

PENGGUNAAN:
  deploy          - Deploy Orthanc ke server produksi
  backup          - Backup current installation
  rollback        - Rollback ke backup terbaru
  check           - Cek status deployment
  check-server    - Cek koneksi ke server
  restart         - Restart container
  stop            - Stop container
  start           - Start container
  config          - Tampilkan konfigurasi
  help            - Tampilkan pesan ini

NOTES:
  - Backup sebelum deploy
  - Test deployment di staging dulu
  - Monitor deployment dengan check
========================================
HELP
}

# ==================================
# MAIN
# ==================================

main() {
    local cmd="${1:-help}"

    case "$cmd" in
        backup)
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
        check)
            check_prerequisites
            check_container_status
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
        config)
            cat "${PROJECT_DIR}/orthanc.json" 2>/dev/null || echo "Configuration file not found"
            ;;
        help|*)
            show_help
            ;;
    esac
}

main "$@"
