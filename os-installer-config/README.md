# os-installer-config
This config for os-installer has a hand full of quirks you should be aware of if you plan on forking it or using it as a reference for your own configuration.
1. These scripts only work if the user running os-installer has the ability to sudo without password, this can be configured in the sudoers file
2. `pacman-init.service` should finish running before you run the installation scripts, you can configure this service as a `Before` requirement to `display-manager.service` in its .service file
3. No user account is created on the newly installed system, gnome-initial-setup is utilized for account creation
4. The config as-is relies on the arkane package repos, remove or replace any Arkane packages in `base-package.list` and `package.list` to turn in to a generic Arch Linux installer
