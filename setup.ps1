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

# Detect Python stub and select interpreter
$pythonCmd = $null
# If 'python' exists, check if it's a WindowsApps stub
$pythonPath = (Get-Command python -ErrorAction SilentlyContinue)?.Path
if ($pythonPath) {
    if ($pythonPath -like '*WindowsApps*') {
        Write-Host "Detected Python stub; launching Microsoft Store installer..." -ForegroundColor Yellow
        Start-Process -FilePath $pythonPath
        Write-Error "Please install Python and rerun this script."
        exit 1
    } else {
        $pythonCmd = 'python'
    }
}
# Fallback to 'py' launcher if 'python' not available
if (-not $pythonCmd) {
    if (Get-Command py -ErrorAction SilentlyContinue) {
        Write-Host "Using 'py' launcher instead of 'python'." -ForegroundColor Cyan
        $pythonCmd = 'py'
    } else {
        Write-Host "Python not found; launching installer prompt..." -ForegroundColor Yellow
        Start-Process -FilePath 'python'
        Write-Error "Please install Python and rerun this script."
        exit 1
    }
}

# Prompt for clone directory
Write-Host "`nDefault clone location: $DefaultRepo" -ForegroundColor Cyan
Write-Host "Examples: C:\Users\Name\Documents\my-project  |  D:\Dev\anki-vscode" -ForegroundColor Yellow
$InputRepo = Read-Host 'Press Enter to accept default or type custom path'
$CloneDir = if ([string]::IsNullOrWhiteSpace($InputRepo)) { $DefaultRepo } else { $InputRepo }
Write-Host "Cloning to: $CloneDir" -ForegroundColor Green

# Ensure Git is available
if (-not (Get-Command git -ErrorAction SilentlyContinue)) {
    Write-Error 'Git is not installed or not in PATH.'; exit 1
}

# Clone or update repository
if (-not (Test-Path $CloneDir)) {
    git clone $REPO_URL $CloneDir
} else {
    Write-Host "Repo exists; pulling latest changes..." -ForegroundColor Yellow
    Set-Location $CloneDir; git pull
}

Set-Location $CloneDir

# Prompt for venv location
$DefaultVenv = Join-Path $CloneDir 'venv'
Write-Host "`nDefault venv location: $DefaultVenv" -ForegroundColor Cyan
Write-Host "Examples: C:\Envs\anki-env  |  .\venv" -ForegroundColor Yellow
$InputVenv = Read-Host 'Press Enter to accept default or type custom path'
$VenvDir = if ([string]::IsNullOrWhiteSpace($InputVenv)) { $DefaultVenv } else { $InputVenv }
Write-Host "Creating venv at: $VenvDir" -ForegroundColor Green

# Create virtual environment
& $pythonCmd -m venv $VenvDir

# Install requirements if present
if (Test-Path 'requirements.txt') {
    Write-Host "`nInstalling dependencies from requirements.txt..." -ForegroundColor Cyan
    & "$VenvDir\Scripts\python.exe" -m pip install --upgrade pip
    & "$VenvDir\Scripts\python.exe" -m pip install -r requirements.txt
}

# Activate the virtual environment for current session
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
