# PowerShell script for managing Orange Pi builds from Windows
# Usage: .\orangepi-build.ps1 [command] [options]

param(
    [Parameter(Position=0)]
    [ValidateSet("setup", "build", "deploy", "status", "install", "clean", "help")]
    [string]$Command = "help",
    
    [Parameter()]
    [string]$OrangePiHost = "orangepi.local",
    
    [Parameter()]
    [string]$OrangePiUser = "orangepi",
    
    [Parameter()]
    [string]$Version = "dev",
    
    [Parameter()]
    [switch]$Force
)

# Configuration
$SSHOptions = @"-o", "StrictHostKeyChecking=no", "-o", "UserKnownHostsFile=NUL"
$ProjectRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
$SrackerPath = Join-Path $ProjectRoot "stracker"

function Write-Header {
    param([string]$Message)
    Write-Host "=" * 60 -ForegroundColor Cyan
    Write-Host $Message -ForegroundColor Yellow
    Write-Host "=" * 60 -ForegroundColor Cyan
}

function Write-Success {
    param([string]$Message)
    Write-Host "✓ $Message" -ForegroundColor Green
}

function Write-Error {
    param([string]$Message)
    Write-Host "✗ $Message" -ForegroundColor Red
}

function Write-Info {
    param([string]$Message)
    Write-Host "ℹ $Message" -ForegroundColor Blue
}

function Test-SSHConnection {
    param([string]$Host, [string]$User)
    
    Write-Info "Testing SSH connection to $User@$Host..."
    
    try {
        $result = ssh @SSHOptions $User@$Host "echo 'Connected'"
        if ($result -eq "Connected") {
            Write-Success "SSH connection successful"
            return $true
        }
    }
    catch {
        Write-Error "SSH connection failed: $_"
        return $false
    }
    return $false
}

function Setup-OrangePi {
    Write-Header "Setting up Orange Pi build environment"
    
    if (!(Test-SSHConnection $OrangePiHost $OrangePiUser)) {
        Write-Error "Cannot connect to Orange Pi. Check connection and credentials."
        return $false
    }
    
    Write-Info "Copying setup scripts to Orange Pi..."
    
    # Copy essential files
    $filesToCopy = @(
        "setup_orangepi.sh",
        "create_release_orangepi_arm32.sh",
        "README_OrangePi.md"
    )
    
    foreach ($file in $filesToCopy) {
        $localPath = Join-Path $ProjectRoot $file
        if (Test-Path $localPath) {
            scp @SSHOptions $localPath "$OrangePiUser@${OrangePiHost}:~/"
            Write-Success "Copied $file"
        } else {
            Write-Error "File not found: $file"
        }
    }
    
    Write-Info "Running setup on Orange Pi..."
    ssh @SSHOptions $OrangePiUser@$OrangePiHost "chmod +x ~/setup_orangepi.sh && ~/setup_orangepi.sh"
    
    Write-Success "Orange Pi setup completed"
    return $true
}

function Deploy-ToOrangePi {
    Write-Header "Deploying source code to Orange Pi"
    
    if (!(Test-SSHConnection $OrangePiHost $OrangePiUser)) {
        return $false
    }
    
    Write-Info "Creating remote directory..."
    ssh @SSHOptions $OrangePiUser@$OrangePiHost "mkdir -p ~/sptracker"
    
    Write-Info "Copying source files..."
    
    # Use robocopy to sync files (Windows equivalent of rsync)
    $excludeDirs = @("__pycache__", ".git", "dist", "build", "env", ".vs", "Win32", "x64")
    $excludeFiles = @("*.pyc", "*.pyo", "*.tmp", "*.log")
    
    # Copy main project files
    $robocopyArgs = @(
        $ProjectRoot,
        "\\$OrangePiHost\c$\Users\$OrangePiUser\sptracker",
        "/MIR",
        "/XD", ($excludeDirs -join " "),
        "/XF", ($excludeFiles -join " "),
        "/R:3",
        "/W:1"
    )
    
    # Alternative: use scp for cross-platform compatibility
    Write-Info "Using SCP to copy files..."
    
    # Copy stracker directory
    scp @SSHOptions -r $SrackerPath "$OrangePiUser@${OrangePiHost}:~/sptracker/"
    
    # Copy build scripts
    scp @SSHOptions (Join-Path $ProjectRoot "create_release_orangepi_arm32.sh") "$OrangePiUser@${OrangePiHost}:~/sptracker/"
    scp @SSHOptions (Join-Path $ProjectRoot "setup_orangepi.sh") "$OrangePiUser@${OrangePiHost}:~/sptracker/"
    
    Write-Success "Source code deployed"
    return $true
}

