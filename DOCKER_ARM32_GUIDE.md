# 🍊 Guía de Compilación Docker ARM32 para Orange Pi

## 🎯 Resumen
Esta guía te permitirá compilar **SPTracker** para **Orange Pi ARM32** directamente desde **Windows** usando **Docker** con emulación, sin necesidad del dispositivo físico.

## 📋 Requisitos Previos

### 🖥️ Sistema Host (Windows)
- Windows 10/11 con WSL2 habilitado
- Docker Desktop 4.0+
- 8GB RAM mínimo (16GB recomendado)
- 10GB espacio libre en disco
- Conexión a internet estable

### 🐳 Docker Desktop
- Experimental features habilitadas
- BuildX plugin instalado
- Memoria asignada: 4GB+ 

## 🚀 Configuración Automática

### Paso 1: Configurar Docker
```cmd
# Ejecutar configurador automático
setup_docker_arm32.cmd
```

Este script:
- ✅ Verifica Docker Desktop
- ✅ Configura BuildX multi-arquitectura
- ✅ Habilita emulación QEMU ARM32
- ✅ Prueba el entorno ARM32

### Paso 2: Compilar para Orange Pi
```cmd
# Ejecutar compilador ARM32
docker_build_arm32.cmd
```

## 🛠️ Opciones de Compilación

### 1. 🚀 Compilación Rápida (Recomendada)
- **Tiempo**: 15-20 minutos
- **Tamaño**: ~50MB imagen Docker
- **Genera**: `stracker_orangepi_arm32.tgz`
- **Incluye**: Binario stracker + configuración básica

### 2. 🏗️ Compilación Completa
- **Tiempo**: 25-35 minutos  
- **Tamaño**: ~200MB imagen Docker
- **Genera**: `stracker_orangepi_arm32.tgz`
- **Incluye**: Binario + todas las dependencias

### 3. 🧪 Compilación de Prueba
- **Tiempo**: 5-10 minutos
- **Propósito**: Verificar entorno sin compilar
- **Útil para**: Debuggear problemas

## 📦 Archivos Generados

Después de la compilación encontrarás en `versions/`:

```
versions/
├── stracker_orangepi_arm32.tgz    # Binario ARM32 para Orange Pi
└── deploy_orangepi.sh             # Script de despliegue
```

## 🍊 Desplegar en Orange Pi

### Método 1: Copia Manual
```bash
# En tu Orange Pi
scp usuario@windows-pc:/ruta/versions/stracker_orangepi_arm32.tgz .
tar -xzf stracker_orangepi_arm32.tgz
chmod +x dist/stracker
./dist/stracker
```

### Método 2: Script Automático
```bash
# Copiar script y archivo
scp deploy_orangepi.sh stracker_orangepi_arm32.tgz orangepi@192.168.1.100:~/

# En Orange Pi
./deploy_orangepi.sh
```

## 🔧 Arquitecturas Docker Soportadas

| Plataforma | Docker Platform | Descripción |
|------------|----------------|-------------|
| Orange Pi | `linux/arm/v7` | ARM32v7 (Cortex-A7/A53) |
| Raspberry Pi 3+ | `linux/arm/v7` | ARM32v7 compatible |
| Raspberry Pi 4 | `linux/arm64` | ARM64 (usar imagen diferente) |

## 🐛 Solución de Problemas

### Error: "Docker Desktop not running"
```cmd
# Iniciar Docker Desktop
start "" "C:\Program Files\Docker\Docker\Docker Desktop.exe"

# Esperar 2-3 minutos y reintentar
```

### Error: "no matching manifest for linux/arm/v7"
```cmd
# Habilitar emulación QEMU
docker run --rm --privileged multiarch/qemu-user-static --reset -p yes

# Verificar soporte
docker buildx ls
```

### Error: "failed to solve with frontend dockerfile.v0"
```cmd
# Actualizar Docker Desktop a la última versión
# Limpiar cache de Docker
docker system prune -a
```

### Compilación muy lenta
```cmd
# Asignar más recursos en Docker Desktop:
# Settings > Resources > Advanced
# - CPUs: 4+
# - Memory: 6GB+
# - Disk: 20GB+
```

### Error de memoria durante compilación
```cmd
# En Docker Desktop Settings:
# - Aumentar memoria a 8GB
# - Habilitar swap en WSL2
```

## ⚡ Optimizaciones

### 🔧 Acelerar Compilaciones
```cmd
# 1. Usar compilación rápida para desarrollo
docker_build_arm32.cmd -> Opción [1]

# 2. Compilación completa solo para releases
docker_build_arm32.cmd -> Opción [2]

# 3. Reutilizar capas Docker
# No hacer "docker system prune" entre compilaciones
```

### 💾 Reducir Uso de Disco
```cmd
# Limpiar imágenes no utilizadas
docker image prune -a

# Limpiar buildx cache
docker buildx prune -a
```

## 📊 Rendimiento Esperado

### Tiempo de Compilación por Hardware

| Componente | Tiempo Compilación Rápida | Tiempo Compilación Completa |
|------------|---------------------------|------------------------------|
| CPU Intel i5 | 15-20 min | 25-30 min |
| CPU Intel i7 | 10-15 min | 20-25 min |
| CPU AMD Ryzen 5 | 12-18 min | 22-28 min |
| CPU AMD Ryzen 7 | 8-12 min | 18-22 min |

### Recursos de Sistema

| Recurso | Compilación Rápida | Compilación Completa |
|---------|-------------------|---------------------|
| RAM utilizada | 2-4GB | 4-6GB |
| CPU utilización | 50-70% | 70-90% |
| Disco temporal | 2-3GB | 5-8GB |

## 🏁 Verificación Final

### En Windows (post-compilación)
```cmd
# Verificar archivos generados
dir versions\*arm32*

# Verificar tamaño del archivo
dir versions\stracker_orangepi_arm32.tgz
```

### En Orange Pi (post-despliegue)
```bash
# Verificar arquitectura del binario
file dist/stracker

# Probar ejecución
./dist/stracker --help

# Verificar dependencias
ldd dist/stracker
```

## 📚 Referencias

- [Docker BuildX Documentation](https://docs.docker.com/buildx/)
- [QEMU ARM Emulation](https://github.com/multiarch/qemu-user-static)
- [Orange Pi Official Site](http://www.orangepi.org/)

---

**🎯 ¡Con esta configuración puedes compilar para Orange Pi ARM32 sin tener el dispositivo físico!**

*¿Problemas? Crea un [Issue](https://github.com/rodrigoangeloni/sptracker/issues) con logs de Docker.*
