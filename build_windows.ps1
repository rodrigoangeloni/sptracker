# ===================================================================
# SPTracker v4.0.1 - Compilación PowerShell para Windows
# ===================================================================
# Script optimizado para compilación rápida y eficiente
# Genera binarios listos para distribución
# ===================================================================

param(
    [switch]$PtrackerOnly,
    [switch]$StrackerOnly,
    [switch]$Clean,
    [switch]$Help
)

function Show-Help {
    Write-Host @"
╔══════════════════════════════════════════════════════════════════╗
║                 SPTracker v4.0.1 - Build Script                 ║
╚══════════════════════════════════════════════════════════════════╝

USO:
  .\build_windows.ps1                    # Compilación completa
  .\build_windows.ps1 -PtrackerOnly      # Solo cliente GUI
  .\build_windows.ps1 -StrackerOnly      # Solo servidor web
  .\build_windows.ps1 -Clean             # Limpiar y compilar
  .\build_windows.ps1 -Help              # Mostrar esta ayuda

SALIDAS:
  • ptracker-V4.0.1.exe   - Cliente Windows con interfaz gráfica
  • stracker-V4.0.1.zip   - Servidor web para Windows

REQUISITOS:
  • Python 3.11+ con PySide6
  • Entorno virtual en env\windows\
  • NSIS para generar instalador

"@
}

function Write-Banner {
    Write-Host @"

╔══════════════════════════════════════════════════════════════════╗
║                 SPTracker v4.0.1 - Windows Build                ║
║                      🏎️  Telemetry System                        ║
╚══════════════════════════════════════════════════════════════════╝

"@ -ForegroundColor Cyan
}

function Test-Prerequisites {
    Write-Host "🔍 Verificando requisitos..." -ForegroundColor Yellow
    
    # Verificar directorio
    if (-not (Test-Path "release_settings.py")) {
        Write-Host "❌ ERROR: No se encuentra release_settings.py" -ForegroundColor Red
        Write-Host "   Ejecuta este script desde el directorio raíz de SPTracker" -ForegroundColor Red
        exit 1
    }
    
    # Verificar entorno virtual
    if (-not (Test-Path "env\windows")) {
        Write-Host "❌ ERROR: No se encuentra el entorno virtual de Windows" -ForegroundColor Red
        Write-Host "   Ejecuta primero: .\inicio_rapido.ps1" -ForegroundColor Red
        exit 1
    }
    
    Write-Host "✅ Requisitos verificados" -ForegroundColor Green
}

function Invoke-Cleanup {
    Write-Host "🧹 Limpiando archivos temporales..." -ForegroundColor Yellow
    
    $cleanupPaths = @("dist", "build", "*.spec")
    foreach ($path in $cleanupPaths) {
        if (Test-Path $path) {
            Remove-Item $path -Recurse -Force -ErrorAction SilentlyContinue
        }
    }
    
    Get-ChildItem -Name "nsis_temp_files*" | Remove-Item -Force -ErrorAction SilentlyContinue
    Write-Host "✅ Limpieza completada" -ForegroundColor Green
}

function Start-Build {
    param($BuildType)
    
    Write-Host "🚀 Iniciando compilación..." -ForegroundColor Yellow
    
    # Activar entorno virtual
    & "env\windows\Scripts\Activate.ps1"
    
    # Verificar Python
    $pythonVersion = python --version 2>&1
    Write-Host "🐍 $pythonVersion" -ForegroundColor Blue
    
    # Determinar argumentos de compilación
    $buildArgs = @()
    switch ($BuildType) {
        "ptracker" { $buildArgs += "--ptracker_only" }
        "stracker" { $buildArgs += "--stracker_only" }
        "windows"  { $buildArgs += "--windows_only" }
        default    { $buildArgs += "--windows_only" }
    }
    
    # Generar log con timestamp
    $timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
    $logFile = "build_log_windows_$timestamp.txt"
    
    Write-Host "📝 Log: $logFile" -ForegroundColor Blue
    
    # Ejecutar compilación
    $process = Start-Process -FilePath "python" -ArgumentList (@("create_release.py") + $buildArgs) -NoNewWindow -PassThru -RedirectStandardOutput $logFile -RedirectStandardError $logFile
    $process.WaitForExit()
    
    return $process.ExitCode, $logFile
}

function Show-Results {
    param($ExitCode, $LogFile)
    
    if ($ExitCode -eq 0) {
        Write-Host @"

✅ ¡COMPILACIÓN EXITOSA!

📦 Archivos generados:
"@ -ForegroundColor Green
        
        $versions = Get-ChildItem "versions" -Filter "*.exe", "*.zip" | Sort-Object Name
        foreach ($file in $versions) {
            $size = [math]::Round($file.Length / 1MB, 1)
            Write-Host "   ✓ $($file.Name) - $size MB" -ForegroundColor Green
        }
        
        Write-Host @"

📂 Ubicación: $(Get-Location)\versions\
📝 Log detallado: $LogFile

🎉 SPTracker v4.0.1 está listo para Windows!
"@ -ForegroundColor Green
        
    } else {
        Write-Host @"

❌ ERROR EN LA COMPILACIÓN

📝 Revisa el log detallado: $LogFile
🔍 Errores comunes:
   • Falta PySide6: pip install PySide6
   • Falta NSIS: Instalar desde https://nsis.sourceforge.io/
   • Permisos insuficientes: Ejecutar como administrador

"@ -ForegroundColor Red
    }
}

# ===================================================================
# SCRIPT PRINCIPAL
# ===================================================================

if ($Help) {
    Show-Help
    exit 0
}

Write-Banner
Test-Prerequisites

if ($Clean) {
    Invoke-Cleanup
}

# Determinar tipo de build
$buildType = "windows"
if ($PtrackerOnly) { $buildType = "ptracker" }
if ($StrackerOnly) { $buildType = "stracker" }

$startTime = Get-Date
$exitCode, $logFile = Start-Build $buildType
$buildTime = (Get-Date) - $startTime

Write-Host "⏱️ Tiempo de compilación: $([math]::Round($buildTime.TotalMinutes, 1)) minutos" -ForegroundColor Blue

Show-Results $exitCode $logFile

Write-Host "`nPresiona cualquier tecla para continuar..." -ForegroundColor Gray
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
