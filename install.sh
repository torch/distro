#!/usr/bin/env bash

THIS_DIR=$(cd $(dirname $0); pwd)
PREFIX="${THIS_DIR}/install"
BATCH_INSTALL=0

while getopts 'bh:' x; do
    case "$x" in
        h) 
            echo "usage: $0
This script will install Torch and related, useful packages into $PREFIX.

    -b      Run without requesting any user input (will automatically add PATH to shell profile)
"
            exit 2
            ;;
        b)
            BATCH_INSTALL=1
            ;;
    esac
done
            

# Scrub an anaconda install, if exists, from the PATH. 
# It has a malformed MKL library (as of 1/17/2015)
OLDPATH=$PATH
if [[ $(echo $PATH | grep anaconda) ]]; then
    export PATH=$(echo $PATH | tr ':' '\n' | grep -v "anaconda/bin" | grep -v "anaconda/lib" | grep -v "anaconda/include" | uniq | tr '\n' ':')
fi

echo "Prefix set to $PREFIX"

if [[ `uname` == 'Linux' ]]; then
    export CMAKE_LIBRARY_PATH=/opt/OpenBLAS/include:/opt/OpenBLAS/lib:$CMAKE_LIBRARY_PATH
fi

git submodule update --init --recursive

# If we're on OS X, use clang
if [[ `uname` == "Darwin" ]]; then
    # make sure that we build with Clang. CUDA's compiler nvcc
    # does not play nice with any recent GCC version.
    export CC=clang
    export CXX=clang++
fi

mkdir -p build
cd build
cmake .. -DCMAKE_INSTALL_PREFIX="${PREFIX}" -DCMAKE_BUILD_TYPE=Release -DWITH_LUAJIT21=ON
make && make install
cd ..

# Check for a CUDA install (using nvcc instead of nvidia-smi for cross-platform compatibility)
path_to_nvcc=$(which nvcc)
path_to_nvidiasmi=$(which nvidia-smi)

# check if we are on mac and fix RPATH for local install
path_to_install_name_tool=$(which install_name_tool)
if [ -x "$path_to_install_name_tool" ]
then
   install_name_tool -id ${PREFIX}/lib/libluajit.dylib ${PREFIX}/lib/libluajit.dylib
fi

$PREFIX/bin/luarocks install luafilesystem
$PREFIX/bin/luarocks install penlight
$PREFIX/bin/luarocks install lua-cjson

cd ${THIS_DIR}/pkg/sundown && $PREFIX/bin/luarocks make rocks/sundown-scm-1.rockspec
cd ${THIS_DIR}/pkg/cwrap && $PREFIX/bin/luarocks make rocks/cwrap-scm-1.rockspec
cd ${THIS_DIR}/pkg/paths && $PREFIX/bin/luarocks make rocks/paths-scm-1.rockspec
cd ${THIS_DIR}/pkg/torch && $PREFIX/bin/luarocks make rocks/torch-scm-1.rockspec
cd ${THIS_DIR}/pkg/dok && $PREFIX/bin/luarocks make rocks/dok-scm-1.rockspec
cd ${THIS_DIR}/pkg/gnuplot && $PREFIX/bin/luarocks make rocks/gnuplot-scm-1.rockspec
cd ${THIS_DIR}/exe/qtlua && $PREFIX/bin/luarocks make rocks/qtlua-scm-1.rockspec
cd ${THIS_DIR}/exe/trepl && $PREFIX/bin/luarocks make
cd ${THIS_DIR}/exe/env && $PREFIX/bin/luarocks make
cd ${THIS_DIR}/pkg/sys && $PREFIX/bin/luarocks make sys-1.1-0.rockspec
cd ${THIS_DIR}/pkg/xlua && $PREFIX/bin/luarocks make xlua-1.0-0.rockspec
cd ${THIS_DIR}/extra/nn && $PREFIX/bin/luarocks make rocks/nn-scm-1.rockspec

if [ -x "$path_to_nvcc" ] || [ -x "$path_to_nvidiasmi" ]
then
    cd ${THIS_DIR}/extra/cutorch && $PREFIX/bin/luarocks make rocks/cutorch-scm-1.rockspec
    cd ${THIS_DIR}/extra/cunn && $PREFIX/bin/luarocks make rocks/cunn-scm-1.rockspec
    cd ${THIS_DIR}/extra/cunnx && $PREFIX/bin/luarocks make rocks/cunnx-scm-1.rockspec
    cd ${THIS_DIR}/extra/cudnn && $PREFIX/bin/luarocks make cudnn-scm-1.rockspec
