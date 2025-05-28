# Guía de Compilación para Orange Pi ARM32

## Introducción

Esta guía te permitirá compilar **stracker** (parte del proyecto sptracker) específicamente para Orange Pi de 32 bits. El proyecto ha sido reconfigurado para facilitar el proceso de compilación en dispositivos ARM32.

## Componentes del Proyecto

- **stracker**: Servidor de seguimiento de datos para Assetto Corsa (compatible con Orange Pi)
- **ptracker**: Cliente de seguimiento (solo Windows x86/x64 - no compatible con ARM)
- **CreateFileHook**: Componente nativo de Windows (no compatible con ARM)

## ¿Qué es stracker?

Stracker es el componente servidor de sptracker que:
- Rastrea y almacena datos de sesiones de Assetto Corsa
- Proporciona una interfaz web para ver estadísticas
- Funciona independientemente del juego (ideal para servidores dedicados)
- Puede ejecutarse en dispositivos ARM de bajo consumo como Orange Pi

## Características de esta adaptación

- ✅ Optimizado para ARM 32-bit (Orange Pi, Raspberry Pi, etc.)
- ✅ Compilación nativa en el dispositivo
- ✅ Scripts de instalación automática
- ✅ Servicios systemd incluidos
- ✅ Configuración simplificada
- ❌ No incluye componentes específicos de Windows (CreateFileHook)
- ❌ No incluye ptracker (cliente del juego)

## Requisitos

### Hardware mínimo
- Orange Pi (cualquier modelo con ARM 32-bit)
- 512 MB de RAM mínimo (1 GB recomendado)
- 2 GB de espacio libre en disco
- Conectividad de red

### Software
- Armbian/Ubuntu/Debian para Orange Pi
- Python 3.7 o superior
- Acceso a internet para descarga de dependencias

## Instalación rápida

### 1. Preparar el Orange Pi

```bash
# En tu Orange Pi, descarga el proyecto
git clone https://github.com/rodrigoangeloni/sptracker.git
cd sptracker

# Ejecuta el script de configuración automática
chmod +x setup_orangepi.sh
./setup_orangepi.sh
```

### 2. Compilar stracker

```bash
# Cambiar al directorio de compilación
cd ~/sptracker_build/sptracker

# Compilar para Orange Pi ARM32
./create_release_orangepi_arm32.sh
```

### 3. Desplegar

```bash
# En el directorio stracker después de la compilación
cd stracker
./deploy_orangepi.sh

# Configurar el servicio (opcional)
sudo systemctl enable stracker
sudo systemctl start stracker
```

## Compilación manual

Si prefieres compilar manualmente:

```bash
# Crear entorno virtual
cd stracker
python3 -m venv env/orangepi_arm32
source env/orangepi_arm32/bin/activate

# Instalar dependencias
pip install --upgrade pip setuptools wheel
pip install bottle cherrypy python-dateutil wsgi-request-logger simplejson
pip install psycopg2-binary  # o psycopg2
pip install pyinstaller apsw

# Compilar
pyinstaller --clean -y -s \
    --exclude-module http_templates \
    --hidden-import cherrypy.wsgiserver.wsgiserver3 \
    --hidden-import psycopg2 \
    --add-data "http_static:http_static" \
    --name stracker_orangepi_arm32 \
    stracker.py
```

## Configuración

### Configuración básica

Edita `~/stracker/stracker.ini`:

```ini
[STRACKER_CONFIG]
enabled = True
listen_addr = 0.0.0.0
listen_port = 50041
database_type = sqlite3
database_file = stracker.db
pickup_mode_enabled = True
log_level = INFO

[AC_SERVER_CFG]
ac_server_config_ini = /path/to/your/ac/server.cfg
```

### Variables importantes

- `listen_addr`: IP donde escucha el servidor (0.0.0.0 para todas las interfaces)
- `listen_port`: Puerto del servidor web (por defecto 50041)
- `database_type`: Tipo de base de datos (sqlite3 o postgresql)
- `ac_server_config_ini`: Ruta al archivo de configuración del servidor AC

## Uso

### Iniciar stracker manualmente

```bash
cd ~/stracker
./stracker_orangepi_arm32
```

### Usar como servicio

```bash
# Iniciar
sudo systemctl start stracker

# Detener
sudo systemctl stop stracker

# Ver estado
sudo systemctl status stracker

# Ver logs
journalctl -u stracker -f
```

### Acceder a la interfaz web

Abre en tu navegador: `http://IP-DE-TU-ORANGEPI:50041`

## Solución de problemas

### Error de compilación de psycopg2

```bash
# Instalar dependencias de PostgreSQL
sudo apt-get install libpq-dev python3-dev

# O usar la versión binaria
pip install psycopg2-binary
```

### Error de APSW

```bash
# Instalar dependencias de SQLite
sudo apt-get install libsqlite3-dev sqlite3

# Compilar desde fuente
pip install apsw --no-binary apsw
```

### Problemas de memoria

Para Orange Pi con poca RAM:

```bash
# Aumentar swap
sudo fallocate -l 1G /swapfile
sudo chmod 600 /swapfile
sudo mkswap /swapfile
sudo swapon /swapfile
```

### Problemas de permisos

```bash
# Asegurar permisos correctos
chmod +x ~/stracker/stracker_orangepi_arm32
chown -R orangepi:orangepi ~/stracker
```

## Optimizaciones para Orange Pi

### Reducir uso de memoria

En `stracker.ini`:

```ini
[STRACKER_CONFIG]
# Reducir cache
cache_size = 100
# Guardar datos cada 5 minutos en lugar de cada minuto
save_interval = 300
```

### Usar base de datos SQLite

Para evitar overhead de PostgreSQL:

```ini
[STRACKER_CONFIG]
database_type = sqlite3
database_file = stracker.db
```

## Estructura de archivos

```
~/stracker/                    # Directorio de ejecución
├── stracker_orangepi_arm32    # Ejecutable compilado
├── stracker.ini               # Configuración
├── stracker.db               # Base de datos SQLite
└── logs/                     # Logs del servidor

~/sptracker_build/sptracker/   # Directorio de compilación
├── create_release_orangepi_arm32.sh
├── setup_orangepi.sh
└── stracker/
    ├── stracker.py
    ├── env/orangepi_arm32/
    └── dist/
```

## Contribuir

Para contribuir al proyecto:

1. Fork este repositorio
2. Crea una rama para tu feature
3. Prueba en un Orange Pi real
4. Envía un pull request

## Licencia

Este proyecto mantiene la misma licencia GPL v3 del proyecto original sptracker.

## Soporte

Para problemas específicos de Orange Pi:
- Abre un issue en este repositorio
- Incluye la salida de `uname -a` y `python3 --version`
- Proporciona logs relevantes

Para problemas generales de sptracker:
- Ver el repositorio actual: https://github.com/rodrigoangeloni/sptracker
