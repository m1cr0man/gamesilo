#!/usr/bin/env bash
set -euo pipefail

function check_args() {
	if [ $# -ne 2 ]; then
		echo "Usage: $(basename $0) library date"
		echo -e "library\t\tLibrary name"
		echo -e "date\t\tSnapshot date"
		exit 1
	fi
	return 0
}

function main() {
	local library="$1"
	local date="$2"
	local master="$("$GS" _config get "$library" master)"
	local snapshot="$master@$date"
	zfs destroy "$snapshot" > /dev/null
	echo "Deleted snapshot $snapshot"
	return 0
}

check_args $*
main $*
