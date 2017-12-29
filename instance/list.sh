#!/usr/bin/env bash
set -euo pipefail

function check_args() {
	if [ $# -lt 1 ]; then
		echo "Usage: $(basename $0) library --raw"
		echo -e "library\tLibrary name"
		echo -e "--raw\tReturn names only"
		exit 1
	fi
	check_library "$1"
	return 0
}

function main() {
	local library="$1"
	local raw="${2-false}"
	local root="$("$GS" _config get "$library" root)"
	local master="$("$GS" _config get "$library" master)"

	# The / after $root filters the top level directory out
	# The second grep filters the master dataset (which is not an instance, per se) and the header
	if [ "$raw" = "--raw" ]; then
		zfs list -o name,used,creation | grep -e "$root/" -e CREATION | grep -ve "$master " \
										| grep -Eo "$root/[^ ]+" | rev | cut -d'/' -f1 | rev
	else
		zfs list -o name,used,creation | grep -e "$root/" -e CREATION | grep -ve "$master "
	fi
}

check_args $*
main $*
