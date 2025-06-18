#!/bin/bash
#
# ==========================================================================
#  Anki-VSCode Setup Script
#  Description : Clones the anki-vscode and ankimon repos, sets up venv,
#                installs dependencies, configures add-on and launch.json.
#  Author      : h0tp-ftw
#  Date        : $(date +"%Y-%m-%d")
#  Usage       : curl -fsSL <URL>/setup.sh | bash
# ==========================================================================

echo "====================================================================="
echo "  Anki-VSCode Integration Script (for Ankimon Experimental)"
echo "  by h0tp-ftw | https://github.com/h0tp-ftw/anki-vscode"
echo "  Date: $(date +"%Y-%m-%d")"
echo "====================================================================="
echo ""

set -e

REPO_URL="https://github.com/h0tp-ftw/anki-vscode.git"
REPO_NAME="anki-vscode"

# Check for required tools
if ! command -v git &> /dev/null; then
    echo "Error: git is not installed or not in PATH."
    exit 1
fi

if ! command -v python3 &> /dev/null; then
    echo "Error: Python 3 is not installed or not in PATH."
    exit 1
fi

if ! python3 -m venv --help &> /dev/null; then
    echo "Error: Python venv module is not available."
    exit 1
fi

# Detect OS for Documents folder path
if [[ "$OSTYPE" == "darwin"* ]]; then
    DEFAULT_CLONE_DIR="$HOME/Documents/$REPO_NAME"
elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
    DEFAULT_CLONE_DIR="$HOME/Documents/$REPO_NAME"
else
    DEFAULT_CLONE_DIR="$HOME/Documents/$REPO_NAME"
fi

echo "Repository Clone Location Selection"
echo "=================================="
echo "Default clone location: $DEFAULT_CLONE_DIR"
echo ""
echo "Directory format examples:"
echo "  Absolute path: /home/username/Documents/my-projects"
echo "  Home relative: ~/Documents/my-projects"
echo "  Current dir relative: ./my-projects"
echo ""
echo -n "Press Enter to use default location, or type a custom directory path: " > /dev/tty
read  USER_CLONE_DIR < /dev/tty

CLONE_DIR="${USER_CLONE_DIR:-$DEFAULT_CLONE_DIR}"
CLONE_DIR="${CLONE_DIR/#\~/$HOME}"

echo "Cloning repository to: $CLONE_DIR"

# Create parent directory if it doesn't exist
PARENT_DIR=$(dirname "$CLONE_DIR")
mkdir -p "$PARENT_DIR"

# Clone or update repository
if [ ! -d "$CLONE_DIR" ]; then
    echo "Cloning repository from $REPO_URL ..."
    git clone "$REPO_URL" "$CLONE_DIR"
else
    echo "Repository directory already exists. Updating..."
    cd "$CLONE_DIR"
    git pull
fi

cd "$CLONE_DIR"

# Virtual environment setup
DEFAULT_VENV_DIR="$(pwd)/venv"
echo ""
echo "Virtual Environment Setup"
echo "========================"
echo "Default virtual environment location: $DEFAULT_VENV_DIR"
echo ""
echo "Directory format examples:"
echo "  Absolute path: /home/username/my-venv"
echo "  Relative to repo: ./venv"
echo "  Custom location: ~/python-envs/anki-vscode"
echo ""
echo -n "Press Enter to use default location, or type a custom venv path: " > /dev/tty
read  USER_VENV_DIR < /dev/tty

VENV_DIR="${USER_VENV_DIR:-$DEFAULT_VENV_DIR}"
VENV_DIR="${VENV_DIR/#\~/$HOME}"

echo "Creating virtual environment at: $VENV_DIR"
mkdir -p "$(dirname "$VENV_DIR")"
python3 -m venv "$VENV_DIR"

if [ $? -ne 0 ]; then
    echo "❌ Failed to create the virtual environment."
    exit 1
fi

# Install requirements if they exist
REQUIREMENTS_INSTALLED=false
if [ -f "requirements.txt" ]; then
    echo ""
    echo "Installing requirements from requirements.txt..."
    "$VENV_DIR/bin/python" -m pip install --upgrade pip
    "$VENV_DIR/bin/pip" install -r requirements.txt
    
    if [ $? -eq 0 ]; then
        echo "✅ Requirements installed successfully!"
        REQUIREMENTS_INSTALLED=true
    else
        echo "⚠️  Some requirements may have failed to install. Check the output above."
    fi
