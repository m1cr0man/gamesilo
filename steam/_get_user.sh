#!/usr/bin/env bash
set -euo pipefail

. "$GSDIR/steam/_common.sh"

function check_args() {
	if [ $# -ne 1 ]; then
		echo "Usage: $(basename "$0") user"
		echo -e "user\tSteam user name"
		exit 1
	fi
	return 0
}

function main() {
	local user="$1"

	grep -E " $user " "$USERS_DB" || >&2 echo "User doesn't exist" && exit 2
}

check_args $*
main $*
