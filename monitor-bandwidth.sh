#!/bin/bash

###############################################################################
# DrayTek Router Bandwidth Monitoring Script
# 
# Description: Real-time bandwidth monitoring using SNMP
#              Tracks WAN/LAN traffic, generates graphs and alerts
# 
# Author: DrayTek Enterprise Lab
# Version: 1.0
# Date: 2026-01-17
#
# Usage: 
#   ./monitor-bandwidth.sh [OPTIONS]
#
# Options: 
#   -i, --ip         Router IP address (default: 192.168.99.1)
#   -c, --community  SNMP community string (default: public)
#   -d, --duration   Monitoring duration in seconds (default: 3600)
#   -n, --interval   Sample interval in seconds (default: 5)
#   -o, --output     Output directory (default: ./bandwidth-reports)
#   -a, --alert      Alert threshold in Mbps (default: 80)
#   -h, --help       Show help
#
# Example:
#   ./monitor-bandwidth.sh -i 192.168.99.1 -c public -d 1800 -n 10
###############################################################################

set -euo pipefail

# Default configuration
ROUTER_IP="${ROUTER_IP:-192.168.99.1}"
SNMP_COMMUNITY="${SNMP_COMMUNITY:-public}"
DURATION="${DURATION:-3600}"  # 1 hour default
INTERVAL="${INTERVAL:-5}"     # 5 seconds
OUTPUT_DIR="${OUTPUT_DIR:-./bandwidth-reports}"
ALERT_THRESHOLD="${ALERT_THRESHOLD:-80}"  # Mbps

# SNMP OIDs for interface statistics
OID_IF_IN_OCTETS="1.3.6.1.2.1.2.2.1.10"   # ifInOctets
OID_IF_OUT_OCTETS="1.3.6.1.2.1.2.2.1.16"  # ifOutOctets
OID_IF_DESCR="1.3.6.1.2.1.2.2.1.2"        # ifDescr
OID_IF_SPEED="1.3.6.1.2.1.2.2.1.5"        # ifSpeed

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
MAGENTA='\033[0;35m'
NC='\033[0m'

# Data storage
declare -A PREV_IN_OCTETS
declare -A PREV_OUT_OCTETS
declare -A PREV_TIMESTAMP

# Banner
show_banner() {
    cat << "EOF"
╔═════════════════════════════════════════════════════��═════╗
║   DrayTek Bandwidth Monitoring Script v1.0                ║
║   Real-time traffic analysis and reporting                ║
╚═══════════════════════════════════════════════════════════╝
EOF
}

# Logging
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

log_data() {
    echo -e "${CYAN}[DATA]${NC} $1"
}

# Help
show_help() {
    cat << EOF
Usage: $0 [OPTIONS]

Options:
  -i, --ip IP              Router IP address (default: 192.168.99.1)
  -c, --community STRING   SNMP community (default: public)
  -d, --duration SECONDS   Monitoring duration (default:  3600)
  -n, --interval SECONDS   Sample interval (default: 5)
  -o, --output DIR         Output directory (default: ./bandwidth-reports)
  -a, --alert MBPS         Alert threshold in Mbps (default: 80)
  -h, --help               Show this help

Examples: 
  $0 -i 192.168.10.1 -c MyCommString
  $0 --duration 1800 --interval 10 --alert 50
  $0 -i 192.168.99.1 -o /var/reports/bandwidth

EOF
}

# Parse arguments
parse_args() {
    while [[ $# -gt 0 ]]; do
        case $1 in
            -i|--ip)
                ROUTER_IP="$2"
                shift 2
                ;;
            -c|--community)
                SNMP_COMMUNITY="$2"
                shift 2
                ;;
            -d|--duration)
                DURATION="$2"
                shift 2
                ;;
            -n|--interval)
                INTERVAL="$2"
                shift 2
                ;;
            -o|--output)
                OUTPUT_DIR="$2"
                shift 2
                ;;
            -a|--alert)
                ALERT_THRESHOLD="$2"
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

