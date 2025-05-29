#!/usr/bin/env python3

# Release settings for WSL Linux compilation

import os

# Version del build
sptracker_version = "4.0.1"

# Paths for Linux/WSL environment
build_stracker_linux = True
build_ptracker = False  # No GUI in WSL
build_stracker_windows = False
build_stracker_orangepi_arm32 = False
build_stracker_packager = False

# Path al código fuente de Assetto Corsa (no necesario para stracker Linux)
ac_server_path = ""

# WSL build environment
use_virtualenv = True
virtualenv_path = "venv_wsl"

print(f"Linux WSL build configuration loaded for SPTracker v{sptracker_version}")
