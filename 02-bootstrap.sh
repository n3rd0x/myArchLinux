#!/bin/bash
read -p "Initialise the bootstrap process? Enter (y) to process: " ans
if [ "${ans}" = "y" ]; then
	pacstrap /mnt base base-devel linux-firmware linux-lts linux-lts-headers vim bash-completion
	
	genfstab -U /mnt >> /mnt/etc/fstab
fi

arch-chroot /mnt
