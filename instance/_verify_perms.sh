#!/usr/bin/env bash
set -euo pipefail

function check_args() {
	if [ $# -ne 2 ]; then
		echo "Usage: $(basename $0) library name"
		echo -e "library\tLibrary name"
		echo -e "name\tInstance name"
		exit 1
	fi
	check_instance "$1" "$2"
	return 0
}

function main() {
	local library="$1"
	local instance="$2"
	local root="$("$GS" _config get "$library" root)"
	local group="$("$GS" _config get "$library" group)"

	# Ensure permissions are correct on the files
	echo "Verifying permissions"
	chgrp -R "$group" "/$root/$instance"
	chmod -R 2770 "/$root/$instance"
	echo "Done"
	return 0
}

check_args $*
main $*
