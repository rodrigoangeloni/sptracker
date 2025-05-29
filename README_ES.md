# 🏁 SPTracker - Guía Completa de Instalación y Desarrollo

**SPTracker** es una suite de aplicaciones para **Assetto Corsa** que incluye:
- **ptracker**: Cliente que se ejecuta dentro de Assetto Corsa para rastrear tu rendimiento
- **stracker**: Servidor que recopila y almacena datos de múltiples sesiones y jugadores

**Autor Original**: NEYS  
**Actualizado y Mejorado por**: Rodrigo Angeloni

## 🚀 Características Añadidas por Rodrigo Angeloni

Esta versión incluye mejoras significativas y nuevas características:

### 🍊 Soporte para Orange Pi / ARM32
- Compilación nativa para dispositivos ARM32 (Orange Pi, Raspberry Pi)
- Scripts de configuración automática para Orange Pi
- Optimizaciones específicas para sistemas embebidos
- Despliegue sin interfaz gráfica (headless) para servidores dedicados

### 🔧 Sistema de Compilación Mejorado
- Scripts automatizados de setup y validación
- Compilación cruzada (cross-compilation) desde Windows/Linux
- Makefile para compilación remota
- Soporte para múltiples arquitecturas simultáneamente

### 📚 Documentación Completa en Español
- Guías detalladas de instalación y compilación
- Comandos de referencia rápida
- Scripts de inicio automatizado (`inicio_rapido.ps1` / `inicio_rapido.sh`)
- Resolución de problemas comunes

### ⚡ Herramientas de Automatización
- Scripts de despliegue automático
- Validación de entorno pre-compilación
- Configuración de servicios systemd
- Gestión remota desde Windows PowerShell

### 🎯 Optimizaciones de Rendimiento
- Dependencias opcionales para ARM32
- Gestión de memoria mejorada para dispositivos limitados
- Configuración específica por modelo de Orange Pi

## 📖 ¿Qué hace este proyecto?

### 🎯 ptracker (Cliente)
- **Telemetría en tiempo real**: Muestra datos de vuelta, sector, combustible y neumáticos
- **Análisis de rendimiento**: Compara tus vueltas con referencias personales y de otros pilotos
- **Interfaz en AC**: Se integra directamente en el juego con paneles personalizables
- **Grabación de datos**: Registra automáticamente todas tus sesiones de conducción

### 🖥️ stracker (Servidor)
- **Servidor web**: Interfaz web para ver estadísticas históricas
- **Base de datos**: Almacena datos de vueltas, pilotos, circuitos y sesiones
- **Múltiples plataformas**: Funciona en Windows, Linux y ARM32 (Orange Pi/Raspberry Pi)
- **API REST**: Permite integración con otras herramientas y aplicaciones

## 🚀 Instalación Rápida (Usuarios)

### Para Windows (Usuarios finales)
```powershell
# 1. Descargar la última versión desde:
# https://github.com/rodrigoangeloni/sptracker/releases

# 2. Ejecutar el instalador
ptracker-V4.0.1.exe

# 3. Configurar en Assetto Corsa:
# - Ir a Options > General > UI Modules
# - Activar "ptracker"
```

### Para Linux/Orange Pi (Servidor)
```bash
# Descargar y extraer
wget https://github.com/rodrigoangeloni/sptracker/releases/download/v4.0.1/stracker-V4.0.1.zip
unzip stracker-V4.0.1.zip
cd stracker

# Ejecutar servidor
./stracker
```

---

## 👨‍💻 Guía de Desarrollo y Compilación

### 📋 Requisitos Generales

**Obligatorios para todos los sistemas:**
- Python 3.7 o superior
- Git
- Conexión a internet (para descargar dependencias)

