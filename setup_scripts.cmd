@echo off
REM ===================================================================
REM SPTracker v4.0.1 - ACTIVADOR DE SCRIPTS UNIX EN WINDOWS
REM ===================================================================
REM Convierte archivos .sh para ser ejecutables en Git Bash
REM ===================================================================

echo.
echo 🔧 Configurando permisos de scripts para Git Bash...
echo.

REM Verificar si estamos en el directorio correcto
if not exist "compile_easy.sh" (
    echo ❌ ERROR: compile_easy.sh no encontrado
    echo    Ejecuta desde el directorio de SPTracker
    pause
    exit /b 1
)

REM Usar Git Bash para hacer ejecutables los scripts
echo 📋 Scripts a configurar:
echo    • compile_easy.sh
echo    • build_linux.sh  
echo    • build_universal.py
echo    • setup_orangepi.sh
echo    • validate_orangepi.sh
echo.

REM Verificar si Git Bash está disponible
where bash >nul 2>&1
if %errorlevel% neq 0 (
    echo ⚠️ Git Bash no encontrado en PATH
    echo    Intentando rutas comunes...
    
    if exist "C:\Program Files\Git\bin\bash.exe" (
        set BASH_CMD="C:\Program Files\Git\bin\bash.exe"
    ) else if exist "C:\Program Files (x86)\Git\bin\bash.exe" (
        set BASH_CMD="C:\Program Files (x86)\Git\bin\bash.exe"
    ) else (
        echo ❌ No se pudo encontrar Git Bash
        echo    Instala Git for Windows primero
        pause
        exit /b 1
    )
) else (
    set BASH_CMD=bash
)

echo 🚀 Configurando permisos con Git Bash...

REM Hacer ejecutables los scripts
%BASH_CMD% -c "chmod +x compile_easy.sh build_linux.sh setup_orangepi.sh validate_orangepi.sh create_release_orangepi_arm32.sh create_release.sh 2>/dev/null || true"

if %errorlevel% equ 0 (
    echo ✅ Permisos configurados correctamente
) else (
    echo ⚠️ No se pudieron configurar algunos permisos
    echo    Esto es normal en Windows - los scripts funcionarán igual
)

echo.
echo 📝 Scripts listos para usar:
echo.
echo    Windows (CMD):
echo    • 🎯 COMPILAR FÁCIL.cmd
echo    • 🚀 COMPILAR SPTRACKER.cmd
echo.
echo    Windows (PowerShell):
echo    • compile_easy.ps1
echo    • build_windows.ps1
echo.
echo    Linux/WSL/Git Bash:
echo    • ./compile_easy.sh
echo    • ./build_linux.sh
echo.
echo    Universal (Python):
echo    • python compile_smart.py
echo    • python build_universal.py
echo.
echo ✨ ¡Ya puedes compilar SPTracker fácilmente!
echo.
pause
