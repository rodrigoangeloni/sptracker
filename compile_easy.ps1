# ===================================================================
# SPTracker v4.0.1 - SCRIPT DE COMPILACIÓN SUPER FÁCIL
# ===================================================================
# Script único que detecta todo automáticamente y compila
# ===================================================================

param(
    [string]$Version = "dev-$(Get-Date -Format 'yyyyMMdd-HHmm')",
    [switch]$Clean,
    [switch]$Test,
    [switch]$Silent,
    [switch]$Help
)

# Configuración
$ErrorActionPreference = "Stop"
$Script:LogFile = "compile_$(Get-Date -Format 'yyyyMMdd_HHmm').log"

function Write-Log {
    param([string]$Message, [string]$Color = "White")
    $timestamp = Get-Date -Format "HH:mm:ss"
    $logMessage = "[$timestamp] $Message"
    
    if (-not $Silent) {
        Write-Host $logMessage -ForegroundColor $Color
    }
    Add-Content -Path $Script:LogFile -Value $logMessage
}

function Show-Banner {
    if (-not $Silent) {
        Clear-Host
        Write-Host @"

 ░██████╗██████╗░████████╗██████╗░░█████╗░░█████╗░██╗░░██╗███████╗██████╗░
 ██╔════╝██╔══██╗╚══██╔══╝██╔══██╗██╔══██╗██╔══██╗██║░██╔╝██╔════╝██╔══██╗
 ╚█████╗░██████╔╝░░░██║░░░██████╔╝███████║██║░░╚═╝█████═╝░█████╗░░██████╔╝
 ░╚═══██╗██╔═══╝░░░░██║░░░██╔══██╗██╔══██║██║░░██╗██╔═██╗░██╔══╝░░██╔══██╗
 ██████╔╝██║░░░░░░░░██║░░░██║░░██║██║░░██║╚█████╔╝██║░╚██╗███████╗██║░░██║
 ╚═════╝░╚═╝░░░░░░░░╚═╝░░░╚═╝░░╚═╝╚═╝░░╚═╝░╚════╝░╚═╝░░╚═╝╚══════╝╚═╝░░╚═╝

      🏎️ COMPILADOR AUTOMÁTICO v4.0.1 - Sistema de Telemetría      
                         ⚡ DETECCIÓN AUTOMÁTICA ⚡

"@ -ForegroundColor Cyan
    }
}

function Show-Help {
    Write-Host @"
╔══════════════════════════════════════════════════════════════════╗
║                SPTracker v4.0.1 - Compilador Fácil              ║
╚══════════════════════════════════════════════════════════════════╝

DESCRIPCIÓN:
  Script inteligente que detecta automáticamente tu entorno y compila
  SPTracker de la manera más óptima.

USO:
  .\compile_easy.ps1                     # Compilación automática
  .\compile_easy.ps1 -Version "2.1.0"   # Versión específica
  .\compile_easy.ps1 -Clean              # Limpiar antes de compilar
  .\compile_easy.ps1 -Test               # Modo de prueba
  .\compile_easy.ps1 -Silent             # Sin salida visual
  .\compile_easy.ps1 -Help               # Mostrar ayuda

DETECCIÓN AUTOMÁTICA:
  ✓ Sistema operativo (Windows/Linux/WSL)
  ✓ Arquitectura (x64/ARM)
  ✓ Python disponible y versión
  ✓ Entorno virtual existente
  ✓ Assetto Corsa instalado
  ✓ NSIS para instaladores
  ✓ Dependencias necesarias

SALIDAS:
  • versions/ptracker-V{version}.exe    - Cliente Windows
  • versions/stracker-V{version}.zip    - Servidor multiplataforma
  • {script}.log                        - Log detallado de compilación

"@
    exit 0
}

