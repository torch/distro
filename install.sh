#!/bin/bash
currdir=`dirname $0`
currdir=$(cd "$currdir" && pwd)
#######################################
PREFIX="${currdir}/install"
#######################################

echo "Prefix set to $PREFIX"

if [[ `uname` == 'Linux' ]]; then
    export CMAKE_LIBRARY_PATH=/opt/OpenBLAS/include:/opt/OpenBLAS/lib:$CMAKE_LIBRARY_PATH
fi

git submodule init
git submodule update

mkdir -p build
cd build
cmake .. -DCMAKE_INSTALL_PREFIX="${PREFIX}" -DCMAKE_BUILD_TYPE=Release
make && make install
cd ..

# check if we are on mac and fix RPATH for local install
path_to_install_name_tool=$(which install_name_tool)
if [ -x "$path_to_install_name_tool" ] 
then
   install_name_tool -id ${PREFIX}/lib/libluajit.dylib ${PREFIX}/lib/libluajit.dylib
fi

$PREFIX/bin/luarocks install sundown

cd ${currdir}/pkg/cwrap && $PREFIX/bin/luarocks make rocks/cwrap-scm-1.rockspec
cd ${currdir}/pkg/paths && $PREFIX/bin/luarocks make rocks/paths-scm-1.rockspec
cd ${currdir}/pkg/torch && $PREFIX/bin/luarocks make rocks/torch-scm-1.rockspec
cd ${currdir}/pkg/dok && $PREFIX/bin/luarocks make rocks/dok-scm-1.rockspec
cd ${currdir}/pkg/gnuplot && $PREFIX/bin/luarocks make rocks/gnuplot-scm-1.rockspec

cd ${currdir}/exe/qtlua && $PREFIX/bin/luarocks make rocks/qtlua-scm-1.rockspec
cd ${currdir}/exe/trepl && $PREFIX/bin/luarocks make rocks/trepl-scm-1.rockspec

cd ${currdir}/extra/nn && $PREFIX/bin/luarocks make rocks/nn-scm-1.rockspec

path_to_nvcc=$(which nvcc)
if [ -x "$path_to_nvcc" ]
then  
    cd ${currdir}/extra/cutorch && $PREFIX/bin/luarocks make rocks/cutorch-scm-1.rockspec
    cd ${currdir}/extra/cunn && $PREFIX/bin/luarocks make rocks/cunn-scm-1.rockspec
fi

$PREFIX/bin/luarocks install qttorch
$PREFIX/bin/luarocks install luafilesystem
$PREFIX/bin/luarocks install penlight
$PREFIX/bin/luarocks install sys
$PREFIX/bin/luarocks install xlua
$PREFIX/bin/luarocks install image
$PREFIX/bin/luarocks install optim
$PREFIX/bin/luarocks install lua-cjson
$PREFIX/bin/luarocks install luafilesystem
