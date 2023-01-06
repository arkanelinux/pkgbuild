#!/usr/bin/bash

# This is an example installer script. For OS-Installer to use it, place it at:
# /etc/os-installer/scripts/install.sh
# The script gets called with the following environment variables set:
# OSI_LOCALE              : Locale to be used in the new system
# OSI_DEVICE_PATH         : Device path at which to install
# OSI_DEVICE_IS_PARTITION : 1 if the specified device is a partition (0 -> disk)
# OSI_DEVICE_EFI_PARTITION: Set if device is partition and system uses EFI boot.
# OSI_USE_ENCRYPTION      : 1 if the installation is to be encrypted
# OSI_ENCRYPTION_PIN      : The encryption pin to use (if encryption is set)

# sanity check that all variables were set
if [ -z ${OSI_LOCALE+x} ] || \
   [ -z ${OSI_DEVICE_PATH+x} ] || \
   [ -z ${OSI_DEVICE_IS_PARTITION+x} ] || \
   [ -z ${OSI_DEVICE_EFI_PARTITION+x} ] || \
   [ -z ${OSI_USE_ENCRYPTION+x} ] || \
   [ -z ${OSI_ENCRYPTION_PIN+x} ]
then
    echo "Installer script called without all environment variables set!"
    exit 1
fi

# Partition the disk
#
# We will load the partitioning scheme from part.sfdisk
sudo sfdisk ${OSI_DEVICE_PATH} < /etc/os-installer/bits/part.sfdisk

# Check if NVMe or not
#
# NVMe drives follow a slightly different naming scheme to other
# block devices
if [[ "${OSI_DEVICE_PATH}" == *"nvme"*"n"* ]];
then
	IS_NVME="p"
else
	IS_NVME=""
fi

# Check if encryption is requested and partition accordingly
if [[ ${OSI_USE_ENCRYPTION} == 1 ]];
then
	# Create filesystems on the target disk
	sudo mkfs.fat -F32 "${OSI_DEVICE_PATH}${IS_NVME}1"
	sudo mkswap "${OSI_DEVICE_PATH}${IS_NVME}2"
	echo "${OSI_ENCRYPTION_PIN}" | sudo cryptsetup -q luksFormat "${OSI_DEVICE_PATH}${IS_NVME}3"
	echo "${OSI_ENCRYPTION_PIN}" | sudo cryptsetup open "${OSI_DEVICE_PATH}${IS_NVME}3" arkane_root -
	sudo mkfs.btrfs -f -L arkane_root /dev/mapper/arkane_root

	# Mount partitions to /mnt and activate swap
	sudo mount -o compress=zstd /dev/mapper/arkane_root /mnt
	sudo mount --mkdir "${OSI_DEVICE_PATH}${IS_NVME}1" /mnt/boot
	sudo swapon "${OSI_DEVICE_PATH}${IS_NVME}2"
else
	# Create filesystems on the target disk
	sudo mkfs.fat -F32 "${OSI_DEVICE_PATH}1${IS_NVME}"
	sudo mkswap "${OSI_DEVICE_PATH}${IS_NVME}2"
	sudo mkfs.btrfs -L arkane_root "${OSI_DEVICE_PATH}${IS_NVME}3"

	# Mount partitions to /mnt and activate swap
	sudo mount -o compress=zstd "${OSI_DEVICE_PATH}${IS_NVME}3" /mnt
	sudo mount --mkdir "${OSI_DEVICE_PATH}${IS_NVME}1" /mnt/boot
	sudo swapon "${OSI_DEVICE_PATH}${IS_NVME}2"
fi

# Install base-packages to root
#
# We start with just a basic list of core packages for some packages
# might fail installation when /dev, /proc etc.. are not mounted
sudo pacstrap -K /mnt - < /etc/os-installer/bits/base-package.list

# Generate fstab
sudo genfstab -U /mnt | sudo tee /mnt/etc/fstab

# Copy pacman.conf to root
#
# Our arkaneiso pacman.conf contains all the changes the new install
# will need also such as the Arkane repo definitions and ILoveCandy :)
sudo cp -v /etc/pacman.conf /mnt/etc/pacman.conf

# Populate Ach keyring
#
# For some reason Arch does not populate the keyring upon installing
# arkane-keyring, thus we have to call it manually
sudo arch-chroot /mnt pacman-key --populate arkane

# Install remaining packages to root
#
# Now that the core OS is installed we can install the remaining packages
# via arch-chroot + pacman on the new install
sudo arch-chroot /mnt pacman -S --noconfirm - < /etc/os-installer/bits/package.list

# Install systemd-boot
sudo arch-chroot /mnt bootctl install

exit 0
