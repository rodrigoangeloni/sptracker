# =====================================================
# SCRIPT DE INICIO RÁPIDO PARA SPTRACKER (PowerShell)
# =====================================================

param(
    [Parameter(Position=0)]
    [string]$Action = "help"
)

Write-Host "🏁 SPTracker - Script de Inicio Rápido" -ForegroundColor Cyan
Write-Host "======================================" -ForegroundColor Cyan

# Función para mostrar ayuda
function Show-Help {
    Write-Host ""
    Write-Host "🚀 Comandos disponibles:" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "  .\inicio_rapido.ps1 setup     - Configurar entorno de desarrollo"
    Write-Host "  .\inicio_rapido.ps1 windows   - Compilar para Windows"
    Write-Host "  .\inicio_rapido.ps1 linux     - Compilar para Linux"
    Write-Host "  .\inicio_rapido.ps1 orangepi  - Compilar para Orange Pi ARM32"
    Write-Host "  .\inicio_rapido.ps1 test      - Modo de prueba"
    Write-Host "  .\inicio_rapido.ps1 help      - Mostrar esta ayuda"
    Write-Host ""
    Write-Host "Ejemplos:" -ForegroundColor Green
    Write-Host "  .\inicio_rapido.ps1 setup"
    Write-Host "  .\inicio_rapido.ps1 test"
    Write-Host "  .\inicio_rapido.ps1 windows"
    Write-Host ""
}

# Función de setup
function Setup-Environment {
    Write-Host "🔧 Configurando entorno de desarrollo..." -ForegroundColor Yellow
    
    # Verificar Python
    try {
        $pythonVersion = python --version 2>$null
        Write-Host "✅ Python encontrado: $pythonVersion" -ForegroundColor Green
    }
    catch {
        Write-Host "❌ Python no encontrado. Instalar desde https://python.org" -ForegroundColor Red
        exit 1
    }
    
    # Crear configuración si no existe
    if (-not (Test-Path "release_settings.py")) {
        Write-Host "📋 Creando release_settings.py..." -ForegroundColor Yellow
        if (Test-Path "release_settings_ES.py.in") {
            Copy-Item "release_settings_ES.py.in" "release_settings.py"
            Write-Host "✅ Configuración creada con comentarios en español" -ForegroundColor Green
        }
        elseif (Test-Path "release_settings.py.in") {
            Copy-Item "release_settings.py.in" "release_settings.py"
            Write-Host "✅ Configuración creada" -ForegroundColor Green
        }
        else {
            Write-Host "❌ No se encontró plantilla de configuración" -ForegroundColor Red
            exit 1
        }
        Write-Host "⚠️  ¡IMPORTANTE: Edita release_settings.py con tus rutas!" -ForegroundColor Magenta
    }
    else {
        Write-Host "✅ release_settings.py ya existe" -ForegroundColor Green
    }
    
    # Crear directorio versions
    if (-not (Test-Path "versions")) {
        Write-Host "📁 Creando directorio versions..." -ForegroundColor Yellow
        New-Item -ItemType Directory -Name "versions" | Out-Null
        Write-Host "✅ Directorio versions creado" -ForegroundColor Green
    }
    else {
        Write-Host "✅ Directorio versions ya existe" -ForegroundColor Green
    }
    
    # Verificar Git
    try {
        $gitVersion = git --version 2>$null
        Write-Host "✅ Git encontrado: $gitVersion" -ForegroundColor Green
    }
    catch {
        Write-Host "⚠️  Git no encontrado. Instalar desde https://git-scm.com" -ForegroundColor Yellow
    }
    
    Write-Host "✅ Setup completado" -ForegroundColor Green
    Write-Host ""
    Write-Host "📝 Próximos pasos:" -ForegroundColor Cyan
    Write-Host "1. Editar release_settings.py con tus rutas"
    Write-Host "2. Ejecutar: .\inicio_rapido.ps1 test (para probar)"
    Write-Host "3. Ejecutar: .\inicio_rapido.ps1 windows (para compilar)"
}

# Función para compilar
function Compile-Project {
    param([string]$Platform)
    
    $version = "dev-$(Get-Date -Format 'yyyyMMdd')"
    
    Write-Host "🏗️ Compilando para $Platform..." -ForegroundColor Yellow
    Write-Host "Versión: $version" -ForegroundColor Cyan
    
    switch ($Platform) {
        "windows" {
            python create_release.py --windows_only $version
        }
        "linux" {
            python create_release.py --linux_only $version
        }
        "orangepi" {
            python create_release.py --orangepi_arm32_only $version
        }
        "test" {
            Write-Host "🧪 Modo de prueba - No se crearán archivos reales" -ForegroundColor Magenta
            python create_release.py --test_release_process --orangepi_arm32_only test
        }
    }
    
    if ($LASTEXITCODE -eq 0) {
        Write-Host "✅ Compilación exitosa" -ForegroundColor Green
        if ($Platform -ne "test") {
            Write-Host "📁 Archivos generados en: versions/" -ForegroundColor Cyan
            Get-ChildItem versions\ | Format-Table Name, Length, LastWriteTime
        }
    }
    else {
        Write-Host "❌ Error en la compilación" -ForegroundColor Red
        exit 1
    }
}

# Procesar argumentos
switch ($Action.ToLower()) {
    "setup" {
        Setup-Environment
    }
    "windows" {
        Compile-Project "windows"
    }
    "linux" {
        Compile-Project "linux"
    }
    "orangepi" {
        Compile-Project "orangepi"
    }
    "test" {
        Compile-Project "test"
    }
    default {
        Show-Help
    }
}
