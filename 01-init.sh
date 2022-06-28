#!/bin/bash

trap Cancel INT

function Cancel() {
	echo "== Process Interupted =="
	exit 0
}


. 00-vars.sh

loadkeys no

read -p "Enter your Wifi SSID: " ans
if [ ! "${ans}" = "" ]; then
    iwctl station wlan0 connect ${ans}
    sleep 1
    iwctl station wlan0 show
fi

timedatectl set-ntp true
timedatectl set-timezone Europe/Oslo

read -p "Open disk partitioning? Enter (y) to accept: " ans
if [ "${ans}" = "y" ]; then
	fdisk /dev/nvme0n1
fi


read -p "Encrypt and format the disk? Enter (y) to accept: " ans
if [ "${ans}" = "y" ]; then
	echo "Format Boot partition."
	mkfs.vfat -F32 ${sdboot}

	echo "Encrypt Data partition."
	cryptsetup -v luksFormat ${sddata}

	echo "Encrypt Swap partition."
	cryptsetup -v luksFormat ${sdswap}

	echo "Encrypt Root parition."
	cryptsetup -v luksFormat ${sdroot}


	echo "Decrypt Data partition."
	cryptsetup -v luksOpen ${sddata} ${rddata}

	echo "Decrypt Swap partition."
	cryptsetup -v luksOpen ${sdswap} ${rdswap}

	echo "Decrypt Root partition."
	cryptsetup -v luksOpen ${sdroot} ${rdroot}


	echo "Format Data partition (ext4)."
	mkfs.ext4 ${dmdata}

	echo "Format Swap partition (swap)."
	mkswap ${dmswap}

	echo "Format Root partition (btrfs)."
	mkfs.btrfs ${dmroot}


	echo "Create BTRFS subvolumes."
	mount ${dmroot} /mnt
	btrfs subvolume create /mnt/@
	btrfs sub cr /mnt/@home
	btrfs sub cr /mnt/@log
	btrfs sub cr /mnt/@pkg
	btrfs sub cr /mnt/@tmp
	btrfs sub cr /mnt/@snapshots

	umount /mnt
fi


echo "Mount partitions...."
opts=noatime,nodiratime,ssd,space_cache=v2,compress=zstd
if [ ! -b "${dmroot}" ]; then
	echo "Mounting Root: ${sdroot} as ${rdroot}."
	cryptsetup -v luksOpen ${sdroot} ${rdroot}
	mount -v -o ${opts},subvol=@ ${dmroot} /mnt


	if [ ! -d "/mnt/boot" ]; then
		mkdir -v /mnt/boot
	fi


	if [ ! -d "/mnt/home" ]; then
		mkdir -v /mnt/home
	fi
	mount -v -o ${opts},subvol=@home ${dmroot} /mnt/home


	if [ ! -d "/mnt/var/log" ]; then
		mkdir -v -p /mnt/var/log
	fi
	mount -v -o ${opts},subvol=@log ${dmroot} /mnt/var/log


	if [ ! -d "/mnt/var/cache/pacman/pkg" ]; then
		mkdir -v -p /mnt/var/cache/pacman/pkg
	fi
	mount -v -o ${opts},subvol=@pkg ${dmroot} /mnt/var/cache/pacman/pkg


	if [ ! -d "/mnt/.snapshots" ]; then
		mkdir -v /mnt/.snapshots
	fi
	mount -v -o ${opts},subvol=@snapshots ${dmroot} /mnt/.snapshots
fi

if [ ! -d "/mnt/boot/efi" ]; then
	echo "Mount Boot: ${sdboot} into /mnt/boot."
	mount -v -o noatime,nodiratime ${sdboot} /mnt/boot
fi
