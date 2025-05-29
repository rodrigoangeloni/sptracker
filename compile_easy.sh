#!/bin/bash
# ===================================================================
# SPTracker v4.0.1 - COMPILADOR SÚPER FÁCIL PARA LINUX
# ===================================================================
# Script inteligente que detecta todo automáticamente
# ===================================================================

set -e  # Salir en caso de error

# Colores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
PURPLE='\033[0;35m'
NC='\033[0m' # Sin color

# Variables globales
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LOG_FILE="compile_$(date +%Y%m%d_%H%M).log"
VERSION="${1:-dev-$(date +%Y%m%d-%H%M)}"

# Funciones de logging
log() {
    local message="$1"
    local color="${2:-$NC}"
    local timestamp=$(date '+%H:%M:%S')
    echo -e "${color}[$timestamp] $message${NC}" | tee -a "$LOG_FILE"
}

show_banner() {
    clear
    cat << 'EOF'

 ░██████╗██████╗░████████╗██████╗░░█████╗░░█████╗░██╗░░██╗███████╗██████╗░
 ██╔════╝██╔══██╗╚══██╔══╝██╔══██╗██╔══██╗██╔══██╗██║░██╔╝██╔════╝██╔══██╗
 ╚█████╗░██████╔╝░░░██║░░░██████╔╝███████║██║░░╚═╝█████═╝░█████╗░░██████╔╝
 ░╚═══██╗██╔═══╝░░░░██║░░░██╔══██╗██╔══██║██║░░██╗██╔═██╗░██╔══╝░░██╔══██╗
 ██████╔╝██║░░░░░░░░██║░░░██║░░██║██║░░██║╚█████╔╝██║░╚██╗███████╗██║░░██║
 ╚═════╝░╚═╝░░░░░░░░╚═╝░░░╚═╝░░╚═╝╚═╝░░╚═╝░╚════╝░╚═╝░░╚═╝╚══════╝╚═╝░░╚═╝

      🏎️ COMPILADOR AUTOMÁTICO v4.0.1 - Sistema de Telemetría      
                     ⚡ DETECCIÓN AUTOMÁTICA LINUX ⚡

EOF
}

show_help() {
    cat << 'EOF'
╔══════════════════════════════════════════════════════════════════╗
║                SPTracker v4.0.1 - Compilador Fácil              ║
╚══════════════════════════════════════════════════════════════════╝

DESCRIPCIÓN:
  Script inteligente que detecta automáticamente tu entorno Linux
  y compila SPTracker de la manera más óptima.

USO:
  ./compile_easy.sh                      # Compilación automática
  ./compile_easy.sh 2.1.0               # Versión específica
  ./compile_easy.sh --clean              # Limpiar antes de compilar
  ./compile_easy.sh --test               # Modo de prueba
  ./compile_easy.sh --orangepi           # Compilar para Orange Pi ARM32
  ./compile_easy.sh --help               # Mostrar ayuda

DETECCIÓN AUTOMÁTICA:
  ✓ Distribución Linux (Ubuntu/Debian/Arch/CentOS)
  ✓ Arquitectura (x64/ARM32/ARM64)
  ✓ Python disponible y versión
  ✓ Herramientas de desarrollo (gcc, make)
  ✓ Dependencias de sistema
  ✓ Entorno virtual existente

SALIDAS:
  • versions/stracker-V{version}.zip     - Servidor para Linux
  • stracker/stracker_linux_x86.tgz     - Binario Linux x86
  • stracker/stracker_orangepi_arm32.tgz - Binario Orange Pi (si aplica)

EOF
    exit 0
}

detect_environment() {
    log "🔍 Detectando entorno de compilación..." "$YELLOW"
    
    # Detectar distribución
    if [ -f /etc/os-release ]; then
        . /etc/os-release
        DISTRO="$NAME"
        log "  • Distribución: $DISTRO"
    else
        DISTRO="Unknown Linux"
        log "  • Distribución: $DISTRO"
    fi
    
    # Detectar arquitectura
    ARCH=$(uname -m)
    log "  • Arquitectura: $ARCH"
    
    # Detectar si es WSL
    if grep -q Microsoft /proc/version 2>/dev/null; then
        IS_WSL=true
        log "  • Entorno: WSL (Windows Subsystem for Linux)" "$CYAN"
    else
        IS_WSL=false
        log "  • Entorno: Linux nativo"
    fi
    
    # Detectar si es Orange Pi
    if [[ "$ARCH" == arm* ]] && [ -f /proc/cpuinfo ]; then
        if grep -q "Allwinner" /proc/cpuinfo 2>/dev/null; then
            IS_ORANGEPI=true
            log "  • Dispositivo: Orange Pi detectado" "$GREEN"
        else
            IS_ORANGEPI=false
            log "  • Dispositivo: ARM genérico"
        fi
    else
        IS_ORANGEPI=false
    fi
}

