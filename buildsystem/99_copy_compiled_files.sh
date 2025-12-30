#!/bin/bash

# Set current folder as home
HOME="`cd $0 >/dev/null 2>&1; pwd`" >/dev/null 2>&1

# Create output folder
if [ ! -d BINARY_FILES ]; then
    mkdir BINARY_FILES
fi

# Copy aasdk so's
if [ -f ./aasdk_build/lib/libaasdk.so ]; then
    cp ./aasdk_build/lib/libaasdk.so ./BINARY_FILES/
fi

if [ -f ./aasdk_build/lib/libaap_protobuf.so ]; then
    cp ./aasdk_build/lib/libaap_protobuf.so ./BINARY_FILES/libaasdk_proto.so
fi

# Copy openauto
if [ -f ./openauto_build/bin/autoapp ]; then
    cp ./openauto_build/bin/autoapp ./BINARY_FILES/
fi

if [ -f ./openauto_build/bin/btservice ]; then
    cp ./openauto_build/bin/btservice ./BINARY_FILES/
fi

# Copy gpio2kbd
if [ -f ./gpio2kbd/gpio2kbd ]; then
    cp ./gpio2kbd/gpio2kbd ./BINARY_FILES/
fi

# Copy cam_overlay.bin
if [ -f ./cam_overlay/cam_overlay.bin ]; then
    cp ./cam_overlay/cam_overlay.bin ./BINARY_FILES/
fi

# Copy usbreset
if [ -f ./usbreset/usbreset ]; then
    cp ./usbreset/usbreset ./BINARY_FILES/
fi

# Create compressed qt5
QTVERSION=`cat /usr/local/qt5/lib/pkgconfig/Qt5Core.pc | grep Version: | cut -d: -f2 | sed 's/ //g' | sed 's/\.//g'`
ARMARCH=`uname -m`
tar -cvf $HOME/BINARY_FILES/Qt_${QTVERSION}_${ARMARCH}_OpenGLES2.tar.xz /usr/local/qt5
split -b 50m -d $HOME/BINARY_FILES/Qt_${QTVERSION}_${ARMARCH}_OpenGLES2.tar.xz "$HOME/BINARY_FILES/Qt_${QTVERSION}_${ARMARCH}_OpenGLES2.tar.xz.part"
rm $HOME/BINARY_FILES/Qt_${QTVERSION}_${ARMARCH}_OpenGLES2.tar.xz

cd $HOME
