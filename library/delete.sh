#!/usr/bin/env bash
set -euo pipefail

function check_args() {
	if [ $# -ne 1 ]; then
		echo "Usage: $(basename "$0") library"
		echo -e "library\tLibrary name"
		exit 1
	fi
	return 0
}

function main() {
	# TODO Confirmation
	local libray="$1"

	# Check library exists
	"$GS" library list | grep "$1" || echo 'Library does not exist' && exit 0

	local root="$("$GS" _config get "$1" root)"
	local master="$("$GS" _config get "$1" master)"
	zfs destroy "$master"
	zfs destroy "$root"
	"$GS" _config delete "$1"
	echo "Library deleted"
	return 0
}

check_args $*
main $*
