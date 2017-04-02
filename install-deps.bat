@echo off

::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:::: This script setup directories, dependencies for Torch7 ::::
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::


:::: Customizable variables ::::


:: which lua version will be installed for Torch7, default to LUAJIT21
:: accepted lua versions: LUAJIT21, LUAJIT20, LUA53, LUA52, LUA51
REM  set TORCH_LUA_VERSION=LUAJIT21

:: where to install Torch7, default to install\ under distro\
REM  set TORCH_INSTALL_DIR=D:\Torch

:: conda environment name for Torch7, default to torch-vcversion
REM  set TORCH_CONDA_ENV=mytorch7

:: which blas/lapack libraries will be used, default to openblas installed by conda
:: [1] mkl: download from https://software.intel.com/intel-mkl, install and set following two variables
REM  set INTEL_MKL_DIR=D:\\Intel\\SWTools\\compilers_and_libraries\\windows\\mkl\\
REM  set INTEL_COMPILER_DIR=D:\\Intel\\SWTools\\compilers_and_libraries\\windows\\compiler\\
:: [2] other: set path to the blas library and path to the laback library
:: both BLAS and LAPACK should be set even if they refer to the same library
:: take openblas for example: download latest release from https://github.com/xianyi/OpenBLAS/releases/latest
:: use mingw cross compiler tools in cygwin, since mingw windows native gfortrain is available in cygwin but not in msys2
:: compilation command in cygwin: make CC=x86_64-w64-mingw32-gcc FC=x86_64-w64-mingw32-gfortran CROSS_SUFFIX=x86_64-w64-mingw32-
:: please refer to openblas's README for detailed installation instructions
REM  set BLAS_LIBRARIES=D:\\Libraries\\lib\libopenblas.dll.a
REM  set LAPACK_LIBRARIES=D:\\Libraries\\lib\libopenblas.dll.a

:: where to find cudnn library
REM  set CUDNN_PATH=D:\NVIDIA\CUDNN\v5.1\bin\cudnn64_5.dll

:: whether update dependencies if already setup, default to not update
REM  set TORCH_UPDATE_DEPS=

::::  End of customization  ::::


set ECHO_PREFIX=+++++++
set TORCH_SETUP_FAIL=1

:::: validate msvc version  ::::

if "%VisualStudioVersion%" == "" (
  if not "%VS150COMNTOOLS%" == "" ( call "%VS150COMNTOOLS%..\..\VC\Auxiliary\Build\vcvarsall.bat" x64 && goto :VS_SETUP)
  if not "%VS140COMNTOOLS%" == "" ( call "%VS140COMNTOOLS%..\..\VC\vcvarsall.bat" x64 && goto :VS_SETUP)
  if not "%VS120COMNTOOLS%" == "" ( call "%VS120COMNTOOLS%..\..\VC\vcvarsall.bat" x64 && goto :VS_SETUP)
  if not "%VS110COMNTOOLS%" == "" ( call "%VS110COMNTOOLS%..\..\VC\vcvarsall.bat" x64 && goto :VS_SETUP)
  if not "%VS100COMNTOOLS%" == "" ( call "%VS100COMNTOOLS%..\..\VC\vcvarsall.bat" x64 && goto :VS_SETUP)
  if not "%VS90COMNTOOLS%"  == "" ( call "%VS90COMNTOOLS%..\..\VC\vcvarsall.bat"  x64 && goto :VS_SETUP)
)
:VS_SETUP

if "%VisualStudioVersion%" == "" (
  echo %ECHO_PREFIX% Can not find environment variable VisualStudioVersion, msvc is not setup porperly
  goto :FAIL
)

set TORCH_VS_VERSION=%VisualStudioVersion:.0=%

