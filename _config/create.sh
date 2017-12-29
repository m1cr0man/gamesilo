#!/usr/bin/env bash
set -euo pipefail

. $GSDIR/_config/_common.sh

function check_args() {
	if [ $# -ne 1 ]; then
		echo "Usage: $(basename $0) library"
		echo -e "library\tLibrary name"
		exit 1
	fi
	return 0
}

function main() {
	# Create the config file
	mkdir -p "$CONFIG_ROOT"
	if [ -f "$CONFIG_ROOT/$1$EXT" ]; then
		>&2 echo "Config already exists"
		exit 2
	else
		touch "$CONFIG_ROOT/$1$EXT"
		echo "Config created"
		return 0
	fi
}

check_args $*
main $*
