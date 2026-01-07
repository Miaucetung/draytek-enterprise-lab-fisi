<#
.SYNOPSIS
    Automated DrayTek Router Configuration Backup Script
    
.DESCRIPTION
    This PowerShell script automatically backs up DrayTek router configuration
    via HTTP/HTTPS and stores it with timestamp. 
    
.PARAMETER RouterIP
    IP address of the DrayTek router (default: 192.168.99.1)
    
.PARAMETER Username
    Admin username (default: admin)
    
.PARAMETER Password
    Admin password (prompt if not provided)
    
.PARAMETER BackupPath
    Directory to store backups (default: .\backups)
    
.PARAMETER UseHTTPS
    Use HTTPS instead of HTTP (default: true)
    
.EXAMPLE
    .\backup-config.ps1 -RouterIP 192.168.99.1 -Username admin
    
.EXAMPLE
    .\backup-config. ps1 -BackupPath "C:\RouterBackups" -UseHTTPS $true
    
.NOTES
    Author: DrayTek Enterprise Lab
    Version: 1.0
    Date: 2026-01-17
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory=$false)]
    [string]$RouterIP = "192.168.99.1",
    
    [Parameter(Mandatory=$false)]
    [string]$Username = "admin",
    
    [Parameter(Mandatory=$false)]
    [securestring]$Password,
    
    [Parameter(Mandatory=$false)]
    [string]$BackupPath = ".\backups",
    
    [Parameter(Mandatory=$false)]
    [bool]$UseHTTPS = $true,
    
    [Parameter(Mandatory=$false)]
    [int]$RetentionDays = 90
)

# Script configuration
$ErrorActionPreference = "Stop"
$ProgressPreference = "SilentlyContinue"

# ASCII Art Banner
$banner = @"
╔═══════════════════════════════════════════════════════════╗
║   DrayTek Router Configuration Backup Script v1.0         ║
║   Author: Enterprise Lab                                  ║
╚═══════════════════════════════════════════════════════════╝
"@

Write-Host $banner -ForegroundColor Cyan

# Function:  Write colored log
function Write-Log {
    param(
        [string]$Message,
        [ValidateSet("INFO", "SUCCESS", "WARNING", "ERROR")]
        [string]$Level = "INFO"
    )
    
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $color = switch ($Level) {
        "INFO"    { "White" }
        "SUCCESS" { "Green" }
        "WARNING" { "Yellow" }
        "ERROR"   { "Red" }
    }
    
    Write-Host "[$timestamp] [$Level] $Message" -ForegroundColor $color
    
    # Log to file
    $logFile = Join-Path $BackupPath "backup. log"
    "[$timestamp] [$Level] $Message" | Out-File -FilePath $logFile -Append -Encoding UTF8
}

# Function: Get password if not provided
function Get-RouterPassword {
    if (-not $Password) {
        Write-Log "Password not provided, prompting..." -Level "INFO"
        $securePassword = Read-Host "Enter router admin password" -AsSecureString
        return $securePassword
    }
    return $Password
}

# Function: Convert SecureString to PlainText (for HTTP Auth)
function ConvertFrom-SecureStringToPlainText {
    param([securestring]$SecurePassword)
    
    $BSTR = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($SecurePassword)
    $PlainPassword = [System.Runtime.InteropServices.Marshal]:: PtrToStringAuto($BSTR)
    [System.Runtime.InteropServices. Marshal]::ZeroFreeBSTR($BSTR)
    return $PlainPassword
}

# Function: Test router connectivity
function Test-RouterConnectivity {
    param([string]$IP)
    
    Write-Log "Testing connectivity to router $IP..." -Level "INFO"
    
    if (Test-Connection -ComputerName $IP -Count 2 -Quiet) {
        Write-Log "Router is reachable via ICMP" -Level "SUCCESS"
        return $true
    } else {
        Write-Log "Router is not reachable via ICMP" -Level "ERROR"
        return $false
    }
}

# Function: Download config from DrayTek
function Backup-DrayTekConfig {
    param(
        [string]$IP,
        [string]$User,
        [securestring]$Pass,
        [bool]$HTTPS
    )
    
    $protocol = if ($HTTPS) { "https" } else { "http" }
    $timestamp = Get-Date -Format "yyyyMMdd-HHmmss"
    $backupFileName = "draytek-$IP-$timestamp.cfg"
    $backupFilePath = Join-Path $BackupPath $backupFileName
    
    # DrayTek backup URL (varies by model, adjust if needed)
    # Common endpoints: 
    # /cgi-bin/export_conf.cgi
    # /doc/config. cfg
    # /config/config. cfg
    $backupURL = "${protocol}://${IP}/doc/config.cfg"
    
    Write-Log "Attempting to download config from $backupURL..." -Level "INFO"
    
    try {
        # Disable SSL certificate validation (for self-signed certs)
        if ($HTTPS) {
            [System.Net.ServicePointManager]:: ServerCertificateValidationCallback = {$true}
            [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.SecurityProtocolType]::Tls12
        }
        
        # Create credential
        $plainPassword = ConvertFrom-SecureStringToPlainText -SecurePassword $Pass
        $secpasswd = ConvertTo-SecureString $plainPassword -AsPlainText -Force
        $credential = New-Object System.Management. Automation.PSCredential ($User, $secpasswd)
        
        # Download config
        Invoke-WebRequest -Uri $backupURL -Credential $credential -OutFile $backupFilePath -UseBasicParsing
        
        if (Test-Path $backupFilePath) {
            $fileSize = (Get-Item $backupFilePath).Length
            Write-Log "Backup successful! File: $backupFileName ($fileSize bytes)" -Level "SUCCESS"
            
            # Verify file is not empty and is valid config
            if ($fileSize -lt 100) {
                Write-Log "WARNING:  Backup file is suspiciously small ($fileSize bytes). Might be error page." -Level "WARNING"
            }
            
            return $backupFilePath
        } else {
            Write-Log "Backup file not found after download" -Level "ERROR"
            return $null
        }
        
    } catch {
        Write-Log "Backup failed: $_" -Level "ERROR"
        return $null
    }
}

