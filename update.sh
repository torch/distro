# git pull
# git submodule update
git submodule foreach git fetch
git submodule foreach git pull origin master
git submodule foreach git checkout master
git submodule foreach git pull
git add extra pkg exe
git commit -m "updating packages"
