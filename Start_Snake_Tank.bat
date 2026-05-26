@echo off
:: Snake Tank Portable Security Toolkit Wrapper
:: Created by Snake Tank

title Snake Tank Security Toolkit - Main Launcher
color 0A

:: Check for Administrator privileges
net session >nul 2>&1
if %errorLevel% == 0 (
    cd /d "%~dp0"
    powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0core\engine.ps1" -Tab "Dashboard"
) else (
    echo [!] Requesting UAC Administrator elevation...
    powershell -NoProfile -ExecutionPolicy Bypass -Command "Start-Process powershell -ArgumentList '-NoProfile -ExecutionPolicy Bypass -File \"%~dp0core\engine.ps1\" -Tab Dashboard' -Verb RunAs"
)
exit /b
