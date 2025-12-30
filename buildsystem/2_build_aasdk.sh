#!/bin/bash

if [ -z "${AASDK_GIT_REPO}" ]; then
  AASDK_GIT_REPO='https://github.com/opencardev/aasdk.git'
fi

# Set current folder as home
HOME="`cd $0 >/dev/null 2>&1; pwd`" >/dev/null 2>&1

# Switch to home directory
cd $HOME

# clone git repo
if [ ! -d aasdk ]; then
  echo "Cloning aasdk repository..."
  # prefer branch 'newdev' if present, otherwise fall back to 'main' or default
  if git ls-remote --heads ${AASDK_GIT_REPO} newdev | grep -q refs/heads/newdev; then
    echo "Found branch 'newdev' - cloning it"
    git clone -b newdev ${AASDK_GIT_REPO} || { echo "git clone failed"; exit 1; }
  elif git ls-remote --heads ${AASDK_GIT_REPO} main | grep -q refs/heads/main; then
    echo "Branch 'newdev' not found - cloning 'main'"
    git clone -b main ${AASDK_GIT_REPO} || { echo "git clone failed"; exit 1; }
  else
    echo "Branch 'newdev' and 'main' not found - cloning default branch"
    git clone ${AASDK_GIT_REPO} || { echo "git clone failed"; exit 1; }
  fi
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
