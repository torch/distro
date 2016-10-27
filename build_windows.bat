rem assumptions:
rem
rem - ec2 windows 2012 r2 default box (eg ami-281ad849, or equivalent, in ec2, click 'Launch' and select
rem   'Microsoft Windows Server 2012 R2 Base', from 'Quick Start')
rem
rem - visual studio 2015 community
rem    https://beta.visualstudio.com/vs/community/
rem
rem - cmake installed at C:\Program Files (x86)\CMake\bin\cmake.exe (3.6.2-amd64)
rem       https://cmake.org/files/v3.6/cmake-3.6.2-win64-x64.msi
rem
rem - msys git available at C:\Program Files\Git (git-2.9.2 64-bit)
rem       latest: https://github.com/git-for-windows/git/releases/download/v2.10.0.windows.1/Git-2.10.0-64-bit.exe
rem       2.9.2 64-bit: https://github.com/git-for-windows/git/releases/download/v2.9.2.windows.1/Git-2.9.2-64-bit.exe
rem
rem - 7zip available at C:\Program Files\7-Zip\7z.exe (7z920-x64)
rem       7z920-x64: http://7-zip.org/a/7z920-x64.msi
rem
rem Not used currently, but assumed avaliable (can ignore for now, if preparing a jenkins agent):
rem - python 3.5 is available at c:\py35-64 (python 3.5.2-amd64) (not used currently)
rem - cygwin64 available at c:\cygwin64 (not needed currently)
rem
rem Target build:
rem - windows 64 bit
rem - cpu architecture etc on a g2.2xlarge ec2 box
rem
rem environment:
rem - jenkins agent
rem - running out of a job/workspace directory
rem - on C: drive, eg c:\jenkins\workspace\[job name]
rem - workspace is wiped at start of each job (this is an option in the 'git' section of a jenkins job)
rem - we are in a directory containing this (distro-win) already cloned, by virtue of the jenkins job bringing it down
rem - to simulate this enviornment, open a cmd, and run:
rem
rem     git clone --recursive https://github.com/hughperkins/distro -b distro-win torch
rem     cd torch

rem based heavily/entirely on what hiili wrote at https://github.com/torch/torch7/wiki/Windows#using-visual-studio
setlocal
call "%VS140COMNTOOLS%\..\..\VC\bin\amd64\vcvars64.bat"
@echo on

set "CMAKE=C:\Program Files\CMake\bin\cmake.exe"
set "GIT=C:\Program Files\Git\bin\git.exe"

rem check if git and cmake is there

set BASE=%~dp0
set "THIS_DIR=%BASE%"
set "PREFIX=%BASE%\install"

set "CMAKE_LIBRARY_PATH=%BASE%/include:%BASE%/lib:%CMAKE_LIBRARY_PATH%"
set "CMAKE_PREFIX_PATH=%PREFIX%"

rem "%GIT%" submodule update --init --recursive

echo BASE: %BASE%

echo luajit-rocks
mkdir "%BASE%\build"
cd "%BASE%\build"
"%CMAKE%" ..\exe\luajit-rocks -DWITH_LUAJIT21=true -DCMAKE_INSTALL_PREFIX=%PREFIX% -G "NMake Makefiles" -DCMAKE_BUILD_TYPE=Release
if errorlevel 1 exit /B 1
nmake
if errorlevel 1 exit /B 1
"%CMAKE%" -DCMAKE_INSTALL_PREFIX=%PREFIX% -G "NMake Makefiles" -P cmake_install.cmake -DCMAKE_BUILD_TYPE=Release
if errorlevel 1 exit /B 1

set "LUA_CPATH=%BASE%/install/?.DLL;%BASE%/install/LIB/?.DLL;?.DLL"
set "LUA_DEV=%BASE%/install"
set "LUA_PATH=;;%BASE%/install/?;%BASE%/install/?.lua;%BASE%/install/lua/?;%BASE%/install/lua/?.lua;%BASE%/install/lua/?/init.lua
set "PATH=%PATH%;%BASE%\install;%BASE%\install\bin"
luajit -e "print('ok')"
if errorlevel 1 goto :error
echo did luajit
cmd /c luarocks
if errorlevel 1 goto :error
echo did luarocks

copy "%BASE%\win-files\cmake.cmd" "%BASE%\install"
if errorlevel 1 exit goto :error
echo did copy of cmake

echo "Installing common Lua packages"
cd %THIS_DIR%extra\luafilesystem
cmd /c luarocks make rockspecs/luafilesystem-1.6.3-1.rockspec
if errorlevel 1 exit /B 1
cd %THIS_DIR%extra\penlight
cmd /c luarocks make
if errorlevel 1 exit /B 1
cd %THIS_DIR%extra\lua-cjson
cmd /c luarocks make
if errorlevel 1 exit /B 1

echo "Installing core Torch packages"
cd %THIS_DIR%extra\luaffifb
cmd /c luarocks make %Base%/win-files/luaffi-scm-1.rockspec
if errorlevel 1 exit /B 1
cd %THIS_DIR%pkg\sundown
cmd /c luarocks make rocks/sundown-scm-1.rockspec
if errorlevel 1 exit /B 1
cd %THIS_DIR%pkg\cwrap
cmd /c luarocks make rocks/cwrap-scm-1.rockspec
if errorlevel 1 exit /B 1
cd %THIS_DIR%pkg\paths
cmd /c luarocks make rocks/paths-scm-1.rockspec
if errorlevel 1 exit /B 1
cd %THIS_DIR%pkg\torch
cmd /c luarocks make %Base%/win-files/torch-scm-1.rockspec
if errorlevel 1 exit /B 1
cd %THIS_DIR%pkg\dok
cmd /c luarocks make rocks/dok-scm-1.rockspec
if errorlevel 1 exit /B 1
cd %THIS_DIR%exe\trepl
cmd /c luarocks make %Base%/win-files/trepl-scm-1.rockspec
if errorlevel 1 exit /B 1
cd %THIS_DIR%pkg\sys
cmd /c luarocks make sys-1.1-0.rockspec
if errorlevel 1 exit /B 1
cd %THIS_DIR%pkg\xlua
cmd /c luarocks make xlua-1.0-0.rockspec
if errorlevel 1 exit /B 1
cd %THIS_DIR%extra\nn
cmd /c luarocks make rocks/nn-scm-1.rockspec
if errorlevel 1 exit /B 1
cd %THIS_DIR%extra\graph
cmd /c luarocks make rocks/graph-scm-1.rockspec
if errorlevel 1 exit /B 1
cd %THIS_DIR%extra\nngraph
cmd /c luarocks make
if errorlevel 1 exit /B 1
cd %THIS_DIR%pkg\image
cmd /c luarocks make image-1.1.alpha-0.rockspec
if errorlevel 1 exit /B 1
cd %THIS_DIR%pkg\optim
cmd /c luarocks make optim-1.0.5-0.rockspec
if errorlevel 1 exit /B 1

luajit -e "require('torch')"
if errorlevel 1 exit /B 1

luajit -e "require('torch'); torch.test()"
if errorlevel 1 exit /B 1

goto :eof

:error
echo something went wrong ...
exit 1
