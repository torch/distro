cat .gitmodules |while read i
do
  if [[ $i == \[submodule* ]]; then
    mpath=$(echo $i | cut -d\" -f2)
    read i; read i;
    murl=$(echo $i|cut -d\  -f3)
    mcommit=`eval "git submodule status ${mpath} |cut -d\  -f2"`
    mname=$(basename $mpath)
    echo -e "$name\t$mpath\t$murl\t$mcommit"
    git submodule deinit $mpath
    git rm -r --cached $mpath
    rm -rf $mpath
    git remote add $mname $murl
    git fetch $mname
    git branch _$mname $mcommit
    git read-tree --prefix=$mpath/ -u _$mname
fi
done
git rm .gitmodules
