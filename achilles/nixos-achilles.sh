#!/bin/env bash

# Single Disk ZFS NixOS Installation

# Always use the by-id aliases for devices, otherwise ZFS can choke on imports.
OS_DISK=/dev/disk/by-id/...
DATA_DISK=/dev/disk/by-id/...

# Remove Crypto Signatures
dd if=/dev/urandom of=$OS_DISK-part2 bs=512 count=40960
dd if=/dev/urandom of=$OS_DISK-part3 bs=512 count=40960
dd if=/dev/urandom of=$DATA_DISK-part1 bs=512 count=40960


# Wipe disk signatures
wipefs -fa $OS_DISK
wipefs -fa $DATA_DISK

# Clear Disk
sgdisk --zap-all $OS_DISK
sgdisk --zap-all $DATA_DISK


# OS DISK
# Partition 1 will be the boot partition EFI
# For EFI support, make an EFI partition:
sgdisk -n1:0:+1G -t1:EF00 -c1:"Fat32 ESP Partition" $OS_DISK
# Partition 2 will be the Swap partition (Encrypted with LUKS) with Hibernation Support (1.5x RAM)
sgdisk -n2:0:+48G -t2:8300 -c2:"Swap Partition" $OS_DISK
# Partition 2 will be the main ZFS partition (Encrypted with LUKS), using up the remaining space on the drive.
sgdisk -n3:0:0 -t3:8300 -c3:"Root Partition" $OS_DISK
partx -u $OS_DISK

# DATA DISK
sgdisk -n1:0:0 -t1:8300 -c1:"Data Partition" $DATA_DISK
partx -u $DATA_DISK


# Swap
cryptsetup luksFormat --label cryptswap -c aes-xts-plain64 -s 512 -h sha256 $OS_DISK-part2
cryptsetup luksOpen $OS_DISK-part2 cryptswap
mkswap -f /dev/mapper/cryptswap
swapon /dev/mapper/cryptswap

# Setup LUKS Encryption of Root
cryptsetup luksFormat --label cryptroot -c aes-xts-plain64 -s 512 -h sha256 $OS_DISK-part3
cryptsetup luksOpen $OS_DISK-part3 cryptroot

# Setup LUKS Encryption of Data
cryptsetup luksFormat --label cryptdata -c aes-xts-plain64 -s 512 -h sha256 $DATA_DISK-part1
cryptsetup luksOpen $DATA_DISK-part1 cryptdata


# Create the pool. If you want to tweak this a bit and you're feeling adventurous, you
# might try adding one or more of the following additional options:
# To disable writing access times:
#   -O atime=off
# To enable filesystem compression:
#   -O compression=lz4
# To improve performance of certain extended attributes:
#   -O xattr=sa
# For systemd-journald posixacls are required
# https://github.com/NixOS/nixpkgs/issues/16954
#   -O  acltype=posixacl 
# To specify that your drive uses 4K sectors instead of relying on the size reported
# by the hardware (note small 'o'):
#   -o ashift=12
#
# The 'mountpoint=none' option disables ZFS's automount machinery; we'll use the
# normal fstab-based mounting machinery in Linux.
# '-R /mnt' is not a persistent property of the FS, it'll just be used while we're installing.
zpool create -f \
        -o ashift=12 \
        -O compression=lz4 \
        -O atime=on \
        -O relatime=on \
        -O normalization=formD \
        -O xattr=sa \
        -O acltype=posixacl \
        -m none \
        -R /mnt \
        zroot /dev/mapper/cryptroot

zpool create -f \
        -o ashift=12 \
        -O compression=lz4 \
        -O atime=on \
        -O relatime=on \
        -O normalization=formD \
        -O xattr=sa \
        -O acltype=posixacl \
        -m none \
        zdata /dev/mapper/cryptdata

# Create the filesystems. This layout is designed so that /home is separate from the root
# filesystem, as you'll likely want to snapshot it differently for backup purposes. It also
# makes a "nixos" filesystem underneath the root, to support installing multiple OSes if
# that's something you choose to do in future.
# / (root) datasets
zfs create -o mountpoint=none -o canmount=off zroot/ROOT
zfs create -o mountpoint=legacy -o canmount=on zroot/ROOT/nixos
mount -t zfs zroot/ROOT/nixos /mnt
zpool set bootfs=zroot/ROOT/nixos zroot
# /nix datasets outside of the root dataset
zfs create -o mountpoint=none -o canmount=off zroot/NIX
zfs create -o mountpoint=legacy -o canmount=on zroot/NIX/nix
mkdir /mnt/nix
mount -t zfs zroot/NIX/nix /mnt/nix
# /home datasets outside of root dataset
zfs create -o mountpoint=none -o canmount=off zroot/HOME
zfs create -o mountpoint=legacy -o canmount=on zroot/HOME/home
# Set Auto Snapshots on /home dataset
zfs set com.sun:auto-snapshot=true zroot/HOME/home
mkdir /mnt/home
mount -t zfs zroot/HOME/home /mnt/home
# /tmp datasets outside of root dataset
zfs create -o mountpoint=none -o canmount=off zroot/TMP
zfs create -o mountpoint=legacy -o canmount=on -o sync=disabled zroot/TMP/tmp
mkdir /mnt/tmp
mount -t zfs zroot/TMP/tmp /mnt/tmp
chmod 1777 /mnt/tmp

# For EFI, you'll need to set up /boot as a non-ZFS partition.
mkfs.vfat -n EFI $OS_DISK-part1
mkdir /mnt/boot
mount -L EFI /mnt/boot

# Configure Data Disk
zfs create -o mountpoint=none -o canmount=off zdata/BACKUP
zfs create -o mountpoint=legacy -o canmount=on zdata/BACKUP/backup
zfs set com.sun:auto-snapshot=true zdata/BACKUP/backup
mkdir /mnt/backup
mount -t zfs zdata/BACKUP/backup /mnt/backup


zfs create -o mountpoint=none -o canmount=off zdata/ONEDRIVE
zfs create -o mountpoint=legacy -o canmount=on zdata/ONEDRIVE/tracerte
zfs set com.sun:auto-snapshot=true zdata/ONEDRIVE/tracerte
mkdir -p /mnt/onedrive/tracerte
mount -t zfs zdata/ONEDRIVE/tracerte /mnt/onedrive/tracerte


# Create configuration directory
mkdir -p /mnt/etc/nixos
echo "Everything setup. Please move/symlink your configuration.nix to /mnt/etc/nixos"
echo "To symlink your configuration run: "
echo "$ ln -s src/nixos/configuration.nix /mnt/etc/nixos/configuration.nix"
echo "To begin installation: "
echo "$ nixos-install"
echo "After successful installation unmount system and export zpool(s)"
echo "umount -lR /mnt"
echo "zpool export zroot"
echo "zpool export zdata"