if "%PreferredToolArchitecture%" == "x64" (
  if "%CommandPromptType%" == "Cross" (
    if "%Platform%" == "ARM" set TORCH_VS_PLATFORM=amd64_arm
    if "%Platform%" == "X86" set TORCH_VS_PLATFORM=amd64_x86
    if "%Platform%" == "x86" set TORCH_VS_PLATFORM=amd64_x86
  )
) else (
  if "%CommandPromptType%" == "Cross" (
    if "%Platform%" == "ARM" set TORCH_VS_PLATFORM=x86_arm
    if "%Platform%" == "X64" set TORCH_VS_PLATFORM=x86_amd64
    if "%Platform%" == "x64" set TORCH_VS_PLATFORM=x86_amd64
  )
  if "%CommandPromptType%" == "Native" (
    if "%Platform%" == "X64" set TORCH_VS_PLATFORM=x64
    if "%Platform%" == "x64" set TORCH_VS_PLATFORM=x64
  )
  if "%Platform%"   == ""    set TORCH_VS_PLATFORM=x86
)

if     "%TORCH_VS_PLATFORM%" == "x86"                       set TORCH_VS_TARGET=x86
if not "%TORCH_VS_PLATFORM%" == "%TORCH_VS_PLATFORM:_x86=%" set TORCH_VS_TARGET=x86
if not "%TORCH_VS_PLATFORM%" == "%TORCH_VS_PLATFORM:_arm=%" set TORCH_VS_TARGET=arm
if     "%TORCH_VS_TARGET%"   == ""                          set TORCH_VS_TARGET=x64

::::  validate lua version  ::::

:: [TODO] currently luajit lua luarocks are installed from source. they can be changed to use luajit-rocks when
::        luajit-rocks is ready for windows

if "%TORCH_LUA_VERSION%" == "" set TORCH_LUA_VERSION=LUAJIT21
if /i "%TORCH_LUA_VERSION%" == "LUAJIT21" (
  set TORCH_LUAJIT_BRANCH=v2.1
  set TORCH_LUA_SOURCE=luajit-2.1
  set TORCH_LUAROCKS_LUA=5.1
)
if /i "%TORCH_LUA_VERSION%" == "LUAJIT20" (
  set TORCH_LUAJIT_BRANCH=master
  set TORCH_LUA_SOURCE=luajit-2.0
  set TORCH_LUAROCKS_LUA=5.1
)
if /i "%TORCH_LUA_VERSION%" == "LUA53" (
  set TORCH_LUA_SOURCE=lua-5.3.3
  set TORCH_LUAROCKS_LUA=5.3
)
if /i "%TORCH_LUA_VERSION%" == "LUA52" (
  set TORCH_LUA_SOURCE=lua-5.2.4
  set TORCH_LUAROCKS_LUA=5.2
)
if /i "%TORCH_LUA_VERSION%" == "LUA51" (
  set TORCH_LUA_SOURCE=lua-5.1.5
  set TORCH_LUAROCKS_LUA=5.1
)
if /i "%TORCH_LUA_SOURCE%" == "" (
  echo %ECHO_PREFIX% Bad lua version: %TORCH_LUA_VERSION%, only support LUAJIT21, LUAJIT20, LUA53, LUA52, LUA51
  goto :FAIL
)

::::    Setup directories   ::::

set TORCH_DISTRO=%~dp0.
if "%TORCH_INSTALL_DIR%" == "" set TORCH_INSTALL_DIR=%TORCH_DISTRO%\install
set TORCH_INSTALL_BIN=%TORCH_INSTALL_DIR%\bin
set TORCH_INSTALL_LIB=%TORCH_INSTALL_DIR%\lib
set TORCH_INSTALL_INC=%TORCH_INSTALL_DIR%\include
set TORCH_INSTALL_ROC=%TORCH_INSTALL_DIR%\luarocks
if not exist %TORCH_INSTALL_BIN% md %TORCH_INSTALL_BIN%
if not exist %TORCH_INSTALL_LIB% md %TORCH_INSTALL_LIB%
if not exist %TORCH_INSTALL_INC% md %TORCH_INSTALL_INC%
if not "%TORCH_LUAJIT_BRANCH%" == "" if not exist %TORCH_INSTALL_BIN%\lua\jit md %TORCH_INSTALL_BIN%\lua\jit
if not exist %TORCH_DISTRO%\win-files\3rd md %TORCH_DISTRO%\win-files\3rd