check_python() {
    log "🐍 Verificando Python..." "$YELLOW"
    
    PYTHON_CMD=""
    for cmd in python3 python py; do
        if command -v "$cmd" &> /dev/null; then
            VERSION_OUTPUT=$($cmd --version 2>&1)
            if [[ $VERSION_OUTPUT =~ Python\ ([0-9]+\.[0-9]+) ]]; then
                PYTHON_VERSION="${BASH_REMATCH[1]}"
                PYTHON_CMD="$cmd"
                log "  • Python encontrado: $VERSION_OUTPUT ($cmd)" "$GREEN"
                break
            fi
        fi
    done
    
    if [ -z "$PYTHON_CMD" ]; then
        log "❌ Python no encontrado" "$RED"
        log "   Instala Python 3.7+ primero:"
        log "   Ubuntu/Debian: sudo apt install python3 python3-pip python3-venv"
        log "   CentOS/RHEL:   sudo yum install python3 python3-pip"
        log "   Arch:          sudo pacman -S python python-pip"
        exit 1
    fi
    
    # Verificar versión mínima
    if ! python3 -c "import sys; exit(0 if sys.version_info >= (3, 7) else 1)" 2>/dev/null; then
        log "❌ Python 3.7+ requerido, tienes $PYTHON_VERSION" "$RED"
        exit 1
    fi
}

check_dependencies() {
    log "🔧 Verificando dependencias del sistema..." "$YELLOW"
    
    # Lista de dependencias básicas
    REQUIRED_PACKAGES=""
    
    # Verificar compilador
    if ! command -v gcc &> /dev/null; then
        log "⚠️ gcc no encontrado - requerido para compilar dependencias"
        case "$DISTRO" in
            *Ubuntu*|*Debian*)
                REQUIRED_PACKAGES="$REQUIRED_PACKAGES build-essential"
                ;;
            *CentOS*|*RHEL*|*Fedora*)
                REQUIRED_PACKAGES="$REQUIRED_PACKAGES gcc gcc-c++ make"
                ;;
            *Arch*)
                REQUIRED_PACKAGES="$REQUIRED_PACKAGES base-devel"
                ;;
        esac
    else
        log "  • gcc: $(gcc --version | head -n1)" "$GREEN"
    fi
    
    # Verificar Python dev headers
    if ! python3 -c "import distutils.util; import sys; print(distutils.util.get_platform())" &>/dev/null; then
        case "$DISTRO" in
            *Ubuntu*|*Debian*)
                REQUIRED_PACKAGES="$REQUIRED_PACKAGES python3-dev"
                ;;
            *CentOS*|*RHEL*|*Fedora*)
                REQUIRED_PACKAGES="$REQUIRED_PACKAGES python3-devel"
                ;;
            *Arch*)
                # Python dev headers incluidos por defecto
                ;;
        esac
    fi
    
    # Verificar SQLite dev (para APSW)
    if ! pkg-config --exists sqlite3 2>/dev/null; then
        case "$DISTRO" in
            *Ubuntu*|*Debian*)
                REQUIRED_PACKAGES="$REQUIRED_PACKAGES libsqlite3-dev"
                ;;
            *CentOS*|*RHEL*|*Fedora*)
                REQUIRED_PACKAGES="$REQUIRED_PACKAGES sqlite-devel"
                ;;
            *Arch*)
                REQUIRED_PACKAGES="$REQUIRED_PACKAGES sqlite"
                ;;
        esac
    else
        log "  • SQLite dev: $(pkg-config --modversion sqlite3)" "$GREEN"
    fi
    
    # Sugerir instalación si faltan paquetes
    if [ -n "$REQUIRED_PACKAGES" ]; then
        log "⚠️ Faltan dependencias del sistema:" "$YELLOW"
        log "   Paquetes necesarios: $REQUIRED_PACKAGES"
        log ""
        case "$DISTRO" in
            *Ubuntu*|*Debian*)
                log "   Ejecuta: sudo apt update && sudo apt install$REQUIRED_PACKAGES"
                ;;
            *CentOS*|*RHEL*)
                log "   Ejecuta: sudo yum install$REQUIRED_PACKAGES"
                ;;
            *Fedora*)
                log "   Ejecuta: sudo dnf install$REQUIRED_PACKAGES"
                ;;
            *Arch*)
                log "   Ejecuta: sudo pacman -S$REQUIRED_PACKAGES"
                ;;
        esac
        log ""
        read -p "¿Quieres que intente instalar automáticamente? (s/N): " auto_install
        if [[ "$auto_install" =~ ^[Ss]$ ]]; then
            install_dependencies
        else
            log "Instala las dependencias manualmente y ejecuta el script de nuevo"
            exit 1
        fi
    fi
}