# Check dependencies
check_dependencies() {
    local missing=0
    
    for cmd in snmpget snmpwalk bc; do
        if ! command -v $cmd &>/dev/null; then
            log_error "Required command not found: $cmd"
            missing=1
        fi
    done
    
    if [[ $missing -eq 1 ]]; then
        log_error "Please install missing dependencies:"
        log_error "  Ubuntu/Debian: apt install snmp bc"
        log_error "  CentOS/RHEL:    yum install net-snmp-utils bc"
        log_error "  macOS:         brew install net-snmp bc"
        exit 1
    fi
}

# Get SNMP value
snmp_get() {
    local oid="$1"
    snmpget -v2c -c "$SNMP_COMMUNITY" -Oqv "$ROUTER_IP" "$oid" 2>/dev/null || echo "0"
}

# Discover interfaces
discover_interfaces() {
    log_info "Discovering network interfaces..."
    
    local if_list=$(snmpwalk -v2c -c "$SNMP_COMMUNITY" -Oqv "$ROUTER_IP" "$OID_IF_DESCR" 2>/dev/null)
    
    if [[ -z "$if_list" ]]; then
        log_error "Failed to discover interfaces.  Check SNMP connectivity."
        exit 1
    fi
    
    echo "$if_list" | nl -v 1
    
    log_success "Interface discovery complete"
}

# Get interface speed
get_interface_speed() {
    local if_index="$1"
    local speed=$(snmp_get "${OID_IF_SPEED}. ${if_index}")
    
    # Convert to Mbps
    echo "scale=2; $speed / 1000000" | bc
}