function Test-Environment {
    Write-Log "🔍 Detectando entorno de compilación..." "Yellow"
    
    # Detectar OS
    $isWindows = $IsWindows -or ($PSVersionTable.PSVersion.Major -le 5)
    $isLinux = $IsLinux
    $isWSL = Test-Path "/proc/version" -and (Get-Content "/proc/version" -ErrorAction SilentlyContinue | Select-String "Microsoft|WSL")
    
    # Detectar arquitectura
    $arch = if ([Environment]::Is64BitOperatingSystem) { "x64" } else { "x86" }
    
    Write-Log "  • OS: $(if($isWindows){'Windows'}elseif($isWSL){'WSL'}elseif($isLinux){'Linux'}else{'Unknown'})"
    Write-Log "  • Arquitectura: $arch"
    
    # Verificar Python
    $pythonCmd = $null
    foreach ($cmd in @("python", "python3", "py")) {
        try {
            $version = & $cmd --version 2>&1
            if ($version -match "Python (\d+\.\d+)") {
                $pythonCmd = $cmd
                Write-Log "  • Python: $version ($pythonCmd)" "Green"
                break
            }
        } catch {}
    }
    
    if (-not $pythonCmd) {
        Write-Log "❌ Python no encontrado" "Red"
        throw "Python 3.7+ es requerido"
    }
    
    # Verificar directorio de trabajo
    if (-not (Test-Path "create_release.py")) {
        Write-Log "❌ No estás en el directorio correcto de SPTracker" "Red"
        throw "Ejecuta desde el directorio raíz de SPTracker"
    }
    
    # Verificar configuración
    if (-not (Test-Path "release_settings.py")) {
        Write-Log "⚠️ release_settings.py no existe, creando desde template..." "Yellow"
        if (Test-Path "release_settings.py.in") {
            Copy-Item "release_settings.py.in" "release_settings.py"
            Write-Log "📋 release_settings.py creado. ¡Edítalo con tus rutas!" "Magenta"
        } else {
            throw "No se encontró release_settings.py.in template"
        }
    }
    
    # Verificar Assetto Corsa (solo para Windows)
    if ($isWindows) {
        $acPaths = @(
            "C:\Program Files (x86)\Steam\steamapps\common\assettocorsa",
            "C:\Program Files\Epic Games\AssettoCorsaCompetizione",
            "D:\Games\Assetto Corsa",
            "E:\Games\Assetto Corsa"
        )
        
        $acFound = $false
        foreach ($path in $acPaths) {
            if (Test-Path "$path\apps\python\system") {
                Write-Log "  • Assetto Corsa: $path" "Green"
                $acFound = $true
                break
            }
        }
        
        if (-not $acFound) {
            Write-Log "⚠️ Assetto Corsa no detectado automáticamente" "Yellow"
            Write-Log "   Verifica la ruta en release_settings.py"
        }
    }
    
    # Verificar NSIS (solo para Windows)
    if ($isWindows) {
        $nsisPath = "C:\Program Files (x86)\NSIS\makensis.exe"
        if (Test-Path $nsisPath) {
            Write-Log "  • NSIS: Encontrado" "Green"
        } else {
            Write-Log "⚠️ NSIS no encontrado - Los instaladores .exe no se crearán" "Yellow"
        }
    }
    
    return @{
        Python = $pythonCmd
        IsWindows = $isWindows
        IsLinux = $isLinux
        IsWSL = $isWSL
        Architecture = $arch
    }
}

function Install-Dependencies {
    param($Environment)
    
    Write-Log "📦 Verificando dependencias..." "Yellow"
    
    # Crear entorno virtual si no existe
    $envPath = if ($Environment.IsWindows) { "env\windows" } else { "env/linux" }
    
    if (-not (Test-Path $envPath)) {
        Write-Log "🔧 Creando entorno virtual..." "Yellow"
        & $Environment.Python -m venv $envPath
    }
    
    # Activar entorno virtual
    $activateScript = if ($Environment.IsWindows) { 
        "$envPath\Scripts\Activate.ps1" 
    } else { 
        "$envPath/bin/activate" 
    }
    
    if (Test-Path $activateScript) {
        Write-Log "✅ Entorno virtual preparado" "Green"
    }
}

