#!/bin/bash
# requirements.sh - Install dependencies for FastNalysis

set -e

echo "======================================"
echo "FastNalysis Dependency Installer"
echo "======================================"
echo ""

# Detect OS
if [[ "$OSTYPE" == "linux-gnu"* ]]; then
    OS="linux"
elif [[ "$OSTYPE" == "darwin"* ]]; then
    OS="macos"
else
    echo "Unsupported OS: $OSTYPE"
    exit 1
fi

echo "Detected OS: $OS"
echo ""

# Function to check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Update package manager
echo "[*] Updating package manager..."
if [[ "$OS" == "linux" ]]; then
    if command_exists apt-get; then
        sudo apt-get update -y
        PKG_MANAGER="apt-get"
    elif command_exists yum; then
        sudo yum update -y
        PKG_MANAGER="yum"
    elif command_exists pacman; then
        sudo pacman -Sy --noconfirm
        PKG_MANAGER="pacman"
    else
        echo "No supported package manager found!"
        exit 1
    fi
elif [[ "$OS" == "macos" ]]; then
    if ! command_exists brew; then
        echo "[*] Installing Homebrew..."
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    fi
    brew update
    PKG_MANAGER="brew"
fi

echo ""

# Install core utilities
echo "[*] Installing core utilities..."
if [[ "$PKG_MANAGER" == "apt-get" ]]; then
    sudo apt-get install -y \
        file \
        binutils \
        xxd \
        coreutils \
        strace \
        ltrace \
        valgrind \
        python3 \
        python3-pip \
        git
elif [[ "$PKG_MANAGER" == "yum" ]]; then
    sudo yum install -y \
        file \
        binutils \
        vim-common \
        coreutils \
        strace \
        ltrace \
        valgrind \
        python3 \
        python3-pip \
        git
elif [[ "$PKG_MANAGER" == "pacman" ]]; then
    sudo pacman -S --noconfirm \
        file \
        binutils \
        vim \
        coreutils \
        strace \
        ltrace \
        valgrind \
        python \
        python-pip \
        git
elif [[ "$PKG_MANAGER" == "brew" ]]; then
    brew install \
        file-formula \
        binutils \
        xxd \
        coreutils \
        python3 \
        git
    echo "Note: strace/ltrace not available on macOS, use dtruss/dtrace instead"
fi

echo ""

# Install pwntools
echo "[*] Installing pwntools (for checksec)..."
pip3 install --upgrade pwntools 2>/dev/null || python3 -m pip install --upgrade pwntools

echo ""

# Install radare2
echo "[*] Installing radare2..."
if command_exists r2; then
    echo "radare2 already installed: $(r2 -v | head -n1)"
else
    if [[ "$OS" == "linux" ]]; then
        # Install from git for latest version
        echo "Installing radare2 from source..."
        if [ -d /tmp/radare2 ]; then
            rm -rf /tmp/radare2
        fi
        git clone https://github.com/radareorg/radare2.git /tmp/radare2
        cd /tmp/radare2
        sys/install.sh
        cd - > /dev/null
        rm -rf /tmp/radare2
    elif [[ "$OS" == "macos" ]]; then
        brew install radare2
    fi
fi

echo ""

# Install r2ghidra plugin
echo "[*] Installing r2ghidra plugin..."
if command_exists r2pm; then
    r2pm -U || true  # Update package list
    r2pm -ci r2ghidra 2>/dev/null || echo "Note: r2ghidra installation may have issues, but core functionality will work"
else
    echo "r2pm not found, skipping r2ghidra installation"
fi

echo ""

# Verify installations
echo "======================================"
echo "Verifying installations..."
echo "======================================"
echo ""

MISSING=""

command_exists file && echo "✓ file" || { echo "✗ file"; MISSING+="file "; }
command_exists readelf && echo "✓ readelf" || { echo "✗ readelf"; MISSING+="readelf "; }
command_exists xxd && echo "✓ xxd" || { echo "✗ xxd"; MISSING+="xxd "; }
command_exists nm && echo "✓ nm" || { echo "✗ nm"; MISSING+="nm "; }
command_exists strings && echo "✓ strings" || { echo "✗ strings"; MISSING+="strings "; }
command_exists objdump && echo "✓ objdump" || { echo "✗ objdump"; MISSING+="objdump "; }
command_exists strace && echo "✓ strace" || echo "✗ strace (optional)"
command_exists ltrace && echo "✓ ltrace" || echo "✗ ltrace (optional)"
command_exists valgrind && echo "✓ valgrind" || echo "✗ valgrind (optional)"
command_exists ldd && echo "✓ ldd" || { echo "✗ ldd"; MISSING+="ldd "; }
command_exists pwn && echo "✓ pwntools" || { echo "✗ pwntools"; MISSING+="pwntools "; }
command_exists r2 && echo "✓ radare2" || { echo "✗ radare2"; MISSING+="radare2 "; }

echo ""

if [ -z "$MISSING" ]; then
    echo "======================================"
    echo "✓ All required dependencies installed!"
    echo "======================================"
    echo ""
    echo "FastNalysis is ready to use!"
    echo "Run: ./FastNalysis.sh <binary_file>"
else
    echo "======================================"
    echo "⚠ Missing dependencies: $MISSING"
    echo "======================================"
    echo ""
    echo "Please install missing dependencies manually."
    exit 1
fi
