#!/bin/bash
. 00-vars.sh


# ========================================
# Timezone
# ========================================
PrintInfo "Set Europe/Oslo to localtime."
ln -sf /usr/share/zoneinfo/Europe/Oslo /etc/localtime

PrintInfo "Set hardware clock."
hwclock --systohc



# ========================================
# Install Base
# ========================================
PrintInfo "Update repository."
pacman --noconfirm -Syu


PrintInfo "Install base packages?"
Prompt
if [ "${ans}" = "y" ]; then
    # Networks.
    pacman --noconfirm -S dhclient dhcpcd dialog iwd inetutils iputils wpa_supplicant networkmanager openssh

    # Utilities.
    pacman --noconfirm -S man-db man-pages ntp
fi



# ========================================
# Configure System
# ========================================
# Locale.
if [ ! -f /etc/locale.conf ]; then
    PrintInfo "Update locale."
    cp /etc/locale.gen /etc/locale.gen_origin

    echo "en_GB.UTF-8 UTF-8" >> /etc/locale.gen
    #echo "en_US.UTF-8 UTF-8" >> /etc/locale.gen
    #echo "nb_NO.UTF-8 UTF-8" >> /etc/locale.gen

    locale-gen
    locale >> /etc/locale.conf
fi


# Vconsole.
if [ ! -f /etc/vconsole.conf ]; then
    PrintInfo "Update vconsole."
    echo "KEYMAP=no" >> /etc/vconsole.conf
fi


# Hostname.
if [ ! -f /etc/hostname ]; then
    read -p "Enter desired hostname: " ans
    if [ ! "${}" = "" ];
        PrintInfo "Update hostname."
        echo "${ans}" >> /etc/hostname
    else
        PrintWarning "Skip update the hostname."
    fi
fi


# Hosts.
if [ ! -f /etc/hosts ]; then
    PrintInfo "Update hosts."
    echo "127.0.0.1    localhost
::1          localhost" >> /etc/hosts

    if [ -f /etc/hostname ]; then
        PrintInfo "Update with local hostname."
        host=$(cat /etc/hostname)
        echo "127.0.0.1    ${host}.localdomain    ${host}" >> /etc/hosts
    fi
fi


# mkinitcpio
if grep -q "MODULES=()" /etc/mkinitcpio.conf; then
    PrintInfo "Update mkinitcpio."

    cp /etc/mkinitcpio.conf /etc/mkinitcpio.conf_origin
    sed -i 's/MODULES=()/MODULES=(btrfs vmd)/g' /etc/mkinitcpio.conf
    sed -i 's/HOOKS=(base udev autodetect modconf block filesystems keyboard fsck)/HOOKS=(base udev systemd autodetect keyboard sd-vconsole modconf block sd-encrypt filesystems)/g' /etc/mkinitcpio.conf

    mkinitcpio -P

    PrintInfo "Install boot EFI."
    bootctl install
fi


# Bootloader
