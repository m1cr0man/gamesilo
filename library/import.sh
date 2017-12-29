#!/usr/bin/env bash
set -euo pipefail

function check_args() {
	if [ $# -ne 3 ]; then
		echo "Usage: $(basename "$0") library dataset group"
		echo -e "library\tLibrary name"
		echo -e "dataset\tLibrary dataset name"
		echo -e "group\tGroup name for files and directories"
		echo -e "Example usage:"
		echo -e "\t$(basename $0) steam zstorage/steam public"
		exit 1
	fi
	return 0
}

function main() {
	local library="$1"
	local dataset="$2"
	local group="$3"
	if [ ! -d "/$dataset" ]; then
		echo "No such dataset /$dataset"
		exit 2
	elif "$GS" library exists "$library"; then
		echo "Library already exists in Gamesilo"
		exit 2
	else
		# Ensure master is shared
		local share="${library}_master"
		if [ -z "$(net usershare info "$share")" ]; then
			net usershare add "$share" "/$dataset/master" "Gamesilo: $library master library" Everyone:F guest_ok=y
		fi

		# Ensure permissions are correct on the files
		echo "Verifying permissions"
		chgrp -R "$group" "/$dataset" "/$dataset/master"
		chmod -R 2770 "/$dataset" "/$dataset/master"

		# Add config
		echo "Adding configuration"
		"$GS" _config create "$library"
		"$GS" _config set "$library" root "$dataset"
		"$GS" _config set "$library" group "$group"
		"$GS" _config set "$library" master "$dataset/master"

		echo "Library created!"
		echo -e "\tName: $library"
		echo -e "\tDataset: $dataset"
		echo -e "\tGroup: $group"
		echo -e "\tMaster library dataset: $dataset/master"
		echo "The master library has been shared as ${library}_master"
		echo "and can be accessed via CIFS/Samba to add games"
		echo "See the 'instance' subcommand to manage library instances"
		return 0
	fi
}

check_args $*
main $*
