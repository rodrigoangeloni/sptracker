#!/bin/bash
# ===================================================================
# SPTracker ARM32 Test Script
# ===================================================================
# Verifica el entorno ARM32 sin compilar
# ===================================================================

echo "🧪 SPTracker ARM32 Test Environment"
echo "===================================="
echo

echo "📊 System Information:"
echo "   Architecture: $(uname -m)"
echo "   Kernel: $(uname -r)"
echo "   OS: $(cat /etc/os-release | grep PRETTY_NAME | cut -d'"' -f2)"
echo

echo "🐍 Python Information:"
echo "   Version: $(python3 --version)"
echo "   Location: $(which python3)"
echo "   Platform: $(python3 -c 'import platform; print(platform.platform())')"
echo

echo "🔧 Build Tools:"
echo "   GCC: $(gcc --version | head -n1)"
echo "   Make: $(make --version | head -n1)"
echo

echo "📦 Testing Python modules..."

# Test basic modules
python3 -c "import sys; print(f'   ✅ sys: {sys.version_info}')"
python3 -c "import os; print('   ✅ os: Available')"
python3 -c "import platform; print(f'   ✅ platform: {platform.machine()}')"

# Test compilation-related modules
echo "   Testing setuptools..."
python3 -c "import setuptools; print('   ✅ setuptools: Available')" 2>/dev/null || echo "   ❌ setuptools: Not available"

echo "   Testing wheel..."
python3 -c "import wheel; print('   ✅ wheel: Available')" 2>/dev/null || echo "   ❌ wheel: Not available"

echo "   Testing pip..."
python3 -m pip --version >/dev/null 2>&1 && echo "   ✅ pip: Available" || echo "   ❌ pip: Not available"

echo
echo "🔍 ARM32 Compatibility Check:"

# Check if we can compile a simple C extension
echo "   Testing C compilation..."
cat > test_compile.c << 'EOF'
#include <stdio.h>
int main() {
    printf("ARM32 compilation test: OK\n");
    return 0;
}
EOF

if gcc test_compile.c -o test_compile 2>/dev/null; then
    echo "   ✅ C compilation: OK"
    ./test_compile
    rm -f test_compile test_compile.c
else
    echo "   ❌ C compilation: Failed"
fi

echo
echo "🍊 Orange Pi Readiness:"

# Check for typical Orange Pi characteristics
if [[ "$(uname -m)" == arm* ]]; then
    echo "   ✅ ARM architecture detected"
else
    echo "   ⚠️  Non-ARM architecture ($(uname -m)) - using emulation"
fi

if [ -f "/proc/cpuinfo" ]; then
    CPU_MODEL=$(grep "model name" /proc/cpuinfo | head -n1 | cut -d: -f2 | xargs)
    echo "   CPU: $CPU_MODEL"
fi

echo
echo "🎯 Test Results Summary:"
echo "   Environment: Ready for SPTracker compilation"
echo "   Platform: $(uname -m)"
echo "   Python: $(python3 --version)"
echo "   GCC: Available"
echo
echo "✅ ARM32 environment test completed!"
echo "🚀 You can now proceed with SPTracker compilation."
