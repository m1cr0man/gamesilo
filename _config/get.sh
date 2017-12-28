#!/usr/bin/env bash
set -euo pipefail

. $GSDIR/config/_common.sh

function check_args() {
	if [ $# -ne 2 ]; then
		echo "Usage: $(basename $0) library key"
		echo -e "library\tLibrary name"
		echo -e "key\tName of the value"
		exit 1
	fi
	return 0
}

function main() {
	if [ -f "$CONFIG_ROOT/$1$EXT" ]; then
		data=$(grep "${2^^}=" "$CONFIG_ROOT/$1$EXT" || true)
		if [ -n "$data" ]; then
			echo "$data" | cut -d'=' -f2-
			return 0
		else
			>&2 echo "Value $2 not set in library $1"
			echo "unset"
			exit 2
		fi
	else
		>&2 echo "No such library $1"
		exit 2
	fi
}

check_args $*
main $*
