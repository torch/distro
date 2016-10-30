@echo off

::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:::: This script setup directories, dependencies for Torch7 ::::
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::


:::: Customizable variables ::::


:: which lua version will be installed for Torch7, default to LUAJIT21
:: accepted lua versions: LUAJIT21, LUAJIT20, LUA53, LUA52, LUA51
REM  set TORCH_LUA_VERSION=LUAJIT21

:: where to install Torch7, default to install\ under distro\
REM  set TORCH_INSTALL_DIR=install

:: conda environment name for Torch7, default to torch
REM  set TORCH_CONDA_ENV=torch

:: which blas/lapack libraries will be used, default to openblas installed by conda
:: [1] mkl: download from https://software.intel.com/intel-mkl, install and set following two variables
REM  set INTEL_MKL_DIR=D:\\Intel\\SWTools\\compilers_and_libraries\\windows\\mkl\\
REM  set INTEL_COMPILER_DIR=D:\\Intel\\SWTools\\compilers_and_libraries\\windows\\compiler\\
:: [2] other: set path to the blas library and path to the laback library
:: both BLAS and LAPACK should be set even if they refer to the same library
:: take openblas for example: download latest release from https://github.com/xianyi/OpenBLAS/releases/latest
:: use mingw cross compiler tools in cygwin, since mingw windows native gfortrain is available in cygwin but not msys2
:: compilation command in cygwin: make CC=x86_64-w64-mingw32-gcc FC=x86_64-w64-mingw32-gfortran CROSS_SUFFIX=x86_64-w64-mingw32-
:: please refer to openblas's README for detailed installation instructions
REM  set BLAS_LIBRARIES=D:\\Libraries\\lib\libopenblas.dll.a
REM  set LAPACK_LIBRARIES=D:\\Libraries\\lib\libopenblas.dll.a

:: where to find cudnn library
REM  set CUDNN_PATH=D:\NVIDIA\CUDNN\v5.1\bin\cudnn64_5.dll


::::  End of customization  ::::


set ECHO_PREFIX=+++++++

::::  validate lua version  ::::

if "%TORCH_LUA_VERSION%" == "" set TORCH_LUA_VERSION=LUAJIT21
if "%TORCH_LUA_VERSION%" == "LUAJIT21" (
  set TORCH_LUAJIT_VERSION=2.1
  set TORCH_LUA_SOURCE=luajit-2.1
  set TORCH_LUAROCKS_LUA=5.1
)
if "%TORCH_LUA_VERSION%" == "LUAJIT20" (
  set TORCH_LUAJIT_VERSION=2.0
  set TORCH_LUA_SOURCE=luajit-2.0
  set TORCH_LUAROCKS_LUA=5.1
)
if "%TORCH_LUA_VERSION%" == "LUA53" (
  set TORCH_LUA_SOURCE=lua-5.3
  set TORCH_LUAROCKS_LUA=5.3
)
if "%TORCH_LUA_VERSION%" == "LUA52" (
  set TORCH_LUA_SOURCE=lua-5.2
  set TORCH_LUAROCKS_LUA=5.2
)
if "%TORCH_LUA_VERSION%" == "LUA51" (
  set TORCH_LUA_SOURCE=lua-5.1
  set TORCH_LUAROCKS_LUA=5.1
)
if "%TORCH_LUA_SOURCE%" == "" (
  echo %ECHO_PREFIX% Bad lua version: %TORCH_LUA_VERSION%, only support LUAJIT21, LUAJIT20, LUA53, LUA52, LUA51
  goto :FAIL
)

::::    Setup directories   ::::

set TORCH_DISTRO=%cd%
if "%TORCH_INSTALL_DIR%" == "" set TORCH_INSTALL_DIR=%TORCH_DISTRO%\install
set TORCH_INSTALL_BIN=%TORCH_INSTALL_DIR%\bin
set TORCH_INSTALL_LIB=%TORCH_INSTALL_DIR%\lib
set TORCH_INSTALL_INC=%TORCH_INSTALL_DIR%\include
set TORCH_INSTALL_ROC=%TORCH_INSTALL_DIR%\luarocks
if not exist %TORCH_INSTALL_BIN% md %TORCH_INSTALL_BIN%
if not exist %TORCH_INSTALL_LIB% md %TORCH_INSTALL_LIB%
if not exist %TORCH_INSTALL_INC% md %TORCH_INSTALL_INC%
if not %TORCH_LUAJIT_VERSION% == "" if not exist %TORCH_INSTALL_BIN%\lua\jit md %TORCH_INSTALL_BIN%\lua\jit
if not exist %TORCH_DISTRO%\win-files\3rd md %TORCH_DISTRO%\win-files\3rd

