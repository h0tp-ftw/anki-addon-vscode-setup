#!/bin/bash
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
read -p "Press Enter to use default location, or type a custom directory path: " USER_CLONE_DIR

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
read -p "Press Enter to use default location, or type a custom venv path: " USER_VENV_DIR

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
echo "🎉 SETUP COMPLETE - SUMMARY"
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
echo "The virtual environment will remain active in this terminal session."
echo ""
echo "To activate this environment in future terminal sessions, run:"
echo "source \"$VENV_DIR/bin/activate\""
