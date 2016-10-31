@setlocal enableextensions
@echo off

::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:::: This script cleans temporary compilation file          ::::
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::


set TORCH_DISTRO=%~dp0.

for /d %%G in ("%TORCH_DISTRO%\win-files\3rd\wineditline-*") do rmdir /s /q "%%~G"\build
cd %TORCH_DISTRO%\win-files\3rd\dlfcn-win32 && git clean -fdx

cd %TORCH_DISTRO%\exe\luajit-rocks && git clean -fdx
cd %TORCH_DISTRO%\exe\lua-5.1.5 && del /q *.obj *.o *.lib *.dll *.exp *.exe
cd %TORCH_DISTRO%\exe\lua-5.2.4 && del /q *.obj *.o *.lib *.dll *.exp *.exe
cd %TORCH_DISTRO%\exe\lua-5.3.3 && del /q *.obj *.o *.lib *.dll *.exp *.exe
cd %TORCH_DISTRO%\exe\luajit-2.0 && git clean -fdx
cd %TORCH_DISTRO%\exe\luajit-2.1 && git clean -fdx
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
@endlocal
