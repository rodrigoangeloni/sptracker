#!/bin/bash
# Orange Pi setup script for sptracker compilation
# Run this script on your Orange Pi to prepare the build environment

set -e  # Exit on any error

echo "========================================================"
echo "Setting up Orange Pi for sptracker compilation"
echo "========================================================"

# Check if running on Orange Pi / ARM
ARCH=$(uname -m)
echo "Detected architecture: $ARCH"

if [[ "$ARCH" != "armv7l" && "$ARCH" != "armhf" && "$ARCH" != "arm"* ]]; then
    echo "Warning: This script is designed for ARM architecture"
    echo "Current architecture: $ARCH"
    read -p "Continue anyway? (y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        exit 1
    fi
fi

# Update system packages
echo "Updating system packages..."
sudo apt-get update

# Install required system dependencies
echo "Installing system dependencies..."
sudo apt-get install -y \
    python3 \
    python3-dev \
    python3-pip \
    python3-venv \
    build-essential \
    libsqlite3-dev \
    sqlite3 \
    libpq-dev \
    pkg-config \
    git \
    wget \
    curl \
    zip \
    unzip

# Check Python version
PYTHON_VERSION=$(python3 --version 2>&1 | cut -d' ' -f2)
echo "Python version: $PYTHON_VERSION"

# Verify minimum Python version (3.7+)
python3 -c "
import sys
if sys.version_info < (3, 7):
    print('ERROR: Python 3.7+ is required')
    sys.exit(1)
print('Python version check: OK')
"

# Create build directory
BUILD_DIR="$HOME/sptracker_build"
echo "Creating build directory: $BUILD_DIR"
mkdir -p "$BUILD_DIR"

# Clone or update sptracker repository (if not already present)
if [ ! -d "$BUILD_DIR/sptracker" ]; then
    echo "Cloning sptracker repository..."
    cd "$BUILD_DIR"
    # Replace with your actual repository URL
    git clone https://github.com/rodrigoangeloni/sptracker.git
else
    echo "Updating existing sptracker repository..."
    cd "$BUILD_DIR/sptracker"
    git pull
fi

cd "$BUILD_DIR/sptracker"

# Make build scripts executable
chmod +x create_release_orangepi_arm32.sh

# Create Python virtual environment
echo "Creating Python virtual environment..."
VENV_DIR="$BUILD_DIR/sptracker/stracker/env/orangepi_arm32"
python3 -m venv "$VENV_DIR"

# Activate virtual environment and install base packages
echo "Installing base Python packages..."
source "$VENV_DIR/bin/activate"

# Upgrade pip and essential tools
pip install --upgrade pip setuptools wheel

# Install packages that are known to work well on ARM
pip install --upgrade \
    bottle \
    cherrypy \
    python-dateutil \
    wsgi-request-logger \
    simplejson

# Try to install psycopg2-binary (better ARM compatibility)
echo "Installing PostgreSQL adapter..."
pip install psycopg2-binary || {
    echo "Failed to install psycopg2-binary, trying source version..."
    sudo apt-get install -y libpq5
    pip install psycopg2 || echo "Warning: PostgreSQL support may not be available"
}

# Install PyInstaller
echo "Installing PyInstaller..."
pip install pyinstaller

# Install APSW (SQLite wrapper)
echo "Installing APSW..."
pip install apsw || {
    echo "Failed to install APSW from PyPI, trying source compilation..."
    pip install https://github.com/rogerbinns/apsw/releases/download/3.35.4-r1/apsw-3.35.4-r1.zip \
        --global-option=fetch --global-option=--version --global-option=3.35.4 --global-option=--all \
        --global-option=build --global-option=--enable-all-extensions || {
        echo "Warning: APSW installation failed. Some SQLite features may not work."
    }
}

deactivate

# Create systemd service file for stracker
echo "Creating systemd service file..."
sudo tee /etc/systemd/system/stracker.service > /dev/null << 'EOF'
[Unit]
Description=sptracker stracker server
After=network.target

[Service]
Type=simple
User=orangepi
WorkingDirectory=/home/orangepi/stracker
ExecStart=/home/orangepi/stracker/stracker_orangepi_arm32
Restart=always
RestartSec=10

[Install]
WantedBy=multi-user.target
EOF

# Create init script for systems without systemd
echo "Creating init script..."
sudo tee /etc/init.d/stracker > /dev/null << 'EOF'
#!/bin/bash
### BEGIN INIT INFO
# Provides:          stracker
# Required-Start:    $remote_fs $syslog $network
# Required-Stop:     $remote_fs $syslog $network
# Default-Start:     2 3 4 5
# Default-Stop:      0 1 6
# Short-Description: sptracker stracker server
# Description:       Assetto Corsa sptracker stracker server
### END INIT INFO

USER="orangepi"
DAEMON="stracker_orangepi_arm32"
ROOT_DIR="/home/orangepi/stracker"

SERVER="$ROOT_DIR/$DAEMON"
LOCK_FILE="/var/lock/stracker"

start() {
    if [ -f "$LOCK_FILE" ] ; then
        echo "stracker is already running"
        return 1
    fi
    echo -n "Starting $DAEMON: "
    runuser -l "$USER" -c "$SERVER" && echo " OK" || echo " ERROR"
    echo $(pgrep -f $DAEMON) > "$LOCK_FILE"
}

stop() {
    if [ ! -f "$LOCK_FILE" ] ; then
        echo "stracker is not running"
        return 1
    fi
    echo -n "Shutting down $DAEMON: "
    pid=$(cat "$LOCK_FILE")
    kill -9 $pid && echo " OK" || echo " ERROR"
    rm -f "$LOCK_FILE"
}

status() {
    if [ -f "$LOCK_FILE" ] ; then
        echo "stracker is running"
    else
        echo "stracker is not running"
    fi
}

case "$1" in
    start)
        start
        ;;
    stop)
        stop
        ;;
    status)
        status
        ;;
    restart)
        stop
        start
        ;;
    *)
        echo "Usage: $0 {start|stop|status|restart}"
esac

exit 0
EOF

sudo chmod +x /etc/init.d/stracker

# Create deployment directory
echo "Creating deployment directory..."
mkdir -p "$HOME/stracker"

# Create simple configuration file
cat > "$HOME/stracker/stracker.ini" << 'EOF'
# Basic stracker configuration for Orange Pi

[STRACKER_CONFIG]
# Enable web interface
enabled = True

# Listen on all interfaces (change to specific IP if needed)
listen_addr = 0.0.0.0
listen_port = 50041

# Database configuration
database_type = sqlite3
database_file = stracker.db

# Enable AC server pickup
pickup_mode_enabled = True

# Log level (DEBUG, INFO, WARNING, ERROR)
log_level = INFO

[AC_SERVER_CFG]
# Assetto Corsa server configuration
ac_server_config_ini = 
EOF

echo "========================================================"
echo "Orange Pi setup completed successfully!"
echo "========================================================"
echo
echo "Next steps:"
echo "1. Edit the configuration file: ~/stracker/stracker.ini"
echo "2. Build stracker: cd $BUILD_DIR/sptracker && ./create_release_orangepi_arm32.sh"
echo "3. Deploy: cd $BUILD_DIR/sptracker/stracker && ./deploy_orangepi.sh"
echo "4. Start stracker: sudo systemctl start stracker"
echo "   or: sudo service stracker start"
echo
echo "Web interface will be available at: http://your-orangepi-ip:50041"
echo
echo "Build directory: $BUILD_DIR/sptracker"
echo "Deployment directory: ~/stracker"
echo
