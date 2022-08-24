#!/bin/bash
. 00-vars.sh


# ========================================
# Bootstrap
# ========================================
PrintInfo "Initialise the bootstrap process?"
Prompt
if [ "${ans}" = "y" ]; then
    # CPU type.
    ucode="intel-ucode"
    PrintInfo "Please enter your CPU chipset:"
    PrintInfo "  (1) Intel (intel-ucode) => Default"
    PrintInfo "  (2) Amd (amd-ucode)"
    read -p "Enter code: " ans
    if [ "${ans}" = "2" ]; then
        ucode="amd-ucode"
    fi

    pacstrap /mnt base base-devel linux-firmware linux-lts linux-lts-headers mkinitcpio ${ucode} bash-completion btrfs-progs curl git ntfs-3g tar unrar unzip vim wget sudo zip

    PrintInfo "Update fstab."
    genfstab -U /mnt > /mnt/etc/fstab
fi


PrintInfo "Git repo: https://github.com/n3rd0x/myArchLinux.git"
PrintInfo "Change directory into /root"
PrintInfo "Run git clone https://github.com/n3rd0x/myArchLinux.git"


PrintSuccess "==========================="
PrintSuccess "* Bootstrap Completed ^_^ *"
PrintSuccess "==========================="
PrintSuccess "Change root into /mnt."
arch-chroot /mnt