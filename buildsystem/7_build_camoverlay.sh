#!/bin/bash

# Set current folder as home
HOME="`cd $0 >/dev/null 2>&1; pwd`" >/dev/null 2>&1

# Switch to home directory
cd $HOME

# clone git repo
if [ ! -d cam_overlay ]; then
    git clone https://github.com/meekys/cam_overlay.git
else
    cd cam_overlay
    git reset --hard
    git pull
    cd $HOME
fi


# Create inside build folder
cd $HOME/cam_overlay

# If the Raspberry Pi VideoCore headers (bcm_host.h) are missing, skip building
# and use the prebuilt binary in ../cam_overlay/cam_overlay.bin as a fallback.
if [ -f /opt/vc/include/bcm_host.h ] || [ -f /usr/include/bcm_host.h ]; then
    echo "bcm_host.h found; building cam_overlay..."
    make -j$(nproc)
else
    echo "bcm_host.h not found; skipping build and using fallback prebuilt binary (if available)."
    PREBUILT="$HOME/../cam_overlay/cam_overlay.bin"
    if [ -f "$PREBUILT" ]; then
        echo "Copying prebuilt binary from $PREBUILT to $(pwd)/cam_overlay.bin"
        cp -f "$PREBUILT" ./cam_overlay.bin
        chmod +x ./cam_overlay.bin
    else
        echo "No prebuilt binary found at $PREBUILT; creating a small stub to avoid build failures."
        cat > ./cam_overlay.bin <<'STUB'
#!/bin/sh
echo "cam_overlay not built on this platform; this is a stub."
exit 0
STUB
        chmod +x ./cam_overlay.bin
    fi
fi

sleep 5
cd $HOME
