#!/bin/bash
# ===================================================================
# SPTracker ARM32 Builder Script
# ===================================================================
# Compila SPTracker para Orange Pi ARM32 desde Docker
# ===================================================================

set -e  # Exit on any error

echo "🍊 SPTracker ARM32 Builder"
echo "========================="
echo "🏗️ Architecture: $(uname -m)"
echo "🐍 Python: $(python3 --version)"
echo "🔧 GCC: $(gcc --version | head -n1)"
echo

# Verificar que estamos en ARM32
ARCH=$(uname -m)
if [[ "$ARCH" != "armv7l" && "$ARCH" != "arm"* ]]; then
    echo "⚠️  WARNING: Expected ARM architecture, got: $ARCH"
    echo "   Continuing anyway (might be emulation)..."
fi

# Obtener versión del argumento o usar default
VERSION=${1:-"4.0.1-arm32-docker"}
echo "📦 Building version: $VERSION"

# Verificar archivos necesarios
if [ ! -f "create_release.py" ]; then
    echo "❌ ERROR: create_release.py not found"
    echo "   Make sure you're running from SPTracker root directory"
    exit 1
fi

if [ ! -f "release_settings.py" ]; then
    echo "📋 Creating release_settings.py from template..."
    if [ -f "release_settings.py.in" ]; then
        cp release_settings.py.in release_settings.py
        
        # Configurar para ARM32
        cat >> release_settings.py << 'EOF'

# ARM32 specific settings added by Docker builder
git = "/usr/bin/git"
REMOTE_BUILD_CMD = None
REMOTE_COPY_RESULT = None
EOF
        echo "✅ release_settings.py configured for ARM32"
    else
        echo "❌ ERROR: release_settings.py.in template not found"
        exit 1
    fi
fi

# Crear directorio de versiones si no existe
mkdir -p versions

echo
echo "🚀 Starting ARM32 compilation..."
echo "⏱️  This may take 15-30 minutes..."
echo

# Configurar variables para compilación ARM32
export CC=gcc
export CXX=g++
export CFLAGS="-march=armv7-a -mfpu=neon-vfpv4 -mfloat-abi=hard"
export CXXFLAGS="$CFLAGS"

# Ejecutar compilación solo para stracker ARM32
echo "🔧 Running: python3 create_release.py --stracker_only --linux_only $VERSION"
python3 create_release.py --stracker_only --linux_only "$VERSION"

echo
echo "🔍 Checking compilation results..."

# Verificar que se generó el archivo
if [ -d "stracker" ]; then
    cd stracker
    
    # Buscar archivos generados
    if [ -f "dist/stracker" ]; then
        echo "✅ stracker binary generated successfully"
        
        # Verificar arquitectura del binario
        file dist/stracker
        
        # Crear tarball ARM32
        echo "📦 Creating ARM32 package..."
        tar -czf stracker_orangepi_arm32.tgz dist/stracker *.ini *.txt || true
        
        # Mover a directorio de versiones
        mv stracker_orangepi_arm32.tgz ../versions/
        echo "✅ ARM32 package created: versions/stracker_orangepi_arm32.tgz"
        
        # Crear script de despliegue
        cat > deploy_orangepi.sh << 'EOF'
#!/bin/bash
# SPTracker Orange Pi ARM32 Deployment Script
echo "🍊 SPTracker Orange Pi Deployment"
echo "================================="

if [ ! -f "stracker_orangepi_arm32.tgz" ]; then
    echo "❌ ERROR: stracker_orangepi_arm32.tgz not found"
    exit 1
fi

echo "📦 Extracting SPTracker..."
tar -xzf stracker_orangepi_arm32.tgz

echo "🔧 Setting permissions..."
chmod +x dist/stracker

echo "✅ SPTracker ready for Orange Pi!"
echo "🚀 Run: ./dist/stracker"
EOF
        chmod +x deploy_orangepi.sh
        mv deploy_orangepi.sh ../versions/
        
    else
        echo "❌ ERROR: stracker binary not found in dist/"
        exit 1
    fi
    
    cd ..
else
    echo "❌ ERROR: stracker directory not found"
    exit 1
fi

echo
echo "🎉 ARM32 compilation completed successfully!"
echo "📁 Generated files:"
ls -la versions/ | grep -E "(arm32|orangepi)" || echo "   (no ARM32 files found)"

echo
echo "🍊 Ready for Orange Pi deployment!"
echo "   Copy versions/stracker_orangepi_arm32.tgz to your Orange Pi"
echo "   Extract and run: tar -xzf stracker_orangepi_arm32.tgz && ./dist/stracker"
