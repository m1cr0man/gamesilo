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

	echo "Updating all instances"
	"$GS" instance list "$library" --raw | xargs -r -L1 "$GS" instance update "$library"
	echo "Update complete!"
}

check_args $*
main $*
