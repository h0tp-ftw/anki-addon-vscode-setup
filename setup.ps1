<#
 ============================================================================
   Anki-VSCode Setup Script
   Description : Clones the anki-vscode and ankimon repos, creates venv,
                 installs dependencies, configures add-on and launch.json.
   Author      : h0tp-ftw
   Date        : $(Get-Date -Format yyyy-MM-dd)
   Usage       : .\setup.ps1 (download and run interactively)
 ============================================================================
#>

Write-Host "=====================================================================" -ForegroundColor Cyan
Write-Host "  Anki-VSCode Integration Script (for Ankimon Experimental)" -ForegroundColor Cyan
Write-Host "  by h0tp-ftw | https://github.com/h0tp-ftw/anki-vscode" -ForegroundColor Cyan
Write-Host ("  Date: " + (Get-Date -Format yyyy-MM-dd)) -ForegroundColor Cyan
Write-Host "=====================================================================" -ForegroundColor Cyan
Write-Host ""

$ErrorActionPreference = 'Stop'

# Configuration
$REPO_URL    = 'https://github.com/h0tp-ftw/anki-vscode.git'
$REPO_NAME   = 'anki-vscode'
$Documents   = [Environment]::GetFolderPath('MyDocuments')
$DefaultRepo = Join-Path $Documents $REPO_NAME

Write-Host "==== Anki-VSCode Setup for Windows ====" -ForegroundColor Cyan

