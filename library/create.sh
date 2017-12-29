#!/usr/bin/env bash
set -euo pipefail

function check_args() {
	if [ $# -ne 3 ]; then
		echo "Usage: $(basename "$0") library dataset group"
		echo -e "library\tLibrary name"
		echo -e "dataset\tLibrary dataset name"
		echo -e "group\tGroup name for files and directories"
		echo -e "Example usage:"
		echo -e "\t$0 steam zstorage/steam public"
		exit 1
	fi
	return 0
}

function main() {
	local library="$1"
	local dataset="$2"
	local group="$3"
	local parent="$(dirname "$dataset")"
	if [ ! -d "/$parent" ]; then
		echo "Cannot access root dataset at /$parent"
		exit 2
	elif [ -e "/$dataset" ]; then
		echo "Library already exists"
		exit 2
	else
		# Configure ZFS
		zfs create -o casesensitivity=mixed "$dataset"
		zfs create -o casesensitivity=mixed "$dataset/master"

		# The rest can be done by the import scripts
		"$GS" library import "$library" "$dataset" "$group"
		return 0
	fi
}

check_args $*
main $*
