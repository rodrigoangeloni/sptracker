#!/bin/bash
# =====================================================
# SCRIPT DE INICIO RÁPIDO PARA SPTRACKER
# =====================================================

echo "🏁 SPTracker - Script de Inicio Rápido"
echo "======================================"

# Detectar sistema operativo
if [[ "$OSTYPE" == "linux-gnu"* ]]; then
    OS="linux"
elif [[ "$OSTYPE" == "darwin"* ]]; then
    OS="macos"
elif [[ "$OSTYPE" == "msys" ]]; then
    OS="windows"
else
    OS="unknown"
fi

echo "Sistema detectado: $OS"

# Función para mostrar ayuda
show_help() {
    echo ""
    echo "🚀 Comandos disponibles:"
    echo ""
    echo "  ./inicio_rapido.sh setup     - Configurar entorno de desarrollo"
    echo "  ./inicio_rapido.sh windows   - Compilar para Windows"
    echo "  ./inicio_rapido.sh linux     - Compilar para Linux"
    echo "  ./inicio_rapido.sh orangepi  - Compilar para Orange Pi ARM32"
    echo "  ./inicio_rapido.sh test      - Modo de prueba"
    echo "  ./inicio_rapido.sh help      - Mostrar esta ayuda"
    echo ""
}

# Función de setup
setup_environment() {
    echo "🔧 Configurando entorno de desarrollo..."
    
    # Verificar Python
    if ! command -v python3 &> /dev/null; then
        echo "❌ Python 3 no encontrado. Instalar primero."
        exit 1
    fi
    
    echo "✅ Python 3 encontrado: $(python3 --version)"
    
    # Crear configuración si no existe
    if [ ! -f "release_settings.py" ]; then
        echo "📋 Creando release_settings.py..."
        if [ -f "release_settings_ES.py.in" ]; then
            cp release_settings_ES.py.in release_settings.py
            echo "✅ Configuración creada. ¡EDITA release_settings.py con tus rutas!"
        else
            cp release_settings.py.in release_settings.py
            echo "✅ Configuración creada. ¡EDITA release_settings.py con tus rutas!"
        fi
    else
        echo "✅ release_settings.py ya existe"
    fi
    
    # Crear directorio versions
    if [ ! -d "versions" ]; then
        echo "📁 Creando directorio versions..."
        mkdir versions
        echo "✅ Directorio versions creado"
    else
        echo "✅ Directorio versions ya existe"
    fi
    
    # Setup específico para Orange Pi
    if [[ "$OS" == "linux" ]] && [[ $(uname -m) == "arm"* ]]; then
        echo "🍊 Detectado sistema ARM - Configurando para Orange Pi..."
        if [ -f "setup_orangepi.sh" ]; then
            chmod +x setup_orangepi.sh
            echo "🔄 Ejecutando setup_orangepi.sh..."
            ./setup_orangepi.sh
        fi
    fi
    
    echo "✅ Setup completado"
    echo ""
    echo "📝 Próximos pasos:"
    echo "1. Editar release_settings.py con tus rutas"
    echo "2. Ejecutar: ./inicio_rapido.sh test (para probar)"
    echo "3. Ejecutar: ./inicio_rapido.sh windows/linux/orangepi (para compilar)"
}

# Función para compilar
compile_project() {
    local platform=$1
    local version="dev-$(date +%Y%m%d)"
    
    echo "🏗️ Compilando para $platform..."
    echo "Versión: $version"
    
    case $platform in
        "windows")
            python create_release.py --windows_only $version
            ;;
        "linux")
            python create_release.py --linux_only $version
            ;;
        "orangepi")
            python3 create_release.py --orangepi_arm32_only $version
            ;;
        "test")
            echo "🧪 Modo de prueba - No se crearán archivos reales"
            python3 create_release.py --test_release_process --orangepi_arm32_only test
            ;;
    esac
    
    if [ $? -eq 0 ]; then
        echo "✅ Compilación exitosa"
        if [ "$platform" != "test" ]; then
            echo "📁 Archivos generados en: versions/"
            ls -la versions/
        fi
    else
        echo "❌ Error en la compilación"
        exit 1
    fi
}

# Procesar argumentos
case "${1:-help}" in
    "setup")
        setup_environment
        ;;
    "windows")
        compile_project "windows"
        ;;
    "linux")
        compile_project "linux"
        ;;
    "orangepi")
        compile_project "orangepi"
        ;;
    "test")
        compile_project "test"
        ;;
    "help"|*)
        show_help
        ;;
esac
