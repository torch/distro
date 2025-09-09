[![Build Status](https://travis-ci.org/torch/distro.svg?branch=master)](https://travis-ci.org/torch/distro)


# Torch for RISCV64

Cross-compiled Torch framework for RISCV64 architecture.

## Quick Setup

```shell script
git clone --recursive <repo-url> torch-riscv
cd torch-riscv
patch -p1 < torch-static.patch
bash install-deps
./install-x86.sh
#The crosscompilation step might still use a standard gcc
#on some steps so we need to manually re-wire it to the riscv one
mkdir -p /tmp/cross-wrappers
cp cross-gcc /tmp/cross-wrappers/gcc
export PATH="/tmp/cross-wrappers:$PATH"
./riscv64_cross_compilation_setup.sh
```

## Requirements

- Ubuntu/Debian Linux
- RISCV64 cross-compiler: `sudo apt install gcc-riscv64-linux-gnu`
- Standard build tools: `sudo apt install cmake build-essential`


#### NOTE: Torch is not actively developed anymore and is in maintenance mode.

Self-contained Torch installation
============

#### Please refer to the [Torch installation guide](http://torch.ch/docs/getting-started.html#_) for details on how to make a fresh install of Torch on Linux or MacOS.
#### If on windows with msvc, please refer to this [guide](win-files/README.md) for details on installation and usage.


## Repo content
#### Dependencies
Globally installed dependencies can be installed via:
```bash
bash install-deps
```

#### Lua and Torch
The self-contained Lua and Torch installations are performed via:
```bash
./install.sh
```

By default Torch will install LuaJIT 2.1. If you want other options, you can use the command:
```bash
# If a different version was installed, used ./clean.sh to clean it
TORCH_LUA_VERSION=LUA51 ./install.sh
TORCH_LUA_VERSION=LUA52 ./install.sh
```

## Update
To update your already installed distro to the latest `master` branch of `torch/distro` simply run:
```bash
./update.sh
```

## Cleaning
To remove all the temporary compilation files you can run:
```bash
./clean.sh
```

To remove the installation run:
```bash
# Warning: this will remove your current installation
rm -rf ./install
```
You may also want to remove the `torch-activate` entry from your shell start-up script (`~/.bashrc` or `~/.profile`).

## Test
You can test that all libraries are installed properly by running:
```bash
./test.sh
```

Tested on Ubuntu 14.04, CentOS/RHEL 6.3 and OSX
