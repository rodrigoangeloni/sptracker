# 🖥️ Guía Completa de Compilación para Windows

Esta guía te llevará paso a paso para compilar SPTracker completamente desde código fuente en Windows.

## 📋 Requisitos Previos

### 🔧 Software Obligatorio

**1. Python 3.7 o superior**
- **Descargar**: https://www.python.org/downloads/
- **Verificar instalación**:
  ```powershell
  python --version
  # Debe mostrar: Python 3.x.x
  ```

**2. Assetto Corsa**
- **Necesario**: El juego debe estar instalado
- **Ubicaciones comunes**:
  - Steam: `C:\Program Files (x86)\Steam\steamapps\common\assettocorsa`
  - Epic Games: `C:\Program Files\Epic Games\AssettoCorsaCompetizione`
- **Por qué es necesario**: El compilador necesita acceso a las librerías de Python de AC

**3. NSIS (Nullsoft Scriptable Install System)**
- **Descargar**: https://nsis.sourceforge.io/Download
- **Instalar en**: `C:\Program Files (x86)\NSIS\` (ubicación por defecto)
- **Para qué**: Crear el instalador .exe de ptracker

**4. Visual C++ Build Tools**
- **Opción 1**: Visual Studio Community (gratuito)
  - Descargar: https://visualstudio.microsoft.com/vs/community/
  - Instalar con "Desktop development with C++"
- **Opción 2**: Build Tools standalone
  - Descargar: https://visualstudio.microsoft.com/visual-cpp-build-tools/
- **Para qué**: Compilar dependencias nativas de Python (apsw, psycopg2)

**5. Git**
- **Descargar**: https://git-scm.com/download/win
- **Verificar**:
  ```powershell
  git --version
  ```

## ⚙️ Configuración del Proyecto

### 1. Crear archivo de configuración

```powershell
# Copiar template de configuración
copy release_settings.py.in release_settings.py
```

### 2. Editar release_settings.py

Abre `release_settings.py` y configura:

```python
# ==================================================
# CONFIGURACIÓN PARA COMPILACIÓN EN WINDOWS
# ==================================================

# Ruta donde está instalado Assetto Corsa
# ¡IMPORTANTE! Usar barras invertidas dobles (\\) o r""
ac_install_dir = r"C:\Program Files (x86)\Steam\steamapps\common\assettocorsa"

# Ruta de git (normalmente auto-detectada)
git = r"git"

# Para builds remotos de Linux (opcional, dejar None si no usas)
REMOTE_BUILD_CMD = None
REMOTE_COPY_RESULT = None

# ==================================================
# EJEMPLOS DE RUTAS COMUNES DE ASSETTO CORSA:
# ==================================================
# Steam (más común):
# ac_install_dir = r"C:\Program Files (x86)\Steam\steamapps\common\assettocorsa"
#
# Epic Games Store:
# ac_install_dir = r"C:\Program Files\Epic Games\AssettoCorsaCompetizione"
#
# Instalación personalizada:
# ac_install_dir = r"D:\Games\Assetto Corsa"
```

### 3. Verificar estructura de directorios

Tu proyecto debe verse así:
```
sptracker/
├── release_settings.py     ← Tu configuración (creado arriba)
├── create_release.py       ← Script principal de compilación
├── ptracker.py            ← Código fuente del cliente
├── stracker/              ← Código fuente del servidor
├── versions/              ← Se crea automáticamente para outputs
├── env/                   ← Entorno virtual (se crea automáticamente)
└── .gitignore             ← Archivos ignorados por git
```

## 🚀 Proceso de Compilación

### Compilación Completa (Recomendada para primera vez)

```powershell
# Navegar al directorio del proyecto
cd "c:\Users\profesor\Documents\Phyton Proyectos\sptracker"

# Compilar versión completa (ptracker + stracker)
python create_release.py 1.0.0
```

### Opciones de Compilación Específicas

**Solo Windows (sin compilar Linux)**
```powershell
python create_release.py --windows_only 1.0.0
```

**Solo el servidor (stracker)**
```powershell
python create_release.py --stracker_only --windows_only 1.0.0
```

**Solo el cliente (ptracker)**
```powershell
python create_release.py --ptracker_only 1.0.0
```

**Modo de prueba (sin crear release real)**
```powershell
python create_release.py --test_release_process --windows_only test-version
```

### Compilación Paso a Paso (Debugging)

Si tienes problemas, puedes usar estos comandos para entender mejor:

```powershell
# 1. Verificar configuración básica
python -c "import sys; print('Python:', sys.version)"
git --version

