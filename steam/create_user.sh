#!/usr/bin/env bash
set -euo pipefail

. "$GSDIR/steam/_common.sh"

function check_args() {
	if [ $# -ne 3 ]; then
		echo "Usage: $(basename "$0") name steamid priority"
		echo -e "user\t\tSteam user name"
		echo -e "steamid\t\tUser's Steam ID"
		echo -e "priority\tPriority when updating games"
		exit 1
	fi
	return 0
}

function main() {
	local user="$1"
	local steamid="$2"
	local priority="$3"
	if grep "$user" "$USERS_DB" > /dev/null; then
		echo "User already exists"
		exit 0
	else
		read -s -p "Password:" password
		echo "$priority $user $steamid $password" >> "$USERS_DB"

		# Sort by priority
		sort "$USERS_DB" > "$USERS_DB.tmp"
		mv -f "$USERS_DB.tmp" "$USERS_DB"
		echo
		echo "User created"
		return 0
	fi
}

check_args $*
main $*
