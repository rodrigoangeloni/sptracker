#!/bin/bash
# Cross-compilation helper script for Orange Pi ARM32
# This script can be used to prepare a cross-compilation environment on x86_64 Linux

set -e

echo "============================================================"
echo "Setting up cross-compilation environment for Orange Pi ARM32"
echo "============================================================"

# Check if running on x86_64 Linux
ARCH=$(uname -m)
OS=$(uname -s)

if [[ "$OS" != "Linux" ]]; then
    echo "Error: This script requires Linux"
    exit 1
fi

if [[ "$ARCH" != "x86_64" ]]; then
    echo "Warning: This script is designed for x86_64 hosts"
    echo "Current architecture: $ARCH"
fi

# Install cross-compilation tools
echo "Installing cross-compilation tools..."
sudo apt-get update
sudo apt-get install -y \
    gcc-arm-linux-gnueabihf \
    g++-arm-linux-gnueabihf \
    python3-dev \
    python3-pip \
    python3-venv \
    qemu-user-static \
    binfmt-support

# Set up environment variables for cross-compilation
export CC=arm-linux-gnueabihf-gcc
export CXX=arm-linux-gnueabihf-g++
export AR=arm-linux-gnueabihf-ar
export STRIP=arm-linux-gnueabihf-strip
export PKG_CONFIG_PATH=/usr/lib/arm-linux-gnueabihf/pkgconfig

echo "Cross-compilation environment variables:"
echo "CC=$CC"
echo "CXX=$CXX"
echo "AR=$AR"
echo "STRIP=$STRIP"

# Create cross-compilation Python environment
CROSS_VENV="env/cross_arm32"
echo "Creating cross-compilation Python environment: $CROSS_VENV"

python3 -m venv $CROSS_VENV
source $CROSS_VENV/bin/activate

# Upgrade pip
pip install --upgrade pip setuptools wheel

echo "============================================================"
echo "Cross-compilation environment ready!"
echo "============================================================"
echo
echo "To use this environment:"
echo "1. source $CROSS_VENV/bin/activate"
echo "2. Set environment variables:"
echo "   export CC=arm-linux-gnueabihf-gcc"
echo "   export CXX=arm-linux-gnueabihf-g++"
echo "   export AR=arm-linux-gnueabihf-ar"
echo "   export STRIP=arm-linux-gnueabihf-strip"
echo "3. Install packages with: pip install --no-binary :all: package_name"
echo
echo "Note: Cross-compilation can be complex. Direct compilation on"
echo "Orange Pi is often simpler and more reliable."
