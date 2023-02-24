#!/usr/bin/bash

if [[ $1 == 'add' ]]; then
	repo-add arkane.db.tar.zst ./*/*pkg.tar.zst
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
	export repo="${USER}@${ARKANE_REPO}"

	scp ./arkane.* $repo
	scp ./*/*.pkg.tar.zst $repo
	scp ./*/*.pkg.tar.zst.sig $repo
else
	printf "No valid parameter provided\n"
fi
