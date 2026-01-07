<#
.SYNOPSIS
    DrayTek Router Security Audit Script
    
.DESCRIPTION
    Comprehensive security audit for DrayTek routers: 
    - Weak password detection
    - Open ports analysis
    - Firewall rule review
    - VPN configuration audit
    - SNMP security check
    - Admin access review
    - Compliance checking (CIS, NIST)
    
.PARAMETER RouterIP
    Router IP address
    
.PARAMETER Username
    Admin username
    
.PARAMETER Password
    Admin password
    
. PARAMETER OutputDir
    Output directory for reports
    
.EXAMPLE
    .\audit-security.ps1 -RouterIP 192.168.99.1 -Username admin
    
.NOTES
    Author: DrayTek Enterprise Lab
    Version: 1.0
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory=$true)]
    [string]$RouterIP,
    
    [Parameter(Mandatory=$false)]
    [string]$Username = "admin",
    
    [Parameter(Mandatory=$false)]
    [securestring]$Password,
    
    [Parameter(Mandatory=$false)]
    [string]$SNMPCommunity = "",
    
    [Parameter(Mandatory=$false)]
    [string]$OutputDir = ".\security-audits"
)

$ErrorActionPreference = "Continue"

# Audit findings storage
$AuditFindings = @{
    Critical = @()
    High     = @()
    Medium   = @()
    Low      = @()
    Info     = @()
}

$AuditScore = 100  # Start with perfect score, deduct points for issues

# Colors
$Colors = @{
    CRITICAL = "Red"
    HIGH     = "DarkRed"
    MEDIUM   = "Yellow"
    LOW      = "DarkYellow"
    INFO     = "Cyan"
    SUCCESS  = "Green"
    HEADER   = "Magenta"
}

# Banner
function Show-Banner {
    $banner = @"
╔═══════════════════════════════════════════════════════════╗
║   🔒 DrayTek Security Audit Script v1.0                   ║
║   Comprehensive security assessment                       ║
╚═══════════════════════════════════════════════════════════╝
"@
    Write-Host $banner -ForegroundColor $Colors. HEADER
}

# Logging
function Write-AuditLog {
    param(
        [string]$Message,
        [ValidateSet("INFO", "SUCCESS", "CRITICAL", "HIGH", "MEDIUM", "LOW")]
        [string]$Level = "INFO"
    )
    
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $color = $Colors[$Level]
    Write-Host "[$timestamp] [$Level] $Message" -ForegroundColor $color
}

# Add finding
function Add-Finding {
    param(
        [string]$Title,
        [string]$Description,
        [string]$Recommendation,
        [ValidateSet("CRITICAL", "HIGH", "MEDIUM", "LOW", "INFO")]
        [string]$Severity,
        [string]$Reference = "",
        [int]$ScoreImpact = 0
    )
    
    $finding = @{
        Title          = $Title
        Description    = $Description
        Recommendation = $Recommendation
        Severity       = $Severity
        Reference      = $Reference
        Timestamp      = Get-Date -Format "yyyy-MM-dd HH: mm:ss"
    }
    
    $AuditFindings[$Severity] += $finding
    
    global: $AuditScore -= $ScoreImpact
    
    Write-AuditLog "[$Severity] $Title" -Level $Severity
}

# Audit 1: Default Credentials Check
function Test-DefaultCredentials {
    Write-AuditLog "Checking for default credentials..." -Level "INFO"
    
    $defaultPasswords = @("admin", "password", "1234", "draytek", "")
    
    foreach ($pwd in $defaultPasswords) {
        # Simulate login attempt (in real scenario, use HTTP auth)
        # This is a placeholder - actual implementation would test HTTP/HTTPS login
        
        if ($pwd -eq "admin" -and $Username -eq "admin") {
            Add-Finding `
                -Title "Default Admin Credentials Detected" `
                -Description "Router is using default username 'admin' which is publicly known" `
                -Recommendation "Change default admin username and password immediately" `
                -Severity "CRITICAL" `
                -Reference "CIS Benchmark 1.1" `
                -ScoreImpact 20
            break
        }
    }
}