else
    echo "No requirements.txt found. Skipping dependency installation."
fi

# Activate the virtual environment
echo ""
echo "Activating virtual environment..."
source "$VENV_DIR/bin/activate"

# Display comprehensive summary
echo ""
echo "VIRTUAL ENVIRONMENT SET UP - SUMMARY"
echo "=========================="
echo "✅ Repository cloned/updated at: $CLONE_DIR"
echo "✅ Virtual environment created at: $VENV_DIR"
if [ "$REQUIREMENTS_INSTALLED" = true ]; then
    echo "✅ Python packages installed from requirements.txt"
else
    echo "ℹ️  No requirements.txt found - no packages installed"
fi
echo "✅ Virtual environment is now ACTIVE"
echo ""
echo "Environment Details:"
echo "--------------------"
echo "Python version: $(python --version)"
echo "Python executable: $(which python)"
echo "Pip version: $(pip --version | cut -d' ' -f1-2)"
echo "Working directory: $(pwd)"
echo ""
echo "Your development environment is ready to use!"
echo ""
echo "Note: If you ever need to use this environment in future terminal sessions, run:"
echo "source \"$VENV_DIR/bin/activate\""


# ───────────────────────────────────────────────────────────────────────────
# Ankimon Add-on Installation & launch.json Generation
# ───────────────────────────────────────────────────────────────────────────

echo
echo "Ankimon Add-on Installation Mode"
echo "1) Native Anki installation (detect and use your system’s addons21). This will use your existing Anki installation for all the files and addons." 
echo "2) Separate Anki installation (you specify a base directory). This will make an entirely new Anki installation, separate from your normal Anki installation."
echo "Both options are good. 1. is more convenient and mimics your actual installation, and 2. is isolated from your install, and messing up your addon will not affect your normal installation."
echo ""
echo -n "Select [1 or 2]: " > /dev/tty
read  MODE < /dev/tty

# Default Ankimon clone location
DEFAULT_ANKIMON="$HOME/Documents/ankimon"
echo -n "Press Enter to clone Ankimon under [$DEFAULT_ANKIMON], or type custom path: " > /dev/tty
read  ANKIMON_DIR   < /dev/tty
ANKIMON_DIR="${ANKIMON_DIR:-$DEFAULT_ANKIMON}"
mkdir -p "$ANKIMON_DIR"
if [ ! -d "$ANKIMON_DIR/.git" ]; then
  echo "Cloning Ankimon into $ANKIMON_DIR…" 
  git clone https://github.com/h0tp-ftw/ankimon.git "$ANKIMON_DIR"
else
  echo "Updating existing Ankimon repo…" 
  cd "$ANKIMON_DIR" && git pull && cd - >/dev/null
fi

# ───────────────────────────────────────────────────────────────────────────
# Determine Anki addons21 and base directory with confirmation
if [ "$MODE" = "1" ]; then
  echo
  echo "Detecting native Anki addons21 directory..."
  # Common Linux/macOS locations
  POSSIBLE=(
    "$HOME/.var/app/net.ankiweb.Anki/data/Anki2/addons21"
    "$HOME/Library/Application Support/Anki2/addons21"
    "$HOME/.local/share/Anki2/addons21"
  )
  for DIR in "${POSSIBLE[@]}"; do
    if [ -d "$DIR" ]; then
      echo "Found: $DIR"
      echo -n "Use this directory? [Y/n]: " > /dev/tty
      read  yn           < /dev/tty
      case "$yn" in [Nn]*) continue;; *) ADDONS_DIR="$DIR"; break;; esac
    fi
  done
  # Fallback to manual if not set
  if [ -z "$ADDONS_DIR" ]; then
    echo "Could not auto-detect addons21. It should contain folders like '1908235722' and 'community'."
    echo -n "Enter your Anki base directory (parent of addons21): " > /dev/tty
    read  ANKI_BASE     < /dev/tty
    ADDONS_DIR="$ANKI_BASE/addons21"
  else
    ANKI_BASE="$(dirname "$ADDONS_DIR")"
  fi

elif [ "$MODE" = "2" ]; then
  echo
  echo -n "Enter your Anki base directory (will contain addons21): " > /dev/tty
  read  ANKI_BASE     < /dev/tty
  ADDONS_DIR="$ANKI_BASE/addons21"
  mkdir -p "$ADDONS_DIR"

else
  echo "Invalid option; aborting."
  exit 1
fi
# ───────────────────────────────────────────────────────────────────────────

