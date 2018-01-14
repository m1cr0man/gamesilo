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
	local root="$("$GS" _config get "$library" root)"
	local master="/$root/master"

	# Find the steamapps root
	local steamapps="$(find "$master" -maxdepth 4 -name "appmanifest_*.acf" | head -n1 | xargs -r dirname)"
	if [ -z "$steamapps" ]; then
		>&2 echo "Could not find steamapps folder anywhere in $master"
		exit 2
	else
		echo "$steamapps"
		return 0
	fi
}

check_args $*
main $*
