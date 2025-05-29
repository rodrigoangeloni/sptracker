@echo off
REM ===================================================================
REM SPTracker v4.0.1 - COMPILADOR SÚPER FÁCIL
REM ===================================================================
REM Doble clic y listo - Detecta todo automáticamente
REM ===================================================================

title SPTracker v4.0.1 - Compilador Inteligente

echo.
echo  ███████╗██████╗ ████████╗██████╗  █████╗  ██████╗██╗  ██╗███████╗██████╗ 
echo  ██╔════╝██╔══██╗╚══██╔══╝██╔══██╗██╔══██╗██╔════╝██║ ██╔╝██╔════╝██╔══██╗
echo  ███████╗██████╔╝   ██║   ██████╔╝███████║██║     █████╔╝ █████╗  ██████╔╝
echo  ╚════██║██╔═══╝    ██║   ██╔══██╗██╔══██║██║     ██╔═██╗ ██╔══╝  ██╔══██╗
echo  ███████║██║        ██║   ██║  ██║██║  ██║╚██████╗██║  ██╗███████╗██║  ██║
echo  ╚══════╝╚═╝        ╚═╝   ╚═╝  ╚═╝╚═╝  ╚═╝ ╚═════╝╚═╝  ╚═╝╚══════╝╚═╝  ╚═╝
echo.
echo                    🏎️ COMPILADOR INTELIGENTE v4.0.1
echo                    =====================================
echo.

REM Verificar directorio correcto
if not exist "create_release.py" (
    echo ❌ ERROR: Este script debe ejecutarse desde el directorio de SPTracker
    echo    Directorio actual: %CD%
    echo.
    echo 💡 Mueve este archivo al directorio que contiene create_release.py
    pause
    exit /b 1
)

echo 🧠 Detectando entorno automáticamente...
echo.

REM Detectar Python
set PYTHON_CMD=
for %%i in (python py python3) do (
    %%i --version >nul 2>&1
    if !errorlevel! equ 0 (
        set PYTHON_CMD=%%i
        goto :found_python
    )
)

echo ❌ Python no encontrado. Instala Python 3.7+ primero.
pause
exit /b 1

:found_python
for /f "tokens=*" %%i in ('%PYTHON_CMD% --version') do set PYTHON_VERSION=%%i
echo ✅ Python detectado: %PYTHON_VERSION%

REM Verificar configuración
if not exist "release_settings.py" (
    echo 📋 Creando configuración desde template...
    if exist "release_settings.py.in" (
        copy "release_settings.py.in" "release_settings.py" >nul
        echo ⚠️  IMPORTANTE: Edita release_settings.py con tus rutas antes de continuar
        echo.
        echo ¿Quieres abrir el archivo de configuración ahora? (S/N)
        set /p open_config=
        if /i "%open_config%"=="s" (
            notepad "release_settings.py"
        )
    ) else (
        echo ❌ No se encontró template de configuración
        pause
        exit /b 1
    )
)

REM Detectar Assetto Corsa
echo 🔍 Buscando Assetto Corsa...
set AC_FOUND=0

set "AC_PATHS[0]=C:\Program Files (x86)\Steam\steamapps\common\assettocorsa"
set "AC_PATHS[1]=C:\Program Files\Epic Games\AssettoCorsaCompetizione"
set "AC_PATHS[2]=D:\Games\Assetto Corsa"
set "AC_PATHS[3]=E:\Games\Assetto Corsa"

for /L %%i in (0,1,3) do (
    call set "AC_PATH=%%AC_PATHS[%%i]%%"
    if exist "!AC_PATH!\apps\python\system" (
        echo ✅ Assetto Corsa encontrado: !AC_PATH!
        set AC_FOUND=1
        goto :ac_check_done
    )
)

:ac_check_done
if %AC_FOUND% equ 0 (
    echo ⚠️  Assetto Corsa no detectado automáticamente
    echo    Verifica la ruta en release_settings.py
)

REM Detectar NSIS
if exist "C:\Program Files (x86)\NSIS\makensis.exe" (
    echo ✅ NSIS encontrado - Se crearán instaladores .exe
) else (
    echo ⚠️  NSIS no encontrado - Solo se crearán archivos ZIP
)

echo.
echo 🎯 ¿Qué quieres compilar?
echo    [1] COMPILACIÓN COMPLETA (Recomendado)
echo    [2] Solo CLIENTE para Assetto Corsa
echo    [3] Solo SERVIDOR web
echo    [4] COMPILACIÓN de PRUEBA (rápida)
echo    [5] LIMPIAR y compilar completo
echo    [6] Ver AYUDA
echo    [0] Salir
echo.

:menu_choice
set /p choice="Selecciona opción (0-6): "

if "%choice%"=="1" goto build_complete
if "%choice%"=="2" goto build_client
if "%choice%"=="3" goto build_server
if "%choice%"=="4" goto build_test
if "%choice%"=="5" goto build_clean
if "%choice%"=="6" goto show_help
if "%choice%"=="0" goto exit_script

echo ❌ Opción inválida. Intenta de nuevo.
goto menu_choice