echo %ECHO_PREFIX% Torch7 will be installed under %TORCH_INSTALL_DIR% with %TORCH_LUA_SOURCE%
echo %ECHO_PREFIX% Bin: %TORCH_INSTALL_BIN%
echo %ECHO_PREFIX% Lib: %TORCH_INSTALL_LIB%
echo %ECHO_PREFIX% Inc: %TORCH_INSTALL_INC%

::::   Setup dependencies   ::::

if not "%INTEL_MKL_DIR%" == "" if exist %INTEL_MKL_DIR% set TORCH_SETUP_HAS_MKL=1
if not "%BLAS_LIBRARIES%" == "" if exist %BLAS_LIBRARIES% set TORCH_SETUP_HAS_BLAS=1
if not "%LAPACK_LIBRARIES%" == "" if exist %LAPACK_LIBRARIES% set TORCH_SETUP_HAS_LAPACK=1
if not "%TORCH_SETUP_HAS_MKL%" == "1" if not "%TORCH_SETUP_HAS_BLAS%" == "1" set TORCH_SETUP_NO_BLAS=1
for /f "delims=" %%i in ('where nvcc') do (
  set NVCC_CMD=%%i
  goto :AFTER_NVCC
)
:AFTER_NVCC

if not "%NVCC_CMD%" == "" set TORCH_SETUP_HAS_CUDA=1

for /f "delims=" %%i in ('where conda') do (
  set CONDA_CMD=%%i
  goto :AFTER_CONDA
)
:AFTER_CONDA

if not "%CONDA_CMD%" == "" (
  set CONDA_DIR=%CONDA_CMD:Scripts\conda.exe=%
  if "%TORCH_CONDA_ENV%" == "" set TORCH_CONDA_ENV=torch
) else (
  echo %ECHO_PREFIX% Can not find conda, some dependencies can not be resolved
  if "%TORCH_SETUP_NO_BLAS%" == "1" (
    echo %ECHO_PREFIX% Can not install torch, since there is no blas library specified
    goto :FAIL
  )
)

:: use \\ instead of \ for luarocks arguments
set CONDA_DIR=%CONDA_DIR:\=\\%

echo %ECHO_PREFIX% Createing conda environment '%TORCH_CONDA_ENV%' for Torch7 dependencies
conda create -n %TORCH_CONDA_ENV% -c conda-forge vc --yes
set TORCH_CONDA_LIBRARY=%CONDA_DIR%envs\\%TORCH_CONDA_ENV%\\Library

if "%TORCH_SETUP_NO_BLAS%" == "1" (
  echo %ECHO_PREFIX% Installing openblas by conda, since there is no blas library specified
  conda install -n %TORCH_CONDA_ENV% -c ukoethe openblas --yes || goto :Fail
)

echo %ECHO_PREFIX% Installing other dependencies by conda for image, qtlua, etc
conda install -n %TORCH_CONDA_ENV% -c conda-forge jpeg libpng zlib libxml2 qt=4.8.7 --yes

echo %ECHO_PREFIX% Installing tools by conda
set PATH=%TORCH_CONDA_LIBRARY%\bin;%PATH%;

for /f "delims=" %%i in ('where git') do (
  set GIT_CMD=%%i
  goto :AFTER_GIT
)
:AFTER_GIT
if "%GIT_CMD%" == "" conda install -n %TORCH_CONDA_ENV% -c conda-forge git --yes

for /f "delims=" %%i in ('where cmake') do (
  set CMAKE_CMD=%%i
  goto :AFTER_CMAKE
)
:AFTER_CMAKE
if "%CMAKE_CMD%" == "" conda install -n %TORCH_CONDA_ENV% -c conda-forge cmake --yes

set NEW_PATH=%TORCH_CONDA_LIBRARY%\bin;%TORCH_CONDA_LIBRARY%\mingw64\bin;%TORCH_CONDA_LIBRARY%\usr\bin;%NEW_PATH%

::::  git clone luajit-rocks   ::::

echo %ECHO_PREFIX% Git clone luajit-rocks for its tools
cd %TORCH_DISTRO%\exe\
if not exist luajit-rocks\.git git clone https://github.com/torch/luajit-rocks.git

set PATH=%TORCH_DISTRO%\exe\luajit-rocks\luarocks\win32\tools;%PATH%;

::::     install lua       ::::

