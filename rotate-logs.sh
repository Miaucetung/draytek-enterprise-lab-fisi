#!/bin/bash

###############################################################################
# Intelligent Log Rotation and Archiving Script
# 
# Description: Advanced log rotation with compression, archiving, and cleanup
#              Supports multiple log sources and retention policies
# 
# Author: DrayTek Enterprise Lab
# Version: 1.0
# Date: 2026-01-17
#
# Usage: 
#   ./rotate-logs.sh [OPTIONS]
#
# Options:
#   -d, --dir PATH          Log directory (default: /var/log/draytek)
#   -a, --archive PATH      Archive directory (default: /archive/logs)
#   -r, --retention DAYS    Active log retention (default: 90)
#   -l, --archive-retention DAYS  Archive retention (default: 365)
#   -c, --compress          Compress rotated logs (default: true)
#   -e, --encrypt           Encrypt archived logs (default: false)
#   -k, --key EMAIL         GPG key for encryption
#   -v, --verbose           Verbose output
#   -h, --help              Show help
#
# Example:
#   ./rotate-logs.sh -d /var/log/draytek -r 30 -l 365 --encrypt -k admin@company.local
###############################################################################

set -euo pipefail

# Default configuration
LOG_DIR="${LOG_DIR:-/var/log/draytek}"
ARCHIVE_DIR="${ARCHIVE_DIR:-/archive/logs}"
RETENTION_DAYS="${RETENTION_DAYS:-90}"
ARCHIVE_RETENTION_DAYS="${ARCHIVE_RETENTION_DAYS:-365}"
COMPRESS="${COMPRESS:-true}"
ENCRYPT="${ENCRYPT:-false}"
GPG_KEY="${GPG_KEY:-}"
VERBOSE="${VERBOSE:-false}"

# Statistics
STATS_ROTATED=0
STATS_COMPRESSED=0
STATS_ARCHIVED=0
STATS_DELETED=0
STATS_SPACE_FREED=0

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
MAGENTA='\033[0;35m'
NC='\033[0m'

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

log_verbose() {
    if [[ "$VERBOSE" == "true" ]]; then
        echo -e "${CYAN}[VERBOSE]${NC} $(date '+%Y-%m-%d %H:%M:%S') - $1"
    fi
}

# Banner
show_banner() {
    cat << "EOF"
╔═══════════════════════════════════════════════════════════╗
║   📂 Intelligent Log Rotation Script v1.0                 ║
║   Automated log management with archiving                 ║
╚═══════════════════════════════════════════════════════════╝
EOF
}

# Help
show_help() {
    cat << EOF
Usage: $0 [OPTIONS]

Options:
  -d, --dir PATH                  Log directory (default: /var/log/draytek)
  -a, --archive PATH              Archive directory (default: /archive/logs)
  -r, --retention DAYS            Active retention (default: 90)
  -l, --archive-retention DAYS    Archive retention (default: 365)
  -c, --compress true|false       Compress logs (default: true)
  -e, --encrypt true|false        Encrypt archives (default: false)
  -k, --key EMAIL                 GPG key email for encryption
  -v, --verbose                   Verbose output
  -h, --help                      Show this help

Examples:
  $0 -d /var/log/network -r 30 -l 180
  $0 --encrypt true --key admin@company.local
  $0 -d /var/log/draytek -v

EOF
}

# Parse arguments
parse_args() {
    while [[ $# -gt 0 ]]; do
        case $1 in
            -d|--dir)
                LOG_DIR="$2"
                shift 2
                ;;
            -a|--archive)
                ARCHIVE_DIR="$2"
                shift 2
                ;;
            -r|--retention)
                RETENTION_DAYS="$2"
                shift 2
                ;;
            -l|--archive-retention)
                ARCHIVE_RETENTION_DAYS="$2"
                shift 2
                ;;
            -c|--compress)
                COMPRESS="$2"
                shift 2
                ;;
            -e|--encrypt)
                ENCRYPT="$2"
                shift 2
                ;;
            -k|--key)
                GPG_KEY="$2"
                shift 2
                ;;
            -v|--verbose)
                VERBOSE="true"
                shift
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

# Check dependencies
check_dependencies() {
    local missing=0
    
    for cmd in find gzip tar; do
        if !  command -v $cmd &>/dev/null; then
            log_error "Required command not found: $cmd"
            missing=1
        fi
    done
    
    if [[ "$ENCRYPT" == "true" ]]; then
        if ! command -v gpg &>/dev/null; then
            log_error "GPG not found but encryption is enabled"
            log_error "Install:  apt install gnupg (Ubuntu) or yum install gnupg2 (CentOS)"
            missing=1
        fi
        
        if [[ -z "$GPG_KEY" ]]; then
            log_error "Encryption enabled but no GPG key specified (use -k or --key)"
            missing=1
        fi
    fi
    
    if [[ $missing -eq 1 ]]; then
        exit 1
    fi
}

