@setlocal enableextensions
@echo off

::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:::: This script instals Torch7 on windows with msvc        ::::
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::


if not "%TORCH_SETUP_FAIL%" == "0" call install-deps.bat
if not "%TORCH_SETUP_FAIL%" == "0" goto :FAIL

echo %ECHO_PREFIX% Updating submodules
git submodule update --init --recursive

set PATCH_DIR=%TORCH_DISTRO%\win-files\patch

echo %ECHO_PREFIX% Installing common lua packages
cd %TORCH_DISTRO%\extra\luafilesystem && call %LUAROCKS_CMD% make rockspecs\luafilesystem-1.6.3-1.rockspec || goto :FAIL
cd %TORCH_DISTRO%\extra\penlight && call %LUAROCKS_CMD% make penlight-scm-1.rockspec || goto :FAIL
cd %TORCH_DISTRO%\extra\lua-cjson && git apply %PATCH_DIR%\lua-cjson.patch --whitespace=fix & ( call %LUAROCKS_CMD% make lua-cjson-2.1devel-1.rockspec || goto :FAIL ) & git apply %PATCH_DIR%\lua-cjson.patch --reverse --whitespace=fix

echo %ECHO_PREFIX% Installing core Torch7 packages
cd %TORCH_DISTRO%\extra\luaffifb && git apply %PATCH_DIR%\luaffifb.patch --whitespace=fix & ( call %LUAROCKS_CMD% make luaffi-scm-1.rockspec || goto :FAIL ) & git apply %PATCH_DIR%\luaffifb.patch --reverse --whitespace=fix
cd %TORCH_DISTRO%\pkg\sundown && call %LUAROCKS_CMD% make rocks\sundown-scm-1.rockspec || goto :FAIL
cd %TORCH_DISTRO%\pkg\cwrap && call %LUAROCKS_CMD% make rocks\cwrap-scm-1.rockspec || goto :FAIL
cd %TORCH_DISTRO%\pkg\paths && call %LUAROCKS_CMD% make rocks\paths-scm-1.rockspec || goto :FAIL
if "%TORCH_SETUP_HAS_MKL%" == "1" (
  cd %TORCH_DISTRO%\pkg\torch && git apply %PATCH_DIR%\torch.patch --whitespace=fix & ( call %LUAROCKS_CMD% make rocks\torch-scm-1.rockspec INTEL_MKL_DIR="%INTEL_MKL_DIR%" INTEL_COMPILER_DIR="%INTEL_COMPILER_DIR%" || goto :FAIL ) & git apply %PATCH_DIR%\torch.patch --reverse --whitespace=fix
) else (
  cd %TORCH_DISTRO%\pkg\torch && git apply %PATCH_DIR%\torch.patch --whitespace=fix & ( call %LUAROCKS_CMD% make rocks\torch-scm-1.rockspec BLAS_LIBRARIES="%BLAS_LIBRARIES%" LAPACK_LIBRARIES="%LAPACK_LIBRARIES%" LAPACK_FOUND=TRUE || goto :FAIL ) & git apply %PATCH_DIR%\torch.patch --reverse --whitespace=fix
)
cd %TORCH_DISTRO%\pkg\dok && call %LUAROCKS_CMD% make rocks\dok-scm-1.rockspec || goto :FAIL
cd %TORCH_DISTRO%\exe\trepl && call %LUAROCKS_CMD% make trepl-scm-1.rockspec || goto :FAIL
cd %TORCH_DISTRO%\pkg\sys && call %LUAROCKS_CMD% make sys-1.1-0.rockspec || goto :FAIL
cd %TORCH_DISTRO%\pkg\xlua && call %LUAROCKS_CMD% make xlua-1.0-0.rockspec || goto :FAIL
cd %TORCH_DISTRO%\extra\nn && call %LUAROCKS_CMD% make rocks\nn-scm-1.rockspec || goto :FAIL
cd %TORCH_DISTRO%\extra\graph && call %LUAROCKS_CMD% make rocks\graph-scm-1.rockspec || goto :FAIL
cd %TORCH_DISTRO%\extra\nngraph && call %LUAROCKS_CMD% make nngraph-scm-1.rockspec || goto :FAIL
cd %TORCH_DISTRO%\pkg\image && call %LUAROCKS_CMD% make image-1.1.alpha-0.rockspec || goto :FAIL
cd %TORCH_DISTRO%\pkg\optim && call %LUAROCKS_CMD% make optim-1.0.5-0.rockspec || goto :FAIL

if not "%TORCH_SETUP_HAS_CUDA%" == "" if not "%TORCH_VS_TARGET%" == "x86" (
  echo %ECHO_PREFIX% Found CUDA on your machine. Installing CUDA packages
  cd %TORCH_DISTRO%\extra\cutorch && call %LUAROCKS_CMD% make rocks\cutorch-scm-1.rockspec || goto :FAIL
  cd %TORCH_DISTRO%\extra\cunn && call %LUAROCKS_CMD% make rocks\cunn-scm-1.rockspec || goto :FAIL
)

echo %ECHO_PREFIX% Installing optional Torch7 packages
cd %TORCH_DISTRO%\pkg\gnuplot && call %LUAROCKS_CMD% make rocks\gnuplot-scm-1.rockspec
cd %TORCH_DISTRO%\exe\env && call %LUAROCKS_CMD% make env-scm-1.rockspec
cd %TORCH_DISTRO%\extra\nnx && call %LUAROCKS_CMD% make nnx-0.1-1.rockspec
cd %TORCH_DISTRO%\exe\qtlua && call %LUAROCKS_CMD% make rocks\qtlua-scm-1.rockspec
cd %TORCH_DISTRO%\pkg\qttorch && call %LUAROCKS_CMD% make rocks\qttorch-scm-1.rockspec
cd %TORCH_DISTRO%\extra\threads && call %LUAROCKS_CMD% make rocks\threads-scm-1.rockspec WIN_DLFCN_INCDIR=%WIN_DLFCN_INCDIR% WIN_DLFCN_LIBDIR=%WIN_DLFCN_LIBDIR%
cd %TORCH_DISTRO%\extra\argcheck && call %LUAROCKS_CMD% make rocks\argcheck-scm-1.rockspec

if not "%TORCH_SETUP_HAS_CUDA%" == "" if not "%TORCH_VS_TARGET%" == "x86" (
  echo %ECHO_PREFIX% Found CUDA on your machine. Installing optional CUDA packages
  cd %TORCH_DISTRO%\extra\cudnn && call %LUAROCKS_CMD% make cudnn-scm-1.rockspec
)

echo %ECHO_PREFIX% Installation succeed!
goto :END

:FAIL
echo %ECHO_PREFIX% Installation error!

:END
@endlocal
