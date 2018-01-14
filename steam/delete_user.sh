#!/usr/bin/env bash
set -euo pipefail

. "$GSDIR/steam/_common.sh"

function check_args() {
	if [ $# -ne 1 ]; then
		echo "Usage: $(basename "$0") name"
		echo -e "user\tSteam user name"
		exit 1
	fi
	return 0
}

function main() {
	local user="$1"
	if ! grep "$user" "$USERS_DB" > /dev/null; then
		echo "User doesn't exist"
		exit 0
	else
		# || true covers the case that we delete the last user
		(grep -Ev "^[0-9]+ $user " "$USERS_DB" || true) > "$USERS_DB.tmp"
		mv -f "$USERS_DB.tmp" "$USERS_DB"
		echo "User deleted"
		return 0
	fi
}

check_args $*
main $*
