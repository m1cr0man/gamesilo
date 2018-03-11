#!/usr/bin/env bash
set -euo pipefail

function check_args() {
	if [ $# -ne 2 ]; then
		echo "Usage: $(basename $0) library name"
		echo -e "library\tLibrary name"
		echo -e "name\tInstance name"
		exit 1
	elif [ "$2" = "master" ]; then
		echo "master is not a valid name"
		exit 1
	fi
	check_instance "$1" "$2"
	return 0
}

function main() {
	local library="$1"
	local name="$2"
	local snapshot=$("$GS" _snapshot parent "$library" "$name")
	local size="$(zfs get -Hp used "$snapshot" | cut -f3)"

	if [ "$size" -ne "0" ]; then
		echo "$library/$name is stale"
		exit 2
	fi

	echo "$library/$name is fresh"
	return 0
}

check_args $*
main $*
