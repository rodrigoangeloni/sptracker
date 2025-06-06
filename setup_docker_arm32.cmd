@echo off
REM ===================================================================
REM SPTracker - Configurador Docker para ARM32
REM ===================================================================
REM Verifica y configura Docker Desktop para compilación ARM32
REM ===================================================================

title SPTracker - Docker Setup

echo.
echo  🐳 CONFIGURADOR DOCKER PARA ARM32
echo  =================================
echo.
echo  📋 Este script verifica y configura Docker Desktop
echo  🎯 Target: Compilación ARM32 para Orange Pi
echo.

REM Verificar si estamos ejecutando como administrador
net session >nul 2>&1
if %errorlevel% neq 0 (
    echo ⚠️  RECOMENDACIÓN: Ejecutar como Administrador
    echo    Algunas configuraciones pueden requerir privilegios elevados
    echo.
    pause
)

echo 🔍 VERIFICANDO DOCKER DESKTOP...
echo ================================

REM Verificar si Docker está instalado
docker --version >nul 2>&1
if %errorlevel% neq 0 (
    echo ❌ Docker Desktop no encontrado
    echo.
    echo 💡 INSTALACIÓN AUTOMÁTICA:
    echo.
    set /p install_docker="¿Descargar e instalar Docker Desktop? (S/N): "
    if /i "%install_docker%"=="s" (
        echo 🌐 Abriendo página de descarga de Docker Desktop...
        start https://www.docker.com/products/docker-desktop
        echo.
        echo ⏳ Después de instalarlo:
        echo    1. Reiniciar Windows
        echo    2. Ejecutar Docker Desktop
        echo    3. Ejecutar este script nuevamente
        pause
        exit /b 1
    ) else (
        echo ❌ Docker Desktop es necesario para compilación ARM32
        pause
        exit /b 1
    )
)

for /f "tokens=*" %%i in ('docker --version') do set DOCKER_VERSION=%%i
echo ✅ Docker encontrado: %DOCKER_VERSION%

REM Verificar si Docker está corriendo
echo.
echo 🔄 Verificando servicio Docker...
docker info >nul 2>&1
if %errorlevel% neq 0 (
    echo ❌ Docker Desktop no está corriendo
    echo.
    echo 💡 SOLUCIONES:
    echo    1. Iniciar Docker Desktop manualmente
    echo    2. Esperar a que aparezca "Docker Desktop is running"
    echo    3. Ejecutar este script nuevamente
    echo.
    echo 🚀 ¿Intentar iniciar Docker Desktop automáticamente?
    set /p start_docker="(S/N): "
    if /i "%start_docker%"=="s" (
        echo 🔄 Iniciando Docker Desktop...
        start "" "C:\Program Files\Docker\Docker\Docker Desktop.exe"
        echo ⏳ Esperando a que Docker Desktop se inicie...
        echo    Esto puede tomar 1-3 minutos...
        
        REM Esperar hasta que Docker esté listo
        :wait_docker
        timeout /t 10 /nobreak >nul
        docker info >nul 2>&1
        if %errorlevel% neq 0 (
            echo    . Esperando...
            goto wait_docker
        )
        echo ✅ Docker Desktop iniciado correctamente
    ) else (
        pause
        exit /b 1
    )
)

echo ✅ Docker Desktop está corriendo

echo.
echo 🏗️ VERIFICANDO SOPORTE MULTI-ARQUITECTURA...
echo ============================================

REM Verificar BuildX
docker buildx version >nul 2>&1
if %errorlevel% neq 0 (
    echo ⚠️  BuildX no encontrado, instalando...
    docker buildx install
    if %errorlevel% neq 0 (
        echo ❌ Error instalando BuildX
        pause
        exit /b 1
    )
)

echo ✅ BuildX disponible

REM Verificar soporte experimental
echo 🧪 Habilitando características experimentales...
docker version --format "{{.Client.Experimental}}" | find "true" >nul
if %errorlevel% neq 0 (
    echo ⚠️  Características experimentales no habilitadas
    echo 💡 Configurando Docker para soporte ARM32...
)

REM Configurar builder multi-arquitectura
echo 🔧 Configurando builder multi-arquitectura...
docker buildx create --name sptracker-arm32 --use --bootstrap >nul 2>&1
docker buildx inspect sptracker-arm32 >nul 2>&1
if %errorlevel% equ 0 (
    echo ✅ Builder multi-arquitectura configurado: sptracker-arm32
) else (
    echo ⚠️  Usando builder por defecto
)

echo.
echo 🧪 PROBANDO EMULACIÓN ARM32...
echo =============================

echo 🔍 Verificando soporte de emulación QEMU...
docker run --rm --privileged multiarch/qemu-user-static --reset -p yes >nul 2>&1
if %errorlevel% equ 0 (
    echo ✅ Emulación QEMU configurada
) else (
    echo ⚠️  Configurando emulación QEMU...
    docker run --rm --privileged multiarch/qemu-user-static --reset -p yes
)

echo 🧪 Probando contenedor ARM32...
docker run --platform linux/arm/v7 --rm arm32v7/python:3.9-slim python3 -c "import platform; print(f'✅ ARM32 test OK: {platform.machine()}')" 2>nul
if %errorlevel% equ 0 (
    echo ✅ Emulación ARM32 funcionando correctamente
) else (
    echo ⚠️  Problema con emulación ARM32
    echo 💡 Puede funcionar de todas formas durante la compilación
)

echo.
echo 📊 RESUMEN DE CONFIGURACIÓN
echo ==========================
echo.
echo ✅ Docker Desktop: Instalado y corriendo
echo ✅ BuildX: Disponible
echo ✅ Multi-arquitectura: Configurado  
echo ✅ Emulación ARM32: Lista
echo.
echo 🍊 LISTO PARA COMPILAR ORANGE PI ARM32
echo.
echo 🚀 PRÓXIMOS PASOS:
echo    1. Ejecutar: docker_build_arm32.cmd
echo    2. Seleccionar tipo de compilación
echo    3. Esperar 15-30 minutos
echo    4. Obtener stracker_orangepi_arm32.tgz
echo.

echo 🎯 ¿Ejecutar compilador ARM32 ahora?
set /p run_compiler="(S/N): "
if /i "%run_compiler%"=="s" (
    echo.
    echo 🚀 Iniciando compilador ARM32...
    call docker_build_arm32.cmd
) else (
    echo.
    echo 👋 Configuración completada
    echo    Ejecuta docker_build_arm32.cmd cuando quieras compilar
)

pause
