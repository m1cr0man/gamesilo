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
	if [ -f "$CONFIG_ROOT/$1$EXT" ]; then
		rm "$CONFIG_ROOT/$1$EXT"
		echo "Config deleted"
	else
		echo "Config does not exist"
	fi
	return 0
}

check_args $*
main $*
