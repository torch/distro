Self-contained Torch installation
============

Install dependencies. Uses `apt-get` on Ubuntu, which might require `sudo`. Uses `brew` on OSX.
```
curl -sk https://raw.githubusercontent.com/torch/ezinstall/master/install-deps | bash
```

Install this repo, which installs the torch distribution, with a lot of nice goodies.
```
git clone https://github.com/torch/distro.git ~/torch --recursive
cd ~/torch; ./install.sh
```

Now, everything should be installed. Source your profile, or open a new shell
```
source ~/.bashrc  # or ~/.zshrc.
th -e "print 'I just installed Torch! Yesss.'"
```

Note: If you use a non-standard shell, you'll want to add the following directories to your `PATH`
```
export PATH=$HOME/torch/install/bin:$PATH
export LD_LIBRARY_PATH=$HOME/torch/install/lib:$LD_LIBRARY_PATH
export DYLD_LIBRARY_PATH=$HOME/torch/install/lib:$DYLD_LIBRARY_PATH
```

Tested on Ubuntu 14.04, CentOS/RHEL 6.3 and OSX
