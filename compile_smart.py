#!/usr/bin/env python3
# ===================================================================
# SPTracker v4.0.1 - COMPILADOR UNIVERSAL INTELIGENTE
# ===================================================================
# Funciona en cualquier plataforma - Detecta todo automáticamente
# ===================================================================

import os
import sys
import platform
import subprocess
import argparse
import datetime
import shutil
from pathlib import Path

class SmartCompiler:
    def __init__(self):
        self.system = platform.system().lower()
        self.machine = platform.machine().lower()
        self.is_wsl = self._detect_wsl()
        self.is_orangepi = self._detect_orangepi()
        self.python_cmd = self._find_python()
        self.log_file = f"compile_{datetime.datetime.now().strftime('%Y%m%d_%H%M')}.log"
        
    def _detect_wsl(self):
        """Detectar si estamos en WSL"""
        try:
            with open('/proc/version', 'r') as f:
                return 'microsoft' in f.read().lower() or 'wsl' in f.read().lower()
        except:
            return False
    
    def _detect_orangepi(self):
        """Detectar si estamos en Orange Pi"""
        if not self.machine.startswith('arm'):
            return False
        try:
            with open('/proc/cpuinfo', 'r') as f:
                return 'allwinner' in f.read().lower()
        except:
            return False
    
    def _find_python(self):
        """Encontrar comando Python válido"""
        candidates = ['python', 'python3', 'py']
        for cmd in candidates:
            try:
                result = subprocess.run([cmd, '--version'], 
                                      capture_output=True, text=True)
                if result.returncode == 0 and 'Python' in result.stdout:
                    return cmd
            except:
                continue
        return None
    
    def _cleanup_venv(self, venv_path):
        """Limpiar entorno virtual corrupto"""
        if os.path.exists(venv_path):
            try:
                self.log(f"🧹 Limpiando entorno virtual corrupto: {venv_path}", 'yellow')
                shutil.rmtree(venv_path)
                self.log("✅ Entorno virtual eliminado", 'green')
                return True
            except Exception as e:
                self.log(f"⚠️ Error al eliminar entorno virtual: {e}", 'yellow')
                return False
        return True
    
    def log(self, message, color_code=None):
        """Logging con colores y archivo"""
        timestamp = datetime.datetime.now().strftime('%H:%M:%S')
        log_message = f"[{timestamp}] {message}"
        
        # Colores ANSI
        colors = {
            'red': '\033[0;31m',
            'green': '\033[0;32m',
            'yellow': '\033[1;33m',
            'blue': '\033[0;34m',
            'cyan': '\033[0;36m',
            'purple': '\033[0;35m',
            'reset': '\033[0m'
        }
        
        if color_code and self.system != 'windows':
            print(f"{colors.get(color_code, '')}{log_message}{colors['reset']}")
        else:
            print(log_message)
        
        # Escribir al archivo de log
        with open(self.log_file, 'a', encoding='utf-8') as f:
            f.write(log_message + '\n')
    
    def show_banner(self):
        """Mostrar banner del compilador"""
        if self.system == 'windows':
            os.system('cls')
        else:
            os.system('clear')
        
        banner = """
 ░██████╗██████╗░████████╗██████╗░░█████╗░░█████╗░██╗░░██╗███████╗██████╗░
 ██╔════╝██╔══██╗╚══██╔══╝██╔══██╗██╔══██╗██╔══██╗██║░██╔╝██╔════╝██╔══██╗
 ╚█████╗░██████╔╝░░░██║░░░██████╔╝███████║██║░░╚═╝█████═╝░█████╗░░██████╔╝
 ░╚═══██╗██╔═══╝░░░░██║░░░██╔══██╗██╔══██║██║░░██╗██╔═██╗░██╔══╝░░██╔══██╗
 ██████╔╝██║░░░░░░░░██║░░░██║░░██║██║░░██║╚█████╔╝██║░╚██╗███████╗██║░░██║
 ╚═════╝░╚═╝░░░░░░░░╚═╝░░░╚═╝░░╚═╝╚═╝░░╚═╝░╚════╝░╚═╝░░╚═╝╚══════╝╚═╝░░╚═╝

      🏎️ COMPILADOR UNIVERSAL v4.0.1 - Sistema de Telemetría      
                        ⚡ DETECCIÓN AUTOMÁTICA ⚡
        """
        self.log(banner, 'cyan')
    
    def detect_environment(self):
        """Detectar entorno completo"""
        self.log("🔍 Detectando entorno de compilación...", 'yellow')
        
        # Sistema operativo
        if self.system == 'windows':
            self.log(f"  • OS: Windows {platform.release()}")
        elif self.is_wsl:
            self.log("  • OS: WSL (Windows Subsystem for Linux)", 'cyan')
        elif self.system == 'linux':
            self.log("  • OS: Linux")
        elif self.system == 'darwin':
            self.log("  • OS: macOS")
        
        # Arquitectura
        self.log(f"  • Arquitectura: {self.machine}")
        
        # Dispositivo especial
        if self.is_orangepi:
            self.log("  • Dispositivo: Orange Pi detectado", 'green')
        
        # Python
        if self.python_cmd:
            try:
                result = subprocess.run([self.python_cmd, '--version'], 
                                      capture_output=True, text=True)
                self.log(f"  • Python: {result.stdout.strip()} ({self.python_cmd})", 'green')
            except:
                self.log("❌ Error verificando versión de Python", 'red')
                return False
        else:
            self.log("❌ Python no encontrado", 'red')
            return False
        
        return True
    
    def check_project_setup(self):
        """Verificar configuración del proyecto"""
        self.log("📋 Verificando configuración del proyecto...", 'yellow')
        
        # Verificar directorio correcto
        if not Path('create_release.py').exists():
            self.log("❌ No estás en el directorio correcto de SPTracker", 'red')
            self.log("   Ejecuta desde el directorio que contiene create_release.py")
            return False
        
        # Verificar/crear configuración
        if not Path('release_settings.py').exists():
            self.log("📝 Creando configuración desde template...")
            templates = ['release_settings_ES.py.in', 'release_settings.py.in']
            template_found = False
            
            for template in templates:
                if Path(template).exists():
                    shutil.copy(template, 'release_settings.py')
                    self.log(f"✅ Configuración creada desde {template}", 'green')
                    template_found = True
                    break
            
            if not template_found:
                self.log("❌ No se encontró template de configuración", 'red')
                return False
            
            self.log("⚠️ IMPORTANTE: Edita release_settings.py con tus rutas", 'purple')
        else:
            self.log("✅ release_settings.py ya existe", 'green')
        
        # Crear directorio versions
        versions_dir = Path('versions')
        if not versions_dir.exists():
            versions_dir.mkdir()
            self.log("✅ Directorio versions creado", 'green')
        
        return True
    
    def detect_ac_installation(self):
        """Detectar instalación de Assetto Corsa (solo Windows)"""
        if self.system != 'windows':
            return True
        
        self.log("🔍 Buscando Assetto Corsa...", 'yellow')
        
        ac_paths = [
            r"C:\Program Files (x86)\Steam\steamapps\common\assettocorsa",
            r"C:\Program Files\Epic Games\AssettoCorsaCompetizione",
            r"D:\Games\Assetto Corsa",
            r"E:\Games\Assetto Corsa"
        ]
        
        for path in ac_paths:
            ac_path = Path(path)
            if (ac_path / 'apps' / 'python' / 'system').exists():
                self.log(f"  • Assetto Corsa: {path}", 'green')
                return True
        
        self.log("⚠️ Assetto Corsa no detectado automáticamente", 'yellow')
        self.log("   Verifica la ruta en release_settings.py")
        return True  # No es crítico
    
    def detect_nsis(self):
        """Detectar NSIS (solo Windows)"""
        if self.system != 'windows':
            return True
        
        nsis_path = Path(r"C:\Program Files (x86)\NSIS\makensis.exe")
        if nsis_path.exists():
            self.log("  • NSIS: Encontrado", 'green')
        else:
            self.log("⚠️ NSIS no encontrado - Solo se crearán archivos ZIP", 'yellow')
        
        return True
    
    def compile_project(self, version, options):
        """Ejecutar compilación"""
        self.log("🏗️ Iniciando compilación...", 'yellow')
        self.log(f"   Versión: {version}")
        
        # Preparar argumentos
        args = [self.python_cmd, 'create_release.py']
        
        if options.test:
            args.append('--test_release_process')
            self.log("🧪 Modo de prueba activado", 'purple')
        
        if options.client_only:
            args.append('--ptracker_only')
            self.log("🎮 Compilando solo cliente")
        elif options.server_only:
            args.append('--stracker_only')
            self.log("🌐 Compilando solo servidor")
        
        if self.is_orangepi or options.orangepi:
            args.append('--orangepi_arm32_only')
            self.log("🍊 Compilando para Orange Pi ARM32")
        elif self.system == 'windows' and not self.is_wsl:
            args.append('--windows_only')
            self.log("🪟 Compilando para Windows")
        elif self.system == 'linux' or self.is_wsl:
            args.append('--linux_only')
            self.log("🐧 Compilando para Linux")
        
        args.append(version)
          # Ejecutar compilación
        start_time = datetime.datetime.now()
        self.log(f"⏱️ Compilación iniciada: {start_time.strftime('%H:%M:%S')}", 'cyan')
        
        max_retries = 2
        for attempt in range(max_retries):
            try:
                result = subprocess.run(args, check=True, capture_output=True, text=True)
                
                end_time = datetime.datetime.now()
                duration = end_time - start_time
                minutes = duration.total_seconds() // 60
                seconds = duration.total_seconds() % 60
                
                self.log(f"✅ Compilación exitosa en {int(minutes)}m {int(seconds)}s", 'green')
                
                # Mostrar archivos generados
                self._show_generated_files(version)
                return True
                
            except subprocess.CalledProcessError as e:
                # Detectar errores específicos del entorno virtual
                error_output = e.stderr or e.stdout or ""
                
                if ("Permission denied" in error_output or 
                    "env/windows" in error_output or
                    "virtualenv" in error_output or
                    "venv" in error_output) and attempt < max_retries - 1:
                    
                    self.log(f"🔧 Intento {attempt + 1}: Error de entorno virtual detectado", 'yellow')
                    self.log("🧹 Limpiando entorno virtual corrupto...", 'yellow')
                    
                    # Limpiar entorno virtual corrupto
                    venv_paths = ["env/windows", "env\\windows"]
                    for venv_path in venv_paths:
                        if self._cleanup_venv(venv_path):
                            break
                    
                    self.log(f"🔄 Reintentando compilación (intento {attempt + 2})...", 'cyan')
                    continue
                else:
                    self.log(f"❌ Error durante la compilación (código: {e.returncode})", 'red')
                    if error_output:
                        self.log(f"💬 Detalles del error: {error_output[:200]}...", 'red')
                    return False
                    
            except Exception as e:
                self.log(f"💥 Error inesperado: {str(e)}", 'red')
                return False
        
        return False
    
    def _show_generated_files(self, version):
        """Mostrar archivos generados"""
        versions_dir = Path('versions')
        if versions_dir.exists():
            files = list(versions_dir.glob(f'*{version}*'))
            if files:
                self.log("📁 Archivos generados:", 'green')
                for file in files:
                    size_mb = file.stat().st_size / (1024 * 1024)
                    self.log(f"   • {file.name} ({size_mb:.1f} MB)")
    
    def cleanup(self):
        """Limpiar archivos temporales"""
        self.log("🧹 Limpiando archivos temporales...", 'yellow')
        
        cleanup_items = [
            'build', 'dist', '*.spec', 'ptracker-server-dist.py',
            'nsis_temp_files*', 'ptracker.nsh'
        ]
        
        for pattern in cleanup_items:
            for item in Path('.').glob(pattern):
                if item.is_dir():
                    shutil.rmtree(item, ignore_errors=True)
                else:
                    item.unlink(missing_ok=True)
                self.log(f"  • Eliminado: {item}")
        
        # Limpiar directorio stracker
        stracker_dir = Path('stracker')
        if stracker_dir.exists():
            for pattern in ['build', 'dist', '*.spec']:
                for item in stracker_dir.glob(pattern):
                    if item.is_dir():
                        shutil.rmtree(item, ignore_errors=True)
                    else:
                        item.unlink(missing_ok=True)
                    self.log(f"  • Eliminado: stracker/{item.name}")
        
        self.log("✅ Limpieza completada", 'green')

