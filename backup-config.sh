#!/bin/bash

###############################################################################
# DrayTek Router Configuration Backup Script (Linux/macOS)
# 
# Description: Automated backup of DrayTek router configuration via HTTP/HTTPS
# Author: DrayTek Enterprise Lab
# Version: 1.0
# Date: 2026-01-17
#
# Usage:
#   ./backup-config.sh [OPTIONS]
#
# Options:
#   -i, --ip         Router IP address (default: 192.168.99.1)
#   -u, --username   Admin username (default: admin)
#   -p, --password   Admin password (will prompt if not provided)
#   -d, --dir        Backup directory (default: ./backups)
#   -s, --secure     Use HTTPS (default: true)
#   -r, --retention  Retention days (default: 90)
#   -h, --help       Show this help message
#
# Example:
#   ./backup-config.sh -i 192.168.99.1 -u admin -d /var/backups/router
###############################################################################

set -euo pipefail  # Exit on error, undefined vars, pipe failures

# Default configuration
ROUTER_IP="${ROUTER_IP:-192.168.99.1}"
USERNAME="${USERNAME:-admin}"
PASSWORD="${PASSWORD:-}"
BACKUP_DIR="${BACKUP_DIR:-./backups}"
USE_HTTPS="${USE_HTTPS:-true}"
RETENTION_DAYS="${RETENTION_DAYS:-90}"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Logging functions
log_info() {
    echo -e "${BLUE}[INFO]${NC} $(date '+%Y-%m-%d %H:%M:%S') - $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $(date '+%Y-%m-%d %H:%M:%S') - $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $(date '+%Y-%m-%d %H:%M:%S') - $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $(date '+%Y-%m-%d %H:%M:%S') - $1" >&2
}

# Banner
show_banner() {
    cat << "EOF"
╔═══════════════════════════════════════════════════════════╗
║   DrayTek Router Configuration Backup Script v1.0         ║
║   Author: Enterprise Lab (Bash Edition)                   ║
╚═══════════════════════════════════════════════════════════╝
EOF
}

# Help message
show_help() {
    cat << EOF
Usage: $0 [OPTIONS]

Options:
  -i, --ip IP          Router IP address (default: 192.168.99.1)
  -u, --username USER  Admin username (default: admin)
  -p, --password PASS  Admin password (prompt if not provided)
  -d, --dir PATH       Backup directory (default: ./backups)
  -s, --secure         Use HTTPS (default: true, set to false for HTTP)
  -r, --retention DAYS Keep backups for N days (default: 90)
  -h, --help           Show this help message

Examples:
  $0 -i 192.168.10.1 -u admin
  $0 --dir /var/backups/router --retention 30
  $0 -i 192.168.99.1 -p MySecurePassword123

EOF
}

# Parse command-line arguments
parse_args() {
    while [[ $# -gt 0 ]]; do
        case $1 in
            -i|--ip)
                ROUTER_IP="$2"
                shift 2
                ;;
            -u|--username)
                USERNAME="$2"
                shift 2
                ;;
            -p|--password)
                PASSWORD="$2"
                shift 2
                ;;
            -d|--dir)
                BACKUP_DIR="$2"
                shift 2
                ;;
            -s|--secure)
                USE_HTTPS="$2"
                shift 2
                ;;
            -r|--retention)
                RETENTION_DAYS="$2"
                shift 2
                ;;
            -h|--help)
                show_help
                exit 0
                ;;
            *)
                log_error "Unknown option: $1"
                show_help
                exit 1
                ;;
        esac
    done
}

# Get password if not provided
get_password() {
    if [[ -z "$PASSWORD" ]]; then
        read -s -p "Enter router admin password: " PASSWORD
        echo
    fi
}

# Test router connectivity
test_connectivity() {
    log_info "Testing connectivity to router $ROUTER_IP..."
    
    if ping -c 2 -W 2 "$ROUTER_IP" &>/dev/null; then
        log_success "Router is reachable via ICMP"
        return 0
    else
        log_error "Router is not reachable via ICMP"
        return 1
    fi
}

# Download configuration from DrayTek
backup_config() {
    local protocol="http"
    if [[ "$USE_HTTPS" == "true" ]]; then
        protocol="https"
    fi
    
    local timestamp=$(date '+%Y%m%d-%H%M%S')
    local backup_filename="draytek-${ROUTER_IP}-${timestamp}. cfg"
    local backup_filepath="${BACKUP_DIR}/${backup_filename}"
    
    # DrayTek backup URL (adjust if needed for your model)
    local backup_url="${protocol}://${ROUTER_IP}/doc/config.cfg"
    
    log_info "Attempting to download config from $backup_url..."
    
    # Download using curl
    local curl_opts=(
        --user "${USERNAME}:${PASSWORD}"
        --output "$backup_filepath"
        --silent
        --show-error
        --max-time 60
    )
    
    if [[ "$USE_HTTPS" == "true" ]]; then
        curl_opts+=(--insecure)  # Accept self-signed certificates
    fi
    
    if curl "${curl_opts[@]}" "$backup_url"; then
        if [[ -f "$backup_filepath" ]]; then
            local file_size=$(stat -f%z "$backup_filepath" 2>/dev/null || stat -c%s "$backup_filepath" 2>/dev/null)
            log_success "Backup successful! File: $backup_filename ($file_size bytes)"
            
            # Verify file is not empty
            if [[ $file_size -lt 100 ]]; then
                log_warning "Backup file is suspiciously small ($file_size bytes). Might be error page."
            fi
            
            echo "$backup_filepath"
            return 0
        else
            log_error "Backup file not found after download"
            return 1
        fi
    else
        log_error "Backup download failed (curl error code: $?)"
        return 1
    fi
}

