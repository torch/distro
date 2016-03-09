#!/usr/bin/env bash

SKIP_RC=0
BATCH_INSTALL=0

THIS_DIR=$(cd $(dirname $0); pwd)
PREFIX=${PREFIX:-"${THIS_DIR}/install"}
TH_INSTALL_PREFIX=${PREFIX}
BUILD_DIR=${THIS_DIR}/build

TORCH_LUA_VERSION=${TORCH_LUA_VERION:-"LUAJIT21"} # by default install LUAJIT21

while getopts 'absvnh:' x; do
    case "$x" in
        a)
            export CUDA_ARCH_NAME=All
            ;;
        h)
            echo "usage: $0
This script will install Torch and related, useful packages into $PREFIX.

    -b      Run without requesting any user input (will automatically add PATH to shell profile)
    -s      Skip adding the PATH to shell profile
    -v      Verbose execution
"
            exit 2
            ;;
        b)
            BATCH_INSTALL=1
            ;;
        v)
            export IVERBOSE="--verbose"
            ;;
        n)
            TORCH_LUA_VERSION="NATIVE"
            ;;
        s)
            SKIP_RC=1
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

# git submodule update --init --recursive

# If we're on OS X, use clang
if [[ `uname` == "Darwin" ]]; then
    # make sure that we build with Clang. CUDA's compiler nvcc
    # does not play nice with any recent GCC version.
    export CC=clang
    export CXX=clang++
fi

echo "Installing Lua version: ${TORCH_LUA_VERSION}"

mkdir -p ${PREFIX}
mkdir -p ${BUILD_DIR}

cd ${BUILD_DIR}

echo "Configuring Lua version: ${TORCH_LUA_VERSION}"
(cmake ${THIS_DIR} -DCMAKE_INSTALL_PREFIX="${PREFIX}" -DCMAKE_BUILD_TYPE=Release -DWITH_${TORCH_LUA_VERSION}=ON  || exit 1)

if [[ "$TORCH_LUA_VERSION" == "NATIVE" ]]; then
# echo "Using NATIVE Lua version:"

export LUAROCKS="luarocks --tree="$PREFIX/" $IVERBOSE"

export LUA=luajit

else

echo "Installing Lua version: ${TORCH_LUA_VERSION}"
# (cmake ${THIS_DIR} -DCMAKE_INSTALL_PREFIX="${PREFIX}" -DCMAKE_BUILD_TYPE=Release -DWITH_${TORCH_LUA_VERSION}=ON  || exit 1)
(make 2>&1  || exit 1) && (make install 2>&1  || exit 1)
cd ..
export LUAROCKS="${PREFIX}/bin/luarocks --tree="${PREFIX}" $IVERBOSE"
fi
# Done installing LuaRocks

echo "Using luarocks: ${LUAROCKS}"
# echo "LUA_PATH: ${LUA_PATH}"

export CMAKE_PREFIX_PATH=${PREFIX}
export CMAKE_INSTALL_PREFIX=${PREFIX}
export CMAKE_INSTALL_SUBDIR="share/cmake/torch"

# Check for a CUDA install (using nvcc instead of nvidia-smi for cross-platform compatibility)
path_to_nvcc=$(which nvcc)
path_to_nvidiasmi=$(which nvidia-smi)

if [ -x "$path_to_nvcc" ] || [ -x "$path_to_nvidiasmi" ]
then
    echo "Found CUDA on your machine. Installing FindCUDA module to work around .cu bug in CMake 2.8/3.5"
    cd ${THIS_DIR}/extra/FindCUDA && \
(cmake -E make_directory build && cd build && cmake .. -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX="${CMAKE_INSTALL_PREFIX}" -DCMAKE_INSTALL_SUBDIR="${CMAKE_INSTALL_SUBDIR}" && make install) \
    && echo "FindCuda installed" || exit 1
fi

#
# lua/luajit do not accept --tree option, set environment
#

