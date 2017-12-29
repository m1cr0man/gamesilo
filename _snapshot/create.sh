#!/usr/bin/env bash
set -euo pipefail

function check_args() {
	if [ $# -ne 1 ]; then
		echo "Usage: $(basename $0) library"
		echo -e "library\tLibrary name"
		exit 1
	fi
	return 0
}

function main() {
	local library="$1"
	local master="$("$GS" _config get "$library" master)"
	local snapshot="$master@$(date +'%H-%M_%d-%m-%Y')"
	zfs snapshot "$snapshot" > /dev/null
	echo "Snapshot created, name:"
	echo "$snapshot"
	return 0
}

check_args $*
main $*
