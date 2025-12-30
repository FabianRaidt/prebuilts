#!/bin/bash

if [ -z "${AASDK_GIT_REPO}" ]; then
  AASDK_GIT_REPO='https://github.com/FabianRaidt/aasdk.git'
fi

# Set current folder as home
HOME="`cd $0 >/dev/null 2>&1; pwd`" >/dev/null 2>&1

# Switch to home directory
cd $HOME

# clone git repo
if [ ! -d aasdk ]; then
  echo "Cloning aasdk repository..."
  git clone -b main ${AASDK_GIT_REPO} || { echo "git clone failed"; exit 1; }
else
  echo "Updating existing aasdk repository..."
  cd aasdk
  git reset --hard
  git clean -d -x -f
  git pull || { echo "git pull failed"; exit 1; }
  cd $HOME
fi

# Clean build folder
sudo rm -rf $HOME/aasdk_build

# Create build folder
mkdir -p $HOME/aasdk_build

# Create inside build folder
cd $HOME/aasdk_build
cmake -DCMAKE_BUILD_TYPE=Release ../aasdk || { echo "cmake configuration failed"; exit 1; }
make -j$(nproc) || { echo "make failed"; exit 1; }

cd $HOME
