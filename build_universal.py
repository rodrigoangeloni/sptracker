#!/usr/bin/env python3
"""
SPTracker v4.0.1 - Compilador Universal
========================================
Script Python multiplataforma para compilar SPTracker automáticamente
Detecta el sistema operativo y ejecuta la compilación correspondiente
"""

import os
import sys
import platform
import subprocess
import argparse
import time
from pathlib import Path

# Colores ANSI para terminal
class Colors:
    RED = '\033[91m'
    GREEN = '\033[92m'
    YELLOW = '\033[93m'
    BLUE = '\033[94m'
    MAGENTA = '\033[95m'
    CYAN = '\033[96m'
    WHITE = '\033[97m'
    BOLD = '\033[1m'
    END = '\033[0m'

def print_banner():
    """Mostrar banner del programa"""
    banner = f"""
{Colors.CYAN}{Colors.BOLD}
╔══════════════════════════════════════════════════════════════════╗
║                 SPTracker v4.0.1 - Universal Builder            ║
║                      🌍  Multi-Platform Compiler                 ║
╚══════════════════════════════════════════════════════════════════╝
{Colors.END}
"""
    print(banner)

def log_info(message):
    """Log información"""
    print(f"{Colors.BLUE}ℹ️  {message}{Colors.END}")

def log_success(message):
    """Log éxito"""
    print(f"{Colors.GREEN}✅ {message}{Colors.END}")

def log_warning(message):
    """Log advertencia"""
    print(f"{Colors.YELLOW}⚠️  {message}{Colors.END}")

def log_error(message):
    """Log error"""
    print(f"{Colors.RED}❌ {message}{Colors.END}")

def detect_platform():
    """Detectar plataforma del sistema"""
    system = platform.system().lower()
    
    if system == "windows":
        return "windows"
    elif system == "linux":
        # Verificar si estamos en WSL
        try:
            with open('/proc/version', 'r') as f:
                if 'microsoft' in f.read().lower():
                    return "wsl"
            return "linux"
        except:
            return "linux"
    elif system == "darwin":
        return "macos"
    else:
        return "unknown"

def check_prerequisites():
    """Verificar requisitos básicos"""
    log_info("Verificando requisitos...")
    
    # Verificar directorio correcto
    if not Path("release_settings.py").exists():
        log_error("No se encuentra release_settings.py")
        log_error("Ejecuta este script desde el directorio raíz de SPTracker")
        return False
    
    # Verificar Python
    python_version = sys.version_info
    if python_version.major < 3 or (python_version.major == 3 and python_version.minor < 7):
        log_error(f"Se requiere Python 3.7+, encontrado: {python_version.major}.{python_version.minor}")
        return False
    
    log_success("Requisitos básicos verificados")
    return True

def build_windows(target="all"):
    """Compilar para Windows"""
    log_info("Iniciando compilación para Windows...")
    
    # Verificar entorno virtual
    venv_path = Path("env/windows")
    if not venv_path.exists():
        log_error("No se encuentra entorno virtual de Windows")
        log_error("Ejecuta primero: .\\inicio_rapido.ps1")
        return False
    
    # Preparar argumentos
    args = ["python", "create_release.py"]
    
    if target == "ptracker":
        args.append("--ptracker_only")
    elif target == "stracker":
        args.append("--stracker_only")
    else:
        args.append("--windows_only")
    
    # Activar entorno virtual y ejecutar
    activate_script = venv_path / "Scripts" / "activate.bat"
    
    try:
        # En Windows, usar el entorno virtual
        env = os.environ.copy()
        env["VIRTUAL_ENV"] = str(venv_path)
        env["PATH"] = str(venv_path / "Scripts") + os.pathsep + env["PATH"]
        
        result = subprocess.run(args, cwd=Path.cwd(), env=env, 
                              capture_output=True, text=True)
        
        if result.returncode == 0:
            log_success("Compilación Windows exitosa!")
            return True
        else:
            log_error(f"Error en compilación: {result.stderr}")
            return False
            
    except Exception as e:
        log_error(f"Error ejecutando compilación: {e}")
        return False

def build_linux(target="stracker"):
    """Compilar para Linux/WSL"""
    log_info("Iniciando compilación para Linux...")
    
    # Usar el script de Linux
    script_path = Path("build_linux.sh")
    if not script_path.exists():
        log_error("No se encuentra build_linux.sh")
        return False
    
    try:
        # Hacer ejecutable
        os.chmod(script_path, 0o755)
        
        # Ejecutar script
        result = subprocess.run(["bash", str(script_path)], 
                              capture_output=True, text=True)
        
        if result.returncode == 0:
            log_success("Compilación Linux exitosa!")
            return True
        else:
            log_error(f"Error en compilación: {result.stderr}")
            return False
            
    except Exception as e:
        log_error(f"Error ejecutando compilación: {e}")
        return False

