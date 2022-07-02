#!/bin/bash
# Assume that backup files exists.
. 00-vars.sh


# ========================================
# Reset
# ========================================
cp -v /etc/crypttab_origin /etc/crypttab
cp -v /etc/locale.gen_origin /etc/locale.gen
cp -v /etc/mkinitcpio.conf_origin /etc/mkinitcpio.conf
cp -v /etc/sudoers_origin /etc/sudoers
rm -v /boot/loader/entries/arch-lts.conf
rm -v /boot/loader/entries/arch-lts-fallback.conf
rm -v /etc/adjtime
rm -v /etc/crypttab.initramfs
rm -v /etc/hostname
rm -v /etc/hosts
rm -v /etc/locale.conf
rm -v /etc/localtime
rm -v /etc/vconsole.conf
cat /dev/null > /boot/loader/loader.conf
