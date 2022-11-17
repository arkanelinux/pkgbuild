# os-installer-config
This config for os-installer on Arch has a hand full of quirks you should be aware of and take in to consideration were you to us these as a reference for your own os-installer configuration.
1. These scripts only work if the user running os-installer has the ability to sudo without password, this can be configured in the sudoers file
2. `pacman-init.service` should finish running before these scripts are used, you can configure this service as a `Before` requirement to `display-manager.service` in its .service file