install_dependencies() {
    log "📦 Instalando dependencias del sistema..." "$YELLOW"
    
    case "$DISTRO" in
        *Ubuntu*|*Debian*)
            sudo apt update && sudo apt install -y $REQUIRED_PACKAGES
            ;;
        *CentOS*|*RHEL*)
            sudo yum install -y $REQUIRED_PACKAGES
            ;;
        *Fedora*)
            sudo dnf install -y $REQUIRED_PACKAGES
            ;;
        *Arch*)
            sudo pacman -S --noconfirm $REQUIRED_PACKAGES
            ;;
        *)
            log "❌ Distribución no soportada para instalación automática" "$RED"
            exit 1
            ;;
    esac
    
    log "✅ Dependencias instaladas correctamente" "$GREEN"
}

setup_project() {
    log "📋 Configurando proyecto..." "$YELLOW"
    
    # Verificar que estamos en el directorio correcto
    if [ ! -f "create_release.py" ]; then
        log "❌ No estás en el directorio correcto de SPTracker" "$RED"
        log "   Ejecuta desde el directorio que contiene create_release.py"
        exit 1
    fi
    
    # Crear configuración si no existe
    if [ ! -f "release_settings.py" ]; then
        log "📝 Creando configuración desde template..."
        if [ -f "release_settings_ES.py.in" ]; then
            cp "release_settings_ES.py.in" "release_settings.py"
            log "✅ Configuración creada con comentarios en español" "$GREEN"
        elif [ -f "release_settings.py.in" ]; then
            cp "release_settings.py.in" "release_settings.py"
            log "✅ Configuración creada" "$GREEN"
        else
            log "❌ No se encontró template de configuración" "$RED"
            exit 1
        fi
        log "⚠️ IMPORTANTE: Edita release_settings.py con tus rutas si es necesario" "$PURPLE"
    else
        log "✅ release_settings.py ya existe" "$GREEN"
    fi
    
    # Crear directorio versions
    if [ ! -d "versions" ]; then
        log "📁 Creando directorio versions..."
        mkdir -p versions
        log "✅ Directorio versions creado" "$GREEN"
    else
        log "✅ Directorio versions ya existe" "$GREEN"
    fi
}

setup_virtual_environment() {
    log "🐍 Configurando entorno virtual de Python..." "$YELLOW"
    
    ENV_DIR="env/linux"
    if [[ "$IS_ORANGEPI" == true ]] || [[ "$FORCE_ORANGEPI" == true ]]; then
        ENV_DIR="env/orangepi_arm32"
    fi
    
    if [ ! -d "$ENV_DIR" ]; then
        log "🔧 Creando entorno virtual en $ENV_DIR..."
        $PYTHON_CMD -m venv "$ENV_DIR"
    fi
    
    # Activar entorno virtual
    source "$ENV_DIR/bin/activate"
    
    # Verificar si necesitamos instalar/actualizar dependencias
    LASTCHECK_FILE="$ENV_DIR/lastcheck"
    if [ ! -f "$LASTCHECK_FILE" ] || [ $(find "$LASTCHECK_FILE" -mtime +1 2>/dev/null | wc -l) -gt 0 ]; then
        log "📦 Instalando/actualizando dependencias Python..."
        pip install --upgrade pip setuptools wheel
        pip install --upgrade bottle cherrypy python-dateutil wsgi-request-logger simplejson pyinstaller
        
        # PostgreSQL es opcional
        pip install --upgrade psycopg2-binary || log "⚠️ psycopg2 no instalado (PostgreSQL no disponible)"
        
        # APSW es opcional pero recomendado
        if ! pip install --upgrade apsw 2>/dev/null; then
            log "⚠️ APSW no instalado (funciones SQLite avanzadas no disponibles)"
            log "   Esto es normal en algunos sistemas - SQLite básico funcionará"
        fi
        
        touch "$LASTCHECK_FILE"
        log "✅ Dependencias actualizadas" "$GREEN"
    else
        log "✅ Dependencias ya actualizadas (usando cache)" "$GREEN"
    fi
}

cleanup_build() {
    log "🧹 Limpiando archivos de compilación anteriores..." "$YELLOW"
    
    # Limpiar directorio principal
    rm -rf build dist *.spec
    rm -f ptracker-server-dist.py nsis_temp_files* ptracker.nsh
    
    # Limpiar directorio stracker
    if [ -d "stracker" ]; then
        cd stracker
        rm -rf build dist *.spec
        rm -f *.tgz
        cd ..
    fi
    
    log "✅ Limpieza completada" "$GREEN"
}

