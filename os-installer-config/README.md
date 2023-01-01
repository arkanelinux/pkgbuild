# os-installer-config
This is the Arkane Linux configuration for [os-installer](https://gitlab.gnome.org/p3732/os-installer).

## Development
### Quirks
This os-installer configuration has a hand full of quirks you should be aware of when using it as a template for your own work;
1. These scripts only work if the user running os-installer has the ability to sudo without password, this can be configured in the sudoers file
2. No user account is created on the newly installed system, gnome-initial-setup is utilized for account creation on first boot
3. The config as-is relies on the arkane package repos, remove or replace any Arkane packages in `base-package.list` and `package.list` to turn it in to a generic Arch Linux installer
4. This config is intended to be used on a UEFI system, it will not create bootable systems under BIOS

### Layout and files
`prepare.sh`, `install.sh` and `configure.sh` are the scripts run by os-installer, all other files are either used as configuration files by various programs called by these scripts or are copied to the newly installed system.
