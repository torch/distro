torch-distro
============

This is a packaging of torch that installs everything to the same folder (into a subdirectory install/).
It's useful, and is better than installing torch system-wide.

Uses git submodules, so always on the master packages.

```
./install.sh
```
installs torch into the current folder torch-distro/install

If you want to install in another location, change install.sh line 5 
```
./run.sh
```
runs the locally installed torch.

Tested on Ubuntu 14.04, CentOS/RHEL 6.3 and OSX

