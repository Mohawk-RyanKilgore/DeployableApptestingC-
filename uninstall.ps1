#Requires -Version 5.1
<#
.SYNOPSIS
    Uninstalls DeployableApp
    
.EXAMPLE
    irm https://raw.githubusercontent.com/Mohawk-RyanKilgore/cpp-installer-template/main/uninstall.ps1 | iex
#>

$ErrorActionPreference = "Stop"

# ============================================
# CONFIGURATION - Must match install.ps1
# ============================================
$AppName = "DeployableApp"
$ExeName = "deployableapp.exe"
# ============================================

$InstallDir = "$env:LOCALAPPDATA\$AppName"
$ExePath = "$InstallDir\$ExeName"
$DesktopPath = [Environment]::GetFolderPath("Desktop")
$DesktopExe = "$DesktopPath\$ExeName"
$ShortcutPath = "$DesktopPath\$AppName.lnk"

function Write-Step { param($msg) Write-Host "[*] $msg" -ForegroundColor Cyan }
function Write-Success { param($msg) Write-Host "[✓] $msg" -ForegroundColor Green }
function Write-Warn { param($msg) Write-Host "[!] $msg" -ForegroundColor Yellow }

Write-Host ""
Write-Host "================================" -ForegroundColor Magenta
Write-Host "  $AppName Uninstaller" -ForegroundColor Magenta
Write-Host "================================" -ForegroundColor Magenta
Write-Host ""

# 1. Remove from PATH
Write-Step "Removing from PATH..."
$UserPath = [Environment]::GetEnvironmentVariable("Path", "User")
if ($UserPath -like "*$InstallDir*") {
    $NewPath = ($UserPath -split ';' | Where-Object { $_ -ne $InstallDir }) -join ';'
    [Environment]::SetEnvironmentVariable("Path", $NewPath, "User")
    Write-Success "Removed from PATH"
} else {
    Write-Warn "Not found in PATH"
}

# 2. Remove desktop shortcut
Write-Step "Removing desktop shortcut..."
if (Test-Path $ShortcutPath) {
    Remove-Item $ShortcutPath -Force
    Write-Success "Removed shortcut"
} else {
    Write-Warn "Shortcut not found"
}

# 3. Remove desktop exe
Write-Step "Removing desktop exe..."
if (Test-Path $DesktopExe) {
    Remove-Item $DesktopExe -Force
    Write-Success "Removed desktop exe"
} else {
    Write-Warn "Desktop exe not found"
}

# 4. Remove install directory
Write-Step "Removing install directory..."
if (Test-Path $InstallDir) {
    Remove-Item $InstallDir -Recurse -Force
    Write-Success "Removed $InstallDir"
} else {
    Write-Warn "Install directory not found"
}

Write-Host ""
Write-Host "================================" -ForegroundColor Green
Write-Host "  Uninstall Complete!" -ForegroundColor Green
Write-Host "================================" -ForegroundColor Green
Write-Host ""
Write-Host "  $AppName has been removed." -ForegroundColor White
Write-Host ""
