# 🛡️ Snake Tank Security Suite (Portable Edition)

<div align="center">

```
   _____             _             _______              _     
  / ____|           | |           |__   __|            | |    
 | (___  _ __   __ _| | _____  ___   | | __ _ _ __  ___| | __ 
  \___ \| '_ \ / _` | |/ / _ \/ __|  | |/ _` | '_ \/ __| |/ / 
  ____) | | | | (_| |   <  __/\__ \  | | (_| | | | \__ \   <  
 |_____/|_| |_|\__,_|_|\_\___||___/  |_|\__,_|_| |_|___/_|\_\ 
```

**An elite, native Windows endpoint auditing, active threat hunting, and one-click system hardening suite.**

[![PowerShell Support](https://img.shields.io/badge/PowerShell-5.1%20%7C%207.x-blue?style=for-the-badge&logo=powershell&logoColor=white)](https://microsoft.com/powershell)
[![Platform](https://img.shields.io/badge/Platform-Windows%2010%20%7C%2011%20%7C%20Server-0078D6?style=for-the-badge&logo=windows&logoColor=white)](https://microsoft.com/windows)
[![Execution Safety](https://img.shields.io/badge/Status-100%25%20Verified%20Harness-success?style=for-the-badge&logo=checkmarx&logoColor=white)](#🧪-automated-integrity-self-test)
[![PRs Welcome](https://img.shields.io/badge/PRs-welcome-brightgreen?style=for-the-badge)](https://github.com/)

</div>

---

## 📖 Table of Contents
1. [Introduction](#-introduction)
2. [🌟 Key Features](#-key-features)
3. [📂 File Architecture](#-file-architecture)
4. [🔍 24-Audit Checking Matrix](#-24-audit-checking-matrix)
5. [🛡️ 16-Rule System Hardening Baseline](#-16-rule-system-hardening-baseline)
6. [🚀 How to Run](#-how-to-run)
   - [Option A: Standard GUI Startup (Double-Click)](#option-a-standard-gui-startup-double-click)
   - [Option B: Terminal / CLI Startup (PowerShell & CMD)](#option-b-terminal--cli-startup-command-prompt-or-powershell)
7. [🧪 Automated Integrity Self-Test](#-automated-integrity-self-test)
8. [📜 License](#-license)

---

## ⚡ Introduction

**Snake Tank Security Suite** is a **100% portable, zero-dependency, local security assessment and operating system hardening suite** engineered specifically for security auditors, sysadmins, and incident responders. 

Unlike heavy enterprise scanning suites that require massive databases, proprietary clients, or complex runtimes, Snake Tank is built entirely using **native Windows PowerShell and WPF XAML**. This ensures a true, lightning-fast **plug-and-play** experience directly from a secure locally copied folder or USB drive, without introducing any external software footprints on targeted assets.

---

## 🌟 Key Features

* **Glassmorphism Dark-Emerald UI**: Sleek, immersive developer console styling featuring dynamic tab navigation, custom progress widgets, and live terminal event feeds.
* **WMI/CIM Hardware Profiler**: Auto-detects and displays core host hardware specifications (CPU, RAM size, Motherboard product, GPU, and Wi-Fi adapter) with responsive ellipsis-trimming and hover tooltips.
* **Vulnerability Scanner (24 Vectors)**: Audits the system's security architecture across **24 critical vectors** in seconds, compiling detailed findings, evidence strings, and copyable manual CLI remediation commands.
* **Intelligent Hardening Hub (16 Policies)**:
  - Implements **16 enterprise-grade security hardening policies** with single-click batch deployment ("Harden All") or granular per-rule buttons.
  - **Conditional Execution**: Skip rules that are already secure, avoiding redundant registry modifications and enabling ultra-fast execution.
* **Threat Detector & Heuristic Virus Hunter**:
  - Interrogates Microsoft Defender databases programmatically to map active malware infections, their pathways, and threat levels.
  - Custom recursive file scanner checking writable directories (AppData, Temp, Downloads, Startup) for unsigned executables, LOLBins, and double-extension payload delivery files (e.g., `invoice.pdf.exe`).
* **Interactive CVE Search & Software Auditor**:
  - Enumerates all local installed programs via HKLM & HKCU registry uninstall pools.
  - Cross-references local software names and versions against the official, live **CISA Known Exploited Vulnerabilities (KEV)** catalog.
  - Search any software name or specific CVE ID on-demand against public **CIRCL CVE Database APIs** in real-time, complete with CVSS severity badges and Mitre reference source links.
  - **Graceful Offline Fallback**: Senses internet connectivity and seamlessly defaults to a secure offline local inventory catalog without throwing unhandled exceptions.
* **Responsive HTML Report Exporter**: Compiles scan statistics, security scores, and findings into a standalone responsive HTML document directly on the user's Desktop.

---

## 📂 File Architecture

The toolkit has a highly modular, clean workspace footprint:
```
Portable_Toolkit/
├── Start_Snake_Tank.bat        <-- Main launcher wrapper (triggers elevated GUI).
├── Snake_Tank_Scanner.bat      <-- Directly boots elevated GUI onto the Vulnerability Scanner.
├── Snake_Tank_Hardener.bat     <-- Directly boots elevated GUI onto the Hardening Hub.
├── test_harness.ps1            <-- Programmatic, headless testing and validation suite.
├── core/
│   └── engine.ps1              <-- Core logic, WPF XAML design, scanner, and remediations.
└── README.md                   <-- This comprehensive documentation.
```

---

## 🔍 24-Audit Checking Matrix

| ID | 🔴 Audit Check | Severity | Threat Category & Objective |
| :--- | :--- | :--- | :--- |
| **Check 1** | OS Update Baseline | `🟢 Info` | Audits build compliance (19045/22H2 benchmark) to identify unpatched kernels. |
| **Check 2** | SMBv1 Legacy State | `🔴 Critical` | Verifies whether the legacy, exploit-prone SMBv1 network layer is active. |
| **Check 3** | Windows Firewall Status | `🟠 High` | Audits the operational state of Domain, Private, and Public firewall profiles. |
| **Check 4** | Defender RTP Status | `🟠 High` | Audits Defender Real-Time Protection and Behavior Monitoring parameters. |
| **Check 5** | RDP NLA Enforcement | `🟠 High` | Checks if Network Level Authentication is active on RDP connections (mitigates BlueKeep). |
| **Check 6** | Password Policy Strength | `🟠 High` | Evaluates local SAM password parameters (length >= 14, lockout threshold >= 5). |
| **Check 7** | Built-in Guest Account | `🟡 Medium` | Checks if the built-in local Guest account is enabled on the local system. |
| **Check 8** | AlwaysInstallElevated Policy | `🔴 Critical` | Checks for MSI installer elevation parameters in HKLM and HKCU registry keys. |
| **Check 9** | Unquoted Service Paths | `🟡 Medium` | Scans active service pathways for executable files containing unquoted spaces. |
| **Check 10** | Startup Persistence | `🟠 High` | Analyzes Run keys, AppData, and Startup directories for unsigned persistent binaries. |
| **Check 11** | UAC Admin Consent Policy | `🟠 High` | Audits the prompting behavior of UAC prompts for administrative installations. |
| **Check 12** | LLMNR Multicast Resolution | `🟠 High` | Verifies if Link-Local Multicast Name Resolution is active (mitigates responder spoofing). |
| **Check 13** | LSA Protection (RunAsPPL) | `🟠 High` | Checks if LSASS process credential protection is enabled (mitigates Mimikatz dumping). |
| **Check 14** | Default RDP Port Check | `🔵 Low` | Audits if RDP is actively listening on standard port 3389. |
| **Check 15** | PowerShell Script Logging | `🟠 High` | Evaluates Script Block Logging parameters under policies to ensure auditing visibility. |
| **Check 16** | WDigest Caching Status | `🔴 Critical` | Checks if LSASS cleartext credential caching is enabled under SecurityProviders. |
| **Check 17** | AutoPlay/AutoRun Protection | `🟡 Medium` | Audits explorer drive auto-execution parameters to block physical USB propagation. |
| **Check 18** | Remote Registry State | `🔵 Low` | Verifies if the Remote Registry service is actively running or enabled. |
| **Check 19** | Administrators Group Pool | `🟡 Medium` | Checks for excessive membership or standard/guest user accounts in Administrators. |
| **Check 20** | BitLocker Encryption Status | `🟠 High` | Audits the offline volume encryption parameter of C: (mitigates physical data theft). |
| **Check 21** | Exposed Network Ports | `🟡 Medium` | Maps publicly listening high-risk ports on the local network (445, 21, 23, 139). |
| **Check 22** | Third-Party AV/EDR Systems | `🟢 Info` | Interfaces with SecurityCenter2 to map active third-party endpoint security agents. |
| **Check 23** | Anonymous SAM Enumeration | `🟡 Medium` | Audits if anonymous null-sessions can query usernames or share lists over the network. |
| **Check 24** | Legacy TLS 1.0 & 1.1 Status | `🟡 Medium` | Audits SCHANNEL protocol parameters for deprecated legacy TLS versions. |

---

## 🛡️ 16-Rule System Hardening Baseline

| ID | 🛡️ Remediation Rule | Mitigation Target & Objective | Action Type |
| :--- | :--- | :--- | :--- |
| **Rule 1** | Deprecate Legacy SMBv1 | Disables SMBv1 client/server parameters to neutralize WannaCry exploitation. | `Registry/Driver` |
| **Rule 2** | Activate Firewall Profiles | Enforces active states across all local firewall boundaries. | `System Command` |
| **Rule 3** | Enable Defender RTP | Forces Real-Time Monitoring and Active Behavior Scanning to ON. | `MpPreference` |
| **Rule 4** | Enforce RDP NLA | Enforces Network Level Authentication to block unauthenticated RDP remote executions. | `Registry HKLM` |
| **Rule 5** | Harden Local Password Policy | Sets minimum local passwords to 14 characters and locks accounts after 5 failures. | `System CLI` |
| **Rule 6** | Disable Local Guest Account | Deactivates the built-in Guest user profile to limit malicious unauthenticated logins. | `System CLI` |
| **Rule 7** | Disable AlwaysInstallElevated | Deletes registry installer elevation bypass vectors. | `Registry HKLM/HKCU` |
| **Rule 8** | Harden UAC Consent Prompts | Configures secure consent prompting behaviors on the Secure Desktop. | `Registry HKLM` |
| **Rule 9** | Deprecate LLMNR | Disables Link-Local Multicast Name Resolution to block Responder hashing captures. | `Registry HKLM` |
| **Rule 10** | Enable LSA RunAsPPL | Forces LSASS process isolation to prevent memory credential harvesting. | `Registry HKLM` |
| **Rule 11** | Enable PS Logging | Activates PowerShell Script Block Logging for auditing transparency. | `Registry HKLM` |
| **Rule 12** | Disable WDigest Caching | Deactivates cleartext logon credential caching in LSASS. | `Registry HKLM` |
| **Rule 13** | Restrict AutoPlay AutoRun | Deactivates drive AutoPlay/AutoRun triggers across all devices. | `Registry HKLM` |
| **Rule 14** | Stop & Disable Remote Registry | Stops and disables the Remote Registry service startup config. | `Service Config` |
| **Rule 15** | Restrict Anonymous SAM | Restricts anonymous net-client NULL-session user and share name queries. | `Registry HKLM (Lsa)` |
| **Rule 16** | Disable TLS 1.0 & 1.1 | Deprecates deprecated TLS 1.0/1.1 protocols for SCHANNEL Clients & Servers. | `Registry HKLM (Schannel)` |

---

## 🚀 How to Run

> [!WARNING]
> To execute active hardening rules (Registry writes, Service state changes) and read protected system parameters (BitLocker status, local accounts), Snake Tank **must** be launched as an **Administrator** (UAC Elevation).

### Option A: Standard GUI Startup (Double-Click)
1. Copy the `Portable_Toolkit/` directory onto your target system or USB drive.
2. Right-click any of the following batch wrappers and select **"Run as Administrator"**:
   * **`Start_Snake_Tank.bat`**: Opens the Full Main Dashboard.
   * **`Snake_Tank_Scanner.bat`**: Opens directly to the Vulnerability Scanner.
   * **`Snake_Tank_Hardener.bat`**: Opens directly to the System Hardening hub.
3. Click **Yes** on the UAC prompt to launch the premium Emerald-Dark Dashboard!

### Option B: Terminal / CLI Startup (Command Prompt or PowerShell)
If you are already in a terminal window, navigate to the `Portable_Toolkit` directory and execute the appropriate command for your environment:

#### 1. Via PowerShell (Directly Bypassing Restrictions)
* **If already inside an elevated Administrator PowerShell console**:
  ```powershell
  powershell -ExecutionPolicy Bypass -File .\core\engine.ps1
  ```
* **To launch and trigger UAC Administrator prompts automatically**:
  ```powershell
  Start-Process powershell -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File .\core\engine.ps1" -Verb RunAs
  ```

#### 2. Via Command Prompt (CMD)
* **Direct execution of the batch script launcher**:
  ```cmd
  Start_Snake_Tank.bat
  ```
* **To launch and elevate the batch script via CLI**:
  ```cmd
  powershell -Command "Start-Process Start_Snake_Tank.bat -Verb RunAs"
  ```

---

## 🧪 Automated Integrity Self-Test

The toolkit includes an advanced headless **Headless Testing Engine (`test_harness.ps1`)** that programmatically simulates, checks, and validates the entire suite:

* **STEP 1**: GUI engine XAML compiling and visual control binding.
* **STEP 2**: Executes all **24 security audits**, validating findings database insertion.
* **STEP 3**: Validates rule status loaders and registry query providers.
* **STEP 4**: Validates HTML Report Exporter rendering.
* **STEP 5**: Asserts Threat Hunting APIs, local software inventory listing, and CIRCL CVE lookup.

To run the automated integrity self-test, open an elevated PowerShell window and run:
```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .\test_harness.ps1
```

### Mock Console Output:
```text
==================================================
     SNAKE TANK SECURITY TOOLKIT TEST HARNESS      
==================================================
[*] STEP 1: Loading GUI Engine & Verifying Startup...
[+] STEP 1 PASSED: Core GUI engine loaded cleanly!
[*] STEP 2: Running Comprehensive Vulnerability Scan...
[SUCCESS] Vulnerability scan completed. Score: 35/100, Findings: 8.
[+] STEP 2 PASSED: Vulnerability Scanner successfully verified (24/24 audits)!
[*] STEP 5: Testing Threat Detector & CVE Scanner Elements...
    [+] Running Local Software Inventory query... (Found 51 products)
    [+] Verifying CVE Scan and Query functions...
[+] STEP 5 PASSED: Threat Detector & CVE Scanner validated!
==================================================
     ALL TESTS PASSED SUCCESSFULLY! (100% OK)     
==================================================
```

---

## 📜 License

Created and maintained by **Snake Tank**. Distributed as a portable endpoint utility for security professionals, auditors, and system administrators. All rights reserved.
