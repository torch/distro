@setlocal enableextensions
@echo off

::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:::: This script instals Torch7 on windows with msvc        ::::
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::


call install-deps.bat
if "%TORCH_SETUP_FAIL%" == "1" goto :FAIL

echo %ECHO_PREFIX% Updating submodules
git submodule update --init --recursive
set PATCH_DIR=%TORCH_DISTRO%\win-files\patch

echo %ECHO_PREFIX% Installing common lua packages
cd %TORCH_DISTRO%\extra\luafilesystem && call %LUAROCKS_CMD% make rockspecs\luafilesystem-1.6.3-1.rockspec || goto :FAIL
cd %TORCH_DISTRO%\extra\penlight && call %LUAROCKS_CMD% make || goto :FAIL
cd %TORCH_DISTRO%\extra\lua-cjson && git apply %PATCH_DIR%\lua-cjson.patch & call %LUAROCKS_CMD% make & git apply %PATCH_DIR%\lua-cjson.patch --reverse || goto :FAIL

echo %ECHO_PREFIX% Installing core Torch7 packages
cd %TORCH_DISTRO%\extra\luaffifb && git apply %PATCH_DIR%\luaffifb.patch & call %LUAROCKS_CMD% make & git apply %PATCH_DIR%\luaffifb.patch --reverse || goto :FAIL
cd %TORCH_DISTRO%\pkg\sundown && git apply %PATCH_DIR%\sundown.patch --whitespace=nowarn & call %LUAROCKS_CMD% make rocks\sundown-scm-1.rockspec & git apply %PATCH_DIR%\sundown.patch --reverse --whitespace=nowarn || goto :FAIL
cd %TORCH_DISTRO%\pkg\cwrap && call %LUAROCKS_CMD% make rocks\cwrap-scm-1.rockspec || goto :FAIL
cd %TORCH_DISTRO%\pkg\paths && git apply %PATCH_DIR%\paths.patch & call %LUAROCKS_CMD% make rocks\paths-scm-1.rockspec & git apply %PATCH_DIR%\paths.patch --reverse || goto :FAIL
if "%TORCH_SETUP_HAS_MKL%" == "1" (
  cd %TORCH_DISTRO%\pkg\torch && git apply %PATCH_DIR%\torch.patch & call %LUAROCKS_CMD% make rocks/torch-scm-1.rockspec INTEL_MKL_DIR="%INTEL_MKL_DIR%" INTEL_COMPILER_DIR="%INTEL_COMPILER_DIR%" & git apply %PATCH_DIR%\torch.patch --reverse || goto :FAIL
) else (
  if "%TORCH_SETUP_HAS_LAPACK%" == "1" (
    cd %TORCH_DISTRO%\pkg\torch && git apply %PATCH_DIR%\torch.patch & call %LUAROCKS_CMD% make rocks/torch-scm-1.rockspec BLAS_LIBRARIES="%BLAS_LIBRARIES%" LAPACK_LIBRARIES="%LAPACK_LIBRARIES%" LAPACK_FOUND=TRUE & git apply %PATCH_DIR%\torch.patch --reverse || goto :FAIL
  ) else (
    cd %TORCH_DISTRO%\pkg\torch && call %LUAROCKS_CMD% make rocks/torch-scm-1.rockspec || goto :FAIL
  )
)
cd %TORCH_DISTRO%\pkg\dok && call %LUAROCKS_CMD% make rocks/dok-scm-1.rockspec || goto :FAIL
cd %TORCH_DISTRO%\exe\trepl && git apply %PATCH_DIR%\trepl.patch & call %LUAROCKS_CMD% make & git apply %PATCH_DIR%\trepl.patch --reverse || goto :FAIL
cd %TORCH_DISTRO%\pkg\sys && git apply %PATCH_DIR%\sys.patch & call %LUAROCKS_CMD% make sys-1.1-0.rockspec & git apply %PATCH_DIR%\sys.patch --reverse || goto :FAIL
cd %TORCH_DISTRO%\pkg\xlua && call %LUAROCKS_CMD% make xlua-1.0-0.rockspec || goto :FAIL
cd %TORCH_DISTRO%\extra\nn && call %LUAROCKS_CMD% make rocks/nn-scm-1.rockspec || goto :FAIL
cd %TORCH_DISTRO%\extra\graph && git apply %PATCH_DIR%\graph.patch & call %LUAROCKS_CMD% make rocks/graph-scm-1.rockspec & git apply %PATCH_DIR%\graph.patch --reverse || goto :FAIL
cd %TORCH_DISTRO%\extra\nngraph && git apply %PATCH_DIR%\nngraph.patch & call %LUAROCKS_CMD% make & git apply %PATCH_DIR%\nngraph.patch --reverse --whitespace=nowarn || goto :FAIL
cd %TORCH_DISTRO%\pkg\image && call %LUAROCKS_CMD% make image-1.1.alpha-0.rockspec || goto :FAIL
cd %TORCH_DISTRO%\pkg\optim && call %LUAROCKS_CMD% make optim-1.0.5-0.rockspec || goto :FAIL

