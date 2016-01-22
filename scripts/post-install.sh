#!/bin/sh

PREFIX=$1
INSTALLDIR=$2

fix_path() {
  find $1 -type f | xargs sed -i "s@$2@$3@ig"
}

mv $PREFIX/bin/luajit ./luajit.bak
mv $PREFIX/bin/qlua ./qlua.bak

for subdir in bin lib/luarocks share/lua share/cmake etc/luarocks ; do
 fix_path "$PREFIX/$subdir" "$PREFIX" "$INSTALLDIR"
 fix_path "$PREFIX/$subdir"  "$HOME"   "\'\$HOME\'"
done

mv  ./luajit.bak $PREFIX/bin/luajit
mv  ./qlua.bak $PREFIX/bin/qlua
