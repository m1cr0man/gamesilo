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
	local root="$("$GS" _config get "$library" root)"
	local master="$("$GS" _config get "$library" master)"
	# The / after $root filters the top level directory out
	# The second grep filters the master dataset (which is not an instance, per se) and the header
	zfs list -o name,used,creation | grep -e "$root/" -e CREATION | grep -ve "$master "
}

check_args $*
main $*
