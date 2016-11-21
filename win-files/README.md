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
- [Gnuplot](https://sourceforge.net/projects/gnuplot/files/latest), required by gnuplot package for plotting
- [GraphicsMagick](https://sourceforge.net/projects/graphicsmagick/files/latest), optional for image package

## Install
Open "Windows Command Prompt" and run:
```bat
install.bat
```
By default x64 Torch will be installed under install\ with LuaJIT 2.1 and openlblas from conda environment 'torch-vcversion'.
Run install.bat in a specific  "VS\* \* Tools Command Prompt" to compile for a different target. Please choose x64 conda
for x64 Torch and x86 conda for x86 Torch. X86 Torch does not contain cuda packages and has 2G memory limitation.
There are a few customizable environment variables listed on top of install-deps.bat. There is no need to run
install-deps.bat before run install.bat, it sets variables in global and it will be called directly by install.bat.
**Do not** use lua instead of luajit because currently lua version Torch will use luaffifb for ffi which has bugs on windows
and has poor performance.

It is easy to intall multiple Torch by customizing TORCH\_INSTALL\_DIR, TORCH\_LUA\_VERSION, and by making sure
clean.bat is run before running install.bat.

## Use
In order to use Torch in a Self-contained way, a few helper cmd will be installed under the installation directory:
- torch-activate.cmd: setup Torch environment including TORCH\_INSTALL\_DIR, TORCH\_CONDA\_ENV, TORCH\_VS\_VERSION, TORCH\_VS\_PLATFORM, PATH, LUA\_PATH, LUA\_CPATH, CUDNN\_PATH,
- luajit.cmd: a wrapper of luajit.exe with Torch environment
- luarocks.cmd: a wrapper of luarocks.bat with Torch environment
- cmake.cmd: a wrapper of cmake.exe which helps package installation with MSVC

#### Use luajit.cmd and luarocks.cmd directly
```bat
path_to_Torch\luajit -ltorch -e "torch.test()"
```
The installation will remember which MSVC to use for what platform, so luarocks install can be run in a general "Windows
Command Prompt".
```bat
path_to_Torch\luarocks install rnn
```
It will automatically install not installed dependencies.

#### Run torch-activate.cmd, then use availabe Torch executables
```bat
path_to_Torch\torch-activate
th
qlua
```
Trepl on windows should work similarly as on linux or macos. qlua should be used to run qt related lua codes.

## Clean or Uninstall
To remove all the temporary compilation files:
```bat
clean.bat
```

To remove the installation:
```bat
path_to_Torch\torch-activate
uninstall.bat
```
torch-activate.cmd is called before uninstall.bat so that uninstall knows which Torch7 to uninstall.
In addition to clean.bat, this will remove the directory pointed to by TORCH\_INSTALL\_DIR and TORCH\_CONDA\_ENV from conda.

## Test
You can test that all libraries are installed properly by running:
```bat
path_to_Torch\torch-activate
test.bat
```
torch-activate.cmd is called before test.bat so that test knows which Torch7 to test.

Tested x64 Torch7 on Windows 10 x64, Visual Studio Community 2015, Anaconda4, Cuda Toolkit8.0, MKL2017
