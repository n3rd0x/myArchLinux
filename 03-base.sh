#!/bin/bash
. 00-vars.sh


# ========================================
# Timezone
# ========================================
fname="/etc/localtime"
if [ ! -f ${fname} ]; then
    PrintInfo "Set Europe/Oslo to localtime."
    ln -sf /usr/share/zoneinfo/Europe/Oslo ${fname}
fi

if [ ! -f "/etc/adjtime" ]; then
    PrintInfo "Update hardware clock."
    hwclock --systohc --localtime
fi


# ========================================
# Install Base
# ========================================
PrintInfo "Update repository."
pacman --noconfirm -Syu


PrintInfo "(Re)Install base packages?"
Prompt
if [ "${ans}" = "y" ]; then
    # Networks.
    pacman --noconfirm -S networkmanager openssh

    # Utilities.
    pacman --noconfirm -S man-db man-pages ntp
fi



# ========================================
# Configure System
# ========================================
# Locale.
if [ ! -f /etc/locale.conf ]; then
    PrintInfo "Update locale."
    cp -v /etc/locale.gen /etc/locale.gen_origin

    sed -i 's/#en_GB.UTF-8 UTF-8/en_GB.UTF-8 UTF-8/g' /etc/locale.gen
    sed -i 's/#en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/g' /etc/locale.gen
    sed -i 's/#nb_NO.UTF-8 UTF-8/nb_NO.UTF-8 UTF-8/g' /etc/locale.gen

    # Alternative usage.
    #echo "en_GB.UTF-8 UTF-8" >> /etc/locale.gen
    #echo "en_US.UTF-8 UTF-8" >> /etc/locale.gen
    #echo "nb_NO.UTF-8 UTF-8" >> /etc/locale.gen

    locale-gen
    locale >> /etc/locale.conf
fi


# Vconsole.
fname="/etc/vconsole.conf"
if [ ! -f ${fname} ]; then
    PrintInfo "Update vconsole."
    echo "KEYMAP=no" >> ${fname}
fi


# Hostname.
fname="/etc/hostname"
if [ ! -f ${fname} ]; then
    read -p "Enter desired hostname: " ans
    if [ ! "${ans}" = "" ]; then
        PrintInfo "Update hostname as ${ans}."
        echo "${ans}" >> ${fname}
    else
        PrintWarning "Skip update the hostname."
    fi
fi


# Hosts.
fname="/etc/hosts"
if ! grep -q "127.0.0.1" ${fname}; then
    PrintInfo "Update hosts."
    echo "127.0.0.1    localhost" >> ${fname}
    echo "::1          localhost" >> ${fname}

    if [ -f /etc/hostname ]; then
        PrintInfo "Update with local hostname."
        host=$(cat /etc/hostname)
        echo "127.0.0.1    ${host}.localdomain    ${host}" >> ${fname}
    fi
fi


# mkinitcpio
fname="/etc/mkinitcpio.conf"
if grep -q "MODULES=()" ${fname}; then
    PrintInfo "Update mkinitcpio."

    cp ${fname} ${fname}_origin
    sed -i 's/MODULES=()/MODULES=(btrfs vmd)/g' ${fname}
    sed -i 's/HOOKS=(base udev autodetect modconf block filesystems keyboard fsck)/HOOKS=(base udev systemd autodetect keyboard sd-vconsole modconf block sd-encrypt filesystems)/g' ${fname}

    mkinitcpio -P
fi


# Bootloader.
fname="/boot/EFI"
if [ ! -d ${fname} ]; then
    PrintInfo "Install boot EFI."
    bootctl install
fi


fname="/boot/loader/loader.conf"
if ! grep -q "default" ${fname}; then
    PrintInfo "Update loader.conf"
    cp ${fname} ${fname}_origin

    read -p "Enter timeout for the loader, default (0): " ans
    if [ "${ans}" = "" ]; then
        ans="0"
    elif [[ ${ans} -lt 0 || ${ans} -gt 10 ]]; then
        PrintWarning "Invalid value [0, 10]. Set to default."
        ans="0"
    fi

    # Reset file.
    cat /dev/null > ${fname}
    echo "# Set LTS as default.
