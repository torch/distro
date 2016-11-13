@setlocal enableextensions
@echo off

::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:::: This script [1] cleans temporary compilation file      ::::
::::             [2] deletes Torch7 installation directory  ::::
::::             [3] deletes Torch7 conda environment       ::::
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::


if "%TORCH_INSTALL_DIR%" == "" goto :HELP

set ECHO_PREFIX=+++++++

echo %ECHO_PREFIX% cleaning temporary compilation files
call clean.bat

echo %ECHO_PREFIX% deleting Torch7 installation directory
rmdir /s /q %TORCH_INSTALL_DIR%

echo %ECHO_PREFIX% deleting Torch7 conda environment (even if env is removed, packages will stil be kept in conda/pkgs)
conda env remove -n %TORCH_CONDA_ENV% --yes

echo %ECHO_PREFIX% Torch7 has been uninstalled
goto :END

:HELP
echo Please run torch-activate.cmd before run uninstall.bat so that uninstall knows where to find Torch7.

:END
@endlocal