# 2. Verificar que AC está en la ruta correcta
dir "C:\Program Files (x86)\Steam\steamapps\common\assettocorsa\apps\python\system"

# 3. Verificar que NSIS está instalado
dir "C:\Program Files (x86)\NSIS\makensis.exe"

# 4. Probar compilación en modo test
python create_release.py --test_release_process --windows_only test-version
```

## 🔄 Lo que Sucede Durante la Compilación

### Fase 1: Validación Inicial (30 segundos)
- ✅ Verifica que git esté limpio (sin cambios sin commitear)
- ✅ Valida que Assetto Corsa esté instalado en la ruta especificada
- ✅ Comprueba que NSIS esté disponible

### Fase 2: Preparación del Entorno (2-5 minutos)
- 🔧 Crea entorno virtual en `env/windows/`
- 📦 Instala automáticamente las dependencias:
  - **bottle, cherrypy** - Framework web para stracker
  - **psycopg2** - Soporte para base de datos PostgreSQL
  - **python-dateutil, simplejson** - Utilidades
  - **pyinstaller** - Para crear ejecutables
  - **PySide2** - Interfaz gráfica para ptracker
  - **apsw** - SQLite avanzado

### Fase 3: Compilación ptracker (3-8 minutos)
- 📝 Actualiza números de versión en archivos fuente
- 🔒 Genera `ptracker-server-dist.py` con checksums de protección
- ⚙️ Compila `ptracker.exe` usando PyInstaller
- 📦 Crea instalador `ptracker-V1.0.0.exe` con NSIS

### Fase 4: Compilación stracker (2-5 minutos)
- ⚙️ Compila `stracker.exe` usando PyInstaller
- 📄 Genera `stracker-default.ini` con configuración por defecto
- 🛠️ Opcionalmente compila `stracker-packager.exe`

### Fase 5: Empaquetado Final (1-2 minutos)
- 📁 Crea archivos ZIP en directorio `versions/`
- 📋 Incluye documentación y archivos web estáticos
- ✅ Verifica integridad de los archivos generados

## 📁 Archivos Generados

Después de una compilación exitosa encontrarás:

### En el directorio `versions/`:
```
versions/
├── ptracker-V1.0.0.exe          # 💾 Instalador completo de ptracker
├── stracker-V1.0.0.zip          # 📦 Paquete del servidor
└── build_log_1.0.0.txt          # 📋 Log de compilación
```

### En el directorio `stracker/`:
```
stracker/
├── dist/
│   ├── stracker.exe             # 🖥️ Ejecutable del servidor
│   └── stracker-packager.exe    # 🛠️ Herramienta de empaquetado
├── stracker-default.ini         # ⚙️ Configuración por defecto
└── http_static/                 # 🌐 Archivos web del servidor
```

### Archivos temporales (ignorados por git):
```
env/                             # 📁 Entorno virtual de Python
ptracker-server-dist.py          # 🔒 Archivo temporal con checksums
ptracker.nsh                     # 📜 Script temporal de NSIS
nsis_temp_files0/               # 📁 Archivos temporales de NSIS
```

## ⚠️ Solución de Problemas Comunes

### ❌ Error: "No such file or directory: git"

**Problema**: Git no está en el PATH del sistema
```powershell
# Solución 1: Reinstalar Git marcando "Add to PATH"
# Solución 2: Especificar ruta completa en release_settings.py
git = r"C:\Program Files\Git\bin\git.exe"
```

### ❌ Error: "Cannot find Assetto Corsa installation"

**Problema**: Ruta incorrecta en `release_settings.py`
```powershell
# Verificar dónde está instalado AC:
dir "C:\Program Files (x86)\Steam\steamapps\common\assettocorsa"
dir "C:\Program Files\Epic Games\AssettoCorsaCompetizione"

# Actualizar release_settings.py con la ruta correcta
ac_install_dir = r"TU_RUTA_AQUI"
```

### ❌ Error: "NSIS not found"

**Problema**: NSIS no está instalado o en ubicación incorrecta
```powershell
# Verificar instalación:
dir "C:\Program Files (x86)\NSIS\makensis.exe"

