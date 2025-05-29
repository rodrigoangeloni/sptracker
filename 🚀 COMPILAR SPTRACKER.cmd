@echo off
REM ===================================================================
REM SPTracker v4.0.1 - COMPILACIÓN DE UN CLIC
REM ===================================================================
REM Doble clic para compilar automáticamente
REM ===================================================================

title SPTracker v4.0.1 - Compilador Automático

echo.
echo ██████╗ ████████╗██████╗  █████╗  ██████╗██╗  ██╗███████╗██████╗ 
echo ██╔══██╗╚══██╔══╝██╔══██╗██╔══██╗██╔════╝██║ ██╔╝██╔════╝██╔══██╗
echo ██████╔╝   ██║   ██████╔╝███████║██║     █████╔╝ █████╗  ██████╔╝
echo ██╔═══╝    ██║   ██╔══██╗██╔══██║██║     ██╔═██╗ ██╔══╝  ██╔══██╗
echo ██║        ██║   ██║  ██║██║  ██║╚██████╗██║  ██╗███████╗██║  ██║
echo ╚═╝        ╚═╝   ╚═╝  ╚═╝╚═╝  ╚═╝ ╚═════╝╚═╝  ╚═╝╚══════╝╚═╝  ╚═╝
echo.
echo                    🏎️ Sistema de Telemetría v4.0.1
echo                    ================================
echo.

REM Detectar si estamos en el directorio correcto
if not exist "release_settings.py" (
    echo ❌ ERROR: Este script debe ejecutarse desde el directorio raíz de SPTracker
    echo    Directorio actual: %CD%
    echo.
    echo 💡 Mueve este archivo .bat al directorio que contiene release_settings.py
    echo.
    pause
    exit /b 1
)

echo ✨ ¡Bienvenido al compilador automático de SPTracker!
echo.
echo 🎯 Opciones disponibles:
echo    [1] Compilación COMPLETA (Cliente + Servidor Windows)
echo    [2] Solo CLIENTE (ptracker.exe con GUI)
echo    [3] Solo SERVIDOR (stracker.zip para web)
echo    [4] COMPILACIÓN MULTIPLATAFORMA (Windows + Linux)
echo    [5] Mostrar AYUDA
echo    [6] Salir
echo.

set /p choice="Selecciona una opción (1-6): "

if "%choice%"=="1" goto build_complete
if "%choice%"=="2" goto build_client
if "%choice%"=="3" goto build_server
if "%choice%"=="4" goto build_multi
if "%choice%"=="5" goto show_help
if "%choice%"=="6" goto exit_script

echo ❌ Opción inválida. Intenta de nuevo.
echo.
pause
goto :EOF

:build_complete
echo.
echo 🚀 Iniciando compilación COMPLETA para Windows...
call build_windows.cmd
goto end_script

:build_client
echo.
echo 🖥️ Compilando solo CLIENTE (ptracker)...
python build_universal.py --windows --ptracker
goto end_script

:build_server
echo.
echo 🌐 Compilando solo SERVIDOR (stracker)...
python build_universal.py --windows --stracker
goto end_script

:build_multi
echo.
echo 🌍 Iniciando compilación MULTIPLATAFORMA...
python build_universal.py --all
goto end_script

:show_help
echo.
echo ═══════════════════════════════════════════════════════════════════
echo                            📚 AYUDA
echo ═══════════════════════════════════════════════════════════════════
echo.
echo SPTracker v4.0.1 - Sistema de telemetría para Assetto Corsa
echo.
echo 🎯 OPCIONES DE COMPILACIÓN:
echo.
echo    1️⃣ COMPLETA: Genera ptracker-V4.0.1.exe y stracker-V4.0.1.zip
echo       • Cliente con interfaz gráfica para jugadores
echo       • Servidor web para administradores
echo       • Tamaño total: ~205 MB
echo.
echo    2️⃣ CLIENTE: Solo ptracker-V4.0.1.exe
echo       • Interfaz gráfica para telemetría en tiempo real
echo       • Para jugadores de Assetto Corsa
echo       • Tamaño: ~192 MB
echo.
echo    3️⃣ SERVIDOR: Solo stracker-V4.0.1.zip
echo       • Interface web para ver estadísticas
echo       • Para administradores de servidores
echo       • Tamaño: ~13 MB
echo.
echo    4️⃣ MULTIPLATAFORMA: Windows + Linux
echo       • Todos los binarios para ambas plataformas
echo       • Requiere WSL para Linux build
echo       • Tamaño total: ~220 MB
echo.
echo 📋 REQUISITOS:
echo    • Python 3.11+ instalado
echo    • Entorno virtual configurado (env\windows\)
echo    • NSIS instalado para generar .exe
echo    • PySide6 para interfaz gráfica
echo.
echo 📂 SALIDAS en directorio versions\:
echo    • ptracker-V4.0.1.exe      - Cliente Windows
echo    • stracker-V4.0.1.zip      - Servidor Windows  
echo    • stracker-V4.0.1-linux.tgz - Servidor Linux
echo.
echo 🔧 SOLUCIÓN DE PROBLEMAS:
echo    • Si falla: Ejecuta inicio_rapido.ps1 primero
echo    • Error NSIS: Instala desde https://nsis.sourceforge.io/
echo    • Error PySide6: pip install PySide6
echo.
echo ═══════════════════════════════════════════════════════════════════
echo.
pause
goto :EOF

:end_script
echo.
echo 🎉 ¡Proceso completado!
echo.
echo 📂 Revisa el directorio versions\ para ver los archivos generados
echo 📝 Logs disponibles en build_log_*.txt
echo.

:exit_script
echo.
echo 👋 ¡Gracias por usar SPTracker!
echo    🏎️ ¡Disfruta las carreras!
echo.
pause
