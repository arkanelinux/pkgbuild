# os-installer-config
This is the Arkane Linux configuration for [os-installer](https://gitlab.gnome.org/p3732/os-installer).

## Development
### Quirks
This config for os-installer has a hand full of quirks you should be aware of if you plan on forking it or using it as a reference for your own configuration.
1. These scripts only work if the user running os-installer has the ability to sudo without password, this can be configured in the sudoers file
2. No user account is created on the newly installed system, gnome-initial-setup is utilized for account creation
3. The config as-is relies on the arkane package repos, remove or replace any Arkane packages in `base-package.list` and `package.list` to turn it in to a generic Arch Linux installer
4. This config is intended to be used on a UEFI system, it will not (yet) create bootable systems under BIOS

### Layout and files
The os-installer-config's layout may seem like a mess when looking upon this repo, however, it is actually not that bad.

The PKGBUILD will place everything in its intended location, refer to this file for a quick overview of what goes where.

`prepare.sh`, `install.sh` and `configure.sh` are the primary scripts run by os-installer, all other files either serve as configuration files for for various programs run by os-installer-config or are copied to the newly installed OS by one of these three scripts.