# Function:  Cleanup old backups
function Remove-OldBackups {
    param(
        [string]$Path,
        [int]$Days
    )
    
    Write-Log "Cleaning up backups older than $Days days..." -Level "INFO"
    
    $cutoffDate = (Get-Date).AddDays(-$Days)
    $oldBackups = Get-ChildItem -Path $Path -Filter "draytek-*. cfg" | Where-Object {
        $_.LastWriteTime -lt $cutoffDate
    }
    
    $count = 0
    foreach ($file in $oldBackups) {
        try {
            Remove-Item $file.FullName -Force
            Write-Log "Deleted old backup:  $($file.Name)" -Level "INFO"
            $count++
        } catch {
            Write-Log "Failed to delete $($file.Name): $_" -Level "WARNING"
        }
    }
    
    Write-Log "Cleanup complete: $count old backup(s) removed" -Level "SUCCESS"
}

# Function: Create backup report
function New-BackupReport {
    param([string]$BackupFile)
    
    $reportPath = Join-Path $BackupPath "backup-report.html"
    
    $backups = Get-ChildItem -Path $BackupPath -Filter "draytek-*.cfg" | Sort-Object LastWriteTime -Descending
    
    $html = @"
<!DOCTYPE html>
<html>
<head>
    <title>DrayTek Backup Report</title>
    <style>
        body { font-family: Arial, sans-serif; margin: 20px; }
        h1 { color: #0066cc; }
        table { border-collapse: collapse; width: 100%; }
        th, td { border: 1px solid #ddd; padding: 8px; text-align: left; }
        th { background-color: #0066cc; color: white; }
        tr:nth-child(even) { background-color: #f2f2f2; }
        .success { color: green; font-weight: bold; }
        .warning { color: orange; font-weight: bold; }
    </style>
</head>
<body>
    <h1>DrayTek Router Backup Report</h1>
    <p>Generated: $(Get-Date -Format "yyyy-MM-dd HH: mm:ss")</p>
    <p>Latest Backup: <span class="success">$BackupFile</span></p>
    
    <h2>All Backups (Sorted by Date)</h2>
    <table>
        <tr>
            <th>Filename</th>
            <th>Date</th>
            <th>Size (KB)</th>
            <th>Age (Days)</th>
        </tr>
"@
    
    foreach ($backup in $backups) {
        $age = ((Get-Date) - $backup.LastWriteTime).Days
        $sizeKB = [math]::Round($backup.Length / 1KB, 2)
        $html += @"
        <tr>
            <td>$($backup.Name)</td>
            <td>$($backup.LastWriteTime.ToString("yyyy-MM-dd HH:mm:ss"))</td>
            <td>$sizeKB</td>
            <td>$age</td>
        </tr>
"@
    }
    
    $html += @"
    </table>
    
    <h2>Statistics</h2>
    <ul>
        <li>Total Backups: $($backups. Count)</li>
        <li>Retention Period: $RetentionDays days</li>
        <li>Storage Path: $BackupPath</li>
    </ul>
</body>
</html>
"@
    
    $html | Out-File -FilePath $reportPath -Encoding UTF8
    Write-Log "Backup report generated: $reportPath" -Level "INFO"
}

# Main script execution
try {
    Write-Log "=== DrayTek Backup Script Started ===" -Level "INFO"
    Write-Log "Router IP: $RouterIP" -Level "INFO"
    Write-Log "Backup Path: $BackupPath" -Level "INFO"
    Write-Log "Protocol: $(if ($UseHTTPS) { 'HTTPS' } else { 'HTTP' })" -Level "INFO"
    
    # Create backup directory if not exists
    if (-not (Test-Path $BackupPath)) {
        New-Item -Path $BackupPath -ItemType Directory -Force | Out-Null
        Write-Log "Created backup directory:  $BackupPath" -Level "INFO"
    }
    
    # Get password
    $Password = Get-RouterPassword
    
    # Test connectivity
    if (-not (Test-RouterConnectivity -IP $RouterIP)) {
        throw "Router is not reachable.  Aborting backup."
    }
    
    # Perform backup
    $backupFile = Backup-DrayTekConfig -IP $RouterIP -User $Username -Pass $Password -HTTPS $UseHTTPS
    
    if ($backupFile) {
        Write-Log "Backup completed successfully!" -Level "SUCCESS"
        
        # Cleanup old backups
        Remove-OldBackups -Path $BackupPath -Days $RetentionDays
        
        # Generate report
        New-BackupReport -BackupFile (Split-Path $backupFile -Leaf)
        
        Write-Log "=== Backup Process Completed Successfully ===" -Level "SUCCESS"
        exit 0
    } else {
        throw "Backup failed. Check logs for details."
    }
    
} catch {
    Write-Log "FATAL ERROR: $_" -Level "ERROR"
    Write-Log "=== Backup Process Failed ===" -Level "ERROR"
    exit 1
}