if not "%TORCH_SETUP_HAS_CUDA%" == "" (
  echo %ECHO_PREFIX% Found CUDA on your machine. Installing CUDA packages
  REM  cd %TORCH_DISTRO%\extra\cutorch && call %LUAROCKS_CMD% make rocks/cutorch-scm-1.rockspec || goto :FAIL
  REM  cd %TORCH_DISTRO%\extra\cunn && git apply ../../win-files/patch/cunn.patch & call %LUAROCKS_CMD% make rocks/cunn-scm-1.rockspec & git apply ../../win-files/patch/cunn.patch --reverse || goto :FAIL
)

echo %ECHO_PREFIX% Installing optional Torch7 packages
cd %TORCH_DISTRO%\pkg\gnuplot && call %LUAROCKS_CMD% make rocks\gnuplot-scm-1.rockspec
cd %TORCH_DISTRO%\exe\env && call %LUAROCKS_CMD% make
cd %TORCH_DISTRO%\extra\nnx && call %LUAROCKS_CMD% make nnx-0.1-1.rockspec
cd %TORCH_DISTRO%\exe\qtlua && call %LUAROCKS_CMD% make rocks/qtlua-scm-1.rockspec
cd %TORCH_DISTRO%\pkg\qttorch && call %LUAROCKS_CMD% make rocks/qttorch-scm-1.rockspec
cd %TORCH_DISTRO%\extra\threads && call %LUAROCKS_CMD% make rocks/threads-scm-1.rockspec WIN_DLFCN_INCDIR=%WIN_DLFCN_INCDIR% WIN_DLFCN_LIBDIR=%WIN_DLFCN_LIBDIR%
cd %TORCH_DISTRO%\extra\argcheck && call %LUAROCKS_CMD% make rocks/argcheck-scm-1.rockspec

if not "%TORCH_SETUP_HAS_CUDA%" == "" (
  echo %ECHO_PREFIX% Found CUDA on your machine. Installing optional CUDA packages
  REM  cd %TORCH_DISTRO%\extra\cudnn && git apply ../../win-files/patch/cudnn.patch & call %LUAROCKS_CMD% make cudnn-scm-1.rockspec & git apply ../../win-files/patch/cudnn.patch --reverse
)

echo %ECHO_PREFIX% Installing packages optional required by Torch7 packages
cd %TORCH_DISTRO%\extra\
if not exist graphicsmagick\.git git clone https://github.com/clementfarabet/graphicsmagick.git
cd %TORCH_DISTRO%\graphicsmagick && git fetch & git apply %PATCH_DIR%\graphicsmagick.patch --whitespace=nowarn & call %LUAROCKS_CMD% make graphicsmagick-1.scm-0.rockspec & git apply %PATCH_DIR%\graphicsmagick.patch --reverse --whitespace=nowarn
cd %TORCH_DISTRO%\extra\
if not exist totem\.git git clone https://github.com/deepmind/torch-totem.git totem
cd %TORCH_DISTRO%\totem && git fetch & call %LUAROCKS_CMD% make rocks\totem-0-0.rockspec

echo %ECHO_PREFIX% Installation succeed!
goto :END

:FAIL
echo %ECHO_PREFIX% Installation error!

:END
@endlocal
