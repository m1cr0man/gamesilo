#!/usr/bin/env bash
set -euo pipefail

. $GSDIR/_config/_common.sh

function check_args() {
	if [ $# -ne 3 ]; then
		echo "Usage: $(basename $0) library key value"
		echo -e "library\tLibrary name"
		echo -e "key\tName of the value"
		echo -e "value\tThe value"
		exit 1
	fi
	check_library "$1"
	return 0
}

function main() {
	if [ -f "$CONFIG_ROOT/$1$EXT" ]; then
		echo "${2^^}=$3" >> "$CONFIG_ROOT/$1$EXT"
		echo "Value set"
		return 0
	else
		>&2 echo "No such library $1"
		exit 2
	fi
}

check_args $*
main $*