fi

cd ${THIS_DIR}/pkg/qttorch && $PREFIX/bin/luarocks make rocks/qttorch-scm-1.rockspec
cd ${THIS_DIR}/pkg/image && $PREFIX/bin/luarocks make image-1.1.alpha-0.rockspec
cd ${THIS_DIR}/pkg/optim && $PREFIX/bin/luarocks make optim-1.0.5-0.rockspec
cd ${THIS_DIR}/extra/sdl2 && $PREFIX/bin/luarocks make rocks/sdl2-scm-1.rockspec
cd ${THIS_DIR}/extra/threads && $PREFIX/bin/luarocks make rocks/threads-scm-1.rockspec
cd ${THIS_DIR}/extra/graphicsmagick && $PREFIX/bin/luarocks make graphicsmagick-1.scm-0.rockspec
cd ${THIS_DIR}/extra/argcheck && $PREFIX/bin/luarocks make rocks/argcheck-scm-1.rockspec
cd ${THIS_DIR}/extra/audio && $PREFIX/bin/luarocks make audio-0.1-0.rockspec
cd ${THIS_DIR}/extra/fftw3 && $PREFIX/bin/luarocks make rocks/fftw3-scm-1.rockspec
cd ${THIS_DIR}/extra/signal && $PREFIX/bin/luarocks make rocks/signal-scm-1.rockspec
cd ${THIS_DIR}/extra/nnx && $PREFIX/bin/luarocks make nnx-0.1-1.rockspec

export PATH=$OLDPATH # Restore anaconda distribution if we took it out.
cd ${THIS_DIR}/extra/iTorch && $PREFIX/bin/luarocks make


RC_FILE=0
DEFAULT=yes
if [[ $(echo $SHELL | grep bash) ]]; then
    RC_FILE=$HOME/.bashrc
elif [[ $(echo $SHELL | grep zsh) ]]; then
    RC_FILE=$HOME/.zshrc
else
    echo "

Non-standard shell $SHELL detected. You might want to 
add the following lines to your shell profile:

export PATH=$PREFIX/bin:\$PATH
export LD_LIBRARY_PATH=$PREFIX/lib:\$LD_LIBRARY_PATH 
export DYLD_LIBRARY_PATH=$PREFIX/lib:\$DYLD_LIBRARY_PATH 
"
fi

WRITE_PATH_TO_PROFILE=0
if [[ $BATCH_INSTALL == 0 ]]; then
    if [ -f $RC_FILE ]; then
        echo "

Do you want to automatically prepend the Torch install location
to PATH and LD_LIBRARY_PATH in your $RC_FILE? (yes/no)
[$DEFAULT] >>> "
        read input
        if [[ $input == "" ]]; then
            input=$DEFAULT
        fi

        is_yes() {
            yesses={y,Y,yes,Yes,YES}
            if [[ $yesses =~ $1 ]]; then
                echo 1
            fi
        }

        if [[ $(is_yes $input) ]]; then
            WRITE_PATH_TO_PROFILE=1
        fi
    fi
else
    if [[ $RC_FILE ]]; then
        WRITE_PATH_TO_PROFILE=1
    fi
fi

if [[ $WRITE_PATH_TO_PROFILE == 1 ]]; then
    echo "

export PATH=$PREFIX/bin:\$PATH  # Added automatically by torch-dist
export LD_LIBRARY_PATH=$PREFIX/lib:\$LD_LIBRARY_PATH  # Added automatically by torch-dist" >> $RC_FILE
export DYLD_LIBRARY_PATH=$PREFIX/lib:\$DYLD_LIBRARY_PATH  # Added automatically by torch-dist" >> $RC_FILE
    echo "

export PATH=$PREFIX/bin:\$PATH  # Added automatically by torch-dist
export LD_LIBRARY_PATH=$PREFIX/lib:\$LD_LIBRARY_PATH  # Added automatically by torch-dist" >> $HOME/.profile
export DYLD_LIBRARY_PATH=$PREFIX/lib:\$DYLD_LIBRARY_PATH  # Added automatically by torch-dist" >> $HOME/.profile

else
    echo "

Not updating your shell profile.
You might want to 
add the following lines to your shell profile:

export PATH=$PREFIX/bin:\$PATH
export LD_LIBRARY_PATH=$PREFIX/lib:\$LD_LIBRARY_PATH 
export DYLD_LIBRARY_PATH=$PREFIX/lib:\$DYLD_LIBRARY_PATH 
"
fi
