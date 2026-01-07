            # For now, simple HTML wrapper
            $htmlContent = @"
<! DOCTYPE html>
<html>
<head>
    <title>Network Documentation</title>
    <style>
        body { font-family: Arial, sans-serif; max-width: 1200px; margin: 0 auto; padding: 20px; line-height: 1.6; }
        h1 { color: #0066cc; border-bottom: 3px solid #0066cc; }
        h2 { color:  #0066cc; border-bottom: 1px solid #ccc; margin-top: 30px; }
        table { width: 100%; border-collapse: collapse; margin: 20px 0; }
        th, td { padding: 10px; text-align: left; border:  1px solid #ddd; }
        th { background:  #0066cc; color: white; }
        tr:nth-child(even) { background: #f2f2f2; }
        code { background: #f4f4f4; padding: 2px 6px; border-radius: 3px; }
        pre { background: #f4f4f4; padding: 15px; border-radius: 5px; overflow-x: auto; }
    </style>
</head>
<body>
<pre>$Content</pre>
</body>
</html>
"@
            $htmlContent | Out-File -FilePath $outputFile -Encoding UTF8
            Write-DocLog "HTML documentation saved:  $outputFile" -Level "SUCCESS"
        }
        
        "PDF" {
            Write-DocLog "PDF generation requires pandoc or wkhtmltopdf" -Level "WARNING"
            Write-DocLog "Falling back to Markdown output" -Level "INFO"
            $outputFile = Join-Path $OutputDir "network-documentation-$timestamp. md"
            $Content | Out-File -FilePath $outputFile -Encoding UTF8
        }
    }
    
    # Open file
    Start-Process $outputFile
}

# Main execution
try {
    Show-Banner
    
    Write-DocLog "=== Documentation Generation Started ===" -Level "INFO"
    
    # Generate all sections
    New-NetworkOverview
    New-VLANDocumentation
    New-FirewallDocumentation
    New-VPNDocumentation
    New-MonitoringDocumentation
    New-TroubleshootingGuide
    
    # Assemble and save
    $finalDoc = New-FinalDocument
    Save-Documentation -Content $finalDoc
    
    Write-DocLog "=== Documentation Generation Complete ===" -Level "SUCCESS"
    exit 0
    
} catch {
    Write-DocLog "Fatal error: $_" -Level "ERROR"
    exit 1
}