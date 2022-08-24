#!/bin/bash
. 00-vars.sh


if [ ! -d ${wspace} ]; then
	PrintInfo "Create directory structure for workspace."
	mkdir -p ${wspace}/Binaries
	mkdir -p ${wspace}/Data
	mkdir -p ${wspace}/Devs/Builds
	mkdir -p ${wspace}/Devs/Sources
fi

tdir=${wspace}/Devs/Sources/yay.git
if [ ! -d ${tdir} ]; then
	PrintInfo "Install YAY."
	git clone https://aur.archlinux.org/yay.git ${tdir}
	cd ${tdir}
	makepkg -si
	yay -S -noconfirm yay
fi



PrintSuccess "=============================="
PrintSuccess "* Applications Completed ^_^ *"
PrintSuccess "=============================="