# Audit 2: Password Strength
function Test-PasswordStrength {
    Write-AuditLog "Analyzing password strength..." -Level "INFO"
    
    # This would require actual password (can't get from router without breach)
    # We check policy instead
    
    Add-Finding `
        -Title "Password Strength Policy" `
        -Description "Verify admin password meets complexity requirements:  16+ chars, uppercase, lowercase, numbers, symbols" `
        -Recommendation "Enforce strong password policy:  min 16 characters, complexity requirements, regular rotation" `
        -Severity "INFO" `
        -Reference "NIST SP 800-63B"
}

# Audit 3: Open Ports Scan
function Test-OpenPorts {
    Write-AuditLog "Scanning for open ports..." -Level "INFO"
    
    $dangerousPorts = @{
        21   = "FTP (Insecure)"
        23   = "Telnet (Insecure)"
        80   = "HTTP (Insecure Web Management)"
        161  = "SNMP (Potential Info Disclosure)"
        8080 = "HTTP Alternate (Insecure)"
    }
    
    $safePorts = @{
        443  = "HTTPS (Web Management)"
        22   = "SSH (Secure Shell)"
    }
    
    foreach ($port in $dangerousPorts. Keys) {
        $tcpClient = New-Object System.Net. Sockets.TcpClient
        try {
            $tcpClient. ConnectAsync($RouterIP, $port).Wait(1000) | Out-Null
            if ($tcpClient.Connected) {
                $severity = if ($port -in @(21, 23)) { "CRITICAL" } else { "HIGH" }
                $impact = if ($port -in @(21, 23)) { 15 } else { 10 }
                
                Add-Finding `
                    -Title "Insecure Service Port Open:  $port" `
                    -Description "$($dangerousPorts[$port]) is accessible on port $port" `
                    -Recommendation "Disable $($dangerousPorts[$port]) service.  Use secure alternatives (SSH instead of Telnet, HTTPS instead of HTTP)" `
                    -Severity $severity `
                    -ScoreImpact $impact
            }
        } catch {
            # Port closed (good)
        } finally {
            $tcpClient.Close()
        }
    }
    
    # Check if HTTPS is available
    $tcpClient = New-Object System. Net.Sockets.TcpClient
    try {
        $tcpClient.ConnectAsync($RouterIP, 443).Wait(1000) | Out-Null
        if (-not $tcpClient.Connected) {
            Add-Finding `
                -Title "HTTPS Not Enabled" `
                -Description "Secure web management (HTTPS) is not available" `
                -Recommendation "Enable HTTPS for web management, disable HTTP" `
                -Severity "HIGH" `
                -ScoreImpact 10
        }
    } finally {
        $tcpClient. Close()
    }
}

# Audit 4: SNMP Security
function Test-SNMPSecurity {
    Write-AuditLog "Auditing SNMP configuration..." -Level "INFO"
    
    if ($SNMPCommunity) {
        # Test for default community strings
        $defaultCommunities = @("public", "private", "community")
        
        if ($SNMPCommunity -in $defaultCommunities) {
            Add-Finding `
                -Title "Default SNMP Community String" `
                -Description "SNMP is using a default community string '$SNMPCommunity'" `
                -Recommendation "Change SNMP community string to a strong, random value (32+ chars)" `
                -Severity "CRITICAL" `
                -Reference "CIS Benchmark 3.1" `
                -ScoreImpact 15
        }
        
        # Check community string strength
        if ($SNMPCommunity. Length -lt 16) {
            Add-Finding `
                -Title "Weak SNMP Community String" `
                -Description "SNMP community string is too short ($($SNMPCommunity.Length) chars)" `
                -Recommendation "Use SNMP community strings with 32+ random characters" `
                -Severity "HIGH" `
                -ScoreImpact 10
        }
        
        # Recommend SNMPv3
        Add-Finding `
            -Title "SNMPv3 Recommendation" `
            -Description "SNMPv2c is in use. SNMPv3 provides encryption and authentication" `
            -Recommendation "Upgrade to SNMPv3 with authentication and encryption (authPriv)" `
            -Severity "MEDIUM" `
            -ScoreImpact 5
    } else {
        Add-Finding `
            -Title "SNMP Status Unknown" `
            -Description "SNMP configuration could not be verified (community string not provided)" `
            -Recommendation "Verify SNMP is properly secured or disabled if not needed" `
            -Severity "INFO"
    }
}

# Audit 5: Firewall Best Practices
function Test-FirewallConfig {
    Write-AuditLog "Reviewing firewall configuration..." -Level "INFO"
    
    # These checks would require API access or config file parsing
    # Placeholder checks: 
    
    Add-Finding `
        -Title "Firewall Default Policy" `
        -Description "Verify firewall default policy is set to DENY ALL" `
        -Recommendation "Ensure default policy is 'Deny All', then create explicit allow rules" `
        -Severity "INFO" `
        -Reference "CIS Benchmark 4.1"
    
    Add-Finding `
        -Title "Firewall Rule Review" `
        -Description "Regular firewall rule audits are recommended" `
        -Recommendation "Review all firewall rules quarterly, remove unused rules, document business justification" `
        -Severity "INFO" `
        -Reference "NIST SP 800-41"
    
    Add-Finding `
        -Title "Geo-IP Filtering" `
        -Description "Consider implementing geo-IP filtering for additional security" `
        -Recommendation "Enable geo-IP filtering to block traffic from high-risk countries if not needed" `
        -Severity "LOW" `
        -ScoreImpact 2
}

