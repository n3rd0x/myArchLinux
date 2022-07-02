#!/bin/bash
. 00-vars.sh


# ========================================
# Close & Clean Up
# ========================================
PrintInfo "Unmount and close encrypted paritions...."


# Boot.
if [ -d "/mnt/boot" ]; then
    umount -v /mnt/boot
fi


# Root.
if [ -b "${dmroot}" ]; then
    umount -v /mnt/home
    umount -v /mnt/vms
    umount -v /mnt/.snapshots
    umount -v /mnt
    cryptsetup -v luksClose ${rdroot}
fi


# Swap.
if [ -b "${dmswap}" ]; then
    cryptsetup -v luksClose ${rdswap}
fi


PrintSuccess "========================"
PrintSuccess "* Umount Completed ^_^ *"
PrintSuccess "========================"