echo %ECHO_PREFIX% Installing %TORCH_LUA_SOURCE%
cd %TORCH_DISTRO%\exe\luajit-rocks\%TORCH_LUA_SOURCE%\src
if not "%TORCH_LUAJIT_VERSION%"=="" (
  call msvcbuild.bat || goto :FAIL
  copy /y jit\* %TORCH_INSTALL_BIN%\lua\jit\
  copy /y luajit.h %TORCH_INSTALL_INC%\luajit.h
  set LUAJIT_CMD=%TORCH_INSTALL_DIR%\luajit.cmd
) else (
  cl /nologo /c /O2 /W3 /D_CRT_SECURE_NO_DEPRECATE /MD /DLUA_BUILD_AS_DLL *.c || goto :FAIL
  ren lua.obj lua.o || goto :FAIL
  ren luac.obj luac.o || goto :FAIL
  link /nologo /DLL /IMPLIB:%TORCH_LUA_VERSION%.lib /OUT:%TORCH_LUA_VERSION%.dll *.obj || goto :FAIL
  link /nologo /OUT:lua.exe lua.o %TORCH_LUA_VERSION%.lib || goto :FAIL
  lib  /nologo /OUT:%TORCH_LUA_VERSION%-static.lib *.obj || goto :FAIL
  link /nologo /OUT:luac.exe luac.o %TORCH_LUA_VERSION%-static.lib || goto :FAIL
  copy /y lua.hpp %TORCH_INSTALL_INC%\lua.hpp
  set LUA_CMD=%TORCH_INSTALL_DIR%\lua.cmd
  set LUAC_CMD=%TORCH_INSTALL_DIR%\luac.cmd
)
copy /y *.exe %TORCH_INSTALL_BIN%\
copy /y *.dll %TORCH_INSTALL_BIN%\
copy /y *.lib %TORCH_INSTALL_LIB%\
for %%g in (lua.h,luaconf.h,lualib.h,lauxlib.h) do copy /y %%g %TORCH_INSTALL_INC%\%%g

::::   install luarocks    ::::

