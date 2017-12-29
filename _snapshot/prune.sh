#!/usr/bin/env bash
set -euo pipefail

function check_args() {
	if [ $# -ne 1 ]; then
		echo "Usage: $(basename $0) library"
		echo -e "library\tLibrary name"
		exit 1
	fi
	return 0
}

function main() {
	local library="$1"

	# Get all snapshots that have no clones, and delete them
	"$GS" _snapshot list "$library" | grep -P '\t$' | cut -f1 | cut -d'@' -f2 | xargs -r -L1 "$GS" _snapshot delete "$library" || true
	echo "Snapshots pruned"
	return 0
}

check_args $*
main $*