# Check permissions
check_permissions() {
    if [[ ! -d "$LOG_DIR" ]]; then
        log_error "Log directory does not exist: $LOG_DIR"
        exit 1
    fi
    
    if [[ !  -r "$LOG_DIR" ]]; then
        log_error "No read permission for log directory: $LOG_DIR"
        exit 1
    fi
    
    if [[ ! -d "$ARCHIVE_DIR" ]]; then
        log_info "Creating archive directory: $ARCHIVE_DIR"
        mkdir -p "$ARCHIVE_DIR" || {
            log_error "Failed to create archive directory"
            exit 1
        }
    fi
}

# Get file size in human-readable format
get_human_size() {
    local bytes=$1
    
    if [[ $bytes -lt 1024 ]]; then
        echo "${bytes}B"
    elif [[ $bytes -lt 1048576 ]]; then
        echo "$(( bytes / 1024 ))KB"
    elif [[ $bytes -lt 1073741824 ]]; then
        echo "$(( bytes / 1048576 ))MB"
    else
        echo "$(( bytes / 1073741824 ))GB"
    fi
}

# Rotate logs (compress old logs)
rotate_logs() {
    log_info "Rotating logs in $LOG_DIR..."
    
    # Find uncompressed logs older than 1 day
    while IFS= read -r -d '' logfile; do
        if [[ "$COMPRESS" == "true" ]]; then
            local filesize=$(stat -c%s "$logfile" 2>/dev/null || stat -f%z "$logfile" 2>/dev/null)
            
            log_verbose "Compressing:  $(basename "$logfile") ($(get_human_size $filesize))"
            
            if gzip -9 "$logfile" 2>/dev/null; then
                local compressed_size=$(stat -c%s "${logfile}.gz" 2>/dev/null || stat -f%z "${logfile}.gz" 2>/dev/null)
                local saved=$((filesize - compressed_size))
                
                ((STATS_ROTATED++))
                ((STATS_COMPRESSED++))
                STATS_SPACE_FREED=$((STATS_SPACE_FREED + saved))
                
                log_verbose "✓ Compressed to $(get_human_size $compressed_size) (saved $(get_human_size $saved))"
            else
                log_warning "Failed to compress: $logfile"
            fi
        fi
    done < <(find "$LOG_DIR" -name "*. log" -type f -mtime +1 -print0)
    
    log_success "Log rotation complete:  $STATS_ROTATED files processed"
}

# Archive old logs
archive_logs() {
    log_info "Archiving logs older than $RETENTION_DAYS days..."
    
    local archive_date=$(date +%Y%m%d-%H%M%S)
    local archive_name="draytek-logs-archive-${archive_date}. tar"
    local archive_path="${ARCHIVE_DIR}/${archive_name}"
    
    # Find logs older than retention period
    local files_to_archive=$(find "$LOG_DIR" -name "*.log. gz" -type f -mtime +$RETENTION_DAYS)
    local file_count=$(echo "$files_to_archive" | grep -c .  || echo 0)
    
    if [[ $file_count -eq 0 ]]; then
        log_info "No logs to archive (none older than $RETENTION_DAYS days)"
        return
    fi
    
    log_info "Found $file_count log files to archive"
    
    # Create tar archive
    log_verbose "Creating archive: $archive_name"
    
    find "$LOG_DIR" -name "*.log. gz" -type f -mtime +$RETENTION_DAYS -print0 | \
        tar --null -czf "$archive_path. gz" --files-from=-
    
    if [[ $? -eq 0 ]]; then
        local archive_size=$(stat -c%s "${archive_path}.gz" 2>/dev/null || stat -f%z "${archive_path}.gz" 2>/dev/null)
        log_success "Archive created: $(basename "${archive_path}.gz") ($(get_human_size $archive_size))"
        
        # Encrypt archive if requested
        if [[ "$ENCRYPT" == "true" ]]; then
            log_info "Encrypting archive with GPG..."
            
            if gpg --encrypt --recipient "$GPG_KEY" --output "${archive_path}.gz.gpg" "${archive_path}.gz" 2>/dev/null; then
                rm -f "${archive_path}.gz"
                log_success "Archive encrypted:  $(basename "${archive_path}.gz.gpg")"
            else
                log_error "Failed to encrypt archive"
                return 1
            fi
        fi
        
        # Delete archived files from active log directory
        find "$LOG_DIR" -name "*.log.gz" -type f -mtime +$RETENTION_DAYS -delete
        STATS_ARCHIVED=$file_count
        
        log_success "Archived and removed $file_count files from active logs"
    else
        log_error "Failed to create archive"
        return 1
    fi
}