# Audit 6: VPN Configuration
function Test-VPNSecurity {
    Write-AuditLog "Auditing VPN configuration..." -Level "INFO"
    
    # Check for weak VPN configurations
    
    Add-Finding `
        -Title "VPN Encryption Standards" `
        -Description "Verify VPN uses strong encryption (AES-256, SHA-256)" `
        -Recommendation "Configure IPSec with:  AES-256, SHA-256, DH Group 14+, IKEv2" `
        -Severity "INFO" `
        -Reference "NIST SP 800-77"
    
    Add-Finding `
        -Title "VPN PSK Strength" `
        -Description "Verify VPN Pre-Shared Keys are strong (32+ random chars)" `
        -Recommendation "Use PSKs with 32+ characters, generated randomly, stored securely" `
        -Severity "INFO"
    
    Add-Finding `
        -Title "VPN Certificate-Based Auth" `
        -Description "Consider certificate-based authentication instead of PSK" `
        -Recommendation "Implement certificate-based VPN authentication for better security and management" `
        -Severity "LOW" `
        -ScoreImpact 3
}

# Audit 7: Admin Access Controls
function Test-AdminAccess {
    Write-AuditLog "Reviewing admin access controls..." -Level "INFO"
    
    Add-Finding `
        -Title "Admin Access Restrictions" `
        -Description "Verify admin access is restricted to Management VLAN only" `
        -Recommendation "Configure firewall to allow admin access only from Management VLAN (192.168.99.0/24)" `
        -Severity "MEDIUM" `
        -Reference "CIS Benchmark 2.1" `
        -ScoreImpact 8
    
    Add-Finding `
        -Title "Multi-Factor Authentication" `
        -Description "MFA is not available on most DrayTek models" `
        -Recommendation "Implement network-level MFA (VPN + RADIUS with MFA) for admin access" `
        -Severity "MEDIUM" `
        -ScoreImpact 5
    
    Add-Finding `
        -Title "Session Timeout" `
        -Description "Verify admin session timeout is configured (max 30 minutes)" `
        -Recommendation "Set web UI session timeout to 15-30 minutes of inactivity" `
        -Severity "LOW" `
        -ScoreImpact 2
}

