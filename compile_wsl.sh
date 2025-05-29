#!/bin/bash

echo "=== SPTracker WSL Linux Compilation ==="
echo "Compiling stracker server for Linux x86_64..."

# Set environment
export PYTHONPATH=$PWD:$PWD/stracker/externals

# Clean up old builds
echo "Cleaning up old builds..."
cd stracker
rm -f stracker_linux_x86.tgz
rm -rf dist
rm -rf build

# Activate virtual environment
echo "Activating Python virtual environment..."
cd ..
source venv_wsl/bin/activate

# Verify environment
echo "Python version: $(python --version)"
echo "PyInstaller version: $(pyinstaller --version)"

# Go back to stracker directory
cd stracker

echo "Starting PyInstaller compilation..."
pyinstaller --clean -y -s \
    --exclude-module http_templates \
    --hidden-import cherrypy.wsgiserver.wsgiserver3 \
    --exclude-module PySide6 \
    --exclude-module PySide2 \
    --exclude-module PyQt5 \
    --exclude-module PyQt6 \
    --exclude-module tkinter \
    stracker.py

if [ $? -eq 0 ]; then
    echo "Compilation successful!"
    
    # Package the result
    echo "Packaging stracker_linux_x86..."
    mv dist/stracker dist/stracker_linux_x86
    tar cvzf stracker_linux_x86.tgz -C dist stracker_linux_x86
    
    # Move to versions directory
    mkdir -p ../versions
    cp stracker_linux_x86.tgz ../versions/stracker-V4.0.1-linux.tgz
    
    echo "Build completed successfully!"
    echo "Output: versions/stracker-V4.0.1-linux.tgz"
    
    # Show file size
    ls -lh ../versions/stracker-V4.0.1-linux.tgz
else
    echo "Compilation failed!"
    exit 1
fi

# Clean up
rm -rf dist
rm -rf build

echo "=== WSL Compilation Complete ==="