default arch-lts.conf

# Timeout. If timeout is 0, hold space to open the menu.
timeout ${ans}

# To be confirm its usage.
#console-mode [keep|max]

# Editable on the fly.
editor no" >> ${fname}
fi


# Crypttab.
fname="/etc/crypttab"
if [ ! -f ${fname}_origin ]; then
    cp -v ${fname} ${fname}_origin
fi

# Crypttab.initramfs (define the encrypted uuid and options)
# This would be automatically include bootloader.
if [ ! -f ${fname}.initramfs ]; then
    PrintInfo "Update crypttab.initramfs."
    cp -v ${fname} ${fname}.initramfs

    fname="${fname}.initramfs"
    uuid=$(blkid -o value -s UUID ${sdroot})
    echo "luksRoot       UUID=${uuid}    none" >> ${fname}
fi

fname="/boot/loader/entries/arch-lts.conf"
if [ ! -f ${fname} ]; then
    PrintInfo "Create default LTS kernel."
    echo "title Arch Linux (LTS)" >> ${fname}
    echo "linux /vmlinuz-linux-lts" >> ${fname}

    empty=$(find /boot -name "*amd*")
    if [ ! "${empty}" = "" ]; then
        echo "initrd /amd-ucode.img" >> ${fname}
    fi

    empty=$(find /boot -name "*intel*")
    if [ ! "${empty}" = "" ]; then
        echo "initrd /intel-ucode.img" >> ${fname}
    fi

    echo "initrd /initramfs-lts.img" >> ${fname}
    echo "options root=${dmroot} rootflags=subvol=@ rw" >> ${fname}

    # Alternative usage.
    #uuid=$(blkid -o value -s UUID ${sdroot})
    #echo "options rd.luks.name=UUID=${uuid}=luksRoot root=${dmroot} rd.luks.options=UUID=${uuid}=discard rootflags=subvol=@ rw" >> ${fname}
fi

fname="/boot/loader/entries/arch-lts-fallback.conf"
if [ ! -f ${fname} ]; then
    PrintInfo "Create default LTS (fallback) kernel."
    cp /boot/loader/entries/arch-lts.conf ${fname}

    sed -i 's/Arch Linux (LTS)/Arch Linux (LTS) - Fallback/g' ${fname}
    sed -i 's/initramfs-lts.img/initramfs-lts-fallback.img/g' ${fname}
fi



# ========================================
# Users
# ========================================
empty=$(ls /home)
if [ "${empty}" = "" ]; then
    PrintInfo "Create a new user."

    # Expect correct input.
    read -p "Please enter your name: " name
    read -p "Please enter desired username: " user
    if [ ! "${user}" = "" ]; then
        groupadd -g 1001 ${user}
        useradd -m -g ${user} -G adm,audio,log,rfkill,sys,users,video,wheel -c ${name} ${user}

        PrintInfo "Update user password."
        passwd ${user}
    else
        PrintWarning "Skip creating new user due too invalid input."
    fi
fi


PrintInfo "Lock the root account?"
Prompt
if [ "${ans}" = "y" ]; then
    passwd -l root
fi


fname="/etc/sudoers"
if grep -q "# %wheel ALL=(ALL:ALL) ALL" ${fname}; then
    PrintInfo "Update sudoers."
    cp -v ${fname} ${fname}_origin

    sed -i 's/# %wheel ALL=(ALL:ALL) ALL/%wheel ALL=(ALL:ALL) ALL/g' ${fname}
fi



# ========================================
# Daemons
# ========================================
systemctl enable sshd
systemctl enable NetworkManager.service


PrintSuccess "======================"
PrintSuccess "* Base Completed ^_^ *"
PrintSuccess "=========== =========="
PrintInfo "It now safe to reboot!"