fix_path() {
  $LUAROCKS path -bin | sed "s@$1@$2@ig"
}

setup_lua_env_cmd=`fix_path "${HOME}/.luarocks" "$PREFIX"`

eval "$setup_lua_env_cmd"



# end environment setup


echo "Installing common Lua packages into ${TH_INSTALL_PREFIX}"
cd ${THIS_DIR}/extra/luafilesystem && $LUAROCKS make rockspecs/luafilesystem-1.6.3-1.rockspec || exit 1
cd ${THIS_DIR}/extra/penlight && $LUAROCKS make || exit 1
cd ${THIS_DIR}/extra/lua-cjson && $LUAROCKS make || exit 1


# check if we are on mac and fix RPATH for local install
path_to_install_name_tool=$(which install_name_tool 2>/dev/null)
if [ -x "$path_to_install_name_tool" ]
then
   if [ ${TORCH_LUA_VERSION} == "LUAJIT21" ] || [ ${TORCH_LUA_VERSION} == "LUAJIT20" ] ; then
       install_name_tool -id ${PREFIX}/lib/libluajit.dylib ${PREFIX}/lib/libluajit.dylib
   else
       install_name_tool -id ${PREFIX}/lib/liblua.dylib ${PREFIX}/lib/liblua.dylib
   fi
fi

echo "Installing core Torch packages"

cd ${THIS_DIR}/pkg/sundown   && $LUAROCKS make rocks/sundown-scm-1.rockspec || exit 1
cd ${THIS_DIR}/pkg/cwrap     && $LUAROCKS make rocks/cwrap-scm-1.rockspec   || exit 1
cd ${THIS_DIR}/pkg/paths     && $LUAROCKS make rocks/paths-scm-1.rockspec   || exit 1
cd ${THIS_DIR}/pkg/torch     && $LUAROCKS make rocks/torch-scm-1.rockspec   || exit 1
cd ${THIS_DIR}/pkg/dok       && $LUAROCKS make rocks/dok-scm-1.rockspec     || exit 1
cd ${THIS_DIR}/exe/trepl     && $LUAROCKS make                              || exit 1
cd ${THIS_DIR}/pkg/sys       && $LUAROCKS make sys-1.1-0.rockspec           || exit 1
cd ${THIS_DIR}/pkg/xlua      && $LUAROCKS make xlua-1.0-0.rockspec          || exit 1
cd ${THIS_DIR}/extra/luaffifb && $LUAROCKS make luaffi-scm-1.rockspec       || exit 1
cd ${THIS_DIR}/extra/nn      && $LUAROCKS make rocks/nn-scm-1.rockspec      || exit 1
cd ${THIS_DIR}/extra/graph   && $LUAROCKS make rocks/graph-scm-1.rockspec   || exit 1
cd ${THIS_DIR}/extra/nngraph && $LUAROCKS make                              || exit 1
cd ${THIS_DIR}/pkg/image     && $LUAROCKS make image-1.1.alpha-0.rockspec   || exit 1
cd ${THIS_DIR}/pkg/optim     && $LUAROCKS make optim-1.0.5-0.rockspec       || exit 1

if [ -x "$path_to_nvcc" ] || [ -x "$path_to_nvidiasmi" ]
then
    echo "Found CUDA on your machine. Installing CUDA packages"
    cd ${THIS_DIR}/extra/cutorch  && $LUAROCKS  make rocks/cutorch-scm-1.rockspec || exit 1
    cd ${THIS_DIR}/extra/cunn     && $LUAROCKS  make rocks/cunn-scm-1.rockspec    || exit 1
fi