# Cleanup old archives
cleanup_old_archives() {
    log_info "Cleaning up archives older than $ARCHIVE_RETENTION_DAYS days..."
    
    local deleted_count=0
    local space_freed=0
    
    while IFS= read -r -d '' archive; do
        local filesize=$(stat -c%s "$archive" 2>/dev/null || stat -f%z "$archive" 2>/dev/null)
        
        log_verbose "Deleting old archive: $(basename "$archive") ($(get_human_size $filesize))"
        
        if rm -f "$archive"; then
            ((deleted_count++))
            space_freed=$((space_freed + filesize))
        else
            log_warning "Failed to delete:  $archive"
        fi
    done < <(find "$ARCHIVE_DIR" -name "draytek-logs-archive-*. tar. gz*" -type f -mtime +$ARCHIVE_RETENTION_DAYS -print0)
    
    if [[ $deleted_count -gt 0 ]]; then
        STATS_DELETED=$deleted_count
        STATS_SPACE_FREED=$((STATS_SPACE_FREED + space_freed))
        log_success "Deleted $deleted_count old archives (freed $(get_human_size $space_freed))"
    else
        log_info "No old archives to delete"
    fi
}

# Generate integrity checksums
generate_checksums() {
    log_info "Generating checksums for archives..."
    
    local checksum_file="${ARCHIVE_DIR}/checksums.sha256"
    
    # Generate SHA256 checksums for all archives
    find "$ARCHIVE_DIR" -name "draytek-logs-archive-*. tar.gz*" -type f -exec sha256sum {} + > "$checksum_file. tmp"
    
    if [[ -f "$checksum_file.tmp" ]]; then
        mv "$checksum_file.tmp" "$checksum_file"
        local count=$(wc -l < "$checksum_file")
        log_success "Generated checksums for $count archives"
    fi
}

# Generate report
generate_report() {
    local report_file="${ARCHIVE_DIR}/rotation-report-$(date +%Y%m%d-%H%M%S).txt"
    
    cat > "$report_file" << EOF
═══════════════════���═══════════════════════════════════════
         Log Rotation and Archiving Report
═══════════════════════════════════════════════════════════

Date: $(date '+%Y-%m-%d %H:%M:%S')
Log Directory: $LOG_DIR
Archive Directory: $ARCHIVE_DIR

Configuration:
  Active Retention:    $RETENTION_DAYS days
  Archive Retention:  $ARCHIVE_RETENTION_DAYS days
  Compression:        $COMPRESS
  Encryption:          $ENCRYPT
  GPG Key:            ${GPG_KEY:-N/A}

Statistics:
  Files Rotated:      $STATS_ROTATED
  Files Compressed:   $STATS_COMPRESSED
  Files Archived:      $STATS_ARCHIVED
  Archives Deleted:   $STATS_DELETED
  Space Freed:         $(get_human_size $STATS_SPACE_FREED)

Disk Usage:
  Active Logs:        $(du -sh "$LOG_DIR" 2>/dev/null | cut -f1)
  Archives:           $(du -sh "$ARCHIVE_DIR" 2>/dev/null | cut -f1)

Active Log Files:  $(find "$LOG_DIR" -type f | wc -l)
Archive Files:    $(find "$ARCHIVE_DIR" -name "*.tar.gz*" -type f | wc -l)

═══════════════════════════════════════════════════════════
EOF
    
    cat "$report_file"
    log_success "Report saved:  $report_file"
}

# Main execution
main() {
    show_banner
    parse_args "$@"
    
    log_info "=== Log Rotation Started ==="
    log_info "Log Directory: $LOG_DIR"
    log_info "Archive Directory: $ARCHIVE_DIR"
    log_info "Active Retention: $RETENTION_DAYS days"
    log_info "Archive Retention: $ARCHIVE_RETENTION_DAYS days"
    
    check_dependencies
    check_permissions
    
    # Rotate logs (compress)
    rotate_logs
    
    # Archive old logs
    archive_logs
    
    # Cleanup old archives
    cleanup_old_archives
    
    # Generate checksums
    generate_checksums
    
    # Generate report
    echo ""
    generate_report
    
    log_success "=== Log Rotation Completed ==="
    log_success "Total space freed: $(get_human_size $STATS_SPACE_FREED)"
}

main "$@"