echo %ECHO_PREFIX% Torch7 will be installed under %TORCH_INSTALL_DIR% with %TORCH_LUA_SOURCE%, vs%TORCH_VS_VERSION% %TORCH_VS_PLATFORM%
echo %ECHO_PREFIX% Bin: %TORCH_INSTALL_BIN%
echo %ECHO_PREFIX% Lib: %TORCH_INSTALL_LIB%
echo %ECHO_PREFIX% Inc: %TORCH_INSTALL_INC%

::::   Setup dependencies   ::::

:: has blas/lapack?
if not "%INTEL_MKL_DIR%" == "" if exist %INTEL_MKL_DIR% ( set "TORCH_SETUP_HAS_MKL=1" && set "TORCH_SETUP_HAS_BLAS=1" && set "TORCH_SETUP_HAS_LAPACK=1" )
if not "%BLAS_LIBRARIES%" == "" if exist %BLAS_LIBRARIES% set TORCH_SETUP_HAS_BLAS=1
if not "%LAPACK_LIBRARIES%" == "" if exist %LAPACK_LIBRARIES% set TORCH_SETUP_HAS_LAPACK=1

:: has cuda?
for /f "delims=" %%i in ('where nvcc') do (
  set NVCC_CMD=%%i
  goto :AFTER_NVCC
)
:AFTER_NVCC
if not "%NVCC_CMD%" == "" set TORCH_SETUP_HAS_CUDA=1

:: has conda?
for /f "delims=" %%i in ('where conda') do (
  set CONDA_CMD=%%i
  goto :AFTER_CONDA
)
:AFTER_CONDA

if "%CONDA_CMD%" == "" (
  echo %ECHO_PREFIX% Can not find conda, some dependencies can not be resolved
  if not "%TORCH_SETUP_HAS_BLAS%" == "1" (
    echo %ECHO_PREFIX% Can not install torch, please either specify the blas library or install conda
    goto :FAIL
  )
  goto :NO_CONDA
)

set TORCH_CONDA_INFO=%TORCH_DISTRO%\win-files\check_conda_info_for_torch.txt
conda info > %TORCH_CONDA_INFO%
if "%TORCH_VS_TARGET%" == "x64" set TORCH_CONDA_PLATFORM=win-64
if "%TORCH_VS_TARGET%" == "arm" set TORCH_CONDA_PLATFORM=win-64
if "%TORCH_VS_TARGET%" == "x86" set TORCH_CONDA_PLATFORM=win-32

findstr "%TORCH_CONDA_PLATFORM%" "%TORCH_CONDA_INFO%" >nul
if errorlevel 1 (
  echo %ECHO_PREFIX% %TORCH_VS_TARGET% Torch7 requires %TORCH_CONDA_PLATFORM% conda, installation will continue without conda
  goto :NO_CONDA
)

if %TORCH_VS_VERSION% GEQ 14 ( set CONDA_VS_VERSION=14&& goto :CONDA_SETUP )
if %TORCH_VS_VERSION% GEQ 10 ( set CONDA_VS_VERSION=10&& goto :CONDA_SETUP )
set CONDA_VS_VERSION=9

:CONDA_SETUP

if "%TORCH_CONDA_ENV%" == "" set TORCH_CONDA_ENV=torch-vc%CONDA_VS_VERSION%

echo %ECHO_PREFIX% Createing conda environment '%TORCH_CONDA_ENV%' for Torch7 dependencies
conda create -n %TORCH_CONDA_ENV% -c conda-forge vc=%CONDA_VS_VERSION% --yes

set CONDA_DIR=%CONDA_CMD:\Scripts\conda.exe=%
set TORCH_CONDA_LIBRARY=%CONDA_DIR%\envs\%TORCH_CONDA_ENV%\Library
set TORCH_CONDA_LIBRARY=%TORCH_CONDA_LIBRARY:\=\\%
set PATH=%TORCH_CONDA_LIBRARY%\bin;%PATH%;
set NEW_PATH=%%CONDA_DIR%%\Scripts;%%CONDA_DIR%%\envs\%TORCH_CONDA_ENV%\Library\bin;%NEW_PATH%

