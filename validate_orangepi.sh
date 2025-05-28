#!/bin/bash
# Validation script for Orange Pi ARM32 build environment
# Run this script to verify that everything is set up correctly

set -e

echo "============================================================"
echo "Validating Orange Pi ARM32 build environment"
echo "============================================================"

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Status counters
PASSED=0
FAILED=0
WARNINGS=0

# Helper functions
check_pass() {
    echo -e "${GREEN}✓ PASS:${NC} $1"
    ((PASSED++))
}

check_fail() {
    echo -e "${RED}✗ FAIL:${NC} $1"
    ((FAILED++))
}

check_warn() {
    echo -e "${YELLOW}⚠ WARN:${NC} $1"
    ((WARNINGS++))
}

check_info() {
    echo -e "${BLUE}ℹ INFO:${NC} $1"
}

# Check system architecture
echo "Checking system architecture..."
ARCH=$(uname -m)
case "$ARCH" in
    armv7l|armhf)
        check_pass "ARM 32-bit architecture detected: $ARCH"
        ;;
    arm*)
        check_warn "ARM architecture detected but may not be 32-bit: $ARCH"
        ;;
    x86_64|i686|i386)
        check_warn "x86 architecture detected: $ARCH (cross-compilation setup needed)"
        ;;
    *)
        check_fail "Unknown or unsupported architecture: $ARCH"
        ;;
esac

# Check operating system
echo ""
echo "Checking operating system..."
if [ -f /etc/os-release ]; then
    . /etc/os-release
    check_info "OS: $NAME $VERSION"
    
    case "$ID" in
        ubuntu|debian|armbian)
            check_pass "Supported OS detected: $ID"
            ;;
        *)
            check_warn "OS may be supported but not specifically tested: $ID"
            ;;
    esac
else
    check_warn "Cannot determine OS version"
fi

# Check Python version
echo ""
echo "Checking Python installation..."
if command -v python3 > /dev/null 2>&1; then
    PYTHON_VERSION=$(python3 --version 2>&1 | cut -d' ' -f2)
    check_info "Python version: $PYTHON_VERSION"
    
    # Check if version is 3.7 or higher
    python3 -c "
import sys
if sys.version_info >= (3, 7):
    exit(0)
else:
    exit(1)
" 2>/dev/null
    
    if [ $? -eq 0 ]; then
        check_pass "Python version is 3.7 or higher"
    else
        check_fail "Python version must be 3.7 or higher (current: $PYTHON_VERSION)"
    fi
else
    check_fail "Python 3 is not installed"
fi

# Check pip
if command -v pip3 > /dev/null 2>&1; then
    PIP_VERSION=$(pip3 --version | cut -d' ' -f2)
    check_pass "pip3 is installed (version: $PIP_VERSION)"
else
    check_fail "pip3 is not installed"
fi

# Check venv module
echo ""
echo "Checking Python venv module..."
python3 -c "import venv" 2>/dev/null
if [ $? -eq 0 ]; then
    check_pass "Python venv module is available"
else
    check_fail "Python venv module is not available (install python3-venv)"
fi

# Check build tools
echo ""
echo "Checking build tools..."
BUILD_TOOLS=("gcc" "make" "pkg-config")
for tool in "${BUILD_TOOLS[@]}"; do
    if command -v "$tool" > /dev/null 2>&1; then
        VERSION=$(${tool} --version | head -n1)
        check_pass "$tool is installed: $VERSION"
    else
        check_fail "$tool is not installed"
    fi
done

# Check development libraries
echo ""
echo "Checking development libraries..."
DEV_PACKAGES=("python3-dev" "libsqlite3-dev" "libpq-dev")
for package in "${DEV_PACKAGES[@]}"; do
    if dpkg -l | grep -q "^ii  $package "; then
        VERSION=$(dpkg -l | grep "^ii  $package " | awk '{print $3}')
        check_pass "$package is installed: $VERSION"
    else
        check_warn "$package may not be installed (recommended for compilation)"
    fi
done

# Check available memory
echo ""
echo "Checking system resources..."
TOTAL_MEM=$(free -m | awk '/^Mem:/{print $2}')
AVAIL_MEM=$(free -m | awk '/^Mem:/{print $7}')

check_info "Total memory: ${TOTAL_MEM}MB"
check_info "Available memory: ${AVAIL_MEM}MB"

