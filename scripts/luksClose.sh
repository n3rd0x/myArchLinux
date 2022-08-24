#!/bin/bash
cd "$(dirname "$0")"
. ../00-vars.sh

if [ -b "${dmdata}" ]; then
	mtdata="/mnt/data"
	sudo umount ${mtdata}
	sudo cryptsetup -v luksClose ${dmdata}
fi