# ───────────────────────────────────────────────────────────────────────────
# User Backup Warning and Double Confirmation

echo ""
echo "⚠️  IMPORTANT: USER FILES BACKUP REQUIRED ⚠️" > /dev/tty
echo "Before installing the Ankimon add-on, your existing Ankimon user files in the Anki add-ons directory WILL BE DELETED and replaced." > /dev/tty
echo "You MUST backup the following files from the 'user_files' directory inside your Ankimon add-on folder (if present):" > /dev/tty
echo "  - meta.json" > /dev/tty
echo "  - mypokemon.json" > /dev/tty
echo "  - mainpokemon.json" > /dev/tty
echo "  - badges.json" > /dev/tty
echo "  - items.json" > /dev/tty
echo "  - teams.json (if present)" > /dev/tty
echo "  - data.json (if present)" > /dev/tty
echo "In total, you may have 5 to 7 files to back up depending on your usage." > /dev/tty
if [ "$MODE" = "2" ]; then
    echo "Note: If you are using a NEW SEPARATE installation (mode 2), this may not be needed, but it is still recommended to backup in case any issues occur." > /dev/tty
fi
echo "" > /dev/tty
echo "Please backup these files now before proceeding." > /dev/tty
echo -n "Have you backed up all your user files? Type YES (in all caps) to continue: " > /dev/tty
read CONFIRM1 < /dev/tty
if [ "$CONFIRM1" != "YES" ]; then
    echo "Aborting installation. Please backup your files before running this script again." > /dev/tty
    exit 1
fi
echo -n "This is your FINAL WARNING. Are you absolutely sure you have backed up your user files? Type YES (in all caps) to proceed: " > /dev/tty
read CONFIRM2 < /dev/tty
if [ "$CONFIRM2" != "YES" ]; then
    echo "Aborting installation. Please backup your files before running this script again." > /dev/tty
    exit 1
fi
echo "Proceeding with Ankimon add-on installation..." > /dev/tty
# ───────────────────────────────────────────────────────────────────────────


# Symlink src/Ankimon -> addons21/1908235722
SRC_DIR="$ANKIMON_DIR/src/Ankimon"
TARGET_LINK="$ADDONS_DIR/1908235722"

echo "Linking $SRC_DIR -> $TARGET_LINK"
# Use -n to avoid clobbering existing directory, -f to overwrite stale link
ln -sfn "$SRC_DIR" "$TARGET_LINK" \
  && echo "Symlink created successfully." \
  || { 
       echo "⚠️  Failed to link. Please backup $TARGET_LINK and try again.";
       exit 1;
     }

# Generate .vscode/launch.json in Ankimon repo
LAUNCH_DIR="$ANKIMON_DIR/.vscode"
mkdir -p "$LAUNCH_DIR"
cat > "$LAUNCH_DIR/launch.json" <<EOF
{
    "version": "0.2.0",
    "configurations": [
        {
            "name": "Python Anki",
            "type": "debugpy",
            "request": "launch",
            "stopOnEntry": false,
            "program": "$VENV_DIR/bin/anki",
            "cwd": "\${workspaceRoot}",
            "env": {},
            "args": [
                "-b",
                "$ANKI_BASE"
            ],
            "envFile": "\${workspaceRoot}/.env"
        }
    ]
}
EOF

echo
echo "✅ Ankimon add-on installed at: $TARGET_LINK"
echo "✅ Launch configuration created at: $LAUNCH_DIR/launch.json"
echo
echo "Your venv Python binary path (to be used as interpreter): $VENV_DIR/bin/anki"
echo "Anki data dir: $ANKI_BASE"
echo "Your virtual environment Anki: $VENV_DIR/bin/anki"
echo ""
echo "Next steps:"
echo "1. Open the folder '$ANKIMON_DIR' in VS Code (File -> Open Folder, and open that folder) and go to the __init__.py file for the addon."
echo "2. Set $VENV_DIR/bin/anki as your Python interpreter path (in VS Code, type >interpreter in top bar and select Python: Select Interpreter)"
echo "3. Now run the debug mode using the launch.json file - Go to top right, press the dropdown on the right of the Start button, and click Debug using launch.json"
echo "If everything went well, "Python Anki" should pop up as the config. After clicking that, Anki should open properly and your addon should be available!"
echo ""
echo "Please save the info above for future reference!"
echo ""
echo "Thanks for using the tool, hope it helps <3 - h0tp"
echo

# ───────────────────────────────────────────────────────────────────────────
