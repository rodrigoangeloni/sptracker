# SPTracker v4.0.1 - Assetto Corsa Telemetry Suite

This is the source code of `ptracker` and `stracker` (or in short: `sptracker`), an app suite for 
Assetto Corsa with advanced telemetry tracking and race management capabilities.

**Original Author**: NEYS  
**Updated and Enhanced by**: Rodrigo Angeloni

## 🚀 What's New in v4.0.1

This enhanced version includes **revolutionary one-click compilation scripts** and significant improvements:

### ⚡ **One-Click Compilation System**
- **🎯 Windows**: Double-click `🎯 COMPILAR FÁCIL.cmd` - Super easy!
- **🐧 Linux/WSL**: Run `./compile_easy.sh` - Automatic dependency detection
- **🌍 Universal**: Use `python compile_smart.py` - Works everywhere
- **🔧 Smart error recovery**: Automatically fixes broken virtual environments
- **📋 Detailed logging**: Color-coded output with timestamped logs

### 🎮 **Enhanced Features**
- Orange Pi / ARM32 support for headless server deployment
- Enhanced build system with intelligent cross-platform compilation
- Automated setup and deployment scripts with dependency auto-installation
- Improved documentation and comprehensive user guides
- Performance optimizations for embedded systems
- Intelligent environment detection (Windows/Linux/WSL/macOS/ARM)

## 📚 Documentation / Documentación

- **🇬🇧 English**: This README (below)
- **🇪🇸 Español**: [README_ES.md](README_ES.md) - Guía completa en español
- **⚡ New Scripts**: [NUEVOS_SCRIPTS.md](NUEVOS_SCRIPTS.md) - New compilation scripts guide
- **📋 Quick Commands**: [COMANDOS_RAPIDOS.md](COMANDOS_RAPIDOS.md) - Comandos rápidos en español
- **🍊 Orange Pi/ARM32**: [README_OrangePi.md](README_OrangePi.md) - Orange Pi specific guide
- **✅ Project Status**: [PROYECTO_COMPLETADO.md](PROYECTO_COMPLETADO.md) - Implementation summary

Please respect the license as provided in [LICENSE.txt].

# Before you start modifying

Quoting NEYS from the original README.txt:
> I was hesitating for a long time to open up the source code for this. The main reason for this
> was the concern that there might be a lot of forks of ptracker and stracker with different 
> network protocols and that not enought care will be taken to make the protocols backwards and
> forward compatible. 
> 
> Now that I see, that my time for contributing to ptracker and stracker will be more limited
> than in the past, I think it is fair to open up the source code, so others might want to 
> jump in and help.
> 
> I can just appeal to the coders to consider contributing to the project instead creating a fork. 
> I'm willing to accept patches if they are mature enough to be integrated and integrate these 
> patches into the mainstream project with the usual experimental/stable releases.

