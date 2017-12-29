#!/usr/bin/env bash
set -euo pipefail

function check_args() {
	if [ $# -ne 3 ]; then
		echo "Usage: $(basename "$0") library dataset group"
		echo -e "library\tLibrary name"
		echo -e "dataset\tLibrary dataset name"
		echo -e "group\tGroup name for files and directories"
		echo -e "Example usage:"
		echo -e "\t$0 steam zstorage/steam"
		exit 1
	fi
	return 0
}

function main() {
	local parent="$(dirname "$2")"
	if [ ! -d "/$parent" ]; then
		echo "Cannot access root dataset at /$parent"
		exit 2
	elif [ -e "/$2" ]; then
		echo "Library already exists"
		exit 2
	else
		# Configure ZFS
		zfs create -o casesensitivity=mixed "$2"
		zfs create -o casesensitivity=mixed "$2/master"
		net usershare add "$1_master" "/$2/master" "Gamesilo: $1 master library" Everyone:F guest_ok=y
		chgrp "$3" "$2" "$2/master"
		chmod 2770 "$2" "$2/master"

		# Add config
		"$GS" _config create "$1"
		"$GS" _config set "$1" root "$2"
		"$GS" _config set "$1" group "$3"
		"$GS" _config set "$1" master "$2/master"

		echo "Library created!"
		echo -e "\tName: $1"
		echo -e "\tDataset: $2"
		echo -e "\tGroup: $3"
		echo -e "\tMaster library dataset: $2/master"
		echo "The master library has been shared as $1_master"
		echo "and can be accessed via CIFS/Samba to add games"
		echo "See the 'instance' subcommand to manage library instances"
		return 0
	fi
}

check_args $*
main $*
