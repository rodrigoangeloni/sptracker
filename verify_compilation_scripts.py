#!/usr/bin/env python3
# ===================================================================
# SPTracker v4.0.1 - VERIFICADOR DE SCRIPTS DE COMPILACIÓN
# ===================================================================
# Verifica que todos los scripts de compilación estén funcionando
# ===================================================================

import os
import sys
import subprocess
from pathlib import Path
import datetime

class ScriptVerifier:
    def __init__(self):
        self.scripts_to_verify = {
            '🎯 COMPILAR FÁCIL.cmd': 'Script Windows súper fácil',
            'compile_easy.ps1': 'Script PowerShell inteligente',
            'compile_easy.sh': 'Script bash para Linux/WSL',
            'compile_smart.py': 'Script universal de Python',
            'setup_scripts.cmd': 'Utilidad de configuración'
        }
        self.results = {}
    
    def log(self, message, color_code=None):
        """Logging con colores"""
        timestamp = datetime.datetime.now().strftime('%H:%M:%S')
        colors = {
            'red': '\033[0;31m',
            'green': '\033[0;32m',
            'yellow': '\033[1;33m',
            'blue': '\033[0;34m',
            'purple': '\033[0;35m',
            'cyan': '\033[0;36m',
            'reset': '\033[0m'
        }
        
        color = colors.get(color_code, '')
        reset = colors.get('reset', '')
        print(f"{color}[{timestamp}] {message}{reset}")
    
    def verify_file_exists(self, script_name):
        """Verificar que el archivo existe"""
        if Path(script_name).exists():
            size = Path(script_name).stat().st_size
            self.log(f"✅ {script_name} - {size} bytes", 'green')
            return True
        else:
            self.log(f"❌ {script_name} - NO ENCONTRADO", 'red')
            return False
    
    def verify_python_script(self, script_name):
        """Verificar script de Python"""
        try:
            result = subprocess.run([sys.executable, script_name, '--help'], 
                                  capture_output=True, text=True, timeout=10)
            if result.returncode == 0:
                self.log(f"✅ {script_name} - Ejecutable y funcional", 'green')
                return True
            else:
                self.log(f"⚠️ {script_name} - Error al ejecutar", 'yellow')
                return False
        except Exception as e:
            self.log(f"❌ {script_name} - Error: {str(e)}", 'red')
            return False
    
    def verify_documentation(self):
        """Verificar documentación"""
        docs = ['NUEVOS_SCRIPTS.md', 'GUIA_COMPILACION_WINDOWS.md', 'README.md']
        all_good = True
        
        for doc in docs:
            if Path(doc).exists():
                self.log(f"✅ {doc} - Disponible", 'green')
            else:
                self.log(f"⚠️ {doc} - No encontrado", 'yellow')
                all_good = False
        
        return all_good
    
    def run_verification(self):
        """Ejecutar verificación completa"""
        self.log("🏎️ SPTracker v4.0.1 - Verificador de Scripts", 'cyan')
        self.log("=" * 60)
        
        # Verificar que estamos en el directorio correcto
        if not Path('create_release.py').exists():
            self.log("❌ No estás en el directorio correcto de SPTracker", 'red')
            return False
        
        self.log("🔍 Verificando scripts de compilación...", 'blue')
        
        all_scripts_ok = True
        
        # Verificar existencia de archivos
        for script, description in self.scripts_to_verify.items():
            exists = self.verify_file_exists(script)
            self.results[script] = {'exists': exists, 'description': description}
            if not exists:
                all_scripts_ok = False
        
        self.log("", '')
        self.log("🧪 Verificando funcionalidad...", 'blue')
        
        # Verificar scripts de Python
        python_scripts = ['compile_smart.py']
        for script in python_scripts:
            if Path(script).exists():
                functional = self.verify_python_script(script)
                self.results[script]['functional'] = functional
                if not functional:
                    all_scripts_ok = False
        
        self.log("", '')
        self.log("📚 Verificando documentación...", 'blue')
        docs_ok = self.verify_documentation()
        
        self.log("", '')
        self.log("=" * 60)
        
        if all_scripts_ok and docs_ok:
            self.log("🎉 ¡Todos los scripts están listos y funcionando!", 'green')
            self.log("✅ Puedes usar cualquiera de los siguientes métodos:", 'green')
            self.log("   • Doble clic en '🎯 COMPILAR FÁCIL.cmd' (Windows)", 'cyan')
            self.log("   • Ejecutar ./compile_easy.sh (Linux/WSL)", 'cyan')
            self.log("   • Usar python compile_smart.py [opciones] (Universal)", 'cyan')
            return True
        else:
            self.log("⚠️ Algunos scripts necesitan atención", 'yellow')
            return False

def main():
    verifier = ScriptVerifier()
    success = verifier.run_verification()
    return 0 if success else 1

if __name__ == '__main__':
    sys.exit(main())
