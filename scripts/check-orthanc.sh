#!/bin/bash

# ==========================================
# check-orthanc.sh
# Script untuk mengecek status Orthanc server
# ==========================================

set -euo pipefail

# ==========================================
# KONFIGURASI
# ==========================================

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
DATA_DIR="${PROJECT_DIR}/data/orthanc"
LOG_DIR="${PROJECT_DIR}/logs"
LOG_FILE="${LOG_DIR}/orthanc-check.log"

# Color codes
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
RESET='\033[0m'

mkdir -p "$LOG_DIR"

# ==========================================
# FUNGSI LOGGING
# ==========================================

log_info()    { echo -e "${GREEN}[INFO]${RESET} $*" | tee -a "$LOG_FILE"; }
log_success() { echo -e "${GREEN}[SUCCESS]${RESET} $*" | tee -a "$LOG_FILE"; }
log_error()   { echo -e "${RED}[ERROR]${RESET} $*" | tee -a "$LOG_FILE"; }
log_warning() { echo -e "${YELLOW}[WARNING]${RESET} $*" | tee -a "$LOG_FILE"; }

# ==========================================
# FUNGSI STATUS CHECK
# ==========================================

check_docker() {
    log_info "Checking Docker status..."
    if command -v docker >/dev/null 2>&1; then
        log_success "Docker is installed"
    else
        log_error "Docker is not installed"
        return 1
    fi
}

check_orthanc_container() {
    log_info "Checking Orthanc container..."

    if docker ps --format '{{.Names}}' 2>/dev/null | grep -q "server-orthanc"; then
        if curl -sf http://localhost:8042/system >/dev/null 2>&1; then
            log_success "Orthanc HTTP API is accessible"
        else
            log_error "Orthanc HTTP API is not accessible"
            return 1
        fi

        if command -v nc >/dev/null 2>&1; then
            if nc -zv localhost 8042 >/dev/null 2>&1; then
                log_success "Orthanc HTTP port (8042) is open"
            else
                log_error "Orthanc HTTP port (8042) is closed"
                return 1
            fi
        fi
    else
        log_error "Orthanc container 'server-orthanc' not found"
        return 1
    fi
}

check_orthanc_api() {
    log_info "Checking Orthanc API..."

    local system_info
    if system_info=$(curl -sf http://localhost:8042/system 2>/dev/null); then
        log_success "Orthanc API is accessible"
        log_info "System: $(echo "$system_info" | jq -r '.Name // "unknown"')"
        log_info "Version: $(echo "$system_info" | jq -r '.Version // "unknown"')"

        local statistics
        if statistics=$(curl -sf "http://localhost:8042/tools/statistics" 2>/dev/null); then
            log_info "Patients: $(echo "$statistics" | jq -r '.Patients // "N/A"')"
            log_info "Studies:  $(echo "$statistics" | jq -r '.Studies // "N/A"')"
        fi
    else
        log_error "Orthanc API is not accessible"
        return 1
    fi
}

check_disk_space() {
    log_info "Checking disk space..."

    if [ ! -d "$DATA_DIR" ]; then
        log_error "Orthanc data directory not found: $DATA_DIR"
        return 1
    fi

    local usage
    usage=$(du -sh "$DATA_DIR" 2>/dev/null | cut -f1)
    log_info "Data directory size: $usage"

    # Check overall disk usage of the filesystem
    local disk_usage
    disk_usage=$(df "$DATA_DIR" 2>/dev/null | awk 'NR==2 {print $5}' | sed 's/%//')
    if [ -n "$disk_usage" ]; then
        if [ "$disk_usage" -gt 80 ] 2>/dev/null; then
            log_warning "Disk usage is ${disk_usage}% (warning)"
        else
            log_info "Disk usage: ${disk_usage}%"
        fi
    fi
}

check_database() {
    log_info "Checking database..."

    if [ -f "$DATA_DIR/index" ]; then
        local db_size
        db_size=$(du -h "$DATA_DIR/index" 2>/dev/null | cut -f1)
        log_info "Database size: $db_size"

        if command -v sqlite3 >/dev/null 2>&1; then
            if sqlite3 "$DATA_DIR/index" "PRAGMA integrity_check;" 2>/dev/null | grep -q "ok"; then
                log_success "Database integrity check: PASSED"
            else
                log_error "Database integrity check: FAILED"
            fi
        else
            log_warning "sqlite3 not installed, skipping integrity check"
        fi
    else
        log_warning "Database file not found: $DATA_DIR/index"
    fi
}

check_network() {
    log_info "Checking network connectivity..."

    if ping -c 1 -W 3 google.com >/dev/null 2>&1; then
        log_success "Internet connection OK"
    else
        log_warning "No internet connection"
    fi
}

show_status() {
    echo "=========================================="
    echo "       ORTHANC STATUS CHECK"
    echo "=========================================="
    echo

    check_docker
    echo ""
    check_orthanc_container
    echo ""
    check_orthanc_api
    echo ""
    check_disk_space
    echo ""
    check_database
    echo ""
    check_network
    echo ""

    echo "=========================================="
    if docker ps -q 2>/dev/null | grep -q "server-orthanc" && curl -sf http://localhost:8042/system >/dev/null 2>&1; then
        log_success "Orthanc server is fully operational!"
        echo "Access: http://localhost:8042"
    else
        log_error "Orthanc is not accessible. Check services!"
        echo ""
        echo "Troubleshooting:"
        echo "1. Check container: docker ps -a | grep orthanc"
        echo "2. Check logs: docker logs server-orthanc"
        echo "3. Test connection: curl -s http://localhost:8042/system"
        echo "4. Check ports: netstat -tlnp | grep -E '8042|4242'"
    fi
    echo "=========================================="
}

# ==========================================
# USAGE
# ==========================================

usage() {
    echo "Usage: $0 <option>"
    echo ""
    echo "Options:"
    echo "  all        - Check semua status (default)"
    echo "  status     - Show summary status table"
    echo "  docker     - Check Docker service status"
    echo "  container  - Check Orthanc container"
    echo "  api        - Check Orthanc API"
    echo "  disk       - Check disk space"
    echo "  db         - Check database integrity"
    echo "  network    - Check network connectivity"
    echo "  help       - Show this help message"
    echo ""
    echo "Examples:"
    echo "  $0 all        - Check semua status"
    echo "  $0 status     - Show summary table"
    echo "  $0 docker     - Check Docker status only"
}

# ==========================================
# MAIN EXECUTION
# ==========================================

case "${1:-all}" in
    docker)
        check_docker
        ;;
    container)
        check_orthanc_container
        ;;
    api)
        check_orthanc_api
        ;;
    db)
        check_database
        ;;
    disk)
        check_disk_space
        ;;
    network)
        check_network
        ;;
    all)
        check_docker
        check_orthanc_container
        check_orthanc_api
        check_database
        check_disk_space
        check_network
        ;;
    status)
        show_status
        ;;
    help|*)
        usage
        ;;
esac
