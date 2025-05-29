# 🎯 SPTracker v4.0.1 - Guía Rápida de Compilación

## ⚡ COMPILACIÓN ULTRA-RÁPIDA (1 CLIC)

### 🖱️ Windows - Un Solo Clic
```
Doble clic en: 🚀 COMPILAR SPTRACKER.cmd
```

## 🛠️ Scripts Disponibles

| Script | Plataforma | Descripción |
|--------|------------|-------------|
| `🚀 COMPILAR SPTRACKER.cmd` | Windows | **Menú interactivo** - Compilación de un clic |
| `build_windows.cmd` | Windows | Compilación completa Windows |
| `build_windows.ps1` | Windows | PowerShell avanzado con opciones |
| `build_linux.sh` | Linux/WSL | Compilación servidor Linux |
| `build_universal.py` | Multiplataforma | Script Python universal |

## 🎮 Casos de Uso Rápidos

### 🏁 Quiero compilar TODO ahora mismo
```cmd
🚀 COMPILAR SPTRACKER.cmd
# Selecciona opción 1
```

### 🖥️ Solo necesito el cliente Windows
```powershell
.\build_windows.ps1 -PtrackerOnly
```

### 🌐 Solo necesito el servidor web
```bash
./build_linux.sh           # Linux
.\build_windows.ps1 -StrackerOnly  # Windows
```

### 🌍 Quiero compilar para Windows Y Linux
```bash
python build_universal.py --all
```

## 📁 Estructura de Salida

```
versions/
├── ptracker-V4.0.1.exe          # 🖥️ Cliente Windows (192 MB)
├── stracker-V4.0.1.zip          # 🌐 Servidor Windows (13 MB)
└── stracker-V4.0.1-linux.tgz    # 🐧 Servidor Linux (10 MB)
```

## 🚨 Si Algo Falla

1. **Error entorno virtual:**
   ```powershell
   .\inicio_rapido.ps1  # Configura todo automáticamente
   ```

2. **Error dependencias:**
   ```bash
   pip install PySide6 pyinstaller
   ```

3. **Error NSIS:**
   - Descarga: https://nsis.sourceforge.io/
   - Instala y reinicia

4. **Error WSL:**
   ```cmd
   wsl --install -d Debian
   ```

## 🎉 ¡Listo para Usar!

Los scripts están optimizados para:
- ✅ **Detección automática** de plataforma
- ✅ **Configuración automática** de entornos
- ✅ **Logs detallados** para debugging
- ✅ **Limpieza automática** de archivos temporales
- ✅ **Validación** de requisitos
- ✅ **Progreso visual** durante compilación

**💡 Recomendación:** Usa `🚀 COMPILAR SPTRACKER.cmd` para la mejor experiencia.
