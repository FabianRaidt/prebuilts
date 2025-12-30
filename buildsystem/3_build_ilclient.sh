#!/bin/bash

# Set current folder as home
HOME="`cd $0 >/dev/null 2>&1; pwd`" >/dev/null 2>&1

# ilclient is only available on 32-bit systems with VideoCore
PIVERSION=`grep ^Model /proc/cpuinfo`
if [[ ${PIVERSION} =~ 'Raspberry Pi 5' ]] || [[ ${PIVERSION} =~ 'Raspberry Pi 4' ]]; then
    echo "WARNING: ilclient not available on ARM64 Pi 4/5 systems"
    echo "Pi 4/5 use V3D driver instead of VideoCore"
    echo "Skipping ilclient build..."
    exit 0
fi

# Create inside build folder
if [ -d /opt/vc/src/hello_pi/libs/ilclient ]; then
    cd /opt/vc/src/hello_pi/libs/ilclient
    make clean
    make -j2
else
    echo "WARNING: /opt/vc not found - ilclient not available"
fi

cd $HOME