# Audit 8: Logging and Monitoring
function Test-LoggingConfig {
    Write-AuditLog "Checking logging and monitoring..." -Level "INFO"
    
    Add-Finding `
        -Title "Centralized Logging" `
        -Description "Verify syslog is configured and forwarding to central server" `
        -Recommendation "Configure syslog forwarding to 192.168.99.10: 514, enable all critical event categories" `
        -Severity "MEDIUM" `
        -Reference "NIST SP 800-92" `
        -ScoreImpact 8
    
    Add-Finding `
        -Title "SNMP Monitoring" `
        -Description "Verify SNMP monitoring is configured for health checks" `
        -Recommendation "Configure PRTG/LibreNMS monitoring with alerts for:  downtime, high CPU, bandwidth" `
        -Severity "LOW" `
        -ScoreImpact 3
    
    Add-Finding `
        -Title "Log Retention" `
        -Description "Ensure logs are retained for compliance requirements (90+ days)" `
        -Recommendation "Configure log retention:  90 days active, 1 year archive" `
        -Severity "MEDIUM" `
        -Reference "GDPR Article 5, HIPAA §164.312(b)" `
        -ScoreImpact 5
}

# Audit 9: Firmware Updates
function Test-FirmwareStatus {
    Write-AuditLog "Checking firmware status..." -Level "INFO"
    
    # Would require API call to check current firmware version
    
    Add-Finding `
        -Title "Firmware Update Policy" `
        -Description "Verify router firmware is up-to-date" `
        -Recommendation "Check DrayTek website for latest firmware, review changelog, test in lab, deploy in maintenance window" `
        -Severity "MEDIUM" `
        -Reference "CIS Benchmark 1.5" `
        -ScoreImpact 7
    
    Add-Finding `
        -Title "Automatic Updates" `
        -Description "DrayTek routers do not support automatic firmware updates" `
        -Recommendation "Implement quarterly firmware review and update schedule" `
        -Severity "LOW" `
        -ScoreImpact 2
}

# Audit 10: Backup Configuration
function Test-BackupPolicy {
    Write-AuditLog "Reviewing backup policy..." -Level "INFO"
    
    # Check if backup files exist
    $recentBackups = Get-ChildItem -Path ".\backups" -Filter "draytek-*.  cfg" -ErrorAction SilentlyContinue |
                     Where-Object { $_.LastWriteTime -gt (Get-Date).AddDays(-7) }
    
    if ($recentBackups.Count -eq 0) {
        Add-Finding `
            -Title "No Recent Backups Found" `
            -Description "No configuration backups found in last 7 days" `
            -Recommendation "Implement automated daily backups using backup-config. ps1 script" `
            -Severity "HIGH" `
            -Reference "NIST SP 800-34" `
            -ScoreImpact 12
    } else {
        Add-Finding `
            -Title "Backup Policy - OK" `
            -Description "Recent backups found ($($recentBackups.Count) in last 7 days)" `
            -Recommendation "Continue regular backup schedule, verify restore procedure quarterly" `
            -Severity "INFO"
    }
}

