# 🚀 SPTracker v4.0.1 - Sistema de Compilación Inteligente

## 🎯 **Nuevo Sistema de Compilación Súper Fácil**

Esta versión introduce el **Sistema de Compilación Inteligente** que detecta automáticamente tu entorno y guía todo el proceso paso a paso.

### ✨ **Características Principales**

- **🏎️ Compilador Inteligente**: Detección automática de Python, Assetto Corsa y NSIS
- **📋 Menú Interactivo**: 6 opciones de compilación con tiempos estimados
- **🎯 Un Solo Clic**: Ejecuta `🎯 COMPILAR FÁCIL.cmd` y selecciona tu opción
- **🔧 Configuración Automática**: Crea y valida configuración automáticamente

### 🛠️ **Opciones de Compilación Disponibles**

1. **Compilación Completa** ⏱️ 10-15 min - Cliente + Servidor
2. **Solo Cliente** ⏱️ 5-8 min - Para Assetto Corsa únicamente  
3. **Solo Servidor** ⏱️ 3-5 min - Servidor web independiente
4. **Compilación de Prueba** ⏱️ 1-2 min - Verificación rápida
5. **Limpiar y Compilar** ⏱️ 15-20 min - Desde cero
6. **Ver Ayuda** - Documentación completa

### 📦 **Archivos del Release**

| Archivo | Tamaño | Descripción |
|---------|--------|-------------|
| `ptracker-V4.0.1.exe` | 191 MB | 🎮 Instalador completo para Assetto Corsa |
| `stracker-V4.0.1.zip` | 13 MB | 🌐 Servidor web (Windows/Linux) |
| `stracker-V4.0.1-linux.tgz` | 10 MB | 🐧 Servidor optimizado Linux/ARM32 |

### 🚀 **Instalación Rápida**

#### Para Usuarios de Assetto Corsa (Windows):
```powershell
# 1. Descargar ptracker-V4.0.1.exe
# 2. Ejecutar como administrador
# 3. En AC: Options > General > UI Modules > Activar "ptracker"
```

#### Para Servidores (Linux):
```bash
wget https://github.com/rodrigoangeloni/sptracker/releases/download/v4.0.1/stracker-V4.0.1.zip
unzip stracker-V4.0.1.zip && cd stracker && ./stracker
```

### 🔍 **Verificaciones Automáticas**

- ✅ Python 3.7+ detectado automáticamente
- ✅ Assetto Corsa ubicado en rutas comunes
- ✅ NSIS para crear instaladores .exe
- ✅ Configuración validada antes de compilar
- ✅ Limpieza automática de archivos temporales

### 💡 **Mejoras en esta Versión**

- **Interfaz de usuario amigable** con ASCII art y colores
- **Detección inteligente** de entorno de desarrollo
- **Mensajes de error claros** con soluciones sugeridas
- **Documentación completa** en español
- **Scripts multiplataforma** (Windows, Linux, ARM32)
- **Sistema de limpieza** automática de archivos temporales

### 🛠️ **Para Desarrolladores**

```bash
# Clonar repositorio
git clone https://github.com/rodrigoangeloni/sptracker.git
cd sptracker

# Ejecutar compilador inteligente
./🎯 COMPILAR FÁCIL.cmd

# O usar scripts específicos
python create_release.py 4.0.1
```

### 📚 **Documentación**

- `README_ES.md` - Guía completa en español
- `CHANGELOG.md` - Historial de cambios
- `COMPILACION_RAPIDA.md` - Guía de compilación rápida

---

## 🐛 **Problemas Conocidos**

- En algunos antivirus, el archivo .exe puede requerir excepción
- Primera compilación puede tomar más tiempo (descarga dependencias)

## 🤝 **Contribuir**

¡Las contribuciones son bienvenidas! Ver `README_ES.md` para detalles.

---

**🏁 ¡La forma más fácil de compilar SPTracker hasta ahora!**

*¿Problemas? Crea un [Issue](https://github.com/rodrigoangeloni/sptracker/issues)*
