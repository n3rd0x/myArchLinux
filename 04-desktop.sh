#!/bin/bash
. 00-vars.sh


pacman -S xorg-server xf86-video-intel plasma kde-applications
pacman -S ssdm

systemctl enable ssdm
systemctl start ssdm

# Set keymap
localectl set-x11-keymap no

# Fonts
pacman -S ttf-{bitstream-vera,liberation,freefont,dejavu} freetype2


# nVidia drivers.
pacman -S nvidia-lts nvidia-prime nvidia-utils nvidia-settings


PrintSuccess "======================"
PrintSuccess "* Desktop Completed ^_^ *"
PrintSuccess "=========== =========="
