#Requires -Version 5.1
<#
.SYNOPSIS
    Installs DeployableApp from GitHub Releases
    
.DESCRIPTION
    Downloads the latest release, installs to AppData, 
    creates desktop shortcut, and adds to PATH.
    Skips download if already running the latest version.
    
.EXAMPLE
    irm https://raw.githubusercontent.com/Mohawk-RyanKilgore/cpp-installer-template/main/install.ps1 | iex
#>

$ErrorActionPreference = "Stop"

# ============================================
# CONFIGURATION - Update these for your app
# ============================================
$AppName = "DeployableApp"
$RepoOwner = "Mohawk-RyanKilgore"
$RepoName = "cpp-installer-template"
$ExeName = "deployableapp.exe"
# ============================================

$InstallDir = "$env:LOCALAPPDATA\$AppName"
$ExePath = "$InstallDir\$ExeName"
$VersionFile = "$InstallDir\version.txt"

$AuthHeaders = @{ "User-Agent" = "PowerShell" }

function Write-Step { param($msg) Write-Host "[*] $msg" -ForegroundColor Cyan }
function Write-Success { param($msg) Write-Host "[✓] $msg" -ForegroundColor Green }
function Write-Err { param($msg) Write-Host "[✗] $msg" -ForegroundColor Red }
function Write-Info { param($msg) Write-Host "[i] $msg" -ForegroundColor Yellow }

Write-Host ""
Write-Host "================================" -ForegroundColor Magenta
Write-Host "  $AppName Installer" -ForegroundColor Magenta
Write-Host "================================" -ForegroundColor Magenta
Write-Host ""

# 1. Get latest release info from GitHub API
Write-Step "Fetching latest release from GitHub..."
try {
    $ApiUrl = "https://api.github.com/repos/$RepoOwner/$RepoName/releases/latest"
    $Release = Invoke-RestMethod -Uri $ApiUrl -Headers $AuthHeaders
    $Version = $Release.tag_name
    Write-Success "Latest version: $Version"
} catch {
    Write-Err "Failed to fetch release info."
    exit 1
}

# 2. Check if already up-to-date
$InstalledVersion = $null
if (Test-Path $VersionFile) {
    $InstalledVersion = (Get-Content $VersionFile -Raw).Trim()
}

if ($InstalledVersion -eq $Version) {
    Write-Host ""
    Write-Host "================================" -ForegroundColor Green
    Write-Host "  Already Up-to-Date!" -ForegroundColor Green
    Write-Host "================================" -ForegroundColor Green
    Write-Host ""
    Write-Host "  Installed: $InstalledVersion" -ForegroundColor White
    Write-Host "  Latest:    $Version" -ForegroundColor White
    Write-Host ""
    Write-Host "  No update needed." -ForegroundColor Yellow
    Write-Host ""
    exit 0
}

if ($InstalledVersion) {
    Write-Info "Updating from $InstalledVersion to $Version"
} else {
    Write-Info "Fresh install of $Version"
}

# 3. Find the Windows exe in release assets
Write-Step "Looking for Windows binary..."
$Asset = $Release.assets | Where-Object { $_.name -like "*windows*.exe" -or $_.name -eq $ExeName }
if (-not $Asset) {
    $Asset = $Release.assets | Where-Object { $_.name -like "*.exe" } | Select-Object -First 1
}
if (-not $Asset) {
    Write-Err "No Windows executable found in release assets."
    exit 1
}
Write-Success "Found: $($Asset.name)"

# 4. Create install directory
Write-Step "Creating install directory..."
if (-not (Test-Path $InstallDir)) {
    New-Item -ItemType Directory -Path $InstallDir -Force | Out-Null
}
Write-Success "Install dir: $InstallDir"

# 5. Download the executable
Write-Step "Downloading $($Asset.name)..."
$TempFile = "$env:TEMP\$($Asset.name)"
try {
    if (Test-Path $TempFile) { Remove-Item $TempFile -Force }
    if (Test-Path $ExePath) { Remove-Item $ExePath -Force }
    
    $DownloadUrl = $Asset.browser_download_url
    Invoke-WebRequest -Uri $DownloadUrl -OutFile $TempFile -UseBasicParsing
    Move-Item -Path $TempFile -Destination $ExePath -Force
    Write-Success "Downloaded to $ExePath"
} catch {
    Write-Err "Download failed: $_"
    exit 1
}

# 6. Save version file
$Version | Out-File -FilePath $VersionFile -Encoding UTF8 -NoNewline
Write-Success "Saved version info"

# 7. Add to PATH (user level)
Write-Step "Adding to PATH..."
$UserPath = [Environment]::GetEnvironmentVariable("Path", "User")
if ($UserPath -notlike "*$InstallDir*") {
    $NewPath = "$UserPath;$InstallDir"
    [Environment]::SetEnvironmentVariable("Path", $NewPath, "User")
    Write-Success "Added $InstallDir to user PATH"
} else {
    Write-Success "Already in PATH"
}

# 8. Copy to Desktop
Write-Step "Copying to Desktop..."
$DesktopPath = [Environment]::GetFolderPath("Desktop")
$DesktopExe = "$DesktopPath\$ExeName"
Copy-Item -Path $ExePath -Destination $DesktopExe -Force
Write-Success "Copied to $DesktopExe"

# 9. Create Desktop Shortcut
Write-Step "Creating desktop shortcut..."
$ShortcutPath = "$DesktopPath\$AppName.lnk"
$WshShell = New-Object -ComObject WScript.Shell
$Shortcut = $WshShell.CreateShortcut($ShortcutPath)
$Shortcut.TargetPath = $ExePath
$Shortcut.WorkingDirectory = $InstallDir
$Shortcut.Description = "$AppName - Installed via curl"
$Shortcut.Save()
Write-Success "Created shortcut: $ShortcutPath"

# 10. Done!
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
Write-Host "  To uninstall:" -ForegroundColor Gray
Write-Host "  powershell -c `"irm https://raw.githubusercontent.com/$RepoOwner/$RepoName/main/uninstall.ps1 | iex`"" -ForegroundColor Gray
Write-Host ""

# Refresh PATH for current session
$env:Path = [Environment]::GetEnvironmentVariable("Path", "Machine") + ";" + [Environment]::GetEnvironmentVariable("Path", "User")
