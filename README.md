torch-distro
============

### Desired improvements
* [x] Prereqs (install-deps)
* [x] Squash anaconda in PATH
* [x] Install torch-distro
* [x] Update path to opint to torch-distro/install/bin
* [ ] Install fblualib (currently limited by Folly install)
* [ ] Install fbcunn
* [x] nnx
* [x] cunnx
* [x] iTorch
* [ ] cudnn so file

Install dependencies. Uses `apt-get` on Ubuntu, which might require `sudo`. Uses `brew` on OSX.
```
curl -sk https://raw.githubusercontent.com/torch/ezinstall/master/install-deps | bash
```

Install this repo, which installs the torch distribution, with a lot of nice goodies.
```
git clone https://github.com/soumith/torch-distro.git ~/torch-distro --recursive
cd torch-distro; ./install.sh
```

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

