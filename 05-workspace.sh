#!/bin/bash
. 00-vars.sh


# Mount data.
scripts/luksOpen.sh

if [ ! -d "${mtdata}/Admins" ]; then
	PrintInfo "[Data] Setup directory structure."
	mkdir -p -v ${mtdata}/Admins/Keys
	mkdir -p -v ${mtdata}/AppData/GnuPG
	mkdir -p -v ${mtdata}/AppData/Filezilla
fi


if [ ! -d ${HOME}/.gnupg ]; then
	PrintInfo "Create symlink of GnuPG."
	ln -s ${mtdata}/AppData/GnuPG ${HOME}/.gnupg
fi


PrintSuccess "==========================="
PrintSuccess "* Workspace Completed ^_^ *"
PrintSuccess "==========================="