# Optional packages
echo "Installing optional Torch packages"
cd ${THIS_DIR}/pkg/gnuplot          && $LUAROCKS make rocks/gnuplot-scm-1.rockspec || exit 1
cd ${THIS_DIR}/exe/env              && $LUAROCKS make || exit 1
cd ${THIS_DIR}/extra/nnx            && $LUAROCKS make nnx-0.1-1.rockspec || exit 1
# cd ${THIS_DIR}/exe/qtlua            && $LUAROCKS make rocks/qtlua-scm-1.rockspec || exit 1
# cd ${THIS_DIR}/pkg/qttorch          && $LUAROCKS make rocks/qttorch-scm-1.rockspec || exit 1
cd ${THIS_DIR}/extra/threads        && $LUAROCKS make rocks/threads-scm-1.rockspec || exit 1
cd ${THIS_DIR}/extra/graphicsmagick && $LUAROCKS make graphicsmagick-1.scm-0.rockspec || exit 1
cd ${THIS_DIR}/extra/argcheck       && $LUAROCKS make rocks/argcheck-scm-1.rockspec || exit 1
cd ${THIS_DIR}/extra/audio          && $LUAROCKS make audio-0.1-0.rockspec || exit 1
cd ${THIS_DIR}/extra/fftw3          && $LUAROCKS make rocks/fftw3-scm-1.rockspec || exit 1
cd ${THIS_DIR}/extra/signal         && $LUAROCKS make rocks/signal-scm-1.rockspec || exit 1

#Support for Protobuf
cd ${THIS_DIR}/extra/lua-pb         && $LUAROCKS make lua-pb-scm-0.rockspec || exit 1
# Lua Wrapper for LMDB, latest from github (lightningmdb)
cd ${THIS_DIR}/extra/lmdb           && $LUAROCKS make LMDB_INCDIR=/usr/include LMDB_LIBDIR=/usr/lib/x86_64-linux-gnu lightningmdb-scm-1.rockspec || exit 1
cd ${THIS_DIR}/extra/totem          && $LUAROCKS make rocks/totem-0-0.rockspec || exit 1
#HDF5 filesystem support
cd ${THIS_DIR}/extra/hdf5           && $LUAROCKS make hdf5-0-0.rockspec || exit 1
#NCCL (experimental) support
cd ${THIS_DIR}/extra/nccl         && $LUAROCKS make nccl-scm-1.rockspec || exit 1

# Optional CUDA packages
if [ -x "$path_to_nvcc" ]
then
    echo "Found CUDA on your machine. Installing optional CUDA packages"
    cd ${THIS_DIR}/extra/cudnn   && $LUAROCKS make cudnn-scm-1.rockspec || exit 1
#    cd ${THIS_DIR}/extra/cunnx   && $LUAROCKS make rocks/cunnx-scm-1.rockspec || exit 1
fi

export PATH=$OLDPATH # Restore anaconda distribution if we took it out.
if [[ `uname` == "Darwin" ]]; then
    cd ${THIS_DIR}/extra/iTorch         && $LUAROCKS make OPENSSL_DIR=/usr/local/opt/openssl/
else
    cd ${THIS_DIR}/extra/iTorch         && $LUAROCKS make
fi


if [[ $SKIP_RC == 1 ]]; then
  exit 0
fi

cat <<EOF >$PREFIX/bin/torch-activate
$setup_lua_env_cmd
export PATH=$PREFIX/bin:\$PATH
export LD_LIBRARY_PATH=$PREFIX/lib:$PREFIX/local/lib:\$LD_LIBRARY_PATH
export DYLD_LIBRARY_PATH=$PREFIX/lib:$PREFIX/local/lib:\$DYLD_LIBRARY_PATH
export LUA_CPATH="$PREFIX/lib/?.so;$PREFIX/local/lib/?.so;${LUA_CPATH}"
EOF
chmod +x $PREFIX/bin/torch-activate

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

. $PREFIX/bin/torch-activate
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

. $PREFIX/bin/torch-activate" >> $RC_FILE
    echo "

. $PREFIX/bin/torch-activate" >> $HOME/.profile

else
    echo "

Not updating your shell profile.
You might want to
add the following lines to your shell profile:

. $PREFIX/bin/torch-activate
"
fi
