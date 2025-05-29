# 📋 Historial de Cambios - SPTracker

## 🚀 [v4.0.1] - 2025-05-28

### ✨ Nuevas Características
- **🏎️ Sistema de Compilación Inteligente**: Script automatizado con detección automática de entorno
- **📦 Scripts de Compilación Múltiples**: Soporte para Windows, Linux y ARM32
- **🍊 Optimizaciones para Orange Pi**: Compilación nativa y cross-compilation
- **🎯 Compilador Súper Fácil**: Interface de usuario simplificada con menú interactivo

### 🔧 Mejoras
- **Sistema de detección automática** de Python, Assetto Corsa y NSIS
- **Compilación selectiva**: Cliente solo, servidor solo, o compilación completa
- **Mejores mensajes de error** y guías de resolución de problemas
- **Documentación completa en español** con guías paso a paso

### 📁 Scripts Añadidos
- `🎯 COMPILAR FÁCIL.cmd` - Compilador principal con interfaz amigable
- `🚀 COMPILAR SPTRACKER.cmd` - Script alternativo de compilación
- `build_windows.cmd/.ps1` - Scripts específicos para Windows
- `build_linux.sh` - Script de compilación para Linux
- `build_universal.py` - Constructor multiplataforma
- `release_settings_wsl.py` - Configuración para WSL

### 🛠️ Opciones de Compilación
1. **Compilación Completa** - Cliente + Servidor (10-15 min)
2. **Solo Cliente** - Para Assetto Corsa (5-8 min)
3. **Solo Servidor** - Servidor web (3-5 min)
4. **Compilación de Prueba** - Verificación rápida (1-2 min)
5. **Limpiar y Compilar** - Compilación desde cero

### 📊 Archivos de Release
- `ptracker-V4.0.1.exe` (191 MB) - Instalador completo para Windows/Assetto Corsa
- `stracker-V4.0.1.zip` (13 MB) - Servidor web para Windows/Linux
- `stracker-V4.0.1-linux.tgz` (10 MB) - Servidor optimizado para Linux/ARM32

### 🔍 Verificaciones Automáticas
- ✅ Detección de Python 3.7+
- ✅ Verificación de Assetto Corsa
- ✅ Detección de NSIS para instaladores
- ✅ Validación de configuración
- ✅ Verificación de dependencias

### 💡 Resolución de Problemas
- Guías detalladas para errores comunes
- Scripts de verificación automática
- Configuración paso a paso
- Soporte para múltiples entornos de desarrollo

---

## 📥 Instalación

### Windows (Usuarios Finales)
```bash
# Descargar desde GitHub Releases
# Ejecutar: ptracker-V4.0.1.exe
# Activar en AC: Options > General > UI Modules > ptracker
```

### Linux/Servidor
```bash
wget https://github.com/rodrigoangeloni/sptracker/releases/download/v4.0.1/stracker-V4.0.1.zip
unzip stracker-V4.0.1.zip
cd stracker && ./stracker
```

---

**🏁 ¡La experiencia de compilación más fácil y completa para SPTracker!**

*Para historial completo, ver commits del repositorio.*
