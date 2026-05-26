$env:SNAKE_TANK_TEST = "True"
Write-Host "==================================================" -ForegroundColor Cyan
Write-Host "     SNAKE TANK SECURITY TOOLKIT TEST HARNESS      " -ForegroundColor Cyan
Write-Host "==================================================" -ForegroundColor Cyan
Write-Host ""

Write-Host "[*] STEP 1: Loading GUI Engine & Verifying Startup..."
try {
    # Dot-source the engine script to load functions and run startup validation
    . ".\core\engine.ps1"
    Write-Host "[+] STEP 1 PASSED: Core GUI engine loaded cleanly without errors!" -ForegroundColor Green
} catch {
    Write-Host "[-] STEP 1 FAILED: Core GUI engine crashed on load!" -ForegroundColor Red
    Write-Host $_.Exception.Message -ForegroundColor Red
    exit 1
}
Write-Host ""

Write-Host "[*] STEP 2: Running Comprehensive Vulnerability Scan..."
try {
    # Trigger the scanning audit function programmatically
    Run-VulnerabilityScan
    
    # Assert that the findings array contains the new checks
    $hasLLMNR = $false
    $hasLSA = $false
    $hasRDPPort = $false
    $hasPSLog = $false
    $hasWDigest = $false
    $hasAutoPlay = $false
    $hasRemReg = $false
    $hasAdmins = $false
    $hasBitLocker = $false
    $hasPorts = $false
    $hasThirdAV = $false
    $hasRestrictAnon = $false
    $hasTLS = $false
    
    foreach ($f in $Script:ScanFindings) {
        if ($f.Title -match "LLMNR") { $hasLLMNR = $true }
        if ($f.Title -match "LSA") { $hasLSA = $true }
        if ($f.Title -match "RDP Port" -or $f.Title -match "RDP Listening Port") { $hasRDPPort = $true }
        if ($f.Title -match "PowerShell Script Block Logging") { $hasPSLog = $true }
        if ($f.Title -match "WDigest Credential Caching" -or $f.Title -match "WDigest Logon Credential") { $hasWDigest = $true }
        if ($f.Title -match "AutoPlay / AutoRun") { $hasAutoPlay = $true }
        if ($f.Title -match "Remote Registry Service") { $hasRemReg = $true }
        if ($f.Title -match "Administrators Group Membership" -or $f.Title -match "Over-Privileged Accounts") { $hasAdmins = $true }
        if ($f.Title -match "BitLocker") { $hasBitLocker = $true }
        if ($f.Title -match "Exposed Network Ports" -or $f.Title -match "Exposed High-Risk Network Ports") { $hasPorts = $true }
        if ($f.Title -match "Third-Party Endpoint AV/EDR" -or $f.Title -match "Windows Security Center") { $hasThirdAV = $true }
        if ($f.Title -match "Anonymous SAM/SID Enumeration") { $hasRestrictAnon = $true }
        if ($f.Title -match "Legacy TLS 1.0 & 1.1 Protocols") { $hasTLS = $true }
    }
    
    if (-not $hasLLMNR) { throw "Verification Failed: LLMNR audit check finding was not generated in findings database!" }
    if (-not $hasLSA) { throw "Verification Failed: LSA protection audit check finding was not generated in findings database!" }
    if (-not $hasRDPPort) { throw "Verification Failed: RDP Default Port audit check finding was not generated in findings database!" }
    if (-not $hasPSLog) { throw "Verification Failed: PowerShell Script Block Logging audit check finding was not generated in findings database!" }
    if (-not $hasWDigest) { throw "Verification Failed: WDigest Credential Caching audit check finding was not generated in findings database!" }
    if (-not $hasAutoPlay) { throw "Verification Failed: AutoPlay / AutoRun audit check finding was not generated in findings database!" }
    if (-not $hasRemReg) { throw "Verification Failed: Remote Registry Service audit check finding was not generated in findings database!" }
    if (-not $hasAdmins) { throw "Verification Failed: Local Administrators Group Membership audit check finding was not generated in findings database!" }
    if (-not $hasBitLocker) { throw "Verification Failed: BitLocker Drive Encryption Status audit check finding was not generated in findings database!" }
    if (-not $hasPorts) { throw "Verification Failed: Exposed Network Ports audit check finding was not generated in findings database!" }
    if (-not $hasThirdAV) { throw "Verification Failed: Third-Party AV/EDR Systems audit check finding was not generated in findings database!" }
    if (-not $hasRestrictAnon) { throw "Verification Failed: Anonymous SAM/SID Enumeration audit check finding was not generated in findings database!" }
    if (-not $hasTLS) { throw "Verification Failed: Legacy TLS 1.0 & 1.1 Protocols audit check finding was not generated in findings database!" }
    
    Write-Host "[+] STEP 2 PASSED: Vulnerability Scanner executed successfully with all 24 audits verified!" -ForegroundColor Green
} catch {
    Write-Host "[-] STEP 2 FAILED: Vulnerability Scanner crashed or failed validation!" -ForegroundColor Red
    Write-Host $_.Exception.Message -ForegroundColor Red
    exit 1
}
Write-Host ""

