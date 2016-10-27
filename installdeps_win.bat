set "BASE=%CD%"
set "TORCH_INSTALL=%CD%\install"

rem This is very imperfect, since it assumes a lot of stuff is done by hand
rem But its a start
rem based heavily on hiili's instructions at https://github.com/torch/torch7/wiki/Windows#using-visual-studio

rem assumptions:
rem - ec2 windows 2012 r2 default box (eg ami-281ad849, or equivalent, in ec2, click 'Launch' and select
rem   'Microsoft Windows Server 2012 R2 Base', from 'Quick Start')
rem - powershell available (it is, by default, in above image)
rem
rem Target build:
rem - windows 64 bit
rem - cpu architecture etc on a g2.2xlarge ec2 box
rem
rem Note that this script isnt really standalone currently.  You kind of have to copy and paste a few lines at a
rem time into the terminal really

powershell Set-ExecutionPolicy unrestricted

SET "UN7ZIP=%ProgramFiles%\7-Zip\7z.exe"
SET "CMAKE=%ProgramFiles%\CMake\bin\cmake.exe"

set BASE=%~dp0
set "THIS_DIR=%BASE%"
set "PREFIX=%BASE%\install"
mkdir /D "%BASE%\soft"

pushd "%BASE%"
rem download stuff
cd /d "%BASE%\soft"

if not exist "%ProgramFiles%\7-Zip\7z.exe" (
    Call :Install7Zip
    if errorlevel 1 exit /B 1
)

if not exist "%ProgramFiles%\CMake\bin\cmake.exe" (
    CALL :InstallCMake
    if errorlevel 1 exit /B 1
)

if not exist "%ProgramFiles%\Git\bin\git.exe" (
    CALL :InstallGit
    if errorlevel 1 exit /B 1
)

IF "%VS140COMNTOOLS%" == "" (
echo Please go to https://www.visualstudio.com/products/visual-studio-express-vs to install VS 2015 Comminity edition
rem this will bring up the downloa dpage.  you still need to click through it, but it saves all those ie security dialogs...
rem download the vs2015 community edition, and then open it, run it, install it
    GOTO :EOF
)

rem setup VCVARS
call "%VS140COMNTOOLS%\..\..\VC\bin\amd64\vcvars64.bat"

if not exist %TORCH_INSTALL%\bin\edit.dll (
    CALL :DownloadsLibEdit
    if errorlevel 1 exit /B 1
)

if not exist %TORCH_INSTALL%\libopenblas.dll (
    CALL :InstallOpenBlas
    if errorlevel 1 exit /B 1
)

popd
GOTO :EOF

REM Functions

:Install7Zip
powershell.exe -Command (new-object System.Net.WebClient).DownloadFile('http://7-zip.org/a/7z920-x64.msi', '7x920-x64.msi')
msiexec /passive /i 7x920-x64.msi
sleep 30
EXIT /B

:InstallCMake
powershell.exe -Command "(new-object System.Net.WebClient).DownloadFile('https://cmake.org/files/v3.6/cmake-3.6.2-win64-x64.msi', 'cmake-3.6.2-win64-x64.msi')"
msiexec /passive /i cmake-3.6.2-win64-x64.msi
sleep 30
EXIT /B

:InstallGit
powershell.exe -Command (new-object System.Net.WebClient).DownloadFile('https://github.com/git-for-windows/git/releases/download/v2.9.2.windows.1/Git-2.9.2-64-bit.exe', 'Git-2.9.2-64-bit.exe')
Git-2.9.2-64-bit.exe /silent
sleep 30
Exit /B

:InstallMsys
powershell.exe -Command (new-object System.Net.WebClient).DownloadFile('https://sourceforge.net/projects/msys2/files/Base/x86_64/msys2-base-x86_64-20160205.tar.xz/download', 'msys2-base-x86_64-20160205.tar.xz')
if errorlevel 1 exit /B 1
"%UN7ZIP%" x msys2-base-x86_64-20160205.tar.xz
if errorlevel 1 exit /B 1
"%UN7ZIP%" x msys2-base-x86_64-20160205.tar >nul
if errorlevel 1 exit /B 1
cmd /c msys64\usr\bin\bash --login exit
cmd /c msys64\usr\bin\bash --login -c "pacman -Syu --noconfirm"
cmd /c msys64\usr\bin\bash --login -c "pacman -Sy make mingw-w64-x86_64-gcc mingw-w64-x86_64-gcc-fortran --noconfirm"
Exit /B

:DownloadsLibEdit
powershell.exe -Command (new-object System.Net.WebClient).DownloadFile('http://downloads.sourceforge.net/project/mingweditline/wineditline-2.101.zip', 'wineditline-2.101.zip')
if errorlevel 1 exit /B 1
"%UN7ZIP%" x wineditline-2.101.zip
if errorlevel 1 exit /B 1
cd wineditline-2.101
mkdir build
cd build
"%CMAKE%" .. -DCMAKE_INSTALL_PREFIX=%PREFIX% -G "NMake Makefiles" -DCMAKE_BUILD_TYPE=Release
if errorlevel 1 exit /B 1
NMake
if errorlevel 1 exit /B 1
mkdir %PREFIX%\bin\
copy src\edit.dll %PREFIX%\bin\edit.dll
mkdir %PREFIX%\include\editline
copy ..\include\editline\readline.h %PREFIX%\include\editline\readline.h
mkdir %PREFIX%\lib\
copy src\edit.lib %PREFIX%\lib\libedit.lib
EXIT /B

:DownloadLapack
powershell.exe -Command (new-object System.Net.WebClient).DownloadFile('http://www.netlib.org/lapack/lapack-3.6.1.tgz', 'lapack-3.6.1.tgz')
if errorlevel 1 exit /B 1
"%UN7ZIP%" x lapack-3.6.1.tgz
if errorlevel 1 exit /B 1
"%UN7ZIP%" x lapack-3.6.1.tar >nul
if errorlevel 1 exit /B 1
EXIT /B

:InstallOpenBlas
set BASE=%~dp0
set "TORCH_INSTALL=%BASE%\install"

echo BASE: %BASE%

rem install msys64
rem compared to the instructions on the website, using bash direclty is synchronous, and puts the output into our
rem console/jenkins
rem we install it here, since it's a bit non-standard (cf 7zip, cmake, msvc2015, which I think are reasonably standard?)
rem we need it, because we need a fortran compiler
cd /d "%BASE%\soft"
if not exist "%BASE%\soft\msys64" (
    call :InstallMsys
)

rem Keep openblas in install-dep since the script can handle rerun
cd /d "%BASE%\soft"
if not exist "%BASE%\soft\lapack-3.6.1" (
    CALL :DownloadLapack
)

cd lapack-3.6.1
mkdir build
cd build
set "SOFT=%BASE%\soft"
cmd /c %BASE%\soft\msys64\usr\bin\bash.exe --login "%BASE%\win-files\install_lapack.sh"

Exit /B