#!/usr/bin/env bash
set -euo pipefail

. "$GSDIR/steam/_common.sh"

function check_args() {
	if [ $# -ne 1 ]; then
		echo "Usage: $(basename "$0") token"
		echo -e "token\tSteam API token"
		exit 1
	fi
	return 0
}

function main() {
	local token="$1"
	echo "$token" > "$TOKEN_FILE"
	echo "Token set"
	return 0
}

check_args $*
main $*
