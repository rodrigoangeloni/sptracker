#!/bin/bash

# ===================================================================
# SPTracker v4.0.1 - Compilación Automática para Linux
# ===================================================================
# Este script compila automáticamente SPTracker para Linux x86_64
# Genera: stracker-V4.0.1-linux.tgz
# Compatible con: Ubuntu, Debian, CentOS, RHEL
# ===================================================================

set -e  # Salir en caso de error

# Colores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Función para mostrar banner
show_banner() {
    echo -e "${CYAN}"
    echo "╔══════════════════════════════════════════════════════════════════╗"
    echo "║                 SPTracker v4.0.1 - Linux Build                  ║"
    echo "║                      🐧  Server Edition                          ║"
    echo "╚══════════════════════════════════════════════════════════════════╝"
    echo -e "${NC}"
}

# Función para logging
log_info() {
    echo -e "${BLUE}ℹ️  $1${NC}"
}

log_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

log_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

log_error() {
    echo -e "${RED}❌ $1${NC}"
}

# Función para verificar requisitos
check_prerequisites() {
    log_info "Verificando requisitos..."
    
    # Verificar que estamos en el directorio correcto
    if [[ ! -f "release_settings.py" ]]; then
        log_error "No se encuentra release_settings.py"
        log_error "Ejecuta este script desde el directorio raíz de SPTracker"
        exit 1
    fi
    
    # Verificar Python
    if ! command -v python3 &> /dev/null; then
        log_error "Python 3 no está instalado"
        log_error "Instala Python 3: sudo apt-get install python3 python3-pip"
        exit 1
    fi
    
    # Verificar entorno virtual
    if [[ ! -d "venv_wsl" ]]; then
        log_warning "No se encuentra entorno virtual, creando..."
        python3 -m venv venv_wsl
        source venv_wsl/bin/activate
        pip install --upgrade pip
        pip install pyinstaller bottle cherrypy python-dateutil simplejson
    fi
    
    log_success "Requisitos verificados"
}

# Función para limpiar archivos temporales
cleanup_build() {
    log_info "Limpiando archivos temporales..."
    
    cd stracker 2>/dev/null || {
        log_error "No se encuentra el directorio stracker"
        exit 1
    }
    
    rm -rf dist build *.spec 2>/dev/null || true
    rm -f stracker_linux_x86.tgz 2>/dev/null || true
    
    cd ..
    log_success "Limpieza completada"
}

# Función principal de compilación
build_stracker() {
    log_info "Iniciando compilación de stracker para Linux..."
    
    # Configurar entorno
    export PYTHONPATH="$PWD:$PWD/stracker/externals"
    
    # Activar entorno virtual
    source venv_wsl/bin/activate
    
    # Mostrar información del entorno
    log_info "Python: $(python3 --version)"
    log_info "PyInstaller: $(pyinstaller --version)"
    
    # Ir al directorio de stracker
    cd stracker
    
    # Timestamp para logs
    TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
    LOG_FILE="../build_log_linux_${TIMESTAMP}.txt"
    
    log_info "Log: build_log_linux_${TIMESTAMP}.txt"
    
    # Ejecutar PyInstaller
    log_info "Ejecutando PyInstaller..."
    
    pyinstaller --clean -y -s \
        --exclude-module http_templates \
        --exclude-module PySide6 \
        --exclude-module PySide2 \
        --exclude-module PyQt5 \
        --exclude-module PyQt6 \
        --exclude-module tkinter \
        --exclude-module matplotlib \
        --exclude-module PIL \
        --exclude-module numpy \
        --exclude-module scipy \
        --distpath dist \
        --workpath build \
        stracker.py > "$LOG_FILE" 2>&1
    
    if [[ $? -eq 0 ]]; then
        log_success "Compilación exitosa!"
        
        # Empaquetar resultado
        log_info "Empaquetando stracker_linux_x86..."
        mv dist/stracker dist/stracker_linux_x86
        
        # Crear tarball
        tar czf stracker_linux_x86.tgz -C dist stracker_linux_x86
        
        # Crear directorio versions si no existe
        mkdir -p ../versions
        
        # Copiar a versions con nombre versionado
        cp stracker_linux_x86.tgz "../versions/stracker-V4.0.1-linux.tgz"
        
        # Mostrar resultados
        log_success "¡Compilación completada!"
        echo
        echo -e "${GREEN}📦 Archivos generados:${NC}"
        
        if [[ -f "../versions/stracker-V4.0.1-linux.tgz" ]]; then
            SIZE=$(du -h "../versions/stracker-V4.0.1-linux.tgz" | cut -f1)
            echo -e "${GREEN}   ✓ stracker-V4.0.1-linux.tgz - $SIZE${NC}"
        fi
        
        echo
        echo -e "${BLUE}📂 Ubicación: $(realpath ../versions/)${NC}"
        echo -e "${BLUE}📝 Log detallado: $(realpath $LOG_FILE)${NC}"
        echo
        log_success "SPTracker v4.0.1 Server está listo para Linux!"
        
        # Verificar el archivo
        if command -v file &> /dev/null; then
            echo
            log_info "Verificación del archivo:"
            file "../versions/stracker-V4.0.1-linux.tgz"
        fi
        
    else
        log_error "Error en la compilación"
        log_error "Revisa el log: $(realpath $LOG_FILE)"
        exit 1
    fi
    
    # Limpiar archivos temporales
    rm -rf dist build
    
    cd ..
}

# Función para mostrar ayuda
show_help() {
    echo "SPTracker v4.0.1 - Script de compilación para Linux"
    echo
    echo "USO:"
    echo "  ./build_linux.sh            # Compilación estándar"
    echo "  ./build_linux.sh --help     # Mostrar esta ayuda"
    echo "  ./build_linux.sh --clean    # Limpiar y compilar"
    echo
    echo "SALIDA:"
    echo "  • stracker-V4.0.1-linux.tgz - Servidor web para Linux x86_64"
    echo
    echo "REQUISITOS:"
    echo "  • Python 3.7+"
    echo "  • pip3"
    echo "  • Dependencias: pyinstaller, bottle, cherrypy"
    echo
}

# ===================================================================
# SCRIPT PRINCIPAL
# ===================================================================

# Procesar argumentos
case "${1:-}" in
    --help|-h)
        show_help
        exit 0
        ;;
    --clean)
        CLEAN_BUILD=true
        ;;
esac

# Mostrar banner
show_banner

# Verificar requisitos
check_prerequisites

# Limpiar si se solicita
if [[ "${CLEAN_BUILD:-false}" == "true" ]]; then
    cleanup_build
fi

# Ejecutar compilación
START_TIME=$(date +%s)
build_stracker
END_TIME=$(date +%s)

# Calcular tiempo transcurrido
DURATION=$((END_TIME - START_TIME))
MINUTES=$((DURATION / 60))
SECONDS=$((DURATION % 60))

echo
log_info "Tiempo de compilación: ${MINUTES}m ${SECONDS}s"
echo
echo "🎉 ¡Compilación completada exitosamente!"
