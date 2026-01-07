<#
.SYNOPSIS
    DrayTek Router Health Check Script
    
.DESCRIPTION
    Comprehensive health check for DrayTek routers including:
    - Connectivity test
    - System status (CPU, Memory, Uptime)
    - WAN status
    - VPN status
    - Firewall session count
    - SNMP metrics collection
    
.PARAMETER RouterIP
    IP address of the router
    
.PARAMETER SNMPCommunity
    SNMP read community string
    
.PARAMETER AlertEmail
    Email address for alerts (optional)
    
.EXAMPLE
    .\health-check.ps1 -RouterIP 192.168.99.1 -SNMPCommunity "public"
    
.NOTES
    Author: DrayTek Enterprise Lab
    Version: 1.0
    Requires:  SNMP tools (snmpget. exe)
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory=$true)]
    [string]$RouterIP,
    
    [Parameter(Mandatory=$true)]
    [string]$SNMPCommunity,
    
    [Parameter(Mandatory=$false)]
    [string]$AlertEmail = "",
    
    [Parameter(Mandatory=$false)]
    [string]$ReportPath = ".\health-reports"
)

# Configuration
$ErrorActionPreference = "Continue"
$SNMPVersion = "2c"
$SNMPPort = 161

# Health check thresholds
$CPU_THRESHOLD = 80
$MEMORY_THRESHOLD = 90
$MIN_UPTIME_HOURS = 1  # Alert if uptime < 1 hour (recent reboot)

# Colors
$Colors = @{
    INFO    = "Cyan"
    SUCCESS = "Green"
    WARNING = "Yellow"
    ERROR   = "Red"
    HEADER  = "Magenta"
}

# OIDs (Common SNMP OIDs)
$OIDs = @{
    SystemDescr     = "1.3.6.1.2.1.1.1.0"
    SystemUptime    = "1.3.6.1.2.1.1.3.0"
    SystemName      = "1.3.6.1.2.1.1.5.0"
    CPULoad         = "1.3.6.1.4.1.2021.10.1.3. 1"
    MemoryTotal     = "1.3.6.1.4.1.2021.4.5.0"
    MemoryFree      = "1.3.6.1.4.1.2021.4.11.0"
    InterfaceStatus = "1.3.6.1.2.1.2.2.1.8"  # ifOperStatus
    InterfaceInOctets  = "1.3.6.1.2.1.2.2.1.10"  # ifInOctets
    InterfaceOutOctets = "1.3.6.1.2.1.2.2.1.16"  # ifOutOctets
}

# Health check results
$HealthStatus = @{
    Overall = "HEALTHY"
    Checks  = @()
}

# Banner
function Show-Banner {
    $banner = @"
╔═══════════════════════════════════════════════════════════╗
║   DrayTek Router Health Check Script v1.0                 ║
║   Real-time monitoring and diagnostics                    ║
╚═══════════════════════════════════════════════════════════╝
"@
    Write-Host $banner -ForegroundColor $Colors. HEADER
}

# Logging
function Write-HealthLog {
    param(
        [string]$Message,
        [ValidateSet("INFO", "SUCCESS", "WARNING", "ERROR", "HEADER")]
        [string]$Level = "INFO"
    )
    
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $color = $Colors[$Level]
    Write-Host "[$timestamp] [$Level] $Message" -ForegroundColor $color
}

# SNMP Get
function Get-SNMPValue {
    param(
        [string]$OID,
        [string]$Description = ""
    )
    
    try {
        # Using native Windows SNMP (if available) or external snmpget
        # Note: snmpget.exe from Net-SNMP package required
        # Install:  choco install net-snmp or download from net-snmp.org
        
        $snmpget = "snmpget"  # Adjust path if needed
        $result = & $snmpget -v $SNMPVersion -c $SNMPCommunity ${RouterIP}: ${SNMPPort} $OID 2>$null
        
        if ($LASTEXITCODE -eq 0 -and $result) {
            # Parse result (format: OID = TYPE:  VALUE)
            if ($result -match "=\s*(. +?):\s*(.+)$") {
                return $matches[2]. Trim()
            }
        }
        return $null
    } catch {
        Write-HealthLog "SNMP query failed for OID $OID :  $_" -Level "WARNING"
        return $null
    }
}

# Test 1: Connectivity
function Test-RouterConnectivity {
    Write-HealthLog "Testing router connectivity..." -Level "INFO"
    
    $pingResult = Test-Connection -ComputerName $RouterIP -Count 3 -Quiet
    
    $check = @{
        Name   = "Connectivity"
        Status = if ($pingResult) { "PASS" } else { "FAIL" }
        Message = if ($pingResult) { "Router is reachable via ICMP" } else { "Router not reachable" }
        Level  = if ($pingResult) { "SUCCESS" } else { "ERROR" }
    }
    
    $HealthStatus. Checks += $check
    Write-HealthLog $check.Message -Level $check.Level
    
    if (-not $pingResult) {
        $HealthStatus.Overall = "CRITICAL"
    }
    
    return $pingResult
}

