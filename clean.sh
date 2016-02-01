#!/usr/bin/env bash

THIS_DIR=$(cd $(dirname $0); pwd)
find "${THIS_DIR}/" -type d -name build -o -name install \
    | grep -v '/exe/luajit-rocks/' | xargs -I {} rm -rf {}

rm -rf extra/threads/CMakeFiles
rm -rf extra/threads/build.luarocks
rm -rf extra/threads/CMakeCache.txt
rm -rf extra/threads/Makefile
rm -rf extra/threads/cmake_install.cmake
rm -rf extra/threads/install_manifest.txt

rm -rf extra/luafilesystem/lfs.so
