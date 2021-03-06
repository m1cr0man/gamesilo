#!/usr/bin/env bash
set -euo pipefail

function check_args() {
	if [ $# -ne 2 ]; then
		echo "Usage: $(basename $0) library name"
		echo -e "library\tLibrary name"
		echo -e "name\tInstance name"
		exit 1
	fi
	return 0
}

function main() {
	local library="$1"
	local name="$2"
	"$GS" library exists "$library"
	local root="$("$GS" _config get "$library" root)"
	[ -d "/$root/$name" ]
}

check_args $*
main $*
