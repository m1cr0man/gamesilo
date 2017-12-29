#!/usr/bin/env bash
set -euo pipefail

function check_args() {
	if [ $# -ne 1 ]; then
		echo "Usage: $(basename $0) library"
		echo -e "library\tLibrary name"
		exit 1
	fi
	check_library "$1"
	return 0
}

function main() {
	local library="$1"
	local master="$("$GS" _config get "$library" master)"
	zfs list -Ho name,used,clones -t snapshot | grep "$master"
	return 0
}

check_args $*
main $*
