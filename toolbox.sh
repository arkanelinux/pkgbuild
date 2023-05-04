#!/usr/bin/bash

repo_name='arkane'
repo="${USER}@${ARKANE_REPO}${repo_name}/os/x86_64/"

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
elif [[ $1 == 'push' ]]; then

	scp ./$repo_name.* $repo
	scp ./*/*.pkg.tar.zst $repo
	scp ./*/*.pkg.tar.zst.sig $repo
else
	printf "No valid parameter provided\n"
fi
