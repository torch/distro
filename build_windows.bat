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

rem call "C:\Program Files (x86)\Microsoft Visual Studio 14.0\VC\vcvarsall.bat"
call "C:\Program Files (x86)\Microsoft Visual Studio 14.0\VC\bin\amd64\vcvars64.bat"
set "PATH=%PATH%;C:\Program Files\CMake\bin"
set "PATH=%PATH%;C:\Program Files\Git\bin"

set "BASE=%CD%"
set "TORCH_INSTALL=%CD%\install"

echo BASE: %BASE%

rem rmdir /s /q "%BASE%\soft"
mkdir "%BASE%\soft"

rmdir /s /q pkg\torch
git submodule update --init pkg/torch
if errorlevel 1 exit /B 1
rem git submodule update --init --recursive

rem install msys64
rem compared to the instructions on the website, using bash direclty is synchronous, and puts the output into our
rem console/jenkins
rem we install it here, since it's a bit non-standard (cf 7zip, cmake, msvc2015, which I think are reasonably standard?)
rem we need it, because we need a fortran compiler
cd /d "%BASE%\soft"
powershell.exe -Command (new-object System.Net.WebClient).DownloadFile('https://sourceforge.net/projects/msys2/files/Base/x86_64/msys2-base-x86_64-20160205.tar.xz/download', 'msys2-base-x86_64-20160205.tar.xz')
if errorlevel 1 exit /B 1
"c:\program files\7-Zip\7z.exe" x msys2-base-x86_64-20160205.tar.xz
if errorlevel 1 exit /B 1
"c:\program files\7-Zip\7z.exe" x msys2-base-x86_64-20160205.tar >nul
if errorlevel 1 exit /B 1
cmd /c msys64\usr\bin\bash --login exit
cmd /c msys64\usr\bin\bash --login -c "pacman -Syu --noconfirm"
cmd /c msys64\usr\bin\bash --login -c "pacman -Sy git tar make mingw-w64-x86_64-gcc mingw-w64-x86_64-gcc-fortran --noconfirm"

rem install lapack; I debated whether to put it in 'build' or 'installdeps', but decided 'build' is  maybe better,
rem on the basis that it might be less stable, subject to changes/bugs/tweaks than eg 7zip install?
rem (and also it is architecture specific etc, probalby subject to device-specific optimizations?)
cd /d "%BASE%\soft"
powershell.exe -Command (new-object System.Net.WebClient).DownloadFile('http://www.netlib.org/lapack/lapack-3.6.1.tgz', 'lapack-3.6.1.tgz')
if errorlevel 1 exit /B 1
"c:\program files\7-Zip\7z.exe" x lapack-3.6.1.tgz
if errorlevel 1 exit /B 1
"c:\program files\7-Zip\7z.exe" x lapack-3.6.1.tar >nul
if errorlevel 1 exit /B 1
dir lapack-3.6.1
cd lapack-3.6.1
mkdir build
cd build
set "SOFT=%BASE%\soft"
cmd /c %BASE%\soft\msys64\usr\bin\bash.exe --login "%BASE%\win-files\install_lapack.sh"

echo luajit-rocks
git clone https://github.com/torch/luajit-rocks.git
if errorlevel 1 exit /B 1
cd luajit-rocks
mkdir build
cd build
cmake .. -DCMAKE_INSTALL_PREFIX=%BASE%/install -G "NMake Makefiles" -DCMAKE_BUILD_TYPE=Release
if errorlevel 1 exit /B 1
nmake
if errorlevel 1 exit /B 1
cmake -DCMAKE_INSTALL_PREFIX=%BASE%/install -G "NMake Makefiles" -P cmake_install.cmake -DCMAKE_BUILD_TYPE=Release
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

rem cd "%BASE%\pkg"
cd "%BASE%\pkg\torch"
git checkout 7bbe17917ea560facdc652520e5ea01692e460d3
cmd /c luarocks make "%BASE%\win-files\torch-scm-1.rockspec"
if errorlevel 1 exit /B 1

luajit -e "require('torch')"
if errorlevel 1 exit /B 1

luajit -e "require('torch'); torch.test()"
if errorlevel 1 exit /B 1

goto :eof

:error
echo something went wrong ...
exit 1
