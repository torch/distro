#!/usr/bin/env bash

SKIP_RC=0
BATCH_INSTALL=0

THIS_DIR=$(cd $(dirname $0); pwd)
if [[ "$THIS_DIR" == *" "* ]]; then
    echo "$THIS_DIR: Torch cannot install to a path containing whitespace.
Please try a different path, one without any spaces."
    exit 1
fi
PREFIX=${PREFIX:-"${THIS_DIR}/install"}
TORCH_LUA_VERSION=${TORCH_LUA_VERSION:-"LUA51"} # by default install LUA51

while getopts 'bsh' x; do
    case "$x" in
        h)
            echo "usage: $0
This script will install Torch and related, useful packages into $PREFIX.

    -b      Run without requesting any user input (will automatically add PATH to shell profile)
    -s      Skip adding the PATH to shell profile
"
            exit 2
            ;;
        b)
            BATCH_INSTALL=1
            ;;
        s)
            SKIP_RC=1
            ;;
    esac
done

# Scrub an anaconda/conda install, if exists, from the PATH.
# It has a malformed MKL library (as of 1/17/2015)
OLDPATH=$PATH
if [[ $(echo $PATH | grep conda) ]]; then
    export PATH=$(echo $PATH | tr ':' '\n' | grep -v "conda[2-9]\?" | uniq | tr '\n' ':')
fi

echo "Prefix set to $PREFIX"

if [[ `uname` == 'Linux' ]]; then
    export CMAKE_LIBRARY_PATH=$PREFIX/include:/opt/OpenBLAS/include:$PREFIX/lib:/opt/OpenBLAS/lib:$CMAKE_LIBRARY_PATH
fi
export CMAKE_PREFIX_PATH=$PREFIX

git submodule update --init --recursive

# If we're on OS X, use clang
if [[ `uname` == "Darwin" ]]; then
    # make sure that we build with Clang. CUDA's compiler nvcc
    # does not play nice with any recent GCC version.
    export CC=clang
    export CXX=clang++
fi
# If we're on Arch linux, use gcc v5
if [[ `uname -a` == *"ARCH"* ]]; then
    path_to_gcc5=$(which gcc-5)
    if [ -x "$path_to_gcc5" ]; then
      export CC="$path_to_gcc5"
    else
      echo "Warning: GCC v5 not found. CUDA v8 is incompatible with GCC v6, if installation fails, consider running \$ pacman -S gcc5"
    fi
fi

echo "Installing Lua version: ${TORCH_LUA_VERSION}"
mkdir -p install
mkdir -p build
cd build

cmake .. -DCMAKE_INSTALL_PREFIX="${PREFIX}" -DCMAKE_BUILD_TYPE=Release -DWITH_${TORCH_LUA_VERSION}=ON 2>&1 >>$PREFIX/install.log || exit 1
(make 2>&1 >>$PREFIX/install.log  || exit 1) && (make install 2>&1 >>$PREFIX/install.log || exit 1)
cd ..