# Si no existe, descargar e instalar NSIS desde:
# https://nsis.sourceforge.io/Download
```

### ❌ Error de compilación de dependencias (apsw, psycopg2)

**Problema**: Faltan Visual C++ Build Tools
```powershell
# Instalar Visual Studio Community con "Desktop development with C++"
# O instalar solo Build Tools desde:
# https://visualstudio.microsoft.com/visual-cpp-build-tools/
```

### ❌ Error: "git sandbox is dirty"

**Problema**: Hay cambios sin commitear en git
```powershell
# Ver qué archivos han cambiado:
git status

# Commitear cambios:
git add .
git commit -m "Prepare for release"

# O usar modo de prueba que ignora esto:
python create_release.py --test_release_process --windows_only test
```

### ❌ Error: "Permission denied" o archivos bloqueados

**Problema**: Antivirus o Windows Defender bloqueando
```powershell
# Solución:
# 1. Agregar exclusión en Windows Defender para la carpeta del proyecto
# 2. Ejecutar PowerShell como Administrador
# 3. Cerrar otros programas que puedan usar los archivos
```

### ❌ Error: "Failed to install PySide2" o dependencias

**Problema**: Red lenta o repositorios no disponibles
```powershell
# Probar con timeout mayor:
python -m pip install --timeout 120 PySide2

# O instalar manualmente las dependencias principales:
pip install bottle cherrypy python-dateutil pyinstaller
```

## 🧪 Comandos de Verificación y Testing

### Verificación Rápida (sin compilar)
```powershell
# Verificar que la configuración esté bien
python create_release.py --test_release_process --windows_only test-version
```

### Compilación de Solo Servidor (más rápida para pruebas)
```powershell
python create_release.py --stracker_only --windows_only 1.0.0
```

### Verificar Archivos Generados
```powershell
# Listar archivos en versions/
dir versions\

# Verificar tamaño de ejecutables (deben ser >5MB)
dir stracker\dist\*.exe

# Probar que el servidor funcione
cd stracker\dist
.\stracker.exe --help
```

## 🎯 Comandos Recomendados para Cada Situación

### 🔰 Primera compilación (para verificar que todo funciona)
```powershell
python create_release.py --test_release_process --windows_only test-version
```

### 🚀 Release de producción completo
```powershell
python create_release.py --windows_only 1.0.0
```

### 🛠️ Solo desarrollo del servidor
```powershell
python create_release.py --stracker_only --windows_only dev-build
```

### 🎮 Solo desarrollo del cliente
```powershell
python create_release.py --ptracker_only dev-build
```

## 📈 Tiempos Esperados de Compilación

En una PC típica (Intel i5, 8GB RAM, SSD):

| Componente | Primera vez | Subsecuentes |
|------------|-------------|--------------|
| Setup entorno | 3-5 min | 30 seg |
| ptracker.exe | 5-8 min | 2-3 min |
| stracker.exe | 3-5 min | 1-2 min |
| Empaquetado | 1-2 min | 30 seg |
| **TOTAL** | **12-20 min** | **4-6 min** |

## 🏁 ¡Compilación Exitosa!

Si todo va bien, al final verás algo como:
```
✅ Build completed successfully!
📁 Generated files in versions/:
   - ptracker-V1.0.0.exe (25.4 MB)
   - stracker-V1.0.0.zip (15.2 MB)
🎉 Ready for distribution!
```

## 💡 Consejos Adicionales

- **Usa SSD**: La compilación es mucho más rápida en un disco SSD
- **Primera vez**: La primera compilación tarda más porque descarga todas las dependencias
- **Antivirus**: Temporalmente deshabilita el antivirus para compilaciones más rápidas
- **Versiones**: Usa números de versión descriptivos como `1.0.0`, `2.1.3`, etc.
- **Backup**: Haz backup de tu `release_settings.py` personalizado
- **Testing**: Siempre prueba con `--test_release_process` antes de releases oficiales

---

### 📞 ¿Problemas?

Si sigues teniendo problemas después de seguir esta guía:

1. **Revisa los logs** en la terminal cuidadosamente
2. **Verifica cada requisito** listado arriba
3. **Prueba con modo test** primero
4. **Consulta** [`COMANDOS_RAPIDOS.md`](COMANDOS_RAPIDOS.md) para comandos específicos

---

*Esta guía ha sido creada para SPTracker por Rodrigo Angeloni basándose en el código original de NEYS.*
