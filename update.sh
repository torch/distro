#!/usr/bin/env bash

git fetch
git reset --hard origin/master
# Submodule update is done inside install.sh
./install.sh -s
