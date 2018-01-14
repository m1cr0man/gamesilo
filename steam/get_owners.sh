#!/usr/bin/env bash
set -euo pipefail

. "$GSDIR/steam/_common.sh"

function check_args() {
	if [ $# -ne 1 ]; then
		echo "Usage: $(basename "$0") appid"
		echo -e "appid\tSteam App ID for target game"
		exit 1
	fi
	return 0
}

function main() {
	local appid="$1"

	grep -E "^$appid " "$GAMES_MAP" | cut -d' ' -f2- || >&2 echo "No owner" && exit 2
}

check_args $*
main $*
