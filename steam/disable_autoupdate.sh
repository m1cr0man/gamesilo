#!/usr/bin/env bash
set -euo pipefail

. "$GSDIR/steam/_common.sh"

function check_args() {
	if [ $# -ne 1 ]; then
		echo "Usage: $(basename "$0") library"
		echo -e "library\tLibrary name"
		exit 1
	fi
	check_library "$1"
	return 0
}

function main() {
	local library="$1"
	local steamapps="$("$GS" steam _get_steamapps "$library")"

	"$GS" steam _disable_autoupdate "$steamapps"
}

check_args $*
main $*
