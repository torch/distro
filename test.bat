@setlocal enableextensions
@echo off

::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:::: This script tests if Torch7 is installed properly      ::::
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::


if "%TORCH_INSTALL_DIR%" == "" goto :HELP

for /f "delims=" %%i in ('where luajit.cmd') do (
  set LUA=%%i
  goto :AFTER_LUAJIT
)

:AFTER_LUAJIT
if exist "%LUA%" (
  set TORCH_USE_LUAJIT=1
) else (
  for /f "delims=" %%i in ('where lua.cmd') do (
    set LUA=%%i
    goto :AFTER_LUA
  )
)

:AFTER_LUA
if not exist "%LUA%" (
  echo Neither luajit nor lua found in Torch7 environment
  goto :FAIL
)

set LUA_SAFE_PATH=%LUA:\=\\%
echo Using Lua at: %LUA%

:: smoke tests
call %LUA% -lpaths     -e "print('paths loaded succesfully')" || goto :FAIL
call %LUA% -ltorch     -e "print('torch loaded succesfully')" || goto :FAIL
call %LUA% -lenv       -e "print('env loaded succesfully')" || goto :FAIL
call %LUA% -ltrepl     -e "print('trepl loaded succesfully')" || goto :FAIL
call %LUA% -ldok       -e "print('dok loaded succesfully')" || goto :FAIL
call %LUA% -limage     -e "print('image loaded succesfully')" || goto :FAIL
call %LUA% -lcwrap     -e "print('cwrap loaded succesfully')" || goto :FAIL
call %LUA% -lgnuplot   -e "print('gnuplot loaded succesfully')" || goto :FAIL
call %LUA% -loptim     -e "print('optim loaded succesfully')" || goto :FAIL
call %LUA% -lsys       -e "print('sys loaded succesfully')" || goto :FAIL
for /f "delims=" %%i in ('where basename') do set BASENAME=%%i
if "%BASENAME%" == "" (
  call %LUA% -lxlua    -e "print('xlua loaded succesfully')" || goto :FAIL
) else (
  call %LUA% -lxlua    -e "print('x$(basename %LUA_SAFE_PATH%) loaded succesfully')" || goto :FAIL
)
call %LUA% -largcheck  -e "print('argcheck loaded succesfully')" || goto :FAIL
call %LUA% -lgraph     -e "print('graph loaded succesfully')" || goto :FAIL
call %LUA% -lnn        -e "print('nn loaded succesfully')" || goto :FAIL
call %LUA% -lnngraph   -e "print('nngraph loaded succesfully')" || goto :FAIL
call %LUA% -lnnx       -e "print('nnx loaded succesfully')" || goto :FAIL
call %LUA% -lthreads   -e "print('threads loaded succesfully')" || goto :FAIL

call th -ltorch -e "torch.test()"
call th -lnn    -e "nn.test()"

if "%TORCH_USE_LUAJIT%" == "1" (
  call %LUA% -lsundown -e "print('sundown loaded succesfully')"
)

call %LUA% -lcutorch -e ""
if "%ERRORLEVEL%" == "0" (
  call %LUA% -lcutorch -e "print('cutorch loaded succesfully')"
  call %LUA% -lcunn    -e "print('cunn loaded succesfully')"
  if "%TORCH_USE_LUAJIT%" == "1" %LUA% -lcudnn -e "print('cudnn loaded succesfully')"
  call th -lcutorch    -e "cutorch.test()"
  call th -lcunn       -e "nn.testcuda()"
) else (
  echo "CUDA not found"
)

echo Test succeed
goto :END

:HELP
echo Please run torch-activate.cmd before run test.bat so that test knows where to find Torch7.
goto :END

:FAIL
echo Test fail

:END
@endlocal