compile_project() {
    local version="$1"
    local test_mode="$2"
    local orangepi_mode="$3"
    
    log "🏗️ Iniciando compilación..." "$YELLOW"
    log "   Versión: $version"
    
    # Preparar argumentos
    local args=()
    
    if [[ "$test_mode" == true ]]; then
        args+=("--test_release_process")
        log "🧪 Modo de prueba activado" "$PURPLE"
    fi
    
    if [[ "$orangepi_mode" == true ]] || [[ "$IS_ORANGEPI" == true ]]; then
        args+=("--orangepi_arm32_only")
        log "🍊 Compilando para Orange Pi ARM32"
    else
        args+=("--linux_only")
        log "🐧 Compilando para Linux x86"
    fi
    
    args+=("$version")
    
    # Ejecutar compilación
    local start_time=$(date +%s)
    log "⏱️ Compilación iniciada: $(date '+%H:%M:%S')" "$CYAN"
    
    if $PYTHON_CMD create_release.py "${args[@]}"; then
        local end_time=$(date +%s)
        local duration=$((end_time - start_time))
        local minutes=$((duration / 60))
        local seconds=$((duration % 60))
        
        log "✅ Compilación exitosa en ${minutes}m ${seconds}s" "$GREEN"
        
        # Mostrar archivos generados
        if [ -d "versions" ] && [ "$(ls -A versions/)" ]; then
            log "📁 Archivos generados:" "$GREEN"
            for file in versions/*"$version"*; do
                if [ -f "$file" ]; then
                    local size=$(du -h "$file" | cut -f1)
                    log "   • $(basename "$file") ($size)"
                fi
            done
        fi
        
        return 0
    else
        log "❌ Error durante la compilación" "$RED"
        return 1
    fi
}

show_menu() {
    echo
    log "🎯 ¿Qué quieres compilar?" "$CYAN"
    echo "   [1] COMPILACIÓN ESTÁNDAR para Linux"
    echo "   [2] COMPILACIÓN para ORANGE PI ARM32"
    echo "   [3] COMPILACIÓN de PRUEBA (rápida)"
    echo "   [4] LIMPIAR y compilar"
    echo "   [5] Ver AYUDA"
    echo "   [0] Salir"
    echo
    
    read -p "Selecciona opción (0-5): " choice
    
    case $choice in
        1)
            compile_project "$VERSION" false false
            ;;
        2)
            FORCE_ORANGEPI=true
            setup_virtual_environment
            compile_project "$VERSION" false true
            ;;
        3)
            compile_project "test-version" true false
            ;;
        4)
            cleanup_build
            setup_virtual_environment
            compile_project "$VERSION" false false
            ;;
        5)
            show_help
            ;;
        0)
            log "👋 ¡Hasta luego!" "$CYAN"
            exit 0
            ;;
        *)
            log "❌ Opción inválida" "$RED"
            show_menu
            ;;
    esac
}

# ===================================================================
# PROGRAMA PRINCIPAL
# ===================================================================

# Procesar argumentos
CLEAN_MODE=false
TEST_MODE=false
FORCE_ORANGEPI=false

while [[ $# -gt 0 ]]; do
    case $1 in
        --clean)
            CLEAN_MODE=true
            shift
            ;;
        --test)
            TEST_MODE=true
            shift
            ;;
        --orangepi)
            FORCE_ORANGEPI=true
            shift
            ;;
        --help)
            show_help
            ;;
        *)
            if [[ ! "$1" =~ ^-- ]]; then
                VERSION="$1"
            fi
            shift
            ;;
    esac
done

# Mostrar banner
show_banner

log "🚀 SPTracker v4.0.1 - Compilador Automático Linux" "$CYAN"
log "📅 $(date '+%Y-%m-%d %H:%M:%S')"
log "📂 Directorio: $PWD"
log "📋 Log: $LOG_FILE"
log ""

# Ejecutar detecciones y configuraciones
detect_environment
check_python
check_dependencies
setup_project

# Limpiar si se solicita
if [[ "$CLEAN_MODE" == true ]]; then
    cleanup_build
fi

# Configurar entorno virtual
setup_virtual_environment

# Si hay argumentos específicos, compilar directamente
if [[ "$TEST_MODE" == true ]]; then
    compile_project "test-version" true false
elif [[ "$FORCE_ORANGEPI" == true ]]; then
    compile_project "$VERSION" false true
elif [[ "$#" -eq 0 ]] && [[ "$1" != "--"* ]]; then
    # Modo interactivo
    show_menu
else
    # Compilación estándar
    compile_project "$VERSION" false false
fi

log ""
log "🎉 ¡SCRIPT COMPLETADO!" "$GREEN"
log "📋 Log completo guardado en: $LOG_FILE"

if [[ "$TEST_MODE" != true ]]; then
    log "📁 Revisa la carpeta 'versions/' para los archivos generados"
fi