# Cleanup old backups
cleanup_old_backups() {
    log_info "Cleaning up backups older than $RETENTION_DAYS days..."
    
    local count=0
    while IFS= read -r -d '' file; do
        rm -f "$file"
        log_info "Deleted old backup:  $(basename "$file")"
        ((count++))
    done < <(find "$BACKUP_DIR" -name "draytek-*.cfg" -type f -mtime +$RETENTION_DAYS -print0)
    
    log_success "Cleanup complete: $count old backup(s) removed"
}

# Generate backup report (HTML)
generate_report() {
    local latest_backup="$1"
    local report_path="${BACKUP_DIR}/backup-report.html"
    
    cat > "$report_path" << EOF
<!DOCTYPE html>
<html>
<head>
    <title>DrayTek Backup Report</title>
    <style>
        body { font-family: Arial, sans-serif; margin: 20px; }
        h1 { color: #0066cc; }
        table { border-collapse: collapse; width:  100%; }
        th, td { border: 1px solid #ddd; padding: 8px; text-align: left; }
        th { background-color: #0066cc; color:  white; }
        tr:nth-child(even) { background-color: #f2f2f2; }
        .success { color: green; font-weight:  bold; }
    </style>
</head>
<body>
    <h1>DrayTek Router Backup Report</h1>
    <p>Generated: $(date '+%Y-%m-%d %H:%M:%S')</p>
    <p>Latest Backup:  <span class="success">$(basename "$latest_backup")</span></p>
    
    <h2>All Backups (Sorted by Date)</h2>
    <table>
        <tr>
            <th>Filename</th>
            <th>Date</th>
            <th>Size (KB)</th>
            <th>Age (Days)</th>
        </tr>
EOF
    
    # List all backups
    find "$BACKUP_DIR" -name "draytek-*.cfg" -type f -printf "%T@ %p\n" | sort -rn | while read -r timestamp filepath; do
        local filename=$(basename "$filepath")
        local date_str=$(date -r "$filepath" '+%Y-%m-%d %H:%M:%S' 2>/dev/null || date -d "@${timestamp%.*}" '+%Y-%m-%d %H:%M:%S')
        local size_kb=$(du -k "$filepath" | cut -f1)
        local age_days=$(( ($(date +%s) - ${timestamp%.*}) / 86400 ))
        
        cat >> "$report_path" << EOF
        <tr>
            <td>$filename</td>
            <td>$date_str</td>
            <td>$size_kb</td>
            <td>$age_days</td>
        </tr>
EOF
    done
    
    local backup_count=$(find "$BACKUP_DIR" -name "draytek-*.cfg" -type f | wc -l)
    
    cat >> "$report_path" << EOF
    </table>
    
    <h2>Statistics</h2>
    <ul>
        <li>Total Backups: $backup_count</li>
        <li>Retention Period: $RETENTION_DAYS days</li>
        <li>Storage Path: $BACKUP_DIR</li>
    </ul>
</body>
</html>
EOF
    
    log_info "Backup report generated: $report_path"
}

# Main script execution
main() {
    show_banner
    parse_args "$@"
    
    log_info "=== DrayTek Backup Script Started ==="
    log_info "Router IP: $ROUTER_IP"
    log_info "Backup Path: $BACKUP_DIR"
    log_info "Protocol:  $(if [[ "$USE_HTTPS" == "true" ]]; then echo "HTTPS"; else echo "HTTP"; fi)"
    
    # Create backup directory if not exists
    if [[ ! -d "$BACKUP_DIR" ]]; then
        mkdir -p "$BACKUP_DIR"
        log_info "Created backup directory: $BACKUP_DIR"
    fi
    
    # Log file
    LOG_FILE="${BACKUP_DIR}/backup. log"
    exec > >(tee -a "$LOG_FILE")
    exec 2>&1
    
    # Get password
    get_password
    
    # Test connectivity
    if ! test_connectivity; then
        log_error "Router is not reachable. Aborting backup."
        exit 1
    fi
    
    # Perform backup
    if backup_filepath=$(backup_config); then
        log_success "Backup completed successfully!"
        
        # Cleanup old backups
        cleanup_old_backups
        
        # Generate report
        generate_report "$backup_filepath"
        
        log_success "=== Backup Process Completed Successfully ==="
        exit 0
    else
        log_error "Backup failed. Check logs for details."
        log_error "=== Backup Process Failed ==="
        exit 1
    fi
}

# Run main function
main "$@"