**Para Windows:**
- Assetto Corsa instalado
- [Nullsoft Scriptable Install System (NSIS)](https://nsis.sourceforge.io/Download)
- Visual Studio Build Tools (para compilar componentes nativos)

### 🔧 Configuración Inicial

**1. Clonar el repositorio:**
```bash
git clone https://github.com/rodrigoangeloni/sptracker.git
cd sptracker
```

**2. Configurar settings (IMPORTANTE):**
```bash
# Copiar y editar la configuración
copy release_settings.py.in release_settings.py
# Editar release_settings.py con tus rutas y preferencias
```

**3. Estructura del proyecto:**
```
sptracker/
├── ptracker.py              # Cliente principal
├── stracker/               # Código del servidor
├── create_release.py       # Script de compilación principal
├── versions/              # Archivos compilados
└── env/                   # Entornos virtuales
```

---

## 🖥️ Compilación para Windows

### Compilación Completa (ptracker + stracker)
```powershell
# Compilar todo para Windows
python create_release.py 1.0.0

# Solo ptracker (cliente de AC)
python create_release.py --ptracker_only 1.0.0

# Solo stracker para Windows
python create_release.py --stracker_only --windows_only 1.0.0
```

### Archivos generados:
- `versions/ptracker-V1.0.0.exe` - Instalador completo para Assetto Corsa
- `versions/stracker-V1.0.0.zip` - Servidor para Windows

---

## 🐧 Compilación para Linux

### Opción 1: Compilación Remota (Recomendada)
```powershell
# Desde Windows, compilar remotamente en Linux
python create_release.py --linux_only 1.0.0
```

**Requisitos:**
- Servidor Linux accesible por SSH
- Configurar `release_settings.py` con datos del servidor remoto

### Opción 2: Compilación Local en Linux
```bash
# En el servidor Linux
python3 create_release.py --stracker_only --linux_only 1.0.0
```

### Archivos generados:
- `versions/stracker-V1.0.0.zip` - Contiene `stracker_linux_x86.tgz`

---

## 🍊 Compilación para Orange Pi / ARM32

### Opción 1: Compilación Directa en Orange Pi

**Preparar Orange Pi:**
```bash
# Conectar por SSH
ssh usuario@ip-orangepi

# Instalar dependencias
sudo apt update && sudo apt upgrade -y
sudo apt install -y python3 python3-pip python3-dev python3-venv build-essential gcc git

# Clonar proyecto
git clone https://github.com/rodrigoangeloni/sptracker.git
cd sptracker

# Setup automático
chmod +x *.sh
./setup_orangepi.sh

# Validar entorno
./validate_orangepi.sh
```

**Compilar:**
```bash
# Compilación para Orange Pi ARM32
python3 create_release.py --orangepi_arm32_only 1.0.0
```

### Opción 2: Compilación Remota desde Windows

**Configurar Makefile:**
```makefile
# Editar Makefile y cambiar:
ORANGEPI_HOST = tu-ip-orangepi
ORANGEPI_USER = tu-usuario-orangepi
```

**Compilar remotamente:**
```powershell
# Desde Windows PowerShell
make orangepi BUILD_VERSION=1.0.0
```

### Opción 3: Cross-compilación (Avanzada)
```bash
# Configurar entorno de cross-compilación
./setup_cross_compile.sh

# Compilar
python create_release.py --orangepi_arm32_only 1.0.0
```

### Archivos generados:
- `versions/stracker-V1.0.0.zip` - Contiene `stracker_orangepi_arm32.tgz`
- `stracker/deploy_orangepi.sh` - Script de despliegue

---

## 🎛️ Opciones de Compilación

### Comandos Disponibles
```bash
# Ver ayuda
python create_release.py

# Modo de prueba (no crea release real)
python create_release.py --test_release_process --orangepi_arm32_only test

# Compilaciones específicas
python create_release.py --ptracker_only 1.0.0           # Solo cliente AC
python create_release.py --stracker_only 1.0.0           # Solo servidor
python create_release.py --windows_only 1.0.0            # Solo Windows
python create_release.py --linux_only 1.0.0              # Solo Linux x86
python create_release.py --orangepi_arm32_only 1.0.0     # Solo Orange Pi ARM32
python create_release.py --stracker_packager_only 1.0.0  # Solo empaquetador
```

### Banderas de Compilación
| Bandera | Descripción |
|---------|-------------|
| `--test_release_process` | Modo de prueba, no crea archivos finales |
| `--ptracker_only` | Compila solo el cliente de Assetto Corsa |
| `--stracker_only` | Compila solo el servidor |
| `--windows_only` | Compila solo para Windows |
| `--linux_only` | Compila solo para Linux x86 |
| `--orangepi_arm32_only` | Compila solo para Orange Pi/ARM32 |
| `--stracker_packager_only` | Compila solo el empaquetador |

---

## 🛠️ Resolución de Problemas

### Errores Comunes

**"No such file or directory: versions/"**
```bash
mkdir versions
```

**"git sandbox is dirty"**
```bash
git add .
git commit -m "preparar release"
```

**Error de dependencias en Orange Pi:**
```bash
sudo apt install -y python3-dev build-essential
pip3 install --upgrade pip setuptools wheel
```

**Error de memoria en dispositivos ARM:**
```bash
# Aumentar swap
sudo fallocate -l 1G /swapfile
sudo chmod 600 /swapfile
sudo mkswap /swapfile
sudo swapon /swapfile
```

**Problemas de SSH/conexión remota:**
```bash
# Configurar clave SSH
ssh-keygen -t rsa
ssh-copy-id usuario@servidor-remoto
```

### Validación del Entorno

**Verificar configuración de Orange Pi:**
```bash
./validate_orangepi.sh
```

**Verificar sintaxis sin compilar:**
```bash
python create_release.py --test_release_process --orangepi_arm32_only test
```

---

## 📁 Estructura de Archivos Generados

Después de la compilación encontrarás:

```
versions/
├── ptracker-V1.0.0.exe           # Instalador para Windows/AC
└── stracker-V1.0.0.zip           # Paquete del servidor
    ├── stracker.exe               # Servidor Windows
    ├── stracker_linux_x86.tgz     # Servidor Linux x86
    ├── stracker_orangepi_arm32.tgz # Servidor Orange Pi ARM32
    ├── deploy_orangepi.sh         # Script de despliegue
    ├── documentation.htm          # Documentación
    └── http_static/               # Archivos web
```

---

## 🚀 Despliegue

### Instalar en Assetto Corsa (Windows)
```powershell
# Ejecutar instalador
versions/ptracker-V1.0.0.exe

# Activar en AC:
# Options > General > UI Modules > ptracker ✓
```

### Desplegar servidor en Orange Pi
```bash
# Copiar archivos
scp versions/stracker-V1.0.0.zip usuario@orangepi:/home/usuario/

# En Orange Pi
unzip stracker-V1.0.0.zip
tar -xzf stracker_orangepi_arm32.tgz
cd stracker
./stracker
```

### Configurar como servicio (Linux/Orange Pi)
```bash
# Crear servicio systemd
sudo cp stracker.service /etc/systemd/system/
sudo systemctl enable stracker
sudo systemctl start stracker
```

---

## 🤝 Contribuir al Proyecto

### Desarrollo
```bash
# Fork del repositorio en GitHub
git clone https://github.com/rodrigoangeloni/sptracker.git

# Crear rama para tu feature
git checkout -b mi-nueva-caracteristica

# Hacer commits
git add .
git commit -m "Añadir nueva funcionalidad"

# Push y crear Pull Request
git push origin mi-nueva-caracteristica
```

### Reportar Problemas
- Crear un [Issue en GitHub](https://github.com/rodrigoangeloni/sptracker/issues)
- Incluir logs, sistema operativo y pasos para reproducir

---

## 📞 Contacto y Soporte

- **GitHub Issues**: [Reportar problemas](https://github.com/rodrigoangeloni/sptracker/issues)
- **Autor Original (NEYS)**: `never_eat_yellow_snow1` en foros de Assetto Corsa
- **Actualizado y Mejorado por**: Rodrigo Angeloni
- **Documentación Completa**: Ver `README_OrangePi.md` para detalles específicos de ARM32

---

## 📄 Licencia

Este proyecto está licenciado bajo la GPL v3. Ver `LICENSE.txt` para más detalles.

**¡Respeta la licencia y considera contribuir al proyecto principal en lugar de crear forks!**

---

*Última actualización: Mayo 2025*
