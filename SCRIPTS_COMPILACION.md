# 🏎️ SPTracker v4.0.1 - Scripts de Compilación

Scripts optimizados para compilar SPTracker fácilmente en cualquier plataforma.

## 🚀 Compilación de Un Clic

### Windows
1. **Doble clic en:** `🚀 COMPILAR SPTRACKER.cmd`
2. Selecciona tu opción preferida
3. ¡Listo! Los archivos estarán en `versions/`

### Alternativas por Línea de Comandos

#### Windows PowerShell
```powershell
# Compilación completa
.\build_windows.ps1

# Solo cliente GUI
.\build_windows.ps1 -PtrackerOnly

# Solo servidor web
.\build_windows.ps1 -StrackerOnly

# Limpiar y compilar
.\build_windows.ps1 -Clean
```

#### Windows CMD
```cmd
# Compilación completa
build_windows.cmd
```

#### Linux/WSL
```bash
# Compilación para Linux
./build_linux.sh

# Con limpieza previa
./build_linux.sh --clean
```

#### Multiplataforma (Python)
```bash
# Automático según plataforma
python build_universal.py

# Solo Windows
python build_universal.py --windows

# Solo Linux  
python build_universal.py --linux

# Todas las plataformas
python build_universal.py --all

# Solo cliente ptracker
python build_universal.py --ptracker

# Solo servidor stracker
python build_universal.py --stracker
```

## 📦 Archivos Generados

Todos los archivos se guardan en el directorio `versions/`:

| Archivo | Plataforma | Descripción | Tamaño |
|---------|------------|-------------|--------|
| `ptracker-V4.0.1.exe` | Windows | Cliente con GUI | ~192 MB |
| `stracker-V4.0.1.zip` | Windows | Servidor web | ~13 MB |
| `stracker-V4.0.1-linux.tgz` | Linux | Servidor web | ~10 MB |

## 🔧 Requisitos

### Windows
- ✅ Python 3.11+
- ✅ Entorno virtual en `env\windows\`
- ✅ PySide6 (`pip install PySide6`)
- ✅ NSIS (para generar .exe)

### Linux/WSL
- ✅ Python 3.7+
- ✅ pip3
- ✅ Dependencias: `pyinstaller bottle cherrypy python-dateutil simplejson`

## 🎯 Casos de Uso

### Para Desarrolladores
```bash
# Desarrollo rápido - solo servidor
python build_universal.py --stracker

# Test completo
python build_universal.py --all --clean
```

### Para Distribución
```bash
# Compilación completa para release
🚀 COMPILAR SPTRACKER.cmd → Opción 1
```

### Para Servidores Linux
```bash
# Solo servidor para deploy
./build_linux.sh
```

## 🔍 Solución de Problemas

### Error: "No se encuentra release_settings.py"
**Solución:** Ejecuta los scripts desde el directorio raíz de SPTracker

### Error: "No se encuentra entorno virtual"
**Solución:** Ejecuta primero `inicio_rapido.ps1` (Windows) o instala dependencias manualmente

### Error: "NSIS no encontrado"
**Solución:** Instala NSIS desde https://nsis.sourceforge.io/

### Error: "PySide6 no encontrado"
**Solución:** `pip install PySide6`

### WSL no funciona
**Solución:** 
1. Instala WSL: `wsl --install`
2. Instala Debian: `wsl --install -d Debian`
3. Configura Python en WSL

## 📝 Logs de Compilación

Los logs se guardan automáticamente:
- `build_log_windows_YYYYMMDD_HHMMSS.txt`
- `build_log_linux_YYYYMMDD_HHMMSS.txt`

## 🎉 ¡Listo!

Los scripts detectan automáticamente tu plataforma y configuran todo lo necesario. 
¡Solo ejecuta y disfruta!

---

**💡 Tip:** Para mayor comodidad, ancla `🚀 COMPILAR SPTRACKER.cmd` a la barra de tareas de Windows.
