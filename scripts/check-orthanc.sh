#!/bin/bash

# ==========================================
# check-orthanc.sh
# Script untuk mengecek status Orthanc server
# ==========================================

set -e

# ==========================================
# KONFIGURASI
# ==========================================

PROJECT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")")
DATA_DIR="${PROJECT_DIR}/orthanc-data"
BACKUP_DIR="${PROJECT_DIR}/backups"
LOG_FILE="${PROJECT_DIR}/logs/orthanc-check.log"

# Color codes
GREEN='\033[0;32m'
RED='\033[1;31m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'

# ==========================================
# FUNGSI LOGGING
# ==========================================

log_info() {
    echo -e "${GREEN}[INFO]${RESET} $*" | tee -a "$LOG_FILE"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${RESET} $*" | tee -a "$LOG_FILE"
}

log_error() {
    echo -e "${RED}[ERROR]${RESET} $*" | tee -a "$LOG_FILES"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${RESET} $*" | tee -a "$LOG_FILE"
}

# ==========================================
# FUNGSI STATUS CHECK
# ==========================================

check_docker() {
    log_info "Checking Docker status..."
    if command -v docker >/dev/null; then
        if docker ps --format '{{.Status}}' | grep -q "Running"; then
            log_success "Docker is running"
        else
            log_error "Docker is not running!"
        fi
    else
        log_error "Docker is not installed"
        return 1
    fi
}

check_orthanc_container() {
    log_info "Checking Orthanc container..."

    if command -v docker >/dev/null; then
        if docker ps --format '{{.Names}}' | grep -q "server-orthanc"; then
            # Check HTTP API
            if curl -s http://localhost:8042/system >/dev/null; then
                log_success "Orthanc HTTP API is accessible"
            else
                log_error "Orthanc HTTP API is not accessible"
                return 1
            fi

            # Check DICOM port
            if nc -zv localhost 8042 >/dev/null 2>&1; then
                log_success "Orthanc DICOM port (8042) is open"
            else
                log_error "Orthanc DICOM port (4242) is closed"
                return 1
            fi
        else
            log_error "Orthanc container not found"
            return 1
        fi
    else
        log_error "Docker is not installed"
        return 1
    fi
}

check_orthanc_api() {
    log_info "Checking Orthanc API..."

    if curl -s http://localhost:8042/system >/dev/null 2>&1; then
        log_success "Orthanc API is accessible"

        SYSTEM_INFO=$(curl -s http://localhost:8042/system)

        log_info "System: $(echo "$SYSTEM_INFO" | jq -r '.Name')"
        log_info "Version: $(echo "$SYSTEM_INFO" | jq -r '.Version')"

        STATISTICS=$(curl -s http:// "localhost:8042/tools/statistics" 2>/dev/null)
        log_info "Statistics: $(echo "$STATISTICS" | jq '.Patients, .Studies, .Series, .Instances')"
    else
        log_error "Orthanc API is not accessible"
        return 1
    fi
}

check_disk_space() {
    log_info "Checking disk space..."

    # Check orthanc-data directory
    if [ ! -d "$DATA_DIR" ]; then
        log_error "Orthanc data directory not found: $DATA_DIR"
        return 1
    fi

    # Check disk space
    TOTAL_USAGE=$(du -sh "$DATA_DIR" | tail -n 1)
    AVAILABLE=$((100 - TOTAL_USAGE))

    log_info "Disk usage: $TOTAL_USAGE% used, $AVAILABLE% free"

    if [ $TOTAL_USAGE -gt 80 ]; then
        log_warning "Disk usage is ${TOTAL_USAGE}% (critical!)"
    elif [ $TOTAL_USAGE -gt 60 ]; then
        log_warning "Disk usage is ${TOTAL_USAGE}% (warning)"
    fi
}

check_database() {
    log_info "Checking database..."

    if [ -f "$DATA_DIR/index" ]; then
        DB_SIZE=$(du -sh "$DATA_DIR/index" | cut -f1)
        DB_SIZE_MB=$((DB_SIZE / 1024 / 1024))
        log_info "Database size: $DB_SIZE_MB MB"

        # Check database integrity
        if sqlite3 "$DATA_DIR/index" "PRAGMA integrity_check;" >/dev/null 2>&1; then
            log_success "Database integrity check: PASSED"
        else
            log_error "Database integrity check: FAILED!"
        fi
    else
        log_warning "Database file not found: $DATA_DIR/index"
    fi
}

check_network() {
    log_info "Checking network connectivity..."

    # Test internet connection
    if ping -c 3 google.com >/dev/null 2>&1; then
        log_success "Internet connection OK"
    else
        log_error "No internet connection"
        return 1
    fi

    # Test DNS resolution
    if command -v nslookup >/dev/null; then
        if nslookup orthanc.yourdomain.com >/dev/null 2>/dev/null; then
            log_success "DNS resolution OK"
        else
            log_warning "DNS resolution failed"
        fi
    else
        log_warning "nslookup not installed"
    fi
}

# ==========================================
# MAIN CHECK STATUS
# ==========================================

main_status() {
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
    echo "STATUS: "

    # Show table status
    if command -v docker >/dev/null && docker ps -q | grep -q "server-orthanc"; then
        STATUS="Running"
        COLOR=$GREEN
    else
        STATUS="Stopped"
        COLOR=$RED
    fi

    echo "Container: $STATUS"
    echo "Color: $COLOR"
    echo ""

    echo "=========================================="
}

    # Summary
    if docker ps -q | grep -q "server-orthanc" && curl -s http://localhost:8042/system >/dev/null 2>/dev/null; then
        log_success "Orthanc server is fully operational!"
        echo "Access: http://localhost:8042"
        echo "Login: Tidak ada (authentication disabled)"
    else
        log_error "Orthanc is not accessible. Check services!"
        echo ""
        echo "Troubleshooting:"
        echo "1. Check container: docker ps -a | grep orthanc"
        echo "2. Check logs: docker logs orthanc"
        echo "3. Test connection: curl -s http://localhost:8042/system"
        echo "4. Check ports: sudo netstat -tlnp | grep -E '8042|4242'"
    fi

    echo "=========================================="
}

# ==========================================
# ARGUMENTS
# ==========================================

usage() {
    echo "Usage: $0 <option>"
    echo ""
    echo "Options:"
    echo "  docker   - Check Docker service status"
    echo "  container - Check Orthanc container"
    "  api     - Check Orthanc API"
    "  disk     - Check disk space"
    "  db       - Check database integrity"
    "  network  - Check network connectivity"
    "  all      - Check all services"
    "  status  - Show summary status table"
    "  help     - Show this help message"

    echo ""
    echo "Examples:"
    echo "  $0 all        - Check semua status"
    echo "  $0 status     - Show summary table"
    echo "  $0 docker     - Check Docker status only"
    echo "  $0 container  - Check Orthanc container only"
    echo "  $0 api        - Check Orthanc API only"
    " 0 db          - Check database only"
    echo " 0 network     - Check network only"
    " 0 disk        - Check disk space only"
```

    exit 0
}

# ==========================================
# MAIN EXECUTION
# ==========================================

# Parse arguments
case "$1" in
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
        main_status
        ;;
    help)
        usage
        ;;
    *)
        usage
        ;;
esac
        echo "Command tidak dikenal: $1"
        usage
        ;;
esac
done
