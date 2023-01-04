#!/usr/bin/bash

BASE_DIR=$(pwd)

for dir in *;
do
	if [ -d "$dir" ];
	then
		cd $dir
		makepkg -fcd --sign --key $(git config user.email)
		cd $BASE_DIR
	fi
done