NEYS has since said on [RaceDepartment.com](https://www.racedepartment.com/threads/sp-tracker_source.157319/#post-3380915):
> feel free to use the project for whatever purpose you like, as long as you respect the license.
> I fear I have to say that I've stepped down from playing AC recently and due to that my interest
> in the AC mods went also down. If you want to take over the project I am open to reference the
> fork in the main page here on RD, such that users are guided to your page. 

So Rodrigo Angeloni has taken over the project to enhance and modernize it, with a focus on:
- Adding Orange Pi / ARM32 support for embedded deployments
- Improving the build system and documentation
- Adding automated deployment tools
- Performance optimizations

You can find this enhanced version at https://github.com/rodrigoangeloni/sptracker and collaborate through issues and pull requests.

# 🚀 Quick Start - New One-Click Compilation

## 🎯 Super Easy Compilation (Recommended)

### **Windows Users** 🪟
```cmd
# Just double-click this file:
🎯 COMPILAR FÁCIL.cmd
```
**That's it!** The script will:
- ✅ Auto-detect Python, Assetto Corsa, and NSIS
- ✅ Set up virtual environment automatically
- ✅ Install all dependencies
- ✅ Compile both ptracker and stracker
- ✅ Generate installer files in `versions/` folder
- ✅ **Smart error recovery** - Automatically fixes broken virtual environments
- ✅ **Detailed logging** - Color-coded output with timestamped logs

### **Linux/WSL Users** 🐧
```bash
# Make executable (first time only):
chmod +x compile_easy.sh

# Compile:
./compile_easy.sh
```
**Features:**
- ✅ **Auto-detects** your Linux distribution (Ubuntu/Debian/CentOS/Arch)
- ✅ **Automatically installs** system dependencies
- ✅ **Orange Pi ARM32 support** - Detects and optimizes for ARM devices
- ✅ **Interactive menu** or direct command-line execution

### **Universal (Any OS)** 🌍
```bash
# Basic compilation:
python compile_smart.py

# Advanced options:
python compile_smart.py --help
python compile_smart.py --test --silent test-build
python compile_smart.py --client-only 1.0.0  # ptracker only
python compile_smart.py --server-only 1.0.0  # stracker only
python compile_smart.py --orangepi 1.0.0     # Orange Pi ARM32
python compile_smart.py --clean              # Clean build
```
**Cross-platform features:**
- ✅ **Works everywhere** - Windows/Linux/macOS/WSL/ARM
- ✅ **Intelligent detection** - OS, architecture, Python version
- ✅ **Automatic setup** - Virtual environments and dependencies
- ✅ **Multiple retry logic** - Handles compilation errors gracefully

## 📋 What You Get

After compilation, you'll find in the `versions/` folder:
- **`ptracker-V[version].exe`** - Client application for Assetto Corsa (~183 MB)
- **`stracker-V[version].zip`** - Server telemetry system (~20 MB)

## ⚡ Performance & Verification

### **Compilation Performance**
- **⏱️ Typical build time**: 3-4 minutes (test mode)
- **🔄 Smart caching**: Dependencies cached for faster subsequent builds
- **🧹 Auto-cleanup**: Temporary files automatically removed
- **📊 Progress tracking**: Real-time compilation status with timestamps

### **Verify Your Setup**
```bash
# Check all compilation scripts are working:
python verify_compilation_scripts.py
```

### **Troubleshooting**
- **📋 Detailed logs**: Check `compile_YYYYMMDD_HHMM.log` files
- **🔧 Auto-recovery**: Scripts automatically fix common issues
- **💡 Smart suggestions**: Error messages include troubleshooting tips

# 🛠️ Advanced Setup (Traditional Method)

If you prefer the traditional setup or need to customize the build process:

## 📋 Traditional Compilation Requirements

`create_release.py` does most of the work of fetching and installing dependencies
using virtualenv and pip, and building, but before running it, you need:
1. Windows (for ptracker GUI compilation)
1. Assetto Corsa (for Windows builds)
1. Python 3.8+
1. virtualenv (see [here](https://packaging.python.org/guides/installing-using-pip-and-virtual-environments/#installing-virtualenv) for installation instructions)
1. [Nullsoft Scriptable Install System 3.x](https://nsis.sourceforge.io/Download) (for Windows installers)
1. A linux environment (I use Ubuntu with WSL2, but a remote host also works)
1. A `release_settings.py` which you can make by copying and editing `release_settings.py.in`

**Note**: The new one-click scripts above handle most of these requirements automatically!

## 🔧 Manual Compilation

```bash
# Traditional method (if you need custom settings):
python create_release.py 1.0.0

# Or use the enhanced scripts with more options:
python compile_smart.py --client-only 1.0.0  # ptracker only
python compile_smart.py --server-only 1.0.0  # stracker only
python compile_smart.py --orangepi 1.0.0     # Orange Pi ARM32
```

# 📞 Support & Community

## 🐛 Issues & Bug Reports
- **GitHub Issues**: https://github.com/rodrigoangeloni/sptracker/issues
- **Feature Requests**: Use GitHub Issues with the "enhancement" label

## 👥 Contact Information

**Current Maintainer**: Rodrigo Angeloni
- GitHub: https://github.com/rodrigoangeloni/sptracker
- Issues & Pull Requests: https://github.com/rodrigoangeloni/sptracker/issues

**Original Author**: NEYS
- Assetto Corsa Forums: user `never_eat_yellow_snow1`
- RaceDepartment Forums: user `Neys`

---

## 🎉 v4.0.1 Release Highlights

### 🚀 **Revolutionary Build System**
- **🎯 One-Click Compilation**: `🎯 COMPILAR FÁCIL.cmd` for Windows
- **🐧 Intelligent Linux Support**: `./compile_easy.sh` with auto-dependency detection
- **🌍 Universal Script**: `python compile_smart.py` works on any platform
- **🔧 Smart Error Recovery**: Automatically fixes broken virtual environments
- **📋 Enhanced Logging**: Color-coded output with detailed timestamps

### 🛠️ **Technical Improvements**
- **⚡ Performance**: ~3-4 minute builds with intelligent caching
- **🔄 Retry Logic**: Up to 2 automatic retries for failed compilations
- **🧹 Auto-Cleanup**: Automatic removal of temporary build files
- **📊 Real-time Progress**: Live compilation status with time estimates

### 🌍 **Cross-Platform Excellence**
- **🍊 Orange Pi Support**: Native ARM32 compilation for embedded systems
- **🔍 Auto-Detection**: OS, architecture, Python version, dependencies
- **📦 Dependency Management**: Automatic installation of system packages
- **🎨 User Experience**: Interactive menus and silent automation modes

### 📚 **Documentation & Support**
- **📖 Complete Guides**: Comprehensive documentation in multiple languages
- **🔍 Verification Tools**: Built-in script validation and troubleshooting
- **📋 Detailed Logs**: Timestamped logs with color-coded error messages
- **💡 Smart Help**: Error messages include specific troubleshooting suggestions

**Download**: [Latest Release](https://github.com/rodrigoangeloni/sptracker/releases/latest)  
**Test Status**: ✅ Verified working on Windows 10/11, Ubuntu 20.04+, WSL2, Orange Pi