:build_complete
echo.
echo 🏗️ COMPILACIÓN COMPLETA - Cliente + Servidor
echo ⏱️ Tiempo estimado: 10-15 minutos
echo.
set /p confirm="¿Continuar? (S/N): "
if /i not "%confirm%"=="s" goto menu_choice

set VERSION=4.0.1-%date:~-4,4%%date:~-10,2%%date:~-7,2%
echo 🚀 Iniciando compilación versión %VERSION%...
%PYTHON_CMD% create_release.py --windows_only %VERSION%
goto check_result

:build_client
echo.
echo 🎮 COMPILANDO SOLO CLIENTE para Assetto Corsa
echo ⏱️ Tiempo estimado: 5-8 minutos
echo.
set VERSION=client-4.0.1-%date:~-4,4%%date:~-10,2%%date:~-7,2%
echo 🚀 Iniciando compilación cliente %VERSION%...
%PYTHON_CMD% create_release.py --ptracker_only %VERSION%
goto check_result

:build_server
echo.
echo 🌐 COMPILANDO SOLO SERVIDOR web
echo ⏱️ Tiempo estimado: 3-5 minutos
echo.
set VERSION=server-4.0.1-%date:~-4,4%%date:~-10,2%%date:~-7,2%
echo 🚀 Iniciando compilación servidor %VERSION%...
%PYTHON_CMD% create_release.py --stracker_only --windows_only %VERSION%
goto check_result

:build_test
echo.
echo 🧪 COMPILACIÓN DE PRUEBA (modo test)
echo ⏱️ Tiempo estimado: 1-2 minutos
echo.
echo 🚀 Ejecutando pruebas de compilación...
%PYTHON_CMD% create_release.py --test_release_process --windows_only test-version
goto check_result

:build_clean
echo.
echo 🧹 LIMPIANDO archivos temporales...
if exist build rmdir /s /q build
if exist dist rmdir /s /q dist
if exist *.spec del /q *.spec
if exist ptracker-server-dist.py del /q ptracker-server-dist.py
if exist nsis_temp_files* rmdir /s /q nsis_temp_files*
if exist ptracker.nsh del /q ptracker.nsh

pushd stracker 2>nul
if exist build rmdir /s /q build
if exist dist rmdir /s /q dist
if exist *.spec del /q *.spec
popd

echo ✅ Limpieza completada
echo.
echo 🏗️ COMPILACIÓN COMPLETA después de limpieza
set VERSION=clean-4.0.1-%date:~-4,4%%date:~-10,2%%date:~-7,2%
echo 🚀 Iniciando compilación limpia %VERSION%...
%PYTHON_CMD% create_release.py --windows_only %VERSION%
goto check_result

:show_help
echo.
echo ╔══════════════════════════════════════════════════════════════════╗
echo ║                SPTracker v4.0.1 - Compilador Fácil              ║
echo ╚══════════════════════════════════════════════════════════════════╝
echo.
echo COMPILACIÓN COMPLETA:
echo   • Genera ptracker-V4.0.1.exe (cliente para Assetto Corsa)
echo   • Genera stracker-V4.0.1.zip (servidor web)
echo   • Tiempo: 10-15 minutos en primera ejecución
echo.
echo SOLO CLIENTE:
echo   • Solo genera ptracker-V4.0.1.exe
echo   • Para usar dentro de Assetto Corsa
echo   • Tiempo: 5-8 minutos
echo.
echo SOLO SERVIDOR:
echo   • Solo genera stracker-V4.0.1.zip
echo   • Para ejecutar servidor web independiente
echo   • Tiempo: 3-5 minutos
echo.
echo COMPILACIÓN DE PRUEBA:
echo   • Verifica que todo funcione sin crear archivos finales
echo   • Útil para detectar problemas
echo   • Tiempo: 1-2 minutos
echo.
echo ARCHIVOS GENERADOS:
echo   📁 versions\ptracker-V4.0.1.exe   - Instalador Windows
echo   📁 versions\stracker-V4.0.1.zip   - Servidor web
echo.
echo REQUISITOS:
echo   ✓ Python 3.7 o superior
echo   ✓ Assetto Corsa instalado
echo   ✓ NSIS (opcional, para instaladores .exe)
echo.
pause
goto menu_choice

:check_result
echo.
if %errorlevel% equ 0 (
    echo 🎉 ¡COMPILACIÓN EXITOSA!
    echo.
    echo 📁 Archivos generados en la carpeta "versions":
    if exist versions (
        dir /b versions\*%VERSION%*
    )
    echo.
    echo ✨ ¡Listo para usar!
) else (
    echo 💥 Error durante la compilación
    echo 📋 Revisa los mensajes anteriores para detalles
    echo.
    echo 💡 Consejos para solucionar problemas:
    echo    • Verifica que Python 3.7+ esté instalado
    echo    • Comprueba la ruta de Assetto Corsa en release_settings.py
    echo    • Intenta ejecutar en modo Administrador
    echo    • Deshabilita temporalmente el antivirus
)

echo.
echo Presiona cualquier tecla para continuar...
pause >nul

goto menu_choice

:exit_script
echo.
echo 👋 ¡Hasta luego!
echo    Visita: https://github.com/rodrigoangeloni/sptracker
exit /b 0
