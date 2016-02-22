#!/usr/bin/env bash

THIS_DIR=$(cd $(dirname $0); pwd)

rm -fr install

find "${THIS_DIR}/" -type d -name build  \
    | grep -v '/exe/luajit-rocks/' | xargs -I {} rm -rf {}

cd ${THIS_DIR}

rm -rf extra/threads/CMakeFiles
rm -rf extra/threads/build.luarocks
rm -rf extra/threads/CMakeCache.txt
rm -rf extra/threads/Makefile
rm -rf extra/threads/cmake_install.cmake
rm -rf extra/threads/install_manifest.txt

rm -rf extra/luafilesystem/lfs.so
