#!/bin/bash
# Copyright 2015-2016 NEYS
# This file is part of sptracker.
#
# Build script specifically for Orange Pi ARM 32-bit
# This script should be run on the target Orange Pi device or an ARM32 cross-compilation environment

echo "=========================================="
echo "Building stracker for Orange Pi ARM32"
echo "=========================================="

# Check if we're running on ARM architecture
ARCH=$(uname -m)
echo "Detected architecture: $ARCH"

if [[ "$ARCH" != "armv7l" && "$ARCH" != "armhf" && "$ARCH" != "arm"* ]]; then
    echo "Warning: Not running on ARM architecture. Cross-compilation may be needed."
fi

echo "Setting environment"
export PYTHONPATH=$PWD:$PWD/stracker/externals

echo "Cleaning up old version"
cd stracker
rm -f stracker_orangepi_arm32.tgz
rm -rf dist
rm -rf build

echo "Setting up python environment for ARM32"

# Create ARM32-specific environment directory
ARM_ENV_DIR="env/orangepi_arm32"

# Setting up the env and installing/upgrading takes forever,
# so only do it once a day, or if it hasn't been done yet
if [ -f "$ARM_ENV_DIR/lastcheck" ] && find "$ARM_ENV_DIR/lastcheck" -mtime 0 > /dev/null 2>&1; then
    echo "Using existing environment"
    . "$ARM_ENV_DIR/bin/activate"
else
    echo "Creating new ARM32 environment"
    # Use python3 explicitly for ARM systems
    python3 -m venv "$ARM_ENV_DIR"
    . "$ARM_ENV_DIR/bin/activate"
    
    echo "Upgrading pip and setuptools"
    pip install --upgrade pip setuptools wheel
    
    echo "Installing/upgrading packages for ARM32"
    
    # Install packages with ARM32-specific considerations
    echo "Installing bottle..."
    pip install --upgrade bottle
    
    echo "Installing cherrypy..."
    pip install --upgrade cherrypy
    
    echo "Installing python-dateutil..."
    pip install --upgrade python-dateutil
    
    echo "Installing wsgi-request-logger..."
    pip install --upgrade wsgi-request-logger
    
    echo "Installing simplejson..."
    pip install --upgrade simplejson
    
    # For ARM32, we might need to install psycopg2-binary instead of psycopg2
    echo "Installing psycopg2 (binary version for ARM compatibility)..."
    pip install --upgrade psycopg2-binary || {
        echo "Failed to install psycopg2-binary, trying psycopg2..."
        pip install --upgrade psycopg2 || {
            echo "Warning: psycopg2 installation failed. PostgreSQL support may not work."
        }
    }
    
    echo "Installing pyinstaller..."
    pip install --upgrade pyinstaller
    
    # APSW installation for ARM32 - try binary first, then source
    echo "Installing APSW (SQLite wrapper)..."
    if ! pip show apsw > /dev/null 2>&1; then
        echo "Installing APSW from PyPI (ARM32 compatible)..."
        pip install apsw || {
            echo "Binary APSW failed, trying source compilation..."
            # Install build dependencies for ARM32
            echo "Installing build dependencies..."
            # Note: This assumes apt package manager (Debian/Ubuntu based)
            if command -v apt-get > /dev/null 2>&1; then
                sudo apt-get update
                sudo apt-get install -y libsqlite3-dev sqlite3 build-essential python3-dev
            fi
            
            # Try installing from source with specific version
            pip install https://github.com/rogerbinns/apsw/releases/download/3.35.4-r1/apsw-3.35.4-r1.zip \
                --global-option=fetch --global-option=--version --global-option=3.35.4 --global-option=--all \
                --global-option=build --global-option=--enable-all-extensions || {
                echo "Warning: APSW installation failed. Some SQLite features may not work."
            }
        }
    fi
    
    touch "$ARM_ENV_DIR/lastcheck"
fi

echo "Building stracker with PyInstaller for ARM32"

# PyInstaller command optimized for ARM32
pyinstaller --clean -y -s \
    --exclude-module http_templates \
    --hidden-import cherrypy.wsgiserver.wsgiserver3 \
    --hidden-import psycopg2 \
    --hidden-import sqlite3 \
    --add-data "../stracker/http_static:http_static" \
    --name stracker_orangepi_arm32 \
    stracker.py

if [ $? -eq 0 ]; then
    echo "Build successful!"
    
    # Create distribution package
    mv dist/stracker_orangepi_arm32 dist/stracker_orangepi_arm32_dist
    tar czf stracker_orangepi_arm32.tgz -C dist stracker_orangepi_arm32_dist
    
    echo "Package created: stracker_orangepi_arm32.tgz"
    echo "Size: $(du -h stracker_orangepi_arm32.tgz | cut -f1)"
    
    # Create a simple deployment script
    cat > deploy_orangepi.sh << 'EOF'
#!/bin/bash
# Deployment script for Orange Pi ARM32

echo "Extracting stracker for Orange Pi..."
tar xzf stracker_orangepi_arm32.tgz

echo "Setting up directory structure..."
mkdir -p stracker_orangepi
mv stracker_orangepi_arm32_dist/* stracker_orangepi/
rmdir stracker_orangepi_arm32_dist

echo "Making executable..."
chmod +x stracker_orangepi/stracker_orangepi_arm32

echo "Deployment complete!"
echo "Run with: ./stracker_orangepi/stracker_orangepi_arm32"
EOF
    chmod +x deploy_orangepi.sh
    
    echo "Deployment script created: deploy_orangepi.sh"
else
    echo "Build failed!"
    exit 1
fi

# Cleanup
rm -rf dist/stracker_orangepi_arm32_dist
rm -rf build

echo "=========================================="
echo "Orange Pi ARM32 build completed!"
echo "=========================================="

exit 0