if [ "$TOTAL_MEM" -lt 256 ]; then
    check_fail "Insufficient total memory (minimum 256MB recommended)"
elif [ "$TOTAL_MEM" -lt 512 ]; then
    check_warn "Low total memory (512MB+ recommended for comfortable compilation)"
else
    check_pass "Sufficient memory available"
fi

# Check available disk space
DISK_SPACE=$(df -BM . | awk 'NR==2 {print $4}' | tr -d 'M')
check_info "Available disk space: ${DISK_SPACE}MB"

if [ "$DISK_SPACE" -lt 1024 ]; then
    check_fail "Insufficient disk space (minimum 1GB recommended)"
elif [ "$DISK_SPACE" -lt 2048 ]; then
    check_warn "Low disk space (2GB+ recommended)"
else
    check_pass "Sufficient disk space available"
fi

# Check internet connectivity
echo ""
echo "Checking internet connectivity..."
if ping -c 1 8.8.8.8 > /dev/null 2>&1; then
    check_pass "Internet connectivity is working"
else
    check_warn "Internet connectivity check failed (may affect package downloads)"
fi

# Check for existing sptracker installation
echo ""
echo "Checking for existing installations..."
if [ -d "$HOME/sptracker_build" ]; then
    check_info "Found existing build directory: $HOME/sptracker_build"
fi

if [ -d "$HOME/stracker" ]; then
    check_info "Found existing deployment directory: $HOME/stracker"
fi

# Check project files
echo ""
echo "Checking project files..."
PROJECT_FILES=("create_release_orangepi_arm32.sh" "setup_orangepi.sh" "stracker/stracker.py")
for file in "${PROJECT_FILES[@]}"; do
    if [ -f "$file" ]; then
        check_pass "Found project file: $file"
    else
        check_warn "Project file not found: $file"
    fi
done

# Check system services
echo ""
echo "Checking system services..."
if command -v systemctl > /dev/null 2>&1; then
    check_pass "systemd is available"
    if systemctl list-unit-files | grep -q "stracker.service"; then
        check_info "stracker systemd service is already configured"
    fi
else
    check_info "systemd not available, will use init.d scripts"
fi

# Performance recommendations
echo ""
echo "Performance recommendations..."
CPU_CORES=$(nproc)
check_info "CPU cores available: $CPU_CORES"

if [ "$CPU_CORES" -eq 1 ]; then
    check_warn "Single-core CPU detected - compilation will be slower"
elif [ "$CPU_CORES" -ge 4 ]; then
    check_pass "Multi-core CPU detected - good for compilation performance"
fi

# Orange Pi model detection
echo ""
echo "Attempting Orange Pi model detection..."
if [ -f /proc/device-tree/model ]; then
    MODEL=$(cat /proc/device-tree/model 2>/dev/null | tr -d '\0')
    if [[ "$MODEL" == *"Orange Pi"* ]]; then
        check_pass "Orange Pi model detected: $MODEL"
    else
        check_info "Device model: $MODEL"
    fi
fi

# Final summary
echo ""
echo "============================================================"
echo "Validation Summary"
echo "============================================================"
echo -e "${GREEN}Passed: $PASSED${NC}"
echo -e "${YELLOW}Warnings: $WARNINGS${NC}"
echo -e "${RED}Failed: $FAILED${NC}"

if [ $FAILED -eq 0 ]; then
    echo ""
    echo -e "${GREEN}🎉 Your Orange Pi appears ready for sptracker compilation!${NC}"
    echo ""
    echo "Next steps:"
    echo "1. Run: ./setup_orangepi.sh (if not already done)"
    echo "2. Run: ./create_release_orangepi_arm32.sh"
    echo "3. Deploy: cd stracker && ./deploy_orangepi.sh"
    echo ""
elif [ $FAILED -le 2 ] && [ $WARNINGS -le 5 ]; then
    echo ""
    echo -e "${YELLOW}⚠️  Your Orange Pi might work but has some issues.${NC}"
    echo "Consider fixing the failed checks before proceeding."
    echo ""
else
    echo ""
    echo -e "${RED}❌ Your Orange Pi needs more setup before compilation.${NC}"
    echo "Please address the failed checks and run this script again."
    echo ""
fi

echo "For detailed setup instructions, see: README_OrangePi.md"
echo "============================================================"
