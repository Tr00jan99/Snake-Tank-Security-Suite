@echo off
:: Snake Tank Portable Security Toolkit Wrapper
:: Created by Snake Tank

title Snake Tank Security Toolkit - Vulnerability Auditor
color 0B

:: Check for Administrator privileges
net session >nul 2>&1
if %errorLevel% == 0 (
    cd /d "%~dp0"
    powershell -NoProfile -STA -ExecutionPolicy Bypass -File "%~dp0core\engine.ps1" -Tab "Scanner"
) else (
    echo [!] Requesting UAC Administrator elevation...
    powershell -NoProfile -ExecutionPolicy Bypass -Command "Start-Process powershell -ArgumentList '-NoProfile -STA -ExecutionPolicy Bypass -File \"%~dp0core\engine.ps1\" -Tab Scanner' -Verb RunAs"
)
exit /b