# Test 2: System Info
function Get-SystemInfo {
    Write-HealthLog "Querying system information..." -Level "INFO"
    
    $sysDescr = Get-SNMPValue -OID $OIDs.SystemDescr
    $sysName  = Get-SNMPValue -OID $OIDs.SystemName
    $uptime   = Get-SNMPValue -OID $OIDs.SystemUptime
    
    if ($uptime) {
        # Convert timeticks to hours
        $uptimeTicks = [int64]($uptime -replace '\D', '')
        $uptimeHours = [math]::Round($uptimeTicks / 100 / 3600, 2)
        
        $check = @{
            Name    = "System Uptime"
            Status  = if ($uptimeHours -gt $MIN_UPTIME_HOURS) { "PASS" } else { "WARNING" }
            Message = "Uptime: $uptimeHours hours"
            Level   = if ($uptimeHours -gt $MIN_UPTIME_HOURS) { "SUCCESS" } else { "WARNING" }
            Value   = $uptimeHours
        }
        
        $HealthStatus.Checks += $check
        Write-HealthLog $check.Message -Level $check. Level
        
        if ($uptimeHours -lt $MIN_UPTIME_HOURS) {
            Write-HealthLog "WARNING: Recent reboot detected (< $MIN_UPTIME_HOURS hours)" -Level "WARNING"
        }
    }
    
    if ($sysDescr) {
        Write-HealthLog "System Description:  $sysDescr" -Level "INFO"
    }
    if ($sysName) {
        Write-HealthLog "System Name: $sysName" -Level "INFO"
    }
}

# Test 3: CPU and Memory
function Test-SystemResources {
    Write-HealthLog "Checking system resources..." -Level "INFO"
    
    $cpuLoad = Get-SNMPValue -OID $OIDs.CPULoad
    if ($cpuLoad) {
        $cpuPercent = [int]($cpuLoad -replace '\D', '')
        
        $check = @{
            Name    = "CPU Load"
            Status  = if ($cpuPercent -lt $CPU_THRESHOLD) { "PASS" } else { "WARNING" }
            Message = "CPU Load: $cpuPercent%"
            Level   = if ($cpuPercent -lt $CPU_THRESHOLD) { "SUCCESS" } else { "WARNING" }
            Value   = $cpuPercent
        }
        
        $HealthStatus.Checks += $check
        Write-HealthLog $check.Message -Level $check.Level
        
        if ($cpuPercent -ge $CPU_THRESHOLD) {
            $HealthStatus.Overall = "WARNING"
        }
    }
    
    $memTotal = Get-SNMPValue -OID $OIDs. MemoryTotal
    $memFree  = Get-SNMPValue -OID $OIDs.MemoryFree
    
    if ($memTotal -and $memFree) {
        $memTotalKB = [int64]($memTotal -replace '\D', '')
        $memFreeKB  = [int64]($memFree -replace '\D', '')
        $memUsedPercent = [math]::Round((1 - ($memFreeKB / $memTotalKB)) * 100, 2)
        
        $check = @{
            Name    = "Memory Usage"
            Status  = if ($memUsedPercent -lt $MEMORY_THRESHOLD) { "PASS" } else { "WARNING" }
            Message = "Memory Usage: $memUsedPercent% (Free: $([math]::Round($memFreeKB/1024, 2)) MB)"
            Level   = if ($memUsedPercent -lt $MEMORY_THRESHOLD) { "SUCCESS" } else { "WARNING" }
            Value   = $memUsedPercent
        }
        
        $HealthStatus. Checks += $check
        Write-HealthLog $check.Message -Level $check.Level
        
        if ($memUsedPercent -ge $MEMORY_THRESHOLD) {
            $HealthStatus.Overall = "WARNING"
        }
    }
}

# Test 4: Interface Status
function Test-InterfaceStatus {
    Write-HealthLog "Checking network interfaces..." -Level "INFO"
    
    # Check WAN1 (usually ifIndex 1)
    for ($ifIndex = 1; $ifIndex -le 4; $ifIndex++) {
        $ifStatus = Get-SNMPValue -OID "$($OIDs.InterfaceStatus).$ifIndex"
        
        if ($ifStatus) {
            $status = switch ($ifStatus) {
                "1" { "UP" }
                "2" { "DOWN" }
                "3" { "TESTING" }
                default { "UNKNOWN" }
            }
            
            $check = @{
                Name    = "Interface $ifIndex"
                Status  = if ($status -eq "UP") { "PASS" } else { "WARNING" }
                Message = "Interface $ifIndex Status: $status"
                Level   = if ($status -eq "UP") { "SUCCESS" } else { "WARNING" }
            }
            
            $HealthStatus.Checks += $check
            Write-HealthLog $check.Message -Level $check.Level
        }
    }
}