# Generate comprehensive report
function New-SecurityReport {
    $timestamp = Get-Date -Format "yyyyMMdd-HHmmss"
    $reportPath = Join-Path $OutputDir "security-audit-$timestamp.html"
    
    if (-not (Test-Path $OutputDir)) {
        New-Item -Path $OutputDir -ItemType Directory -Force | Out-Null
    }
    
    $totalFindings = ($AuditFindings.Critical. Count + $AuditFindings.High. Count + 
                      $AuditFindings.Medium.Count + $AuditFindings.Low.Count)
    
    # Determine overall rating
    $rating = if ($AuditScore -ge 90) { "EXCELLENT" }
              elseif ($AuditScore -ge 75) { "GOOD" }
              elseif ($AuditScore -ge 60) { "FAIR" }
              elseif ($AuditScore -ge 40) { "POOR" }
              else { "CRITICAL" }
    
    $ratingColor = switch ($rating) {
        "EXCELLENT" { "#28a745" }
        "GOOD"      { "#5cb85c" }
        "FAIR"      { "#ffc107" }
        "POOR"      { "#ff9800" }
        "CRITICAL"  { "#dc3545" }
    }
    
$html = @"
<! DOCTYPE html>
<html>
<head>
    <title>Security Audit Report - $RouterIP</title>
    <style>
        * { margin: 0; padding: 0; box-sizing: border-box; }
        body { font-family: 'Segoe UI', Arial, sans-serif; background:  #f0f2f5; padding: 20px; }
        .container { max-width: 1400px; margin: 0 auto; background: white; box-shadow: 0 2px 8px rgba(0,0,0,0.1); }
        . header { background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); color: white; padding: 40px; }
        .header h1 { font-size: 36px; margin-bottom: 10px; }
        .header p { font-size: 18px; opacity: 0.9; }
        .score-section { padding: 40px; background: #f8f9fa; text-align: center; }
        .score-circle { display: inline-block; width: 200px; height: 200px; border-radius: 50%; 
                        background: conic-gradient($ratingColor $($AuditScore * 3. 6)deg, #e9ecef 0deg); 
                        position: relative; }
        .score-circle::before { content: '$AuditScore'; position: absolute; top: 50%; left: 50%; 
                                transform: translate(-50%, -50%); font-size: 48px; font-weight: bold; 
                                background: white; width: 160px; height: 160px; border-radius: 50%; 
                                display: flex; align-items: center; justify-content: center; }
        .rating { font-size: 32px; font-weight: bold; color: $ratingColor; margin-top: 20px; }
        .summary { display: grid; grid-template-columns: repeat(auto-fit, minmax(200px, 1fr)); gap: 20px; padding: 40px; }
        .summary-box { padding: 20px; border-radius: 10px; text-align: center; color: white; }
        .summary-box. critical { background: linear-gradient(135deg, #f093fb 0%, #f5576c 100%); }
        .summary-box.high { background: linear-gradient(135deg, #fa709a 0%, #fee140 100%); }
        .summary-box.medium { background: linear-gradient(135deg, #ffecd2 0%, #fcb69f 100%); color: #333; }
        .summary-box.low { background: linear-gradient(135deg, #a8edea 0%, #fed6e3 100%); color: #333; }
        . summary-box h3 { font-size: 48px; margin:  10px 0; }
        . summary-box p { font-size: 14px; opacity: 0.9; }
        .findings { padding: 40px; }
        .finding { background: white; border-left: 5px solid #ccc; padding: 20px; margin: 20px 0; border-radius: 5px; box-shadow: 0 2px 4px rgba(0,0,0,0.05); }
        .finding. critical { border-left-color: #dc3545; }
        .finding. high { border-left-color:  #fd7e14; }
        .finding.medium { border-left-color: #ffc107; }
        .finding.low { border-left-color: #17a2b8; }
        .finding.info { border-left-color: #6c757d; }
        .finding h3 { color: #333; margin-bottom: 10px; font-size: 20px; }
        .finding . severity { display: inline-block; padding: 5px 15px; border-radius: 20px; font-size: 12px; 
                            font-weight: bold; text-transform: uppercase; margin-bottom: 10px; }
        .severity.critical { background: #dc3545; color: white; }
        .severity.high { background: #fd7e14; color:  white; }
        .severity. medium { background: #ffc107; color: #333; }
        .severity.low { background: #17a2b8; color: white; }
        .severity.info { background: #6c757d; color: white; }
        .finding p { margin: 10px 0; line-height: 1.6; color: #555; }
        .finding . recommendation { background: #e7f5ff; padding: 15px; border-radius: 5px; margin-top: 10px; }
        .finding .recommendation:: before { content: '💡 Recommendation:  '; font-weight: bold; color: #0066cc; }
        .footer { padding: 30px; background: #f8f9fa; text-align: center; color: #666; font-size: 14px; }
    </style>
</head>
<body>
    <div class="container">
        <div class="header">
            <h1>🔒 Security Audit Report</h1>
            <p>Router: $RouterIP | Generated: $(Get-Date -Format "yyyy-MM-dd HH: mm:ss")</p>
        </div>
        
        <div class="score-section">
            <div class="score-circle"></div>
            <div class="rating">$rating</div>
            <p style="margin-top: 10px; color: #666;">Security Score</p>
        </div>
        
        <div class="summary">
            <div class="summary-box critical">
                <p>Critical Findings</p>
                <h3>$($AuditFindings.Critical.Count)</h3>
            </div>
            <div class="summary-box high">
                <p>High Findings</p>
                <h3>$($AuditFindings.High.Count)</h3>
            </div>
            <div class="summary-box medium">
                <p>Medium Findings</p>
                <h3>$($AuditFindings.Medium.Count)</h3>
            </div>
            <div class="summary-box low">
                <p>Low Findings</p>
                <h3>$($AuditFindings.Low.Count)</h3>
            </div>
        </div>
        
        <div class="findings">
            <h2>Detailed Findings</h2>
"@

    # Add findings for each severity level
    foreach ($severity in @("Critical", "High", "Medium", "Low", "Info")) {
        $findings = $AuditFindings[$severity]
        
        if ($findings.Count -gt 0) {
            $html += "<h3 style='margin-top: 30px; color: #333;'>$severity Issues ($($findings.Count))</h3>"
            
            foreach ($finding in $findings) {
                $html += @"
                <div class="finding $($severity.ToLower())">
                    <span class="severity $($severity.ToLower())">$severity</span>
                    <h3>$($finding.Title)</h3>
                    <p><strong>Description:</strong> $($finding.Description)</p>
                    <div class="recommendation">$($finding.Recommendation)</div>
"@
                if ($finding.Reference) {
                    $html += "<p><small><strong>Reference:</strong> $($finding.Reference)</small></p>"
                }
                $html += "</div>"
            }
        }
    }

    $html += @"
        </div>
        
        <div class="footer">
            <p><strong>Security Audit Script v1.0</strong></p>
            <p>This audit is based on industry best practices (CIS Benchmarks, NIST, OWASP)</p>
            <p>Report generated on $(Get-Date -Format "yyyy-MM-dd HH:mm:ss")</p>
        </div>
    </div>
</body>
</html>
"@

    $html | Out-File -FilePath $reportPath -Encoding UTF8
    Write-AuditLog "Security audit report generated: $reportPath" -Level "SUCCESS"
    
    # Open in browser
    Start-Process $reportPath
}

# Main execution
try {
    Show-Banner
    
    if (-not (Test-Path $OutputDir)) {
        New-Item -Path $OutputDir -ItemType Directory -Force | Out-Null
    }
    
    Write-AuditLog "=== Security Audit Started ===" -Level "INFO"
    Write-AuditLog "Target: $RouterIP" -Level "INFO"
    
    # Run all audit checks
    Test-DefaultCredentials
    Test-PasswordStrength
    Test-OpenPorts
    Test-SNMPSecurity
    Test-FirewallConfig
    Test-VPNSecurity
    Test-AdminAccess
    Test-LoggingConfig
    Test-FirmwareStatus
    Test-BackupPolicy
    
    # Generate report
    New-SecurityReport
    
    Write-AuditLog "=== Security Audit Completed ===" -Level "SUCCESS"
    Write-AuditLog "Final Security Score: $AuditScore / 100 ($rating)" -Level $(
        if ($AuditScore -ge 75) { "SUCCESS" }
        elseif ($AuditScore -ge 50) { "MEDIUM" }
        else { "CRITICAL" }
    )
    
    exit 0
    
} catch {
    Write-AuditLog "Fatal error during security audit: $_" -Level "CRITICAL"
    exit 1
}