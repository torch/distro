#!/bin/bash
currdir=`dirname $0`
currdir=$(cd "$currdir" && pwd)
#######################################
PREFIX="${currdir}/install"
#######################################

export PATH=$PREFIX/bin:$PATH
export LD_LIBRARY_PATH=$PREFIX/lib:$LD_LIBRARY_PATH
export DYLD_LIBRARY_PATH=$PREFIX/lib:$DYLD_LIBRARY_PATH

th
