torch-distro
============

### Hard to install, but perhaps would be nice to have?
* [ ] Install fblualib (currently limited by Folly install)
* [ ] Install fbcunn
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

Now, everything should be installed. Source your profile, or open a new shell
```
source ~/.bashrc  # or ~/.zshrc.
th -e "print 'hello world!'"
```

Note: If you use a non-standard shell, you'll want to add the following directories to your `PATH`
```
export PATH=/Users/Alex/Code/torch-distro/install/bin:$PATH
export LD_LIBRARY_PATH=/Users/Alex/Code/torch-distro/install/lib:$LD_LIBRARY_PATH
```

Tested on Ubuntu 14.04, CentOS/RHEL 6.3 and OSX

