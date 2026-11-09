#Requires -Version 5.1
<#
.SYNOPSIS
    Installs MyApp from GitHub Releases
    
.DESCRIPTION
    Downloads the latest release, installs to Program Files, 
    creates desktop shortcut, and adds to PATH.
    
.EXAMPLE
    irm https://raw.githubusercontent.com/YOUR_USERNAME/YOUR_REPO/main/install.ps1 | iex
#>

$ErrorActionPreference = "Stop"

# ============================================
# CONFIGURATION - Update these for your app
# ============================================
$AppName = "DeployableApp"
$RepoOwner = "Mohawk-RyanKilgore"
$RepoName = "DeployableApptestingC-"
$ExeName = "deployableapp.exe"
# ============================================

$InstallDir = "$env:LOCALAPPDATA\$AppName"
$ExePath = "$InstallDir\$ExeName"

function Write-Step { param($msg) Write-Host "[*] $msg" -ForegroundColor Cyan }
function Write-Success { param($msg) Write-Host "[✓] $msg" -ForegroundColor Green }
function Write-Error { param($msg) Write-Host "[✗] $msg" -ForegroundColor Red }

Write-Host ""
Write-Host "================================" -ForegroundColor Magenta
Write-Host "  $AppName Installer" -ForegroundColor Magenta
Write-Host "================================" -ForegroundColor Magenta
Write-Host ""

# 1. Get latest release info from GitHub API
Write-Step "Fetching latest release from GitHub..."
try {
    $ApiUrl = "https://api.github.com/repos/$RepoOwner/$RepoName/releases/latest"
    $Release = Invoke-RestMethod -Uri $ApiUrl -Headers @{ "User-Agent" = "PowerShell" }
    $Version = $Release.tag_name
    Write-Success "Found version: $Version"
} catch {
    Write-Error "Failed to fetch release info. Check repo owner/name."
    Write-Host "API URL: $ApiUrl" -ForegroundColor Yellow
    exit 1
}

# 2. Find the Windows exe in release assets
Write-Step "Looking for Windows binary..."
$Asset = $Release.assets | Where-Object { $_.name -like "*windows*.exe" -or $_.name -eq $ExeName }
if (-not $Asset) {
    # Fallback: just grab the first .exe
    $Asset = $Release.assets | Where-Object { $_.name -like "*.exe" } | Select-Object -First 1
}
if (-not $Asset) {
    Write-Error "No Windows executable found in release assets."
    Write-Host "Available assets:" -ForegroundColor Yellow
    $Release.assets | ForEach-Object { Write-Host "  - $($_.name)" }
    exit 1
}
$DownloadUrl = $Asset.browser_download_url
Write-Success "Found: $($Asset.name)"

# 3. Create install directory
Write-Step "Creating install directory..."
if (-not (Test-Path $InstallDir)) {
    New-Item -ItemType Directory -Path $InstallDir -Force | Out-Null
}
Write-Success "Install dir: $InstallDir"

# 4. Download the executable
Write-Step "Downloading $($Asset.name)..."
$TempFile = "$env:TEMP\$($Asset.name)"
try {
    Invoke-WebRequest -Uri $DownloadUrl -OutFile $TempFile -UseBasicParsing
    Move-Item -Path $TempFile -Destination $ExePath -Force
    Write-Success "Downloaded to $ExePath"
} catch {
    Write-Error "Download failed: $_"
    exit 1
}

# 5. Add to PATH (user level)
Write-Step "Adding to PATH..."
$UserPath = [Environment]::GetEnvironmentVariable("Path", "User")
if ($UserPath -notlike "*$InstallDir*") {
    $NewPath = "$UserPath;$InstallDir"
    [Environment]::SetEnvironmentVariable("Path", $NewPath, "User")
    Write-Success "Added $InstallDir to user PATH"
} else {
    Write-Success "Already in PATH"
}

# 6. Copy to Desktop
Write-Step "Copying to Desktop..."
$DesktopPath = [Environment]::GetFolderPath("Desktop")
$DesktopExe = "$DesktopPath\$ExeName"
Copy-Item -Path $ExePath -Destination $DesktopExe -Force
Write-Success "Copied to $DesktopExe"

# 7. Create Desktop Shortcut
Write-Step "Creating desktop shortcut..."
$ShortcutPath = "$DesktopPath\$AppName.lnk"
$WshShell = New-Object -ComObject WScript.Shell
$Shortcut = $WshShell.CreateShortcut($ShortcutPath)
$Shortcut.TargetPath = $ExePath
$Shortcut.WorkingDirectory = $InstallDir
$Shortcut.Description = "$AppName - Installed via curl"
$Shortcut.Save()
Write-Success "Created shortcut: $ShortcutPath"

# 8. Done!
Write-Host ""
Write-Host "================================" -ForegroundColor Green
Write-Host "  Installation Complete!" -ForegroundColor Green
Write-Host "================================" -ForegroundColor Green
Write-Host ""
Write-Host "  Version:   $Version" -ForegroundColor White
Write-Host "  Location:  $ExePath" -ForegroundColor White
Write-Host "  Desktop:   $DesktopExe" -ForegroundColor White
Write-Host ""
Write-Host "  Run '$AppName' from any terminal, or" -ForegroundColor Yellow
Write-Host "  double-click the desktop shortcut." -ForegroundColor Yellow
Write-Host ""

# Refresh PATH for current session
$env:Path = [Environment]::GetEnvironmentVariable("Path", "Machine") + ";" + [Environment]::GetEnvironmentVariable("Path", "User")
