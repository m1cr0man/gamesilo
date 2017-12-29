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

	# Get the latest snapshot that is up to date with the master
	# Tail is used to stop things crashing if #snapshots != 1
	local newest="$("$GS" _snapshot list "$library" | grep -iE '\b0.\b' | tail -n 1 | cut -f1)"
	if [ -z "$newest" ]; then
		# Create an up to date snapshot
		"$GS" _snapshot create "$library" | tail -n 1
	else
		echo "$newest"
	fi
	return 0
}

check_args $*
main $*
