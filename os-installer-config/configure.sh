#!/usr/bin/bash

# This is an example configuration script. For OS-Installer to use it, place it at:
# /etc/os-installer/scripts/configure.sh
# The script gets called with the environment variables from the install script
# (see install.sh) and these additional variables:
# OSI_USER_NAME          : User's name. Not ASCII-fied
# OSI_USER_AUTOLOGIN     : Whether to autologin the user
# OSI_USER_PASSWORD      : User's password. Can be empty if autologin is set.
# OSI_FORMATS            : Locale of formats to be used
# OSI_TIMEZONE           : Timezone to be used
# OSI_ADDITIONAL_SOFTWARE: Space-separated list of additional packages to install

# sanity check that all variables were set
if [ -z ${OSI_LOCALE+x} ] || \
   [ -z ${OSI_DEVICE_PATH+x} ] || \
   [ -z ${OSI_DEVICE_IS_PARTITION+x} ] || \
   [ -z ${OSI_DEVICE_EFI_PARTITION+x} ] || \
   [ -z ${OSI_USE_ENCRYPTION+x} ] || \
   [ -z ${OSI_ENCRYPTION_PIN+x} ] || \
   [ -z ${OSI_USER_NAME+x} ] || \
   [ -z ${OSI_USER_AUTOLOGIN+x} ] || \
   [ -z ${OSI_USER_PASSWORD+x} ] || \
   [ -z ${OSI_FORMATS+x} ] || \
   [ -z ${OSI_TIMEZONE+x} ] || \
   [ -z ${OSI_ADDITIONAL_SOFTWARE+x} ]
then
    echo "Installer script called without all environment variables set!"
    exit 1
fi

# Enable systemd services
#
# A list of systemd services is loaded from systemd.services and
# enabled on by one
#
# I considered using presets for this, however to keep the OS as
# flexible as possible I opted for this method instead, on top of
# that nobody on arch uses systemd presets other than systemd itself
while read i; do
	sudo arch-chroot /mnt systemctl enable $i
done < /etc/os-installer/bits/systemd.services

# Set 15 second default timeout in Systemd to avoid long shutdowns
# when applications refused to shut down
sudo sed -i 's/#DefaultTimeoutStopSec=90s/DefaultTimeoutStopSec=15s/g' /mnt/etc/systemd/system.conf

# Generate locales
#
# We are copying our installer's locale config file for it has all
# the locals we might need already enabled. We have to enable all 
# these locales for gnome-initial-setup requires them, it bases 
# its list of available languages on the generated locals
sudo cp -v /etc/locale.gen /mnt/etc/locale.gen
sudo arch-chroot /mnt locale-gen

# Copy custom GDM configuration file to enable initial setup
#
# gnome-initial-setup is started via gdm, when configured gdm will
# start a minimal gnome-shell and gnome-initial-setup if no users
# are present on the system
sudo cp -v /etc/os-installer/bits/gdm/custom.conf /mnt/etc/gdm/custom.conf
sudo arch-chroot /mnt chown gdm:gdm /etc/gdm/custom.conf

# Copy Systemd-boot configuration
sudo cp -v /etc/os-installer/bits/systemd-boot/arkane.conf /mnt/boot/loader/entries/
sudo cp -v /etc/os-installer/bits/systemd-boot/arkane-fallback.conf /mnt/boot/loader/entries/
sudo cp -v /etc/os-installer/bits/systemd-boot/loader.conf /mnt/boot/loader/

# Add dconf tweaks
sudo mkdir -p /mnt/etc/dconf/db/local.d/
sudo cp -v /etc/os-installer/bits/dconf/00-favorite-apps /mnt/etc/dconf/db/local.d/
sudo cp -v /etc/os-installer/bits/dconf/user /mnt/etc/dconf/profile/
sudo arch-chroot /mnt dconf update

# Remove unwanted .desktop files
#
# Arch packages tend to be... fully featured... and thus sometimes 
# ship unwanted bloat
for f in avahi-discover bssh bvnc qv4l2 qvidcap; do
	sudo rm /mnt/usr/share/applications/$f.desktop
done

# Add various symlinks to binaries
## Symlink vi and vim to neovim
sudo ln -s /usr/bin/nvim /mnt/usr/local/bin/vi
sudo ln -s /usr/bin/nvim /mnt/usr/local/bin/vim
## Workaround to allow nvim to start in kgx using its .desktop file
sudo ln -s /usr/bin/kgx /mnt/usr/local/bin/gnome-terminal

# Configure useradd default on new root
#
# The custom useradd default is used for setting Zsh as the default
# shell for newly created users
sudo cp -v /etc/default/useradd /mnt/etc/default/

# Enable wheel in sudoers
sudo sed -i 's/#\ %wheel\ ALL=(ALL:ALL)\ ALL/%wheel\ ALL=(ALL:ALL)\ ALL/g' /mnt/etc/sudoers

# Set default locale as en_US.UTF-8
#
# gnome-initial-setup will default to this language, it will on
# first boot be changed by gnome-initial-setup
echo "LANG=en_US.UTF-8" | sudo tee /mnt/etc/locale.conf

# Set hostname
echo "arkane" | sudo tee /mnt/etc/hostname

# Configure lsb-release
#
# lsb-release is installed as a dependency of some popular packages,
# it being installed with the default config can mess with fetch
# programs making it report the OS as Arch Linux
sud cp -v /etc/lsb-release /mnt/etc/

# Set kernel parameters in Systemd-boot based on if disk encryption is used or not
#
# This is the base string shared by all configurations
export KERNEL_PARAM="lsm=landlock,lockdown,yama,integrity,apparmor,bpf quiet splash loglevel=3 vt.global_cursor_default=0 systemd.show_status=auto rd.udev.log_level=3 rw"

# The kernel parameters have to be configured differently based upon if the
# user opted for disk encryption or not
if [[ ${OSI_USE_ENCRYPTION} == 1 ]];
then
	LUKS_UUID=$(sudo blkid -o value -s UUID ${OSI_DEVICE_PATH}3)
	echo "options rd.luks.name=$LUKS_UUID=arkane_root root=/dev/mapper/arkane_root $KERNEL_PARAM" | sudo tee -a /mnt/boot/loader/entries/arkane.conf
	echo "options rd.luks.name=$LUKS_UUID=arkane_root root=/dev/mapper/arkane_root $KERNEL_PARAM" | sudo tee -a /mnt/boot/loader/entries/arkane-fallback.conf
	sudo sed -i '/^#/!s/HOOKS=(.*)/HOOKS=(systemd sd-plymouth autodetect keyboard keymap consolefont modconf block sd-encrypt filesystems fsck)/g' /mnt/etc/mkinitcpio.conf
	sudo arch-chroot /mnt mkinitcpio -P
else
	echo "options root=\"LABEL=arkane_root\" $KERNEL_PARAM" | sudo tee -a /mnt/boot/loader/entries/arkane.conf
	echo "options root=\"LABEL=arkane_root\" $KERNEL_PARAM" | sudo tee -a /mnt/boot/loader/entries/arkane-fallback.conf
	sudo sed -i '/^#/!s/HOOKS=(.*)/HOOKS=(systemd sd-plymouth autodetect keyboard keymap consolefont modconf block filesystems fsck)/g' /mnt/etc/mkinitcpio.conf
	sudo arch-chroot /mnt mkinitcpio -P
fi

# Ensure synced and umount
#
# Linux sometimes likes to be smart about these things are write everything
# to the memory instead of the disk
sync
sudo umount -R /mnt

exit 0
