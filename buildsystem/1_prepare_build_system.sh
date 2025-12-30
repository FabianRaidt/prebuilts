#!/bin/bash

# Init
sudo apt-get update
sudo apt-get -y -q upgrade

# Apt packages to build aasdk
sudo apt-get install -y -q --no-install-recommends libboost-all-dev libusb-1.0.0-dev libssl-dev cmake libprotobuf-dev protobuf-c-compiler protobuf-compiler git

# Remove unwanted packages (if present)
sudo apt-get remove --purge -y -q --no-install-recommends libqt5multimedia5 libqt5multimedia5-plugins libqt5multimediawidgets5 qtmultimedia5-dev libqt5bluetooth5 libqt5bluetooth5-bin qtconnectivity5-dev 2>/dev/null || true

# Apt packages to build qt5
sudo apt-get -y -q -f install --no-install-recommends build-essential libfontconfig1-dev libdbus-1-dev libfreetype6-dev libicu-dev libsqlite3-dev libssl-dev libglib2.0-dev bluez libbluetooth-dev libasound2-dev libgstreamer1.0-dev libgstreamer-plugins-base1.0-dev libxkbcommon-dev libwayland-dev libasound2-dev build-essential libfontconfig1-dev libdbus-1-dev libfreetype6-dev libicu-dev libinput-dev libxkbcommon-dev libsqlite3-dev libglib2.0-dev libxcb1-dev libfontconfig1-dev libfreetype6-dev libx11-dev libxext-dev libxfixes-dev libxi-dev libxrender-dev libxcb1-dev libx11-xcb-dev libxcb-glx0-dev libts-dev pulseaudio libpulse-dev librtaudio-dev librtaudio-dev bluez libbluetooth-dev libdbus-c++-dev libdouble-conversion-dev '^libxcb.*-dev' libxcb-xinerama0-dev libproxy-dev libjpeg-dev libjpeg62-turbo-dev libbluetooth-dev bluez libatspi-dev libsctp-dev libxkbcommon-x11-dev libgles2-mesa-dev libgbm-dev libegl1-mesa-dev libgbm-dev libgles2-mesa-dev mesa-common-dev

# Detect if 32-bit or 64-bit and add arch-specific packages
ARCH=$(dpkg --print-architecture)
if [ "$ARCH" = "armhf" ]; then
    # 32-bit specific: VideoCore libraries
    sudo apt-get -y -q install --no-install-recommends libraspberrypi-dev libraspberrypi-bin rpi-update
else
    # 64-bit (arm64): No VideoCore, no rpi-update needed
    echo "ARM64 detected - skipping VideoCore packages and rpi-update"
fi

# Apt packages to build openauto
sudo apt-get install -y -q --no-install-recommends pulseaudio librtaudio-dev libtag1-dev libblkid-dev

#  Apt packages to build cam_overlay
sudo apt-get install -y -q --no-install-recommends libv4l-dev libpng-dev

# Custom packages for script
sudo apt-get -y -q install --no-install-recommends pv unzip kpartx zerofree qemu-user-static binfmt-support

# Cleanup
sudo apt-get clean

# Firmware update - only for 32-bit systems
if [ "$ARCH" = "armhf" ]; then
    updatecheck=`sudo JUST_CHECK=1 rpi-update | grep commit`
    if [ -z "$updatecheck" ]; then
        sudo rpi-update
        echo "############################################################################"
        echo ""
        echo "Firmware was updated - please reboot now!"
        echo "You can run next step after reboot."
        echo ""
        echo "############################################################################"
    else
        echo "############################################################################"
        echo ""
        echo "System ready - you can run next step now."
        echo ""
        echo "############################################################################"
    fi
else
    echo "############################################################################"
    echo ""
    echo "ARM64 system ready - you can run next step now."
    echo "Note: rpi-update not available on ARM64"
    echo ""
    echo "############################################################################"
fi