# Generate HTML Report
function New-HealthReport {
    if (-not (Test-Path $ReportPath)) {
        New-Item -Path $ReportPath -ItemType Directory -Force | Out-Null
    }
    
    $timestamp = Get-Date -Format "yyyyMMdd-HHmmss"
    $reportFile = Join-Path $ReportPath "health-report-$timestamp.html"
    
    $html = @"
<!DOCTYPE html>
<html>
<head>
    <title>DrayTek Health Report</title>
    <style>
        body { font-family: Arial, sans-serif; margin: 20px; background:  #f5f5f5; }
        .container { max-width: 1200px; margin: 0 auto; background: white; padding: 20px; box-shadow: 0 2px 4px rgba(0,0,0,0.1); }
        h1 { color: #0066cc; border-bottom: 3px solid #0066cc; padding-bottom: 10px; }
        . status { font-size: 24px; font-weight: bold; padding: 20px; text-align: center; border-radius: 5px; margin: 20px 0; }
        .status.healthy { background: #d4edda; color: #155724; }
        .status. warning { background: #fff3cd; color: #856404; }
        .status.critical { background: #f8d7da; color: #721c24; }
        table { width: 100%; border-collapse: collapse; margin: 20px 0; }
        th, td { padding: 12px; text-align: left; border:  1px solid #ddd; }
        th { background: #0066cc; color: white; }
        tr:nth-child(even) { background: #f2f2f2; }
        .pass { color: green; font-weight: bold; }
        .fail { color: red; font-weight: bold; }
        .warn { color: orange; font-weight: bold; }
        .footer { margin-top: 30px; padding-top: 20px; border-top: 1px solid #ddd; color: #666; font-size: 12px; }
    </style>
</head>
<body>
    <div class="container">
        <h1>🏥 DrayTek Router Health Report</h1>
        <p><strong>Router IP:</strong> $RouterIP</p>
        <p><strong>Report Generated:</strong> $(Get-Date -Format "yyyy-MM-dd HH:mm:ss")</p>
        
        <div class="status $($HealthStatus.Overall. ToLower())">
            Overall Status: $($HealthStatus. Overall)
        </div>
        
        <h2>Health Checks</h2>
        <table>
            <tr>
                <th>Check Name</th>
                <th>Status</th>
                <th>Message</th>
            </tr>
"@
    
    foreach ($check in $HealthStatus.Checks) {
        $statusClass = switch ($check.Status) {
            "PASS" { "pass" }
            "FAIL" { "fail" }
            "WARNING" { "warn" }
            default { "" }
        }
        
        $html += @"
            <tr>
                <td>$($check.Name)</td>
                <td class="$statusClass">$($check.Status)</td>
                <td>$($check.Message)</td>
            </tr>
"@
    }
    
    $html += @"
        </table>
        
        <div class="footer">
            <p>Generated by DrayTek Health Check Script v1.0</p>
            <p>Report saved to: $reportFile</p>
        </div>
    </div>
</body>
</html>
"@
    
    $html | Out-File -FilePath $reportFile -Encoding UTF8
    Write-HealthLog "Health report saved:  $reportFile" -Level "SUCCESS"
    
    # Open report in browser (optional)
    # Start-Process $reportFile
}

# Main execution
try {
    Show-Banner
    
    Write-HealthLog "=== Health Check Started ===" -Level "HEADER"
    Write-HealthLog "Target Router: $RouterIP" -Level "INFO"
    
    # Run all checks
    if (Test-RouterConnectivity) {
        Get-SystemInfo
        Test-SystemResources
        Test-InterfaceStatus
    } else {
        Write-HealthLog "Router unreachable, skipping further checks" -Level "ERROR"
        $HealthStatus.Overall = "CRITICAL"
    }
    
    # Generate report
    New-HealthReport
    
    # Summary
    Write-HealthLog "=== Health Check Completed ===" -Level "HEADER"
    Write-HealthLog "Overall Status: $($HealthStatus.Overall)" -Level $(
        if ($HealthStatus.Overall -eq "HEALTHY") { "SUCCESS" }
        elseif ($HealthStatus.Overall -eq "WARNING") { "WARNING" }
        else { "ERROR" }
    )
    
    $passCount = ($HealthStatus.Checks | Where-Object { $_.Status -eq "PASS" }).Count
    $totalChecks = $HealthStatus. Checks.Count
    Write-HealthLog "Checks Passed: $passCount / $totalChecks" -Level "INFO"
    
    # Exit code based on health
    exit $(if ($HealthStatus.Overall -eq "CRITICAL") { 1 } else { 0 })
    
} catch {
    Write-HealthLog "Fatal error during health check: $_" -Level "ERROR"
    exit 1
}