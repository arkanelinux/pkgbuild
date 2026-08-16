#!/usr/bin/bash

repo_name='arkane'

if [[ $1 == 'add' ]]; then
	repo-add $repo_name.db.tar.zst ./*/*pkg.tar.zst
elif [[ $1 == 'build' ]]; then
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

elif [[ $1 == 'clear' ]]; then
	rm ./*.old
else
	printf "No valid parameter provided\n"
fi