set TORCH_CONDA_PKGS=%TORCH_DISTRO%\win-files\check_conda_packages_for_torch.txt
conda list -n %TORCH_CONDA_ENV% > %TORCH_CONDA_PKGS%

:: has cmake?
:: cmake should be installed before qt since its on qt5 while qtlua is on qt4
for /f "delims=" %%i in ('where cmake') do (
  set CMAKE_CMD=%%i
  goto :AFTER_CMAKE
)
if "%CMAKE_CMD%" == "" (
  echo %ECHO_PREFIX% Installing cmake by conda
  conda install -n %TORCH_CONDA_ENV% -c conda-forge cmake --yes
)
:AFTER_CMAKE

:: need openblas?
findstr "openblas" "%TORCH_CONDA_PKGS%" >nul
if not errorlevel 1 ( set "TORCH_SETUP_HAS_BLAS=1" && set "TORCH_SETUP_HAS_LAPACK=1" )

if not "%TORCH_SETUP_HAS_BLAS%"   == "1" goto :CONDA_INSTALL_OPENBLAS
if not "%TORCH_SETUP_HAS_LAPACK%" == "1" goto :CONDA_INSTALL_OPENBLAS
goto :AFTER_OPENBLAS

:CONDA_INSTALL_OPENBLAS
echo %ECHO_PREFIX% Installing openblas by conda, since there is no blas library specified
if not "%TORCH_VS_TARGET%" == "x86" conda install -n %TORCH_CONDA_ENV% -c ukoethe openblas --yes || goto :Fail
if     "%TORCH_VS_TARGET%" == "x86" conda install -n %TORCH_CONDA_ENV% -c omnia   openblas --yes || goto :Fail

:AFTER_OPENBLAS
if not "%TORCH_VS_TARGET%" == "x86" (
  if "%BLAS_LIBRARIES%"   == "" set BLAS_LIBRARIES=%TORCH_CONDA_LIBRARY%\\lib\\libopenblas.lib
  if "%LAPACK_LIBRARIES%" == "" set LAPACK_LIBRARIES=%TORCH_CONDA_LIBRARY%\\lib\\libopenblas.lib
)
if     "%TORCH_VS_TARGET%" == "x86" (
  if "%BLAS_LIBRARIES%"   == "" set BLAS_LIBRARIES=%TORCH_CONDA_LIBRARY%\\lib\\libopenblaspy.dll.a
  if "%LAPACK_LIBRARIES%" == "" set LAPACK_LIBRARIES=%TORCH_CONDA_LIBRARY%\\lib\\libopenblaspy.dll.a
)

:: other dependencies
findstr "jpeg" "%TORCH_CONDA_PKGS%" >nul
if errorlevel 1 set TORCH_DEPENDENCIES=%TORCH_DEPENDENCIES% jpeg
findstr "libpng" "%TORCH_CONDA_PKGS%" >nul
if errorlevel 1 set TORCH_DEPENDENCIES=%TORCH_DEPENDENCIES% libpng
findstr "zlib" "%TORCH_CONDA_PKGS%" >nul
if errorlevel 1 set TORCH_DEPENDENCIES=%TORCH_DEPENDENCIES% zlib
findstr "libxml2" "%TORCH_CONDA_PKGS%" >nul
if errorlevel 1 set TORCH_DEPENDENCIES=%TORCH_DEPENDENCIES% libxml2
findstr "qt" "%TORCH_CONDA_PKGS%" >nul
if errorlevel 1 set TORCH_DEPENDENCIES=%TORCH_DEPENDENCIES% qt=4.8.7

if not "%TORCH_DEPENDENCIES%" == "" (
  echo %ECHO_PREFIX% Installing %TORCH_DEPENDENCIES% by conda for Torch7
  conda install -n %TORCH_CONDA_ENV% -c conda-forge %TORCH_DEPENDENCIES% vc=%CONDA_VS_VERSION% --yes
)

