torch-distro
============

## TODO
* [ ] Prereqs (install-deps)
* [ ] Update nn to use getParamsbyDevice branch
* [ ] Squash anaconda in PATH
* [ ] Install torch-distro
* [ ] Update path to opint to torch-distro/install/bin
* [ ] Install fblualib (currently limited by Folly install)
* [ ] Install fbcunn

Need these prereqs installed
```
curl -sk https://raw.githubusercontent.com/torch/ezinstall/master/install-deps | bash
export PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/games:/usr/local/games:/usr/local/cuda/bin:/opt/sge6/bin/linux-x64:/usr/local/cuda/bin:/opt/sge6/bin/linux-x64
git clone https://github.com/soumith/torch-distro.git ~/torch-distro --recursive
cd torch-distro; bash install.sh
echo "export PATH=~/torch-distro/install/bin:\$PATH; export LD_LIBRARY_PATH=~/torch-distro/install/lib:\$LD_LIBRARY_PATH; " >>~/.bashrc && source ~/.bashrc
curl -sk https://raw.githubusercontent.com/soumith/fblualib/master/install_all.sh | sudo bash
git clone https://github.com/torch/nn && cd nn && git checkout getParamsByDevice && luarocks make rocks/nn-scm-1.rockspec
git clone https://github.com/facebook/fbcunn.git
cd fbcunn && luarocks make rocks/fbcunn-scm-1.rockspec # go get a coffee
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

