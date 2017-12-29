#!/usr/bin/env bash
set -euo pipefail

function check_args() {
	if [ $# -ne 2 ]; then
		echo "Usage: $(basename $0) library name"
		echo -e "library\tLibrary name"
		echo -e "name\tInstance name"
		exit 1
	elif [ "$1" = "master" ]; then
		echo "master is not a valid name"
		exit 1
	fi
	return 0
}

function main() {
	local library="$1"
	local name="$2"
	local root="$("$GS" _config get "$library" root)"
	local fullname="$root/$name"

	"$GS" _snapshot list "$library" | grep "$fullname" | cut -f1
	return 0
}

check_args $*
main $*