:NO_CONDA
if exist "%TORCH_CONDA_INFO%" del /q %TORCH_CONDA_INFO%
if exist "%TORCH_CONDA_PKGS%" del /q %TORCH_CONDA_PKGS%

::::  git clone luarocks   ::::

echo %ECHO_PREFIX% Git clone luarocks for its tools
cd %TORCH_DISTRO%\exe\
if not exist luarocks\.git git clone https://github.com/keplerproject/luarocks.git luarocks
set PATH=%TORCH_DISTRO%\exe\luarocks\win32\tools\;%PATH%;

::::     install lua       ::::

echo %ECHO_PREFIX% Installing %TORCH_LUA_SOURCE%
cd %TORCH_DISTRO%\exe\
if not "%TORCH_LUAJIT_BRANCH%" == "" (
  if not exist %TORCH_LUA_SOURCE%\.git git clone -b %TORCH_LUAJIT_BRANCH% http://luajit.org/git/luajit-2.0.git %TORCH_LUA_SOURCE% || goto :Fail
  cd %TORCH_LUA_SOURCE% && ( if "%TORCH_UPDATE_DEPS%" == "1" git pull ) & cd src
) else (
  wget -nc https://www.lua.org/ftp/%TORCH_LUA_SOURCE%.tar.gz --no-check-certificate || goto :Fail
  7z x %TORCH_LUA_SOURCE%.tar.gz -y >NUL && 7z x %TORCH_LUA_SOURCE%.tar -y >NUL && cd %TORCH_LUA_SOURCE%\src
)
if not "%TORCH_LUAJIT_BRANCH%"=="" (
  call msvcbuild.bat || goto :FAIL
  copy /y jit\* %TORCH_INSTALL_BIN%\lua\jit\
  copy /y luajit.h %TORCH_INSTALL_INC%\luajit.h
  set LUAJIT_CMD=%TORCH_INSTALL_DIR%\luajit.cmd
) else (
  del /q *.obj *.o *.lib *.dll *.exp *.exe
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
cd luarocks && ( if "%TORCH_UPDATE_DEPS%" == "1" git pull ) & call install.bat /F /Q /P %TORCH_INSTALL_ROC% /SELFCONTAINED /FORCECONFIG /NOREG /NOADMIN /LUA %TORCH_INSTALL_DIR% || goto :FAIL
for /f %%a in ('dir %TORCH_INSTALL_ROC%\config*.lua /b') do set LUAROCKS_CONFIG=%%a
set LUAROCKS_CONFIG=%TORCH_INSTALL_ROC%\%LUAROCKS_CONFIG%
echo rocks_servers = { >> %LUAROCKS_CONFIG%
echo   [[https://raw.githubusercontent.com/torch/rocks/master]], >> %LUAROCKS_CONFIG%
echo   [[https://raw.githubusercontent.com/rocks-moonscript-org/moonrocks-mirror/master]] >> %LUAROCKS_CONFIG%
echo } >> %LUAROCKS_CONFIG%

set LUAROCKS_CMD=%TORCH_INSTALL_DIR%\luarocks.cmd

:::: install wineditline   ::::

echo %ECHO_PREFIX% Installing wineditline for trepl package
cd %TORCH_DISTRO%\win-files\3rd\
wget -nc https://sourceforge.net/projects/mingweditline/files/wineditline-2.201.zip/download --no-check-certificate -O wineditline.zip
7z x wineditline.zip -y >NUL
cd wineditline*
cmake -E make_directory build && cd build && cmake .. -G "NMake Makefiles" -DLIB_SUFFIX="64" -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=..\ && nmake install

::::  install dlfcn-win32  ::::

echo %ECHO_PREFIX% Installing dlfcn-win32 for thread package
cd %TORCH_DISTRO%\win-files\3rd\
if not exist dlfcn-win32\.git git clone https://github.com/dlfcn-win32/dlfcn-win32.git
cd dlfcn-win32 && ( if "%TORCH_UPDATE_DEPS%" == "1" git pull )
cmake -E make_directory build && cd build && cmake .. -G "NMake Makefiles" -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=..\ && nmake install
set WIN_DLFCN_INCDIR=%TORCH_DISTRO:\=\\%\\win-files\\3rd\\dlfcn-win32\\include
set WIN_DLFCN_LIBDIR=%TORCH_DISTRO:\=\\%\\win-files\\3rd\\dlfcn-win32\\lib
copy /y %TORCH_DISTRO%\win-files\3rd\dlfcn-win32\bin\*.dll %TORCH_INSTALL_BIN%\

::::   download graphviz   ::::

echo %ECHO_PREFIX% Downloading graphviz for graph package
cd %TORCH_DISTRO%\win-files\3rd\
wget -nc https://github.com/mahkoCosmo/GraphViz_x64/raw/master/graphviz-2.38_x64.tar.gz --no-check-certificate -O graphviz-2.38_x64.tar.gz
7z x graphviz-2.38_x64.tar.gz -y && 7z x graphviz-2.38_x64.tar -ographviz-2.38_x64 -y >NUL
if not exist %TORCH_INSTALL_BIN%\graphviz md %TORCH_INSTALL_BIN%\graphviz
copy /y %TORCH_DISTRO%\win-files\3rd\graphviz-2.38_x64\bin\ %TORCH_INSTALL_BIN%\graphviz\

set NEW_PATH=%NEW_PATH%;%%TORCH_INSTALL_DIR%%\bin\graphviz

::::    create cmd utils   ::::

if not "%LUAJIT_CMD%" == "" (
  echo %ECHO_PREFIX% Creating torch-activate.cmd luajit.cmd luarocks.cmd cmake.cmd
) else (
  echo %ECHO_PREFIX% Creating torch-activate.cmd lua.cmd luac.cmd luarocks.cmd cmake.cmd
)

set NEW_PATH=%%TORCH_INSTALL_DIR%%;%%TORCH_INSTALL_DIR%%\bin;%%TORCH_INSTALL_DIR%%\luarocks;%%TORCH_INSTALL_DIR%%\luarocks\tools;%%TORCH_INSTALL_DIR%%\luarocks\systree\bin;%NEW_PATH%;%%PATH%%;;
set NEW_LUA_PATH=%%TORCH_INSTALL_DIR%%\luarocks\lua\?.lua;%%TORCH_INSTALL_DIR%%\luarocks\lua\?\init.lua;%%TORCH_INSTALL_DIR%%\luarocks\systree\share\lua\%TORCH_LUAROCKS_LUA%\?.lua;%%TORCH_INSTALL_DIR%%\luarocks\systree\share\lua\%TORCH_LUAROCKS_LUA%\?\init.lua;;
set NEW_LUA_CPATH=%%TORCH_INSTALL_DIR%%\luarocks\systree\lib\lua\%TORCH_LUAROCKS_LUA%\?.dll;;

set TORCHACTIVATE_CMD=%TORCH_INSTALL_DIR%\torch-activate.cmd
if exist %TORCHACTIVATE_CMD% del %TORCHACTIVATE_CMD%
echo @echo off>> %TORCHACTIVATE_CMD%
echo set CONDA_DIR=%CONDA_DIR%>> %TORCHACTIVATE_CMD%
echo set TORCH_INSTALL_DIR=%%~dp0.>> %TORCHACTIVATE_CMD%
echo set TORCH_CONDA_ENV=%TORCH_CONDA_ENV%>> %TORCHACTIVATE_CMD%
echo set TORCH_VS_VERSION=%TORCH_VS_VERSION%>> %TORCHACTIVATE_CMD%
echo set TORCH_VS_PLATFORM=%TORCH_VS_PLATFORM%>> %TORCHACTIVATE_CMD%
if "%TORCH_VS_VERSION%" == "15" (
  set VCVARSALL_BAT_PATH=..\..\VC\Auxiliary\Build\vcvarsall.bat
) else (
  set VCVARSALL_BAT_PATH=..\..\VC\vcvarsall.bat
)
echo for /f "delims=" %%%%i in ('call echo %%%%VS%TORCH_VS_VERSION%0COMNTOOLS%%%%') do call "%%%%i%VCVARSALL_BAT_PATH%" %TORCH_VS_PLATFORM%>> %TORCHACTIVATE_CMD%
echo set PATH=%NEW_PATH%>> %TORCHACTIVATE_CMD%
echo set LUA_PATH=%NEW_LUA_PATH%>> %TORCHACTIVATE_CMD%
echo set LUA_CPATH=%NEW_LUA_CPATH%>> %TORCHACTIVATE_CMD%
if not "%CUDNN_PATH%" == "" echo set CUDNN_PATH=%CUDNN_PATH%>> %TORCHACTIVATE_CMD%

if not "%LUAJIT_CMD%" == "" (
  if exist "%LUAJIT_CMD%" del %LUAJIT_CMD%
  echo @echo off>> "%LUAJIT_CMD%"
  echo setlocal>> "%LUAJIT_CMD%"
  echo set TORCH_INSTALL_DIR=%%~dp0.>> "%LUAJIT_CMD%"
  echo call %%TORCH_INSTALL_DIR%%\torch-activate.cmd>> "%LUAJIT_CMD%"
  echo %%TORCH_INSTALL_DIR%%\bin\luajit.exe %%*>> "%LUAJIT_CMD%"
  echo endlocal>> "%LUAJIT_CMD%"
)

if not "%LUA_CMD%" == "" (
  if exist "%LUA_CMD%" del %LUA_CMD%
  echo @echo off>> "%LUA_CMD%"
  echo setlocal>> "%LUA_CMD%"
  echo set TORCH_INSTALL_DIR=%%~dp0.>> "%LUA_CMD%"
  echo call %%TORCH_INSTALL_DIR%%\torch-activate.cmd>> "%LUA_CMD%"
  echo %%TORCH_INSTALL_DIR%%\bin\lua.exe %%*>> "%LUA_CMD%"
  echo endlocal>> "%LUA_CMD%"
)

if not "%LUAC_CMD%" == "" (
  if exist "%LUAC_CMD%" del %LUAC_CMD%
  echo @echo off>> "%LUAC_CMD%"
  echo setlocal>> "%LUAC_CMD%"
  echo set TORCH_INSTALL_DIR=%%~dp0.>> "%LUAC_CMD%"
  echo call %%TORCH_INSTALL_DIR%%\torch-activate.cmd>> "%LUAC_CMD%"
  echo %%TORCH_INSTALL_DIR%%\bin\luac.exe %%*>> "%LUAC_CMD%"
  echo endlocal>> "%LUAC_CMD%"
)

if exist %LUAROCKS_CMD% del %LUAROCKS_CMD%
echo @echo off>> %LUAROCKS_CMD%
echo setlocal>> %LUAROCKS_CMD%
echo set TORCH_INSTALL_DIR=%%~dp0.>> %LUAROCKS_CMD%
echo call %%TORCH_INSTALL_DIR%%\torch-activate.cmd>> %LUAROCKS_CMD%
echo call %%TORCH_INSTALL_DIR%%\luarocks\luarocks.bat %%*>> %LUAROCKS_CMD%
echo endlocal>> %LUAROCKS_CMD%

set CMAKE_CMD=%TORCH_INSTALL_DIR%\cmake.cmd
if exist %CMAKE_CMD% del %CMAKE_CMD%
echo @echo off>> %CMAKE_CMD%
echo if "%%1" == ".." if not "%%2" == "-G" goto :G_NMake>> %CMAKE_CMD%
echo cmake.exe %%*>> %CMAKE_CMD%
echo goto :EOF>> %CMAKE_CMD%
echo :G_NMake>> %CMAKE_CMD%
echo shift>> %CMAKE_CMD%
echo cmake.exe .. -G "NMake Makefiles" %%*>> %CMAKE_CMD%

set TORCH_SETUP_FAIL=0
cd %TORCH_DISTRO%
echo %ECHO_PREFIX% Setup succeed!
goto :END

:FAIL
cd %TORCH_DISTRO%
echo %ECHO_PREFIX% Setup fail!

:END
