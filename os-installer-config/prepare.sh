#!/usr/bin/bash

# Infinite loop until pacman-init.service finishes
#
# This is to prevent the user from racing through the os-installer 
# and starting pacman before pacman-init.service finishes running 
# resulting in pacman gpg key errors for the keychain will not be
# synced yet
echo "Waiting for pacman-init.service to finish running before starting the installation..."
while true; do
	systemctl status pacman-init.service | grep "Finished Initializes Pacman keyring."

	if [ $? -eq 0 ];
	then
		echo "pacman-init.service has finished, starting the installation process..."
		break
	fi

	sleep 2
done

# Synchornize with repos
sudo pacman -Syy

exit 0
