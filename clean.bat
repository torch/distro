@setlocal enableextensions
@echo off

::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:::: This script cleans temporary compilation file          ::::
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::


set TORCH_DISTRO=%~dp0.

for /d %%G in ("%TORCH_DISTRO%\win-files\3rd\wineditline-*") do rmdir /s /q "%%~G"\build
cd %TORCH_DISTRO%\win-files\3rd\dlfcn-win32 && git clean -fdx

cd %TORCH_DISTRO%\exe\lua-5.1.5 && del /q *.obj *.o *.lib *.dll *.exp *.exe
cd %TORCH_DISTRO%\exe\lua-5.2.4 && del /q *.obj *.o *.lib *.dll *.exp *.exe
cd %TORCH_DISTRO%\exe\lua-5.3.3 && del /q *.obj *.o *.lib *.dll *.exp *.exe
cd %TORCH_DISTRO%\exe\luajit-2.0 && git clean -fdx
cd %TORCH_DISTRO%\exe\luajit-2.1 && git clean -fdx
cd %TORCH_DISTRO%\exe\luarocks && git clean -fdx

cd %TORCH_DISTRO% && git submodule foreach --recursive git clean -fdx

echo Cleaning is finished
@endlocal
