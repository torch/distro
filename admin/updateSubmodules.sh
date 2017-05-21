git pull
git submodule update
# dont update luajit-rocks because of https://github.com/LuaJIT/LuaJIT/issues/325
git submodule foreach bash -c 'if [ $(basename $(pwd)) != 'luajit-rocks' ]; then git pull origin master; fi'
# git submodule foreach git pull origin master
git add extra pkg exe
git commit -m "updating packages"
