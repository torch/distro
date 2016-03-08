#!/bin/bash

# The envirinment set by create-ubuntu-environmens sscript is trusty, so we should match it.
# Look at debian/gbp.conf for default optiuons sent to gbp.
rm -rf ./install debian/tmp debian/*.log extra/threads/build.luarocks
find . -not -samefile exe/luajit-rocks/luarocks/src/luarocks/build -name build | xargs rm -fr
git commit -a -m 'Preparing for pbuild' && git push
git clean -f
./clean.sh

#setup_lua_env_cmd=$(luarocks path -bin)
#echo "Running: $setup_lua_env_cmd"
#eval "$setup_lua_env_cmd"


gbp buildpackage --git-pbuilder --git-dist=nvidia --git-no-create-orig $1 $2 $3 $4 $5 > ../torch-buildpackage.log 2>&1 &

tail -f ../torch-buildpackage.log

# gbp buildpackage --git-pbuilder --git-dist=trusty $1 $2 $3 $4 $5
# gbp buildpackage $1 $2 $3 $4 $5

# This should produce .deb output in export directory