function Start-Compilation {
    param($Environment, $Version)
    
    Write-Log "🏗️ Iniciando compilación..." "Yellow"
    Write-Log "   Versión: $Version"
    
    # Determinar parámetros de compilación
    $buildArgs = @($Version)
    
    if ($Test) {
        $buildArgs = @("--test_release_process") + $buildArgs
        Write-Log "🧪 Modo de prueba activado" "Magenta"
    }
    
    if ($Environment.IsWindows -and -not $Environment.IsWSL) {
        $buildArgs = @("--windows_only") + $buildArgs
        Write-Log "🪟 Compilando para Windows solamente"
    } elseif ($Environment.IsLinux -or $Environment.IsWSL) {
        $buildArgs = @("--linux_only") + $buildArgs
        Write-Log "🐧 Compilando para Linux"
    }
    
    # Ejecutar compilación
    $startTime = Get-Date
    Write-Log "⏱️ Compilación iniciada: $($startTime.ToString('HH:mm:ss'))" "Cyan"
    
    try {
        & $Environment.Python "create_release.py" $buildArgs
        
        if ($LASTEXITCODE -eq 0) {
            $endTime = Get-Date
            $duration = $endTime - $startTime
            Write-Log "✅ Compilación exitosa en $($duration.Minutes)m $($duration.Seconds)s" "Green"
            
            # Mostrar archivos generados
            if (Test-Path "versions") {
                Write-Log "📁 Archivos generados:" "Green"
                Get-ChildItem "versions" -Filter "*$Version*" | ForEach-Object {
                    $size = [math]::Round($_.Length / 1MB, 1)
                    Write-Log "   • $($_.Name) ($size MB)"
                }
            }
            
            return $true
        } else {
            throw "Error en la compilación (código: $LASTEXITCODE)"
        }
    } catch {
        Write-Log "❌ Error durante la compilación: $($_.Exception.Message)" "Red"
        return $false
    }
}

function Invoke-Cleanup {
    Write-Log "🧹 Limpiando archivos temporales..." "Yellow"
    
    $cleanupItems = @(
        "build",
        "dist", 
        "*.spec",
        "ptracker-server-dist.py",
        "nsis_temp_files*",
        "ptracker.nsh"
    )
    
    foreach ($item in $cleanupItems) {
        if (Test-Path $item) {
            Remove-Item $item -Recurse -Force -ErrorAction SilentlyContinue
            Write-Log "  • Eliminado: $item"
        }
    }
    
    # Limpiar en subdirectorio stracker
    if (Test-Path "stracker") {
        Push-Location "stracker"
        foreach ($item in @("build", "dist", "*.spec")) {
            if (Test-Path $item) {
                Remove-Item $item -Recurse -Force -ErrorAction SilentlyContinue
                Write-Log "  • Eliminado: stracker/$item"
            }
        }
        Pop-Location
    }
    
    Write-Log "✅ Limpieza completada" "Green"
}

# ===================================================================
# PROGRAMA PRINCIPAL
# ===================================================================

if ($Help) { Show-Help }

Show-Banner

Write-Log "🚀 SPTracker v4.0.1 - Compilador Automático" "Cyan"
Write-Log "📅 $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')"
Write-Log "📂 Directorio: $PWD"
Write-Log "📋 Log: $Script:LogFile"
Write-Log ""

try {
    # Detectar entorno
    $env = Test-Environment
    
    # Limpiar si se solicita
    if ($Clean) {
        Invoke-Cleanup
    }
    
    # Instalar dependencias
    Install-Dependencies -Environment $env
    
    # Compilar
    $success = Start-Compilation -Environment $env -Version $Version
    
    if ($success) {
        Write-Log ""
        Write-Log "🎉 ¡COMPILACIÓN COMPLETADA CON ÉXITO!" "Green"
        Write-Log "📁 Revisa la carpeta 'versions/' para los archivos generados"
        Write-Log "📋 Log completo guardado en: $Script:LogFile"
        
        if (-not $Silent) {
            Write-Host ""
            Write-Host "Presiona cualquier tecla para continuar..." -ForegroundColor Gray
            $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
        }
    } else {
        Write-Log "💥 COMPILACIÓN FALLIDA" "Red"
        Write-Log "📋 Revisa el log para más detalles: $Script:LogFile"
        exit 1
    }
    
} catch {
    Write-Log "💥 ERROR CRÍTICO: $($_.Exception.Message)" "Red"
    Write-Log "📋 Log guardado en: $Script:LogFile"
    
    if (-not $Silent) {
        Write-Host ""
        Write-Host "Presiona cualquier tecla para salir..." -ForegroundColor Gray
        $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
    }
    exit 1
}