function Build-OnOrangePi {
    Write-Header "Building stracker on Orange Pi"
    
    if (!(Test-SSHConnection $OrangePiHost $OrangePiUser)) {
        return $false
    }
    
    Write-Info "Starting build on Orange Pi..."
    ssh @SSHOptions $OrangePiUser@$OrangePiHost "cd ~/sptracker && chmod +x create_release_orangepi_arm32.sh && ./create_release_orangepi_arm32.sh"
    
    if ($LASTEXITCODE -eq 0) {
        Write-Success "Build completed successfully"
        
        # Copy build results back
        Write-Info "Copying build results back to Windows..."
        scp @SSHOptions "$OrangePiUser@${OrangePiHost}:~/sptracker/stracker/stracker_orangepi_arm32.tgz" $SrackerPath
        
        if (Test-Path (Join-Path $SrackerPath "stracker_orangepi_arm32.tgz")) {
            Write-Success "Build results copied to: $(Join-Path $SrackerPath 'stracker_orangepi_arm32.tgz')"
        }
        
        return $true
    } else {
        Write-Error "Build failed"
        return $false
    }
}

function Install-OnOrangePi {
    Write-Header "Installing stracker on Orange Pi"
    
    if (!(Test-SSHConnection $OrangePiHost $OrangePiUser)) {
        return $false
    }
    
    Write-Info "Deploying stracker..."
    ssh @SSHOptions $OrangePiUser@$OrangePiHost "cd ~/sptracker/stracker && chmod +x deploy_orangepi.sh && ./deploy_orangepi.sh"
    
    Write-Info "Enabling and starting systemd service..."
    ssh @SSHOptions $OrangePiUser@$OrangePiHost "sudo systemctl enable stracker && sudo systemctl start stracker"
    
    Write-Success "Stracker installed and started"
    Write-Info "Web interface available at: http://${OrangePiHost}:50041"
    return $true
}

function Get-OrangePiStatus {
    Write-Header "Orange Pi stracker status"
    
    if (!(Test-SSHConnection $OrangePiHost $OrangePiUser)) {
        return $false
    }
    
    Write-Info "Service status:"
    ssh @SSHOptions $OrangePiUser@$OrangePiHost "sudo systemctl status stracker --no-pager"
    
    Write-Info "Recent logs:"
    ssh @SSHOptions $OrangePiUser@$OrangePiHost "sudo journalctl -u stracker --lines=20 --no-pager"
    
    return $true
}

function Clean-Build {
    Write-Header "Cleaning build artifacts"
    
    $pathsToClean = @(
        (Join-Path $SrackerPath "dist"),
        (Join-Path $SrackerPath "build"),
        (Join-Path $SrackerPath "env\orangepi_arm32"),
        (Join-Path $SrackerPath "stracker_orangepi_arm32.tgz"),
        (Join-Path $SrackerPath "deploy_orangepi.sh")
    )
    
    foreach ($path in $pathsToClean) {
        if (Test-Path $path) {
            Remove-Item -Path $path -Recurse -Force
            Write-Success "Removed: $path"
        }
    }
    
    # Clean on Orange Pi too
    if (Test-SSHConnection $OrangePiHost $OrangePiUser) {
        ssh @SSHOptions $OrangePiUser@$OrangePiHost "rm -rf ~/sptracker/stracker/dist ~/sptracker/stracker/build ~/sptracker/stracker/env/orangepi_arm32"
        Write-Success "Cleaned Orange Pi build artifacts"
    }
    
    return $true
}

function Show-Help {
    Write-Host @"
Orange Pi Build Script for sptracker

Usage: .\orangepi-build.ps1 [command] [options]

Commands:
  setup     - Setup Orange Pi build environment
  deploy    - Deploy source code to Orange Pi  
  build     - Build stracker on Orange Pi
  install   - Install and start stracker service
  status    - Show stracker status on Orange Pi
  clean     - Clean build artifacts
  help      - Show this help

Options:
  -OrangePiHost <host>    Orange Pi hostname or IP (default: orangepi.local)
  -OrangePiUser <user>    Orange Pi username (default: orangepi)
  -Version <version>      Build version (default: dev)
  -Force                  Force operation without prompts

Examples:
  .\orangepi-build.ps1 setup
  .\orangepi-build.ps1 deploy -OrangePiHost 192.168.1.100
  .\orangepi-build.ps1 build -Version 1.0.0
  .\orangepi-build.ps1 status

Prerequisites:
  - SSH client (OpenSSH or PuTTY)
  - SCP for file transfers
  - Network access to Orange Pi
  - SSH key or password authentication configured

"@ -ForegroundColor White
}

# Main execution
switch ($Command.ToLower()) {
    "setup" {
        Setup-OrangePi
    }
    "deploy" {
        Deploy-ToOrangePi
    }
    "build" {
        if (Deploy-ToOrangePi) {
            Build-OnOrangePi
        }
    }
    "install" {
        Install-OnOrangePi
    }
    "status" {
        Get-OrangePiStatus
    }
    "clean" {
        Clean-Build
    }
    "help" {
        Show-Help
    }
    default {
        Write-Error "Unknown command: $Command"
        Show-Help
    }
}

if ($LASTEXITCODE -ne 0) {
    Write-Error "Operation failed with exit code: $LASTEXITCODE"
    exit $LASTEXITCODE
}
