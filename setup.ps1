# setup_windows.ps1
# Automated clone, venv creation, package install, and activation for Windows

# Strict error handling
$ErrorActionPreference = 'Stop'

# Configuration
$REPO_URL    = 'https://github.com/h0tp-ftw/anki-vscode.git'
$REPO_NAME   = 'anki-vscode'
$Documents   = [Environment]::GetFolderPath('MyDocuments')
$DefaultRepo = Join-Path $Documents $REPO_NAME

Write-Host "==== Anki-VSCode Setup for Windows ====" -ForegroundColor Cyan

# Prompt for clone directory
Write-Host "Default clone location: $DefaultRepo"
Write-Host "Examples: C:\Users\Name\Documents\my-project|D:\Dev\anki-vscode"
$InputRepo = Read-Host 'Press Enter to accept default or type custom path'
if ([string]::IsNullOrWhiteSpace($InputRepo)) {
    $CloneDir = $DefaultRepo
} else {
    $CloneDir = $InputRepo
}
Write-Host "Cloning to: $CloneDir" -ForegroundColor Green

# Ensure Git is available
if (-not (Get-Command git -ErrorAction SilentlyContinue)) {
    Write-Error 'Git is not installed or not in PATH.'; exit 1
}

# Clone or update
if (-not (Test-Path $CloneDir)) {
    git clone $REPO_URL $CloneDir
} else {
    Write-Host 'Repo exists; pulling latest changes...' -ForegroundColor Yellow
    Set-Location $CloneDir; git pull
}

Set-Location $CloneDir

# Prompt for venv location
$DefaultVenv = Join-Path $CloneDir 'venv'
Write-Host "`nDefault venv location: $DefaultVenv"
Write-Host "Examples: C:\Envs\anki-env|.\venv"
$InputVenv = Read-Host 'Press Enter to accept default or type custom path'
if ([string]::IsNullOrWhiteSpace($InputVenv)) {
    $VenvDir = $DefaultVenv
} else {
    $VenvDir = $InputVenv
}
Write-Host "Creating venv at: $VenvDir" -ForegroundColor Green

# Ensure Python is available
if (-not (Get-Command python -ErrorAction SilentlyContinue)) {
    Write-Error 'Python is not installed or not in PATH.'; exit 1
}

# Create venv
python -m venv $VenvDir

# Install requirements
if (Test-Path 'requirements.txt') {
    Write-Host 'Installing dependencies...' -ForegroundColor Cyan
    & "$VenvDir\Scripts\python.exe" -m pip install --upgrade pip
    & "$VenvDir\Scripts\pip.exe" install -r requirements.txt
}

# Activate venv in current session
Write-Host "`nActivating virtual environment..." -ForegroundColor Cyan
& "$VenvDir\Scripts\Activate.ps1"

# Summary
Write-Host "`n=== Setup Summary ===" -ForegroundColor Cyan
Write-Host "Repository path : $CloneDir" -ForegroundColor Green
Write-Host "Virtual env path: $VenvDir" -ForegroundColor Green
if (Test-Path 'requirements.txt') {
    Write-Host 'Dependencies     : Installed' -ForegroundColor Green
} else {
    Write-Host 'Dependencies     : None found' -ForegroundColor Yellow
}
Write-Host 'Virtual env      : Active in this session' -ForegroundColor Green
Write-Host "======================================`n" -ForegroundColor Cyan
