#!/usr/bin/env bash
currdir=`dirname $0`
currdir=$(cd "$currdir" && pwd)
#######################################
PREFIX="${currdir}/install"
#######################################

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

git submodule init
git submodule update

# NOTE: This gets most up-to-date packages. Desired behavior?
# Submodules usually point to specific commits.
git submodule foreach git pull origin master

# If we're on OS X, first assert cmake is relatively recent,
# and then delete the cmake directory for CUDA-dependent packages.
# If this is not done on Yosemite,
if [[ `uname` == "Darwin" ]]; then
    # Check the dot version (currently only tested on Yosemite, 10.10)
    osx_dotversion=$(sw_vers -productVersion | tr '.' "\n" | sed '2!d')
    if [[ "$osx_dotversion" == "10" ]]; then
        # This hurts me more than it hurts you
        rm -rf ${currdir}/extra/cunn/cmake
    fi

    # Also, make sure that we build with Clang. CUDA's compiler nvcc
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

# check if we are on mac and fix RPATH for local install
path_to_install_name_tool=$(which install_name_tool)
if [ -x "$path_to_install_name_tool" ]
then
   install_name_tool -id ${PREFIX}/lib/libluajit.dylib ${PREFIX}/lib/libluajit.dylib
fi

$PREFIX/bin/luarocks install luafilesystem
$PREFIX/bin/luarocks install penlight
$PREFIX/bin/luarocks install lua-cjson

cd ${currdir}/pkg/sundown && $PREFIX/bin/luarocks make rocks/sundown-scm-1.rockspec
cd ${currdir}/pkg/cwrap && $PREFIX/bin/luarocks make rocks/cwrap-scm-1.rockspec
cd ${currdir}/pkg/paths && $PREFIX/bin/luarocks make rocks/paths-scm-1.rockspec
cd ${currdir}/pkg/torch && $PREFIX/bin/luarocks make rocks/torch-scm-1.rockspec
cd ${currdir}/pkg/dok && $PREFIX/bin/luarocks make rocks/dok-scm-1.rockspec
cd ${currdir}/pkg/gnuplot && $PREFIX/bin/luarocks make rocks/gnuplot-scm-1.rockspec
cd ${currdir}/exe/qtlua && $PREFIX/bin/luarocks make rocks/qtlua-scm-1.rockspec
cd ${currdir}/exe/trepl && $PREFIX/bin/luarocks make
cd ${currdir}/exe/env && $PREFIX/bin/luarocks make
cd ${currdir}/extra/nn && $PREFIX/bin/luarocks make rocks/nn-scm-1.rockspec

if [ -x "$path_to_nvcc" ]
then
    cd ${currdir}/extra/cutorch && $PREFIX/bin/luarocks make rocks/cutorch-scm-1.rockspec
    cd ${currdir}/extra/cunn && $PREFIX/bin/luarocks make rocks/cunn-scm-1.rockspec
    cd ${currdir}/extra/cunnx && $PREFIX/bin/luarocks make rocks/cunnx-scm-1.rockspec
    cd ${currdir}/extra/cudnn && $PREFIX/bin/luarocks make cudnn-scm-1.rockspec
fi

cd ${currdir}/pkg/qttorch && $PREFIX/bin/luarocks make rocks/qttorch-scm-1.rockspec
cd ${currdir}/pkg/sys && $PREFIX/bin/luarocks make sys-1.1-0.rockspec
cd ${currdir}/pkg/xlua && $PREFIX/bin/luarocks make xlua-1.0-0.rockspec
cd ${currdir}/pkg/image && $PREFIX/bin/luarocks make image-1.1.alpha-0.rockspec
cd ${currdir}/pkg/optim && $PREFIX/bin/luarocks make optim-1.0.5-0.rockspec
cd ${currdir}/extra/sdl2 && $PREFIX/bin/luarocks make rocks/sdl2-scm-1.rockspec
cd ${currdir}/extra/threads && $PREFIX/bin/luarocks make rocks/threads-scm-1.rockspec
cd ${currdir}/extra/graphicsmagick && $PREFIX/bin/luarocks make graphicsmagick-1.scm-0.rockspec
cd ${currdir}/extra/argcheck && $PREFIX/bin/luarocks make rocks/argcheck-scm-1.rockspec
cd ${currdir}/extra/audio && $PREFIX/bin/luarocks make audio-0.1-0.rockspec
cd ${currdir}/extra/fftw3 && $PREFIX/bin/luarocks make rocks/fftw3-scm-1.rockspec
cd ${currdir}/extra/signal && $PREFIX/bin/luarocks make rocks/signal-scm-1.rockspec
cd ${currdir}/extra/nnx && $PREFIX/bin/luarocks make nnx-0.1-1.rockspec
export PATH=$OLDPATH # Restore anaconda distribution if we took it out.
cd ${currdir}/extra/iTorch && $PREFIX/bin/luarocks make


echo '\nWriting new paths to shell config\n'

if [[ $(echo $SHELL | grep bash) ]]; then
    echo "\n" >> $HOME/.bashrc # in case the last line ends in a comment, or is not blank
    echo "export PATH=$PREFIX/bin:\$PATH  \# Added automatically by torch-dist" >> $HOME/.bashrc
    echo "export LD_LIBRARY_PATH=$PREFIX/lib:\$LD_LIBRARY_PATH  \# Added automatically by torch-dist" >> $HOME/.bashrc
elif [[ $(echo $SHELL | grep zsh) ]]; then
    echo "\n" >> $HOME/.zshrc # in case the last line ends in a comment, or is not blank
    echo "export PATH=$PREFIX/bin:\$PATH  \# Added automatically by torch-dist" >> $HOME/.zshrc
    echo "export LD_LIBRARY_PATH=$PREFIX/lib:\$LD_LIBRARY_PATH  \# Added automatically by torch-dist" >> $HOME/.zshrc
fi