echo %ECHO_PREFIX% Installing luarocks
cd %TORCH_DISTRO%\exe\
if not exist luarocks\.git git clone https://github.com/keplerproject/luarocks.git luarocks
cd luarocks && git fetch & call install.bat /F /Q /P %TORCH_INSTALL_ROC% /SELFCONTAINED /FORCECONFIG /NOREG /NOADMIN /LUA %TORCH_INSTALL_DIR% || goto :FAIL
for /f %%a in ('dir %TORCH_INSTALL_ROC%\config*.lua /b') do set LUAROCKS_CONFIG=%%a
set LUAROCKS_CONFIG=%TORCH_INSTALL_ROC%\%LUAROCKS_CONFIG%
echo rocks_servers = { >> %LUAROCKS_CONFIG%
echo   [[https://raw.githubusercontent.com/torch/rocks/master]], >> %LUAROCKS_CONFIG%
echo   [[https://raw.githubusercontent.com/rocks-moonscript-org/moonrocks-mirror/master]] >> %LUAROCKS_CONFIG%
echo } >> %LUAROCKS_CONFIG%

set LUAROCKS_CMD=%TORCH_INSTALL_DIR%\luarocks.cmd
set NEW_PATH=%TORCH_INSTALL_ROC%\tools\;%NEW_PATH%

:::: install wineditline   ::::

echo %ECHO_PREFIX% Installing wineditline for trepl package
cd %TORCH_DISTRO%\win-files\3rd\
wget -nc https://sourceforge.net/projects/mingweditline/files/latest --no-check-certificate -O wineditline.zip
7z x wineditline.zip -y >NUL
cd wineditline*
cmake -E make_directory build && cd build && cmake .. -G "NMake Makefiles" -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=..\ && nmake install

::::  install dlfcn-win32  ::::
echo %ECHO_PREFIX% Installing dlfcn-win32 for thread package
cd %TORCH_DISTRO%\win-files\3rd\
if not exist dlfcn-win32\.git git clone https://github.com/dlfcn-win32/dlfcn-win32.git
cd dlfcn-win32 && git pull
cmake -E make_directory build && cd build && cmake .. -G "NMake Makefiles" -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=..\ && nmake install
set WIN_DLFCN_INCDIR=%TORCH_DISTRO:\=\\%\\win-files\\3rd\\dlfcn-win32\\include
set WIN_DLFCN_LIBDIR=%TORCH_DISTRO:\=\\%\\win-files\\3rd\\dlfcn-win32\\lib

set NEW_PATH=%TORCH_DISTRO%\win-files\3rd\dlfcn-win32\bin;%NEW_PATH%

::::   download graphviz   ::::

echo %ECHO_PREFIX% Downloading graphviz for graph package
cd %TORCH_DISTRO%\win-files\3rd\
wget -nc https://github.com/mahkoCosmo/GraphViz_x64/raw/master/graphviz-2.38_x64.tar.gz --no-check-certificate -O graphviz-2.38_x64.tar.gz
7z x graphviz-2.38_x64.tar.gz -ographviz -y >NUL

set NEW_PATH=%TORCH_DISTRO%\win-files\3rd\graphviz-2.38_x64\bin;%NEW_PATH%

::::    create cmd utils   ::::

if not "%LUAJIT_CMD%" == "" (
  echo %ECHO_PREFIX% Creating torch-activate.cmd luajit.cmd luarocks.cmd cmake.cmd
) else (
  echo %ECHO_PREFIX% Creating torch-activate.cmd lua.cmd luac.cmd luarocks.cmd cmake.cmd
)

set NEW_PATH=%TORCH_INSTALL_BIN%;%TORCH_INSTALL_ROC%;%TORCH_INSTALL_ROC%\tools;%TORCH_INSTALL_ROC%\systree\bin;%NEW_PATH%;%%PATH%%;;
set NEW_LUA_PATH=%TORCH_INSTALL_ROC%\lua\?.lua;%TORCH_INSTALL_ROC%\lua\?\init.lua;%TORCH_INSTALL_ROC%\systree\share\lua\%TORCH_LUAROCKS_LUA%\?.lua;%TORCH_INSTALL_ROC%\systree\share\lua\%TORCH_LUAROCKS_LUA%\?\init.lua;;
set NEW_LUA_CPATH=%TORCH_INSTALL_ROC%\systree\lib\lua\%TORCH_LUAROCKS_LUA%\?.dll;;

set TORCHACTIVATE_CMD=%TORCH_INSTALL_DIR%\torch-activate.cmd
if exist %TORCHACTIVATE_CMD% del %TORCHACTIVATE_CMD%
echo @echo off >> %TORCHACTIVATE_CMD%
echo set TORCH_INSTALL_DIR=%TORCH_INSTALL_DIR% >> %TORCHACTIVATE_CMD%
echo set TORCH_CONDA_ENV=%TORCH_CONDA_ENV% >> %TORCHACTIVATE_CMD%
echo set PATH=%NEW_PATH% >> %TORCHACTIVATE_CMD%
echo set LUA_PATH=%NEW_LUA_PATH% >> %TORCHACTIVATE_CMD%
echo set LUA_CPATH=%NEW_LUA_CPATH% >> %TORCHACTIVATE_CMD%
if not "%CUDNN_PATH%" == "" echo set CUDNN_PATH=%CUDNN_PATH% >> %TORCHACTIVATE_CMD%

if not "%LUAJIT_CMD%" == "" (
  if exist "%LUAJIT_CMD%" del %LUAJIT_CMD%
  echo @echo off >> "%LUAJIT_CMD%"
  echo setlocal >> "%LUAJIT_CMD%"
  echo call %TORCHACTIVATE_CMD% >> "%LUAJIT_CMD%"
  echo %TORCH_INSTALL_DIR%\bin\luajit.exe %%* >> "%LUAJIT_CMD%"
  echo endlocal >> "%LUAJIT_CMD%"
)

if not "%LUA_CMD%" == "" (
  if exist "%LUA_CMD%" del %LUA_CMD%
  echo @echo off >> "%LUA_CMD%"
  echo setlocal >> "%LUA_CMD%"
  echo call %TORCHACTIVATE_CMD% >> "%LUA_CMD%"
  echo %TORCH_INSTALL_DIR%\bin\lua.exe %%* >> "%LUA_CMD%"
  echo endlocal >> "%LUA_CMD%"
)

if not "%LUAC_CMD%" == "" (
  if exist "%LUAC_CMD%" del %LUAC_CMD%
  echo @echo off >> "%LUAC_CMD%"
  echo setlocal >> "%LUAC_CMD%"
  echo call %TORCHACTIVATE_CMD% >> "%LUAC_CMD%"
  echo %TORCH_INSTALL_DIR%\bin\luac.exe %%* >> "%LUAC_CMD%"
  echo endlocal >> "%LUAC_CMD%"
)

if exist %LUAROCKS_CMD% del %LUAROCKS_CMD%
echo @echo off >> %LUAROCKS_CMD%
echo setlocal >> %LUAROCKS_CMD%
echo call %TORCHACTIVATE_CMD% >> %LUAROCKS_CMD%
echo call %TORCH_INSTALL_DIR%\luarocks\luarocks.bat %%* >> %LUAROCKS_CMD%
echo endlocal >> %LUAROCKS_CMD%

set CMAKE_CMD=%TORCH_INSTALL_DIR%\cmake.cmd
if exist %CMAKE_CMD% del %CMAKE_CMD%
echo @echo off >> %CMAKE_CMD%
echo if "%%1" == ".." if not "%%2" == "-G" goto :G_NMake >> %CMAKE_CMD%
echo cmake.exe %%* >> %CMAKE_CMD%
echo goto :EOF >> %CMAKE_CMD%
echo :G_NMake >> %CMAKE_CMD%
echo shift >> %CMAKE_CMD%
echo cmake.exe .. -G "NMake Makefiles" %%* >> %CMAKE_CMD%

echo %ECHO_PREFIX% Setup succeed!
goto :END

:FAIL
set TORCH_SETUP_FAIL=1
echo %ECHO_PREFIX% Setup fail!

:END