# Detect Python stub and select interpreter
$pythonCmd = $null
$cmd       = Get-Command python -ErrorAction SilentlyContinue
if ($cmd) {
    $pythonPath = $cmd.Path
    if ($pythonPath -like '*WindowsApps*') {
        Write-Host "Detected Python stub; launching Store installer..." -ForegroundColor Yellow
        Start-Process -FilePath $pythonPath
        Write-Error "Please install Python and rerun this script."
        exit 1
    } else {
        $pythonCmd = 'python'
    }
}
if (-not $pythonCmd) {
    if (Get-Command py -ErrorAction SilentlyContinue) {
        Write-Host "Using 'py' launcher." -ForegroundColor Cyan
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
Write-Host "Examples: C:\Users\Name\Documents\my-project | D:\Dev\anki-vscode" -ForegroundColor Yellow
$InputRepo = Read-Host 'Press Enter to accept default or type custom path'
$CloneDir  = if ([string]::IsNullOrWhiteSpace($InputRepo)) { $DefaultRepo } else { $InputRepo }
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
Write-Host "Examples: C:\Envs\anki-env | .\venv" -ForegroundColor Yellow
$InputVenv = Read-Host 'Press Enter to accept default or type custom path'
$VenvDir   = if ([string]::IsNullOrWhiteSpace($InputVenv)) { $DefaultVenv } else { $InputVenv }
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

# ───────────────────────────────────────────────────────────────────────────
# Ankimon Add-on Installation & launch.json Generation
# ───────────────────────────────────────────────────────────────────────────

Write-Host ""
Write-Host "Ankimon Add-on Installation Mode" -ForegroundColor Cyan
Write-Host "1) Native Anki installation (detect and use your system’s addons21)" -ForegroundColor Yellow
Write-Host "2) Separate Anki installation (you specify a base directory)" -ForegroundColor Yellow
$MODE = Read-Host 'Select [1 or 2]'

# Default Ankimon clone location
$DefaultAnkimon = Join-Path $Documents 'ankimon'
$AnkimonDir = Read-Host "Press Enter to clone Ankimon under [$DefaultAnkimon], or type custom path"
if ([string]::IsNullOrWhiteSpace($AnkimonDir)) { $AnkimonDir = $DefaultAnkimon }
if (-not (Test-Path $AnkimonDir)) { New-Item -ItemType Directory -Path $AnkimonDir | Out-Null }
if (-not (Test-Path (Join-Path $AnkimonDir '.git'))) {
    Write-Host "Cloning Ankimon into $AnkimonDir…" -ForegroundColor Green
    git clone https://github.com/h0tp-ftw/ankimon.git $AnkimonDir
} else {
    Write-Host "Updating existing Ankimon repo…" -ForegroundColor Yellow
    Push-Location $AnkimonDir
    git pull
    Pop-Location
}

# Determine Anki addons21 and base directory with confirmation
if ($MODE -eq '1') {
    Write-Host ""
    Write-Host "Detecting native Anki addons21 directory..." -ForegroundColor Cyan
    $possible = @(
        "$env:USERPROFILE\.var\app\net.ankiweb.Anki\data\Anki2\addons21",
        "$env:APPDATA\Anki2\addons21",
        "$env:LOCALAPPDATA\Anki2\addons21"
    )
    $AddonsDir = $null
    foreach ($dir in $possible) {
        if (Test-Path $dir) {
            Write-Host "Found: $dir" -ForegroundColor Green
            $yn = Read-Host "Use this directory? [Y/n]"
            if ($yn -eq '' -or $yn -match '^[Yy]') {
                $AddonsDir = $dir
                break
            }
        }
    }
    if (-not $AddonsDir) {
        Write-Host "Could not auto-detect addons21. It should contain folders like '1908235722' and 'community'." -ForegroundColor Yellow
        $AnkiBase = Read-Host "Enter your Anki base directory (parent of addons21)"
        $AddonsDir = Join-Path $AnkiBase 'addons21'
    } else {
        $AnkiBase = Split-Path $AddonsDir -Parent
    }
} elseif ($MODE -eq '2') {
    Write-Host ""
    $AnkiBase = Read-Host "Enter your Anki base directory (will contain addons21)"
    $AddonsDir = Join-Path $AnkiBase 'addons21'
    if (-not (Test-Path $AddonsDir)) { New-Item -ItemType Directory -Path $AddonsDir | Out-Null }
} else {
    Write-Host "Invalid option; aborting." -ForegroundColor Red
    exit 1
}

# ───────────────────────────────────────────────────────────────────────────
# User Backup Warning and Double Confirmation
# ───────────────────────────────────────────────────────────────────────────

Write-Host ""
Write-Host "⚠️  IMPORTANT: USER FILES BACKUP REQUIRED ⚠️" -ForegroundColor Red[#]
Write-Host "Before installing the Ankimon add-on, your existing Ankimon user files in the Anki add-ons directory WILL BE DELETED and replaced." -ForegroundColor Yellow[#]
Write-Host "You MUST backup the following files from the 'user_files' directory inside your Ankimon add-on folder (if present):" -ForegroundColor Yellow[#]
Write-Host "  - meta.json" -ForegroundColor Yellow[#]
Write-Host "  - mypokemon.json" -ForegroundColor Yellow[#]
Write-Host "  - mainpokemon.json" -ForegroundColor Yellow[#]
Write-Host "  - badges.json" -ForegroundColor Yellow[#]
Write-Host "  - items.json" -ForegroundColor Yellow[#]
Write-Host "  - teams.json (if present)" -ForegroundColor Yellow[#]
Write-Host "  - data.json (if present)" -ForegroundColor Yellow[#]
Write-Host "In total, you may have 5 to 7 files to back up depending on your usage." -ForegroundColor Yellow[#]
if ($MODE -eq '2') {
    Write-Host "Note: For a NEW SEPARATE installation (mode 2), backups may not be strictly necessary, but are still **strongly recommended**." -ForegroundColor Yellow[#]
}
Write-Host ""
$confirm1 = Read-Host "Have you backed up all your user files? Type YES (all caps) to continue" 
if ($confirm1 -ne 'YES') {
    Write-Host "Aborting installation. Please backup your files before running this script again." -ForegroundColor Red[#]
    exit 1
}
$confirm2 = Read-Host "FINAL WARNING: Type YES to proceed with deletion and installation" 
if ($confirm2 -ne 'YES') {
    Write-Host "Aborting installation. Please backup your files before running this script again." -ForegroundColor Red[#]
    exit 1
}
Write-Host "Proceeding with Ankimon add-on installation..." -ForegroundColor Green[#]

# ───────────────────────────────────────────────────────────────────────────
# Symlink src/Ankimon -> addons21/1908235722
# ───────────────────────────────────────────────────────────────────────────

$srcDir     = Join-Path $AnkimonDir 'src\Ankimon'
$targetLink = Join-Path $AddonsDir '1908235722'

Write-Host ""
Write-Host "Linking `$srcDir` → `$targetLink`" -ForegroundColor Cyan[#]
if (Test-Path $targetLink) {
    Write-Host "Removing existing link or folder at `$targetLink`..." -ForegroundColor Yellow[#]
    Remove-Item -Recurse -Force $targetLink
}
New-Item -ItemType SymbolicLink -Path $targetLink -Target $srcDir | Out-Null
Write-Host "✅ Symlink created: $targetLink → $srcDir" -ForegroundColor Green[#]

# ───────────────────────────────────────────────────────────────────────────
# Generate .vscode/launch.json in Ankimon repo
# ───────────────────────────────────────────────────────────────────────────

$launchDir = Join-Path $AnkimonDir '.vscode'
if (-not (Test-Path $launchDir)) { New-Item -ItemType Directory -Path $launchDir | Out-Null }
$launchFile = Join-Path $launchDir 'launch.json'

@"
{
    "version": "0.2.0",
    "configurations": [
        {
            "name": "Python Anki",
            "type": "debugpy",
            "request": "launch",
            "stopOnEntry": false,
            "program": "$VenvDir\Scripts\anki.exe",
            "cwd": "`\${workspaceRoot}",
            "env": {},
            "args": [
                "-b",
                "$AnkiBase"
            ],
            "envFile": "`\${workspaceRoot}\.env"
        }
    ]
}
"@ | Set-Content -Path $launchFile -Encoding UTF8

# ───────────────────────────────────────────────────────────────────────────
# Final Confirmation & User Guidance
# ───────────────────────────────────────────────────────────────────────────

Write-Host ""
Write-Host "✅ Ankimon add-on installed at: $targetLink" -ForegroundColor Green
Write-Host "✅ Launch configuration created at: $launchFile" -ForegroundColor Green
Write-Host ""
Write-Host "Your venv Python binary path (to be used as interpreter): $VenvDir\Scripts\anki.exe" -ForegroundColor Cyan
Write-Host "Anki data dir: $AnkiBase" -ForegroundColor Cyan
Write-Host "Your virtual environment Anki: $VenvDir\Scripts\anki.exe" -ForegroundColor Cyan
Write-Host ""
Write-Host "Next steps:" -ForegroundColor Cyan
Write-Host "1. Open the folder $AnkimonDir in VS Code (File > Open Folder) and navigate to the __init__.py file for the add-on." -ForegroundColor Cyan
Write-Host "2. In VS Code, press Ctrl+Shift+P, type Python - Select Interpreter, and set $VenvDir\Scripts\anki.exe as your interpreter." -ForegroundColor Cyan
Write-Host "3. Start debugging: click the dropdown next to the Start button, choose Python Anki, and debug via launch.json." -ForegroundColor Cyan
Write-Host "If everything goes well, Python Anki should appear as the debug configuration and Anki will open with your add-on loaded." -ForegroundColor Cyan
Write-Host ""
Write-Host "Please save the info above for future reference!" -ForegroundColor Cyan
Write-Host ""
Write-Host "Thanks for using the tool, hope it helps <3 - h0tp" -ForegroundColor Magenta
Write-Host ""

# ───────────────────────────────────────────────────────────────────────────
