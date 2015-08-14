#!/usr/bin/env bash

THIS_DIR=$(cd $(dirname $0); pwd)
find "${THIS_DIR}/" -type d -name build -o -name install \
    | grep -v '/exe/luajit-rocks/' | xargs -I {} rm -rf {}
