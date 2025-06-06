@echo off
REM ===================================================================
REM SPTracker v4.0.1 - Compilador Docker ARM32 para Orange Pi
REM ===================================================================
REM Compila para Orange Pi desde Windows usando Docker + emulación
REM ===================================================================

title SPTracker - Compilador Docker ARM32

echo.
echo  🍊 COMPILADOR DOCKER ARM32 PARA ORANGE PI
echo  ==========================================
echo.
echo  🐳 Compilación cross-platform usando Docker
echo  📦 Target: Orange Pi / Raspberry Pi (ARM32)
echo  💻 Host: Windows
echo.

REM Verificar Docker
echo 🔍 Verificando Docker Desktop...
docker --version >nul 2>&1
if %errorlevel% neq 0 (
    echo ❌ ERROR: Docker Desktop no encontrado
    echo.
    echo 💡 SOLUCIÓN:
    echo    1. Instalar Docker Desktop: https://www.docker.com/products/docker-desktop
    echo    2. Reiniciar Windows
    echo    3. Ejecutar este script nuevamente
    echo.
    pause
    exit /b 1
)

for /f "tokens=*" %%i in ('docker --version') do set DOCKER_VERSION=%%i
echo ✅ Docker detectado: %DOCKER_VERSION%

REM Verificar si Docker está corriendo
echo 🔄 Verificando servicio Docker...
docker info >nul 2>&1
if %errorlevel% neq 0 (
    echo ❌ ERROR: Docker Desktop no está corriendo
    echo.
    echo 💡 SOLUCIÓN:
    echo    1. Iniciar Docker Desktop
    echo    2. Esperar a que aparezca "Docker Desktop is running"
    echo    3. Ejecutar este script nuevamente
    echo.
    pause
    exit /b 1
)

echo ✅ Docker Desktop está corriendo

REM Verificar soporte multi-arquitectura
echo 🏗️ Verificando soporte multi-arquitectura...
docker buildx version >nul 2>&1
if %errorlevel% neq 0 (
    echo ⚠️  BuildX no encontrado, habilitando...
    docker buildx install
)

echo ✅ BuildX disponible

REM Configurar builder multi-arquitectura
echo 🔧 Configurando builder multi-arquitectura...
docker buildx create --name arm32builder --use --bootstrap >nul 2>&1
docker buildx inspect arm32builder >nul 2>&1

echo.
echo 🎯 OPCIONES DE COMPILACIÓN DOCKER ARM32
echo ======================================
echo.
echo    [1] Compilación RÁPIDA (solo binario)
echo    [2] Compilación COMPLETA (con dependencias)
echo    [3] Compilación de PRUEBA (validar entorno)
echo    [4] Ver información del sistema ARM32
echo    [0] Salir
echo.

:menu_choice
set /p choice="Selecciona opción (0-4): "

if "%choice%"=="1" goto build_fast
if "%choice%"=="2" goto build_complete
if "%choice%"=="3" goto build_test
if "%choice%"=="4" goto show_info
if "%choice%"=="0" goto exit_script

echo ❌ Opción inválida. Intenta de nuevo.
goto menu_choice

:build_fast
echo.
echo 🚀 COMPILACIÓN RÁPIDA ARM32
echo ===========================
echo ⏱️ Tiempo estimado: 15-20 minutos
echo 📦 Genera: stracker_orangepi_arm32.tgz
echo.
set /p confirm="¿Continuar? (S/N): "
if /i not "%confirm%"=="s" goto menu_choice

set VERSION=4.0.1-arm32-%date:~-4,4%%date:~-10,2%%date:~-7,2%
echo 🐳 Construyendo imagen ARM32...

docker buildx build --platform linux/arm/v7 --load -t sptracker-arm32:fast -f docker/Dockerfile.arm32.fast . --progress=plain
if %errorlevel% neq 0 goto build_error

echo 🏗️ Compilando SPTracker para Orange Pi...
docker run --platform linux/arm/v7 --rm -v "%CD%\versions:/app/versions" sptracker-arm32:fast %VERSION%
goto check_result

:build_complete
echo.
echo 🏗️ COMPILACIÓN COMPLETA ARM32
echo =============================
echo ⏱️ Tiempo estimado: 25-35 minutos
echo 📦 Genera: stracker_orangepi_arm32.tgz + extras
echo.
set /p confirm="¿Continuar? (S/N): "
if /i not "%confirm%"=="s" goto menu_choice

set VERSION=4.0.1-arm32-complete-%date:~-4,4%%date:~-10,2%%date:~-7,2%
echo 🐳 Construyendo imagen ARM32 completa...

docker buildx build --platform linux/arm/v7 --load -t sptracker-arm32:complete -f docker/Dockerfile.arm32.complete . --progress=plain
if %errorlevel% neq 0 goto build_error

echo 🏗️ Compilando SPTracker completo para Orange Pi...
docker run --platform linux/arm/v7 --rm -v "%CD%\versions:/app/versions" sptracker-arm32:complete %VERSION%
goto check_result

:build_test
echo.
echo 🧪 COMPILACIÓN DE PRUEBA ARM32
echo ==============================
echo ⏱️ Tiempo estimado: 5-10 minutos
echo 🔍 Valida: Entorno ARM32 + dependencias
echo.

docker buildx build --platform linux/arm/v7 --load -t sptracker-arm32:test -f docker/Dockerfile.arm32.test . --progress=plain
if %errorlevel% neq 0 goto build_error

echo 🧪 Ejecutando pruebas en entorno ARM32...
docker run --platform linux/arm/v7 --rm sptracker-arm32:test
goto check_result

:show_info
echo.
echo 📊 INFORMACIÓN DEL SISTEMA ARM32
echo ================================
echo.

docker run --platform linux/arm/v7 --rm arm32v7/python:3.9-slim uname -a
docker run --platform linux/arm/v7 --rm arm32v7/python:3.9-slim python3 --version
docker run --platform linux/arm/v7 --rm arm32v7/python:3.9-slim gcc --version

echo.
pause
goto menu_choice

:build_error
echo.
echo 💥 ERROR durante la construcción de la imagen Docker
echo.
echo 💡 POSIBLES SOLUCIONES:
echo    • Verificar conexión a internet
echo    • Liberar espacio en disco (mínimo 5GB)
echo    • Reiniciar Docker Desktop
echo    • Ejecutar: docker system prune -a
echo.
pause
goto menu_choice

:check_result
echo.
if %errorlevel% equ 0 (
    echo 🎉 ¡COMPILACIÓN ARM32 EXITOSA!
    echo.
    echo 📁 Archivos generados:
    if exist versions (
        echo.
        dir /b versions\*arm32* 2>nul
        echo.
    )
    echo 🍊 Listo para Orange Pi!
    echo.
    echo 📋 PRÓXIMOS PASOS:
    echo    1. Copiar archivo .tgz a tu Orange Pi
    echo    2. Extraer: tar -xzf stracker_orangepi_arm32.tgz
    echo    3. Ejecutar: ./stracker
) else (
    echo 💥 Error durante la compilación ARM32
    echo.
    echo 💡 CONSEJOS:
    echo    • Revisar logs anteriores
    echo    • Intentar compilación de prueba primero
    echo    • Verificar espacio en disco
    echo    • Comprobar conexión a internet
)

echo.
echo Presiona cualquier tecla para continuar...
pause >nul
goto menu_choice

:exit_script
echo.
echo 👋 ¡Hasta luego!
echo    Docker ARM32 Builder para SPTracker
exit /b 0