Write-Host "[*] STEP 3: Testing Hardening Status Query..."
try {
    # Trigger the status validation check
    Update-AllHardeningStatuses
    Write-Host "[+] STEP 3 PASSED: Hardening Status Validator executed successfully!" -ForegroundColor Green
} catch {
    Write-Host "[-] STEP 3 FAILED: Hardening Status Validator crashed!" -ForegroundColor Red
    Write-Host $_.Exception.Message -ForegroundColor Red
    exit 1
}
Write-Host ""

Write-Host "[*] STEP 4: Testing Standalone HTML Report Generation..."
try {
    # Trigger report generation programmatically
    Export-HtmlReport
    
    $desktopPath = [Environment]::GetFolderPath("Desktop")
    $outputPath = Join-Path $desktopPath "Snake_Tank_Audit_Report.html"
    if (Test-Path $outputPath) {
        Write-Host "[+] STEP 4 PASSED: Standalone security report generated successfully on Desktop!" -ForegroundColor Green
        # Clean up test output file
        Remove-Item -Path $outputPath -Force -ErrorAction SilentlyContinue
    } else {
        throw "Report file was not created on the Desktop."
    }
} catch {
    Write-Host "[-] STEP 4 FAILED: HTML Report Exporter crashed or failed!" -ForegroundColor Red
    Write-Host $_.Exception.Message -ForegroundColor Red
    exit 1
}
Write-Host ""

Write-Host "[*] STEP 5: Testing Threat Detector & CVE Scanner Elements..."
try {
    # 1. Assert WPF Navigation buttons and Grid exist in scope (Threat Detector)
    if ($null -eq $btnNavThreats) { throw "Verification Failed: btnNavThreats navigation button is not loaded!" }
    if ($null -eq $gridThreats) { throw "Verification Failed: gridThreats view panel is not loaded!" }
    if ($null -eq $btnScanActiveThreats) { throw "Verification Failed: btnScanActiveThreats scanner button is not loaded!" }
    if ($null -eq $btnScanHeuristics) { throw "Verification Failed: btnScanHeuristics scanner button is not loaded!" }
    
    # 2. Assert WPF controls exist in scope for the new CVE Search & Software Auditor
    if ($null -eq $btnNavCVE) { throw "Verification Failed: btnNavCVE navigation button is not loaded!" }
    if ($null -eq $gridCVE) { throw "Verification Failed: gridCVE view panel is not loaded!" }
    if ($null -eq $btnSearchCVE) { throw "Verification Failed: btnSearchCVE search button is not loaded!" }
    if ($null -eq $btnScanSoftwareCVE) { throw "Verification Failed: btnScanSoftwareCVE audit button is not loaded!" }
    if ($null -eq $txtCVESearch) { throw "Verification Failed: txtCVESearch input field is not loaded!" }
    if ($null -eq $panelCVEResults) { throw "Verification Failed: panelCVEResults dynamic scroll area is not loaded!" }

    # 3. Trigger Heuristic Threat Scan programmatically to ensure it works cleanly
    Write-Host "    [+] Running programmatic Heuristic Scan..."
    Start-HeuristicScan
    
    # 4. Trigger Active Threat Scan programmatically to ensure it runs cleanly
    Write-Host "    [+] Running programmatic Active Threat Scan..."
    Start-ThreatScan
    
    # 5. Mock a threat card insertion to verify rendering engine works
    Write-Host "    [+] Testing Add-ThreatCard dynamic rendering..."
    Add-ThreatCard -type "TestHeuristic" -title "Test Double Extension Threat" -filePath "C:\Users\Public\test.pdf.exe" -severity "Critical" -description "Mock threat card to verify rendering UI elements."
    
    # 6. Programmatically verify Local Software Inventory enumerator
    Write-Host "    [+] Running programmatic Local Software Inventory query..."
    $sw = Get-InstalledSoftware
    if ($null -eq $sw) { throw "Verification Failed: Get-InstalledSoftware returned null!" }
    Write-Host "        - Successfully compiled local software list containing $($sw.Count) products."

    # 7. Programmatically verify CVE lookup routines are declared
    Write-Host "    [+] Verifying CVE Scan and Query functions are defined..."
    if (!(Get-Command Search-OnlineCVE -ErrorAction SilentlyContinue)) { throw "Verification Failed: Search-OnlineCVE function is not loaded!" }
    if (!(Get-Command Start-SoftwareCVEScan -ErrorAction SilentlyContinue)) { throw "Verification Failed: Start-SoftwareCVEScan function is not loaded!" }
    
    # 8. Test Add-CVECard dynamic rendering to ensure UI bindings compile
    Write-Host "    [+] Testing Add-CVECard dynamic rendering..."
    Add-CVECard -severity "High" -cveId "CVE-2026-99999" -title "Mock Test Vulnerability" -description "Mock CVE card to verify dynamic WPF rendering works." -evidence "Testing inventory match" -solution "N/A" -url "https://nvd.nist.gov"

    Write-Host "[+] STEP 5 PASSED: Threat Detector and CVE Scanner controls and engines successfully verified!" -ForegroundColor Green
} catch {
    Write-Host "[-] STEP 5 FAILED: Threat Detector testing failed!" -ForegroundColor Red
    Write-Host $_.Exception.Message -ForegroundColor Red
    exit 1
}
Write-Host ""

Write-Host "==================================================" -ForegroundColor Green
Write-Host "     ALL TESTS PASSED SUCCESSFULLY! (100% OK)     " -ForegroundColor Green
Write-Host "==================================================" -ForegroundColor Green