def build_all_platforms():
    """Compilar para todas las plataformas disponibles"""
    log_info("Iniciando compilación multiplataforma...")
    
    platform_type = detect_platform()
    success_count = 0
    
    if platform_type == "windows":
        log_info("🪟 Compilando para Windows...")
        if build_windows():
            success_count += 1
        
        # También intentar WSL si está disponible
        try:
            result = subprocess.run(["wsl", "--list", "--quiet"], 
                                  capture_output=True, text=True)
            if result.returncode == 0 and result.stdout.strip():
                log_info("🐧 WSL detectado, compilando para Linux...")
                wsl_result = subprocess.run([
                    "wsl", "--", "bash", "-c", 
                    f"cd {Path.cwd().as_posix()} && ./build_linux.sh"
                ], capture_output=True, text=True)
                
                if wsl_result.returncode == 0:
                    success_count += 1
                    log_success("Compilación WSL exitosa!")
                else:
                    log_warning("Error en compilación WSL")
        except:
            log_warning("WSL no disponible")
    
    elif platform_type in ["linux", "wsl"]:
        log_info("🐧 Compilando para Linux...")
        if build_linux():
            success_count += 1
    
    return success_count

def show_results():
    """Mostrar resultados de compilación"""
    versions_dir = Path("versions")
    if not versions_dir.exists():
        log_warning("No se encontró directorio versions/")
        return
    
    log_success("📦 Archivos generados:")
    
    for file_path in sorted(versions_dir.glob("*")):
        if file_path.is_file():
            size_mb = file_path.stat().st_size / (1024 * 1024)
            print(f"   ✓ {file_path.name} - {size_mb:.1f} MB")
    
    print(f"\n📂 Ubicación: {versions_dir.absolute()}")

def main():
    """Función principal"""
    parser = argparse.ArgumentParser(
        description="SPTracker v4.0.1 - Compilador Universal",
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog="""
Ejemplos:
  python build_universal.py                    # Compilación automática
  python build_universal.py --windows          # Solo Windows
  python build_universal.py --linux            # Solo Linux
  python build_universal.py --ptracker         # Solo cliente ptracker
  python build_universal.py --stracker         # Solo servidor stracker
  python build_universal.py --all              # Todas las plataformas
        """
    )
    
    parser.add_argument("--windows", action="store_true", 
                       help="Compilar solo para Windows")
    parser.add_argument("--linux", action="store_true", 
                       help="Compilar solo para Linux")
    parser.add_argument("--ptracker", action="store_true", 
                       help="Compilar solo cliente ptracker")
    parser.add_argument("--stracker", action="store_true", 
                       help="Compilar solo servidor stracker")
    parser.add_argument("--all", action="store_true", 
                       help="Compilar para todas las plataformas")
    parser.add_argument("--clean", action="store_true", 
                       help="Limpiar antes de compilar")
    
    args = parser.parse_args()
    
    # Mostrar banner
    print_banner()
    
    # Verificar requisitos
    if not check_prerequisites():
        sys.exit(1)
    
    # Detectar plataforma
    platform_type = detect_platform()
    log_info(f"Plataforma detectada: {platform_type}")
    
    # Determinar qué compilar
    start_time = time.time()
    
    if args.all:
        success_count = build_all_platforms()
    elif args.windows:
        target = "ptracker" if args.ptracker else "stracker" if args.stracker else "all"
        success_count = 1 if build_windows(target) else 0
    elif args.linux:
        success_count = 1 if build_linux() else 0
    else:
        # Compilación automática según plataforma
        if platform_type == "windows":
            target = "ptracker" if args.ptracker else "stracker" if args.stracker else "all"
            success_count = 1 if build_windows(target) else 0
        else:
            success_count = 1 if build_linux() else 0
    
    # Mostrar resultados
    build_time = time.time() - start_time
    
    print(f"\n⏱️  Tiempo total: {build_time:.1f} segundos")
    
    if success_count > 0:
        show_results()
        print(f"\n🎉 ¡Compilación completada exitosamente! ({success_count} plataforma(s))")
    else:
        log_error("Error en la compilación")
        sys.exit(1)

if __name__ == "__main__":
    main()