def main():
    parser = argparse.ArgumentParser(
        description='SPTracker v4.0.1 - Compilador Universal Inteligente'
    )
    parser.add_argument('version', nargs='?', 
                       default=f"dev-{datetime.datetime.now().strftime('%Y%m%d-%H%M')}",
                       help='Versión a compilar')
    parser.add_argument('--test', action='store_true',
                       help='Modo de prueba (no crea archivos finales)')
    parser.add_argument('--clean', action='store_true',
                       help='Limpiar antes de compilar')
    parser.add_argument('--client-only', action='store_true',
                       help='Compilar solo cliente (ptracker)')
    parser.add_argument('--server-only', action='store_true',
                       help='Compilar solo servidor (stracker)')
    parser.add_argument('--orangepi', action='store_true',
                       help='Forzar compilación para Orange Pi ARM32')
    parser.add_argument('--silent', action='store_true',
                       help='Modo silencioso (sin banner)')
    
    args = parser.parse_args()
    
    # Crear compilador
    compiler = SmartCompiler()
    
    # Mostrar banner
    if not args.silent:
        compiler.show_banner()
    
    compiler.log("🚀 SPTracker v4.0.1 - Compilador Universal", 'cyan')
    compiler.log(f"📅 {datetime.datetime.now().strftime('%Y-%m-%d %H:%M:%S')}")
    compiler.log(f"📂 Directorio: {Path.cwd()}")
    compiler.log(f"📋 Log: {compiler.log_file}")
    compiler.log("")
    
    try:
        # Detectar entorno
        if not compiler.detect_environment():
            return 1
        
        # Verificar proyecto
        if not compiler.check_project_setup():
            return 1
        
        # Verificaciones adicionales
        compiler.detect_ac_installation()
        compiler.detect_nsis()
        
        # Limpiar si se solicita
        if args.clean:
            compiler.cleanup()
        
        # Compilar
        success = compiler.compile_project(args.version, args)
        
        if success:
            compiler.log("")
            compiler.log("🎉 ¡COMPILACIÓN COMPLETADA CON ÉXITO!", 'green')
            compiler.log("📁 Revisa la carpeta 'versions/' para los archivos generados")
            compiler.log(f"📋 Log completo guardado en: {compiler.log_file}")
            return 0
        else:
            compiler.log("💥 COMPILACIÓN FALLIDA", 'red')
            compiler.log(f"📋 Revisa el log para más detalles: {compiler.log_file}")
            return 1
            
    except KeyboardInterrupt:
        compiler.log("\n🛑 Compilación cancelada por el usuario", 'yellow')
        return 1
    except Exception as e:
        compiler.log(f"💥 ERROR CRÍTICO: {str(e)}", 'red')
        compiler.log(f"📋 Log guardado en: {compiler.log_file}")
        return 1

if __name__ == '__main__':
    sys.exit(main())
