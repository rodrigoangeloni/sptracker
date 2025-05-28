# 🚀 SPTracker - Guía Rápida de Comandos

## ⚡ Comandos de Compilación Más Usados

### Windows (Todo)
```powershell
python create_release.py 2.1.0
```

### Solo Cliente de Assetto Corsa
```powershell
python create_release.py --ptracker_only 2.1.0
```

### Solo Servidor Windows
```powershell
python create_release.py --stracker_only --windows_only 2.1.0
```

### Solo Servidor Linux
```powershell
python create_release.py --stracker_only --linux_only 2.1.0
```

### Solo Orange Pi / ARM32
```powershell
python create_release.py --orangepi_arm32_only 2.1.0
```

### Modo de Prueba (No crea archivos)
```powershell
python create_release.py --test_release_process --orangepi_arm32_only test
```

---

## 🍊 Orange Pi - Setup Rápido

### Primera Vez (En Orange Pi)
```bash
# 1. Instalar dependencias
sudo apt update && sudo apt install -y python3 python3-pip python3-dev python3-venv build-essential gcc git

# 2. Clonar proyecto
git clone https://github.com/rodrigoangeloni/sptracker.git
cd sptracker

# 3. Setup automático
chmod +x *.sh
./setup_orangepi.sh

# 4. Validar
./validate_orangepi.sh

# 5. Compilar
python3 create_release.py --orangepi_arm32_only 1.0.0
```

### Compilación Remota (Desde Windows)
```powershell
# 1. Configurar Makefile con tu IP de Orange Pi
# 2. Ejecutar
make orangepi BUILD_VERSION=1.0.0
```

---

## 🔧 Resolución Rápida de Problemas

### Error: "No such file versions/"
```bash
mkdir versions
```

### Error: "git sandbox is dirty"
```bash
git add . && git commit -m "preparar release"
```

### Error de memoria en ARM32
```bash
sudo fallocate -l 1G /swapfile
sudo chmod 600 /swapfile
sudo mkswap /swapfile
sudo swapon /swapfile
```

### Verificar configuración Orange Pi
```bash
./validate_orangepi.sh
```

---

## 📁 Archivos Importantes

| Archivo | Función |
|---------|---------|
| `create_release.py` | Script principal de compilación |
| `release_settings.py` | Configuración (copiar de .py.in) |
| `setup_orangepi.sh` | Setup automático Orange Pi |
| `validate_orangepi.sh` | Validar entorno Orange Pi |
| `Makefile` | Compilación remota |
| `versions/` | Archivos compilados |

---

## 🎯 Archivos Generados

### Windows
- `versions/ptracker-V1.0.0.exe` - Instalador completo
- `versions/stracker-V1.0.0.zip` - Servidor

### Linux/Orange Pi
- `stracker_linux_x86.tgz` - Servidor Linux x86
- `stracker_orangepi_arm32.tgz` - Servidor ARM32
- `deploy_orangepi.sh` - Script de instalación

---

*Ver `README_ES.md` para la guía completa*
