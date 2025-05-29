@echo off
REM ===================================================================
REM SPTracker v4.0.1 - Compilación Automática para Windows
REM ===================================================================
REM Este script compila automáticamente SPTracker para Windows
REM Genera: ptracker-V4.0.1.exe y stracker-V4.0.1.zip
REM ===================================================================

echo.
echo ╔══════════════════════════════════════════════════════════════════╗
echo ║                 SPTracker v4.0.1 - Windows Build                ║
echo ╚══════════════════════════════════════════════════════════════════╝
echo.

REM Verificar que estamos en el directorio correcto
if not exist "release_settings.py" (
    echo ❌ ERROR: No se encuentra release_settings.py
    echo    Ejecuta este script desde el directorio raíz de SPTracker
    pause
    exit /b 1
)

REM Verificar que existe el entorno virtual
if not exist "env\windows" (
    echo ❌ ERROR: No se encuentra el entorno virtual de Windows
    echo    Ejecuta primero: inicio_rapido.ps1
    pause
    exit /b 1
)

echo 🔧 Activando entorno virtual de Python...
call env\windows\Scripts\activate.bat

echo 📋 Verificando entorno de compilación...
python --version
echo.

echo 🧹 Limpiando compilaciones anteriores...
if exist "dist" rmdir /s /q "dist" 2>nul
if exist "build" rmdir /s /q "build" 2>nul
if exist "nsis_temp_files*" del /q "nsis_temp_files*" 2>nul

echo 🚀 Iniciando compilación completa para Windows...
echo    - Cliente ptracker (GUI)
echo    - Servidor stracker (Web)
echo.

REM Ejecutar compilación con logging mejorado
python create_release.py --windows_only > build_log_windows_%date:~-4,4%%date:~-7,2%%date:~-10,2%.txt 2>&1

if %ERRORLEVEL% equ 0 (
    echo.
    echo ✅ ¡COMPILACIÓN EXITOSA!
    echo.
    echo 📦 Archivos generados:
    if exist "versions\ptracker-V4.0.1.exe" (
        echo    ✓ ptracker-V4.0.1.exe - Cliente Windows con GUI
        for %%i in ("versions\ptracker-V4.0.1.exe") do echo      Tamaño: %%~zi bytes
    )
    if exist "versions\stracker-V4.0.1.zip" (
        echo    ✓ stracker-V4.0.1.zip - Servidor web Windows  
        for %%i in ("versions\stracker-V4.0.1.zip") do echo      Tamaño: %%~zi bytes
    )
    echo.
    echo 📂 Ubicación: %CD%\versions\
    echo 📝 Log: build_log_windows_%date:~-4,4%%date:~-7,2%%date:~-10,2%.txt
    echo.
    echo 🎉 SPTracker v4.0.1 está listo para Windows!
) else (
    echo.
    echo ❌ ERROR EN LA COMPILACIÓN
    echo 📝 Revisa el log: build_log_windows_%date:~-4,4%%date:~-7,2%%date:~-10,2%.txt
    echo.
)

echo.
echo Presiona cualquier tecla para continuar...
pause >nul
