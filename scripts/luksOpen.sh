#!/bin/bash
cd "$(dirname "$0")"
. ../00-vars.sh

if [ ! -b "${dmdata}" ]; then
	PrintInfo "Encrypt data partition."
	sudo cryptsetup -v luksOpen ${sddata} ${rddata}
fi


if [ -b "${dmdata}" ]; then
	if [ ! -d "${mtdata}" ]; then
		PrintInfo "Create mounting directory (${mtdata})."
		sudo mkdir -p ${mtdata}

		PrintInfo "Change to user permissions."
		sudo chown -R ${USER}:${USER} ${mtdata}
		cd ${mtdata}
		sudo chown ${USER}:${USER} ..
	fi
	
	if [ ! -d "${mtdata}/Admins" ]; then
		PrintInfo "Mount data partition."
		sudo mount ${dmdata} ${mtdata}
	fi
fi
