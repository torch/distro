Self-contained Torch installation for windows
============

## Prerequisites

#### Must have
- MSVC, anyone of the following choices is sufficient
	- [Visual C++ Build Tools](http://landinghub.visualstudio.com/visual-cpp-build-tools)
	- [Visual Studio Express](https://www.visualstudio.com/vs/visual-studio-express/)
	- [Visual Studio Community](https://www.visualstudio.com/vs/community/)
- [Git](https://git-scm.com/download/win)
- [CMake](https://cmake.org/download/#latest)
- [Conda](http://conda.pydata.org/docs/download.html), manage dependencies like openblas, jpeg, qt, etc

#### If use CUDA

- [CUDA Toolkit](https://developer.nvidia.com/cuda-toolkit)
- [CUDNN](https://developer.nvidia.com/cudnn), if use dnn

#### Optional

- [MKL](https://software.intel.com/intel-mkl), better performance blas/lapack library
- [Gnuplot](https://sourceforge.net/projects/gnuplot/files/latest)
- [GraphicsMagick](https://sourceforge.net/projects/graphicsmagick/files/latest), optional for image package

## Install
Open "Visual Studio Native Tools Command Prompt" and run:
```bat
install.bat
```
By default Torch will be installed under install\ with LuaJIT 2.1 and openlblas from conda environment 'torch'.
There are a few customizable environment variables listed on top of install-deps.bat. There is no need to run
install-deps.bat before run install.bat, it sets variables in global and it will be called directly by install.bat.
*Do not* use lua instead of luajit since lua version Torch will use luaffifb for ffi which has bugs on windows
and has poor performance.

## Use
In order to use Torch in a Self-contained way, a few helper cmd will be installed under the installation directory:
- torchenv.cmd: setup Torch environment including PATH, LUA\_PATH, LUA\_CPATH, CUDNN\_PATH
- luajit.cmd: a wrapper of luajit.exe with Torch environment
- luarocks.cmd: a wrapper of luarocks.bat with Torch environment
- cmake.cmd: a wrapper of cmake.exe which helps package installation with MSVC

#### Use luajit.cmd and luarocks.cmd directly
```bat
path_to_Torch\luajit -ltorch -e "torch.test()"
```
luarocks install should be run in "Visual Studio Native Tools Command Prompt" or consoles with MSVC setup
```bat
path_to_Torch\luarocks install dpnn
```
Torch manages a repo for all packages' rockspecs, however the rockspecs may be not up-to-date. dpnn is one of that
case when I tried. Main problem is that luarocks on windows does not support commands in multiple lines. Instead,
the latest source of [dpnn](https://github.com/Element-Research/dpnn) should be git cloned, cd dpnn and run:
```bat
path_to_Torch\luarocks make rocks\dpnn-scm-1.rockspec
```
It will automatically install not installed dependencies.

#### Run torchenv.cmd, then use availabe Torch executables
```bat
path_to_Torch\torchenv.cmd
th
```
Trepl on windows should work similarly as on linux or macos.

## Clean or Uninstall
To remove all the temporary compilation files:
```bat
clean.bat
```
This will run "git checkout -f" for all packages, so *do not* do modifications in those packages directory, leave them as
synced with github. Do modifications in another cloned folder, and run luarocks.cmd for seperate installation.

To remove the installation:
```bat
uninstall.bat
```
This will remove the install\ directory in addition to clean.bat. Since it has no knowledge where Torch is installed, it
is up to the user to remove the installation directory if Torch is installed in a different place.

## Test
You can test that all libraries are installed properly by running:
```bat
test.bat
```

Tested on Windows 10, Visual Studio Community 2015, Anaconda4, Cuda8.0, MKL2017
