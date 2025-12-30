#!/bin/bash
if [ -z "${CPU_CORES_COUNT}" ]; then
  CPU_CORES_COUNT=`grep -c ^processor /proc/cpuinfo`
fi
if [ -z "${OPENAUTO_GIT_REPO}" ]; then
  OPENAUTO_GIT_REPO='https://github.com/opencardev/openauto.git'
fi

# Detect architecture
ARCH_TRIPLE=arm-linux-gnueabihf
PIVERSION=`grep ^Model /proc/cpuinfo`
if [[ ${PIVERSION} =~ 'Raspberry Pi 5' ]] || [[ ${PIVERSION} =~ 'Raspberry Pi 4' ]]; then
   ARCH_TRIPLE=aarch64-linux-gnu
fi

# Install Pre-reqs
sudo apt-get -y install cmake build-essential git
sudo apt-get -y install libboost-all-dev libusb-1.0.0-dev libssl-dev cmake libprotobuf-dev protobuf-c-compiler protobuf-compiler pulseaudio librtaudio-dev libgps-dev 
sudo apt-get install -y libblkid-dev libtag1-dev libgles2-mesa-dev libegl1-mesa-dev
#libqt5multimedia5 libqt5multimedia5-plugins libqt5multimediawidgets5 qtmultimedia5-dev libqt5bluetooth5 libqt5bluetooth5-bin qtconnectivity5-dev

# Set current folder as home
HOME="`cd $0 >/dev/null 2>&1; pwd`" >/dev/null 2>&1

# Switch to home directory
cd $HOME

# clone git repo
if [ ! -d openauto ]; then
    git clone -b crankshaft-ng ${OPENAUTO_GIT_REPO}
else
    cd openauto
    git reset --hard
    git pull
    cd $HOME
fi

# Clean build folder
rm -rf $HOME/openauto_build

# Create build folder
mkdir -p $HOME/openauto_build

# Link needed libs - only for 32-bit systems with VideoCore
if [ "$ARCH_TRIPLE" = "arm-linux-gnueabihf" ]; then
    if [ -d /opt/vc/lib ]; then
        ln -sf /opt/vc/lib/libbrcmEGL.so /usr/lib/arm-linux-gnueabihf/libEGL.so 2>/dev/null || true
        ln -sf /opt/vc/lib/libbrcmGLESv2.so /usr/lib/arm-linux-gnueabihf/libGLESv2.so 2>/dev/null || true
        ln -sf /opt/vc/lib/libbrcmOpenVG.so /usr/lib/arm-linux-gnueabihf/libOpenVG.so 2>/dev/null || true
        ln -sf /opt/vc/lib/libbrcmWFC.so /usr/lib/arm-linux-gnueabihf/libWFC.so 2>/dev/null || true
    fi
fi
# ARM64 systems (Pi4/Pi5) use Mesa drivers, no symlinks needed

# Create inside build folder
cd $HOME/openauto_build

# Prefer system-installed AASDK/aap_protobuf in /usr/local when available
if [ -d /usr/local/include/aap_protobuf ] || [ -f /usr/local/lib/libaap_protobuf.so ]; then
  AASDK_INCLUDE_DIRS="/usr/local/include"
  AASDK_LIBRARIES="/usr/local/lib/libaasdk.so"
  AASDK_PROTO_INCLUDE_DIRS="/usr/local/include/aap_protobuf"
  AASDK_PROTO_LIBRARIES="/usr/local/lib/libaap_protobuf.so"
else
  AASDK_INCLUDE_DIRS="$HOME/aasdk/include"
  AASDK_LIBRARIES="$HOME/aasdk/lib/libaasdk.so"
  AASDK_PROTO_INCLUDE_DIRS="$HOME/aasdk_build"
  AASDK_PROTO_LIBRARIES="$HOME/aasdk/lib/libaasdk_proto.so"
fi

# On aarch64 (Pi 5 / Pi 4 arm64), build without Raspberry Pi OMX (use Qt backend)
if [ "${ARCH_TRIPLE}" = "aarch64-linux-gnu" ]; then
  CMAKE_PI_FLAGS="-DNOPI=ON"
else
  CMAKE_PI_FLAGS="-DRPI3_BUILD=TRUE"
fi

# Run CMake (also include /usr/local in prefix path so CMake can find installed packages)
echo "Running: cmake ${CMAKE_PI_FLAGS} -DCMAKE_BUILD_TYPE=Release -DAASDK_INCLUDE_DIRS=${AASDK_INCLUDE_DIRS} -DAASDK_LIBRARIES=${AASDK_LIBRARIES} -DAASDK_PROTO_INCLUDE_DIRS=${AASDK_PROTO_INCLUDE_DIRS} -DAASDK_PROTO_LIBRARIES=${AASDK_PROTO_LIBRARIES} -DCMAKE_PREFIX_PATH=/usr/local ../openauto"
cmake ${CMAKE_PI_FLAGS} -DCMAKE_BUILD_TYPE=Release \
    -DAASDK_INCLUDE_DIRS="${AASDK_INCLUDE_DIRS}" \
    -DAASDK_LIBRARIES="${AASDK_LIBRARIES}" \
    -DAASDK_PROTO_INCLUDE_DIRS="${AASDK_PROTO_INCLUDE_DIRS}" \
    -DAASDK_PROTO_LIBRARIES="${AASDK_PROTO_LIBRARIES}" \
    -DCMAKE_PREFIX_PATH=/usr/local ../openauto

make -j$CPU_CORES_COUNT 2>&1 | tee ../openauto-make$(date +"%Y-%m-%d_%H-%M").log

cd $HOME
