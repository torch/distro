#!/bin/sh

SRC=$1
DEST=$2

cat $SRC | sed -f translate_comments_prepare.sed | tr -d '\n' | sed -f translate_comments.sed > $DEST
