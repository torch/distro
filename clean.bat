@setlocal enableextensions
@echo off

::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:::: This script cleans temporary compilation file          ::::
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::


set GIT_CMD=
for /f "delims=" %%i in ('where git') do (
  set GIT_CMD=%%i
  goto :AFTER_GIT
)
:AFTER_GIT

if "%GIT_CMD%"=="" goto :HELP

set TORCH_DISTRO=%cd%

for /d %%G in ("%TORCH_DISTRO%\win-files\3rd\wineditline-*") do rmdir /s /q "%%~G"\build

cd %TORCH_DISTRO%\win-files\3rd\dlfcn-win32 && git clean -fdx

cd %TORCH_DISTRO%\exe\luajit-rocks && git clean -fdx
cd %TORCH_DISTRO%\exe\luarocks && git clean -fdx

cd %TORCH_DISTRO%\extra\luafilesystem && git clean -fdx
cd %TORCH_DISTRO%\extra\penlight && git clean -fdx
cd %TORCH_DISTRO%\extra\lua-cjson && git clean -fdx

cd %TORCH_DISTRO%\extra\luaffifb && git clean -fdx
cd %TORCH_DISTRO%\pkg\sundown && git clean -fdx
cd %TORCH_DISTRO%\pkg\cwrap && git clean -fdx
cd %TORCH_DISTRO%\pkg\paths && git clean -fdx
cd %TORCH_DISTRO%\pkg\torch && git clean -fdx
cd %TORCH_DISTRO%\pkg\dok && git clean -fdx
cd %TORCH_DISTRO%\pkg\sys && git clean -fdx
cd %TORCH_DISTRO%\exe\trepl && git clean -fdx
cd %TORCH_DISTRO%\pkg\xlua && git clean -fdx
cd %TORCH_DISTRO%\extra\nn && git clean -fdx
cd %TORCH_DISTRO%\extra\graph && git clean -fdx
cd %TORCH_DISTRO%\extra\nngraph && git clean -fdx
cd %TORCH_DISTRO%\pkg\image && git clean -fdx
cd %TORCH_DISTRO%\pkg\optim && git clean -fdx

cd %TORCH_DISTRO%\pkg\gnuplot && git clean -fdx
cd %TORCH_DISTRO%\exe\env && git clean -fdx
cd %TORCH_DISTRO%\extra\nnx && git clean -fdx
cd %TORCH_DISTRO%\exe\qtlua && git clean -fdx
cd %TORCH_DISTRO%\pkg\qttorch && git clean -fdx
cd %TORCH_DISTRO%\extra\threads && git clean -fdx
cd %TORCH_DISTRO%\extra\argcheck && git clean -fdx

cd %TORCH_DISTRO%\extra\graphicsmagick && git clean -fdx
cd %TORCH_DISTRO%\extra\totem && git clean -fdx

echo Cleaning is finished
goto :END

:HELP
echo Git is not installed globally in this system.
echo Please run torch-activate.cmd before run clean.bat so that git in your installation can be found.

:END
@endlocal
