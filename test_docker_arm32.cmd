@echo off
REM ===================================================================
REM SPTracker - Test Rápido Docker ARM32
REM ===================================================================
REM Prueba rápida para verificar que Docker ARM32 funciona
REM ===================================================================

title SPTracker - Test Docker ARM32

echo.
echo  🧪 TEST RÁPIDO DOCKER ARM32
echo  ===========================
echo.

echo 🔍 Verificando Docker...
docker --version >nul 2>&1
if %errorlevel% neq 0 (
    echo ❌ Docker no encontrado
    echo 💡 Ejecuta setup_docker_arm32.cmd primero
    pause
    exit /b 1
)

echo ✅ Docker disponible

echo.
echo 🧪 Probando emulación ARM32...
echo ⏱️  Esto tomará 2-3 minutos...

docker buildx build --platform linux/arm/v7 --load -t sptracker-test-arm32 -f docker/Dockerfile.arm32.minimal . --progress=plain
if %errorlevel% neq 0 (
    echo ❌ Error construyendo imagen test ARM32
    pause
    exit /b 1
)

echo.
echo 🚀 Ejecutando test en contenedor ARM32...
docker run --platform linux/arm/v7 --rm sptracker-test-arm32

if %errorlevel% equ 0 (
    echo.
    echo 🎉 ¡TEST ARM32 EXITOSO!
    echo ✅ Docker ARM32 funciona correctamente
    echo 🍊 Listo para compilar SPTracker para Orange Pi
    echo.
    echo 🚀 ¿Ejecutar compilación completa ahora?
    set /p run_build="(S/N): "
    if /i "%run_build%"=="s" (
        echo.
        call docker_build_arm32.cmd
    )
) else (
    echo.
    echo ❌ Test ARM32 falló
    echo 💡 Verificar configuración Docker
)

echo.
pause
