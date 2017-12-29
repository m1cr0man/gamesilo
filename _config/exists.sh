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
	[ -f "$CONFIG_ROOT/$1$EXT" ]
}

check_args $*
main $*
