#!/bin/bash
. 00-vars.sh


# ========================================
# Keyboard, Network & Timezone
# ========================================
# Keyboard layout.
PrintInfo "Load Norwegian keyboard layout."
loadkeys no


# WIFI
read -p "Enter your Wifi SSID to connect, otherwise press ENTER to skip: " ans
if [ ! "${ans}" = "" ]; then
    iwctl station wlan0 connect ${ans}
    sleep 1
    iwctl station wlan0 show
fi


# Time zone.
PrintInfo "Set time zone to Oslo."
timedatectl set-ntp true
timedatectl set-timezone Europe/Oslo
timedatectl status



# ========================================
# Format & Encrypt
# ========================================
PrintInfo "Open disk partition?"
Prompt
if [ "${ans}" = "y" ]; then
    fdisk ${sddisk}
fi


PrintInfo "Encrypt and format the disk?"
Prompt
if [ "${ans}" = "y" ]; then
    PrintInfo "Format Boot partition."
    mkfs.vfat -F32 ${sdboot}

    PrintInfo "Encrypt Data partition."
    cryptsetup -v luksFormat ${sddata}

    PrintInfo "Encrypt Swap partition."
    cryptsetup -v luksFormat ${sdswap}

    PrintInfo "Encrypt Root parition."
    cryptsetup -v luksFormat ${sdroot}


    PrintInfo "Decrypt Data partition."
    cryptsetup -v luksOpen ${sddata} ${rddata}

    PrintInfo "Decrypt Swap partition."
    cryptsetup -v luksOpen ${sdswap} ${rdswap}

    PrintInfo "Decrypt Root partition."
    cryptsetup -v luksOpen ${sdroot} ${rdroot}


    PrintInfo "Format Data partition (ext4)."
    mkfs.ext4 ${dmdata}

    PrintInfo "Format Swap partition (swap)."
    mkswap ${dmswap}

    PrintInfo "Format Root partition (btrfs)."
    mkfs.btrfs ${dmroot}


    PrintInfo "Create BTRFS subvolumes."
    mount ${dmroot} /mnt
    btrfs subvolume create /mnt/@
    btrfs sub cr /mnt/@home
    btrfs sub cr /mnt/@vms
    btrfs sub cr /mnt/@snapshots

    mkdir -v -p /mnt/@{/var,/var/cache/pacman}
    btrfs sub cr /mnt/@/srv
    btrfs sub cr /mnt/@/var/cache/pacman/pkg
    btrfs sub cr /mnt/@/var/log
    btrfs sub cr /mnt/@/var/tmp

    umount /mnt
fi



# ========================================
# Mount Partitions
# ========================================
PrintInfo "Mount partitions...."

# Root.
if [ ! -b "${dmroot}" ]; then
    # Mount options.
    # Change relatime on all non-boot partitions to noatime (reduces wear if using an SSD).
    opts=noatime,nodiratime,ssd,discard,space_cache=v2,compress=zstd

    PrintInfo "Decrypt 'root': ${sdroot} as ${rdroot}."
    cryptsetup -v luksOpen ${sdroot} ${rdroot}
    mount -v -o ${opts},subvol=@ ${dmroot} /mnt


    if [ ! -d "/mnt/boot" ]; then
        mkdir -v /mnt/boot
    fi


    if [ ! -d "/mnt/home" ]; then
        mkdir -v /mnt/home
    fi
    mount -v -o ${opts},subvol=@home ${dmroot} /mnt/home


    if [ ! -d "/mnt/vms" ]; then
        mkdir -v /mnt/vms
    fi
    mount -v -o ${opts},subvol=@vms ${dmroot} /mnt/vms


    #if [ ! -d "/mnt/var/log" ]; then
    #    mkdir -v -p /mnt/var/log
    #fi
    #mount -v -o ${opts},subvol=@log ${dmroot} /mnt/var/log


    #if [ ! -d "/mnt/var/tmp" ]; then
    #    mkdir -v -p /mnt/var/tmp
    #fi
    #mount -v -o ${opts},subvol=@tmp ${dmroot} /mnt/var/tmp


    #if [ ! -d "/mnt/var/cache/pacman/pkg" ]; then
    #    mkdir -v -p /mnt/var/cache/pacman/pkg
    #fi
    #mount -v -o ${opts},subvol=@pkg ${dmroot} /mnt/var/cache/pacman/pkg


    if [ ! -d "/mnt/.snapshots" ]; then
        mkdir -v /mnt/.snapshots
    fi
    mount -v -o ${opts},subvol=@snapshots ${dmroot} /mnt/.snapshots
fi


# Swap.
if [ ! -b "${dmswap}" ]; then
    PrintInfo "Decrypt 'swap': ${sdswap} as ${rdswap}."
    cryptsetup -v luksOpen ${sdswap} ${rdswap}
fi


# Boot.
if [ ! -d "/mnt/boot/efi" ]; then
    mount -v ${sdboot} /mnt/boot
fi


PrintSuccess "==============================="
PrintSuccess "* Initliasation Completed ^_^ *"
PrintSuccess "==============================="