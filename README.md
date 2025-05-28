# SPTracker - Assetto Corsa Telemetry Suite

This is the source code of `ptracker` and `stracker` (or in short: `sptracker`), an app suite for 
Assetto Corsa. 

**Original Author**: NEYS  
**Updated and Enhanced by**: Rodrigo Angeloni

This fork includes significant improvements and new features including:
- Orange Pi / ARM32 support for headless server deployment
- Enhanced build system with cross-platform compilation
- Automated setup and deployment scripts
- Improved documentation and user guides
- Performance optimizations for embedded systems

## 📚 Documentation / Documentación

- **🇬🇧 English**: This README (below)
- **🇪🇸 Español**: [README_ES.md](README_ES.md) - Guía completa en español
- **⚡ Quick Commands**: [COMANDOS_RAPIDOS.md](COMANDOS_RAPIDOS.md) - Comandos rápidos en español
- **🍊 Orange Pi/ARM32**: [README_OrangePi.md](README_OrangePi.md) - Orange Pi specific guide

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

# Getting started

`create_release.py` does most of the work of fetching and installing dependencies
using virtualenv and pip, and building, but before running it, you need:
1. Windows
1. Assetto Corsa
1. Python 3.8+
1. virtualenv (see [here](https://packaging.python.org/guides/installing-using-pip-and-virtual-environments/#installing-virtualenv) for installation instructions)
1. [Nullsoft Scriptable Install System 3.x](https://nsis.sourceforge.io/Download)
1. A linux environment (I use Ubuntu with WSL2, but a remote host also works)
1. A `release_settings.py` which you can make by copying and editing `release_settings.py.in`

# Contacting the authors

The original author NEYS is contactable as user `never_eat_yellow_snow1` at the
[Assetto Corsa forums](http://www.assettocorsa.net/forum/index.php) or as user `Neys` at the 
[RaceDepartment forums](http://www.racedepartment.com/forums/).

The current maintainer (Rodrigo Angeloni) can be contacted through GitHub issues at https://github.com/rodrigoangeloni/sptracker.