# Calculate bandwidth usage
calculate_bandwidth() {
    local if_index="$1"
    local current_time=$(date +%s)
    local current_in=$(snmp_get "${OID_IF_IN_OCTETS}. ${if_index}")
    local current_out=$(snmp_get "${OID_IF_OUT_OCTETS}.${if_index}")
    
    # Remove quotes/spaces
    current_in=${current_in//[^0-9]/}
    current_out=${current_out//[^0-9]/}
    
    # Default to 0 if empty
    current_in=${current_in:-0}
    current_out=${current_out:-0}
    
    if [[ -n "${PREV_IN_OCTETS[$if_index]}" ]]; then
        local time_diff=$((current_time - PREV_TIMESTAMP[$if_index]))
        
        if [[ $time_diff -gt 0 ]]; then
            # Calculate delta (handle counter wrap at 2^32)
            local in_diff=$(( (current_in - PREV_IN_OCTETS[$if_index]) ))
            local out_diff=$(( (current_out - PREV_OUT_OCTETS[$if_index]) ))
            
            # Handle negative values (counter wrapped)
            [[ $in_diff -lt 0 ]] && in_diff=$((4294967296 + in_diff))
            [[ $out_diff -lt 0 ]] && out_diff=$((4294967296 + out_diff))
            
            # Calculate bandwidth in Mbps (octets * 8 / time / 1000000)
            local in_mbps=$(echo "scale=2; $in_diff * 8 / $time_diff / 1000000" | bc)
            local out_mbps=$(echo "scale=2; $out_diff * 8 / $time_diff / 1000000" | bc)
            
            echo "$in_mbps $out_mbps"
        else
            echo "0 0"
        fi
    else
        echo "0 0"
    fi
    
    # Store current values for next iteration
    PREV_IN_OCTETS[$if_index]=$current_in
    PREV_OUT_OCTETS[$if_index]=$current_out
    PREV_TIMESTAMP[$if_index]=$current_time
}

# Format bandwidth for display
format_bandwidth() {
    local mbps="$1"
    
    if (( $(echo "$mbps < 1" | bc -l) )); then
        # Show in Kbps if < 1 Mbps
        local kbps=$(echo "scale=0; $mbps * 1000" | bc)
        echo "${kbps} Kbps"
    else
        printf "%.2f Mbps" "$mbps"
    fi
}

# Create progress bar
progress_bar() {
    local current="$1"
    local max="$2"
    local width=50
    
    local percentage=$(echo "scale=0; $current * 100 / $max" | bc)
    local filled=$(echo "scale=0; $width * $current / $max" | bc)
    
    printf "["
    printf "%${filled}s" | tr ' ' '█'
    printf "%$((width - filled))s" | tr ' ' '���'
    printf "] %3d%%" "$percentage"
}

# Monitor interfaces
monitor_interfaces() {
    local if_index="$1"
    local if_name="$2"
    local csv_file="${OUTPUT_DIR}/bandwidth-if${if_index}-$(date +%Y%m%d-%H%M%S).csv"
    
    mkdir -p "$OUTPUT_DIR"
    
    # CSV header
    echo "Timestamp,Download_Mbps,Upload_Mbps" > "$csv_file"
    
    local start_time=$(date +%s)
    local end_time=$((start_time + DURATION))
    local sample_count=0
    
    log_info "Monitoring Interface $if_index ($if_name) for ${DURATION}s (interval: ${INTERVAL}s)..."
    log_info "Saving data to: $csv_file"
    
    while [[ $(date +%s) -lt $end_time ]]; do
        local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
        
        # Calculate bandwidth
        read -r in_mbps out_mbps < <(calculate_bandwidth "$if_index")
        
        # Default to 0 if empty
        in_mbps=${in_mbps:-0}
        out_mbps=${out_mbps:-0}
        
        # Save to CSV
        echo "$timestamp,$in_mbps,$out_mbps" >> "$csv_file"
        
        # Display real-time stats
        clear
        show_banner
        echo ""
        log_info "Monitoring Interface:  $if_name (Index: $if_index)"
        echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
        
        echo ""
        echo -e "${GREEN}📥 Download: ${NC} $(format_bandwidth "$in_mbps")"
        local in_percentage=$(echo "scale=0; $in_mbps * 100 / 100" | bc)  # Assuming 100 Mbps link
        progress_bar "$in_mbps" "100"
        echo ""
        
        echo ""
        echo -e "${MAGENTA}📤 Upload:${NC}   $(format_bandwidth "$out_mbps")"
        local out_percentage=$(echo "scale=0; $out_mbps * 100 / 100" | bc)
        progress_bar "$out_mbps" "100"
        echo ""
        
        echo ""
        echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
        
        # Check alerts
        if (( $(echo "$in_mbps > $ALERT_THRESHOLD" | bc -l) )); then
            log_warning "⚠️  Download bandwidth exceeded threshold: $(format_bandwidth "$in_mbps") > ${ALERT_THRESHOLD} Mbps"
        fi
        
        if (( $(echo "$out_mbps > $ALERT_THRESHOLD" | bc -l) )); then
            log_warning "⚠️  Upload bandwidth exceeded threshold: $(format_bandwidth "$out_mbps") > ${ALERT_THRESHOLD} Mbps"
        fi
        
        echo ""
        local elapsed=$(($(date +%s) - start_time))
        local remaining=$((DURATION - elapsed))
        echo -e "Sample: $((++sample_count)) | Elapsed: ${elapsed}s | Remaining: ${remaining}s"
        echo -e "Press ${RED}Ctrl+C${NC} to stop monitoring"
        
        sleep "$INTERVAL"
    done
    
    log_success "Monitoring completed.  Data saved to: $csv_file"
}

# Generate report
generate_report() {
    local if_index="$1"
    local if_name="$2"
    local csv_file=$(ls -t "${OUTPUT_DIR}"/bandwidth-if${if_index}-*.csv 2>/dev/null | head -1)
    
    if [[ !  -f "$csv_file" ]]; then
        log_warning "No data file found for interface $if_index"
        return
    fi
    
    log_info "Generating bandwidth report..."
    
    # Calculate statistics
    local avg_download=$(awk -F',' 'NR>1 {sum+=$2; count++} END {if (count>0) print sum/count; else print 0}' "$csv_file")
    local avg_upload=$(awk -F',' 'NR>1 {sum+=$3; count++} END {if (count>0) print sum/count; else print 0}' "$csv_file")
    local max_download=$(awk -F',' 'NR>1 {if ($2>max) max=$2} END {print max+0}' "$csv_file")
    local max_upload=$(awk -F',' 'NR>1 {if ($3>max) max=$3} END {print max+0}' "$csv_file")
    local min_download=$(awk -F',' 'NR>1 {if (min=="" || $2<min) min=$2} END {print min+0}' "$csv_file")
    local min_upload=$(awk -F',' 'NR>1 {if (min=="" || $3<min) min=$3} END {print min+0}' "$csv_file")
    
    local report_file="${OUTPUT_DIR}/bandwidth-report-if${if_index}-$(date +%Y%m%d-%H%M%S).html"
    
    cat > "$report_file" << EOF
<!DOCTYPE html>
<html>
<head>
    <title>Bandwidth Report - Interface $if_name</title>
    <script src="https://cdn.jsdelivr.net/npm/chart.js"></script>
    <style>
        body { font-family:  Arial, sans-serif; margin:  20px; background:  #f5f5f5; }
        .container { max-width: 1400px; margin: 0 auto; background: white; padding: 30px; box-shadow: 0 2px 4px rgba(0,0,0,0.1); }
        h1 { color: #0066cc; border-bottom: 3px solid #0066cc; padding-bottom:  10px; }
        . stats { display: grid; grid-template-columns: repeat(auto-fit, minmax(200px, 1fr)); gap: 20px; margin:  30px 0; }
        . stat-box { background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); color: white; padding: 20px; border-radius: 10px; text-align: center; }
        .stat-box h3 { margin: 0 0 10px 0; font-size: 14px; opacity: 0.9; }
        .stat-box . value { font-size: 32px; font-weight: bold; }
        .stat-box .unit { font-size: 16px; opacity: 0.8; }
        .chart-container { position: relative; height: 400px; margin: 30px 0; }
        table { width: 100%; border-collapse: collapse; margin: 20px 0; }
        th, td { padding: 12px; text-align: left; border:  1px solid #ddd; }
        th { background: #0066cc; color: white; }
        tr:nth-child(even) { background: #f2f2f2; }
    </style>
</head>
<body>
    <div class="container">
        <h1>📊 Bandwidth Report - Interface $if_name</h1>
        <p><strong>Interface Index:</strong> $if_index</p>
        <p><strong>Report Generated:</strong> $(date '+%Y-%m-%d %H:%M:%S')</p>
        <p><strong>Monitoring Duration:</strong> ${DURATION}s ($(echo "scale=1; $DURATION/60" | bc) minutes)</p>
        <p><strong>Sample Interval:</strong> ${INTERVAL}s</p>
        
        <h2>Statistics Summary</h2>
        <div class="stats">
            <div class="stat-box">
                <h3>📥 Avg Download</h3>
                <div class="value">$(printf "%.2f" "$avg_download")</div>
                <div class="unit">Mbps</div>
            </div>
            <div class="stat-box">
                <h3>📤 Avg Upload</h3>
                <div class="value">$(printf "%.2f" "$avg_upload")</div>
                <div class="unit">Mbps</div>
            </div>
            <div class="stat-box">
                <h3>📥 Max Download</h3>
                <div class="value">$(printf "%.2f" "$max_download")</div>
                <div class="unit">Mbps</div>
            </div>
            <div class="stat-box">
                <h3>📤 Max Upload</h3>
                <div class="value">$(printf "%.2f" "$max_upload")</div>
                <div class="unit">Mbps</div>
            </div>
        </div>
        
        <h2>Bandwidth Over Time</h2>
        <div class="chart-container">
            <canvas id="bandwidthChart"></canvas>
        </div>
        
        <h2>Raw Data</h2>
        <p><a href="$(basename "$csv_file")">Download CSV</a></p>
        
        <table>
            <tr>
                <th>Timestamp</th>
                <th>Download (Mbps)</th>
                <th>Upload (Mbps)</th>
            </tr>
EOF
    
    # Add table rows (last 50 samples)
    tail -n 51 "$csv_file" | tail -n 50 | while IFS=',' read -r ts dl ul; do
        [[ "$ts" == "Timestamp" ]] && continue
        cat >> "$report_file" << EOF
            <tr>
                <td>$ts</td>
                <td>$(printf "%.2f" "$dl")</td>
                <td>$(printf "%.2f" "$ul")</td>
            </tr>
EOF
    done
    
    # Generate Chart.js data
    local timestamps=$(awk -F',' 'NR>1 {print "\"" $1 "\""}' "$csv_file" | paste -sd ',' -)
    local downloads=$(awk -F',' 'NR>1 {print $2}' "$csv_file" | paste -sd ',' -)
    local uploads=$(awk -F',' 'NR>1 {print $3}' "$csv_file" | paste -sd ',' -)
    
    cat >> "$report_file" << EOF
        </table>
    </div>
    
    <script>
    const ctx = document.getElementById('bandwidthChart').getContext('2d');
    const chart = new Chart(ctx, {
        type: 'line',
        data: {
            labels: [$timestamps],
            datasets: [{
                label: 'Download (Mbps)',
                data:  [$downloads],
                borderColor: 'rgb(75, 192, 192)',
                backgroundColor: 'rgba(75, 192, 192, 0.1)',
                tension: 0.1
            }, {
                label: 'Upload (Mbps)',
                data: [$uploads],
                borderColor: 'rgb(255, 99, 132)',
                backgroundColor: 'rgba(255, 99, 132, 0.1)',
                tension: 0.1
            }]
        },
        options: {
            responsive: true,
            maintainAspectRatio: false,
            plugins: {
                title: {
                    display:  true,
                    text: 'Bandwidth Usage Over Time'
                },
                legend: {
                    display:  true,
                    position: 'top'
                }
            },
            scales: {
                y: {
                    beginAtZero: true,
                    title: {
                        display: true,
                        text: 'Bandwidth (Mbps)'
                    }
                },
                x: {
                    display: false  // Hide x-axis labels (too many timestamps)
                }
            }
        }
    });
    </script>
</body>
</html>
EOF
    
    log_success "Report generated: $report_file"
    
    # Copy CSV to report directory
    cp "$csv_file" "${OUTPUT_DIR}/"
    
    # Open report in browser (optional, comment out if not wanted)
    if command -v xdg-open &>/dev/null; then
        xdg-open "$report_file" 2>/dev/null &
    elif command -v open &>/dev/null; then
        open "$report_file" 2>/dev/null &
    fi
}

# Cleanup on exit
cleanup() {
    echo ""
    log_info "Monitoring interrupted. Generating report..."
    generate_report "$MONITORED_IF_INDEX" "$MONITORED_IF_NAME"
    exit 0
}

# Main execution
main() {
    show_banner
    parse_args "$@"
    check_dependencies
    
    log_info "=== Bandwidth Monitoring Started ==="
    log_info "Router: $ROUTER_IP"
    log_info "Community: ${SNMP_COMMUNITY: 0:3}*** (hidden)"
    log_info "Duration: ${DURATION}s"
    log_info "Interval:  ${INTERVAL}s"
    log_info "Alert Threshold: ${ALERT_THRESHOLD} Mbps"
    
    # Discover interfaces
    echo ""
    discover_interfaces
    echo ""
    
    # Prompt for interface selection
    read -p "Enter interface index to monitor (default: 1 for WAN): " if_index
    if_index=${if_index:-1}
    
    local if_name=$(snmpget -v2c -c "$SNMP_COMMUNITY" -Oqv "$ROUTER_IP" "${OID_IF_DESCR}. ${if_index}" 2>/dev/null)
    if_name=${if_name:-"Interface $if_index"}
    
    # Export for cleanup function
    MONITORED_IF_INDEX=$if_index
    MONITORED_IF_NAME=$if_name
    
    # Set trap for cleanup
    trap cleanup INT TERM
    
    # Start monitoring
    monitor_interfaces "$if_index" "$if_name"
    
    # Generate final report
    generate_report "$if_index" "$if_name"
    
    log_success "=== Monitoring Complete ==="
}

main "$@"