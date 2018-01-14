#!/usr/bin/env bash
set -euo pipefail

. "$GSDIR/steam/_common.sh"

function check_args() {
	if [ $# -lt 2 ]; then
		echo "Usage: $(basename "$0") library appid [-v]"
		echo -e "library\tLibrary name"
		echo -e "appid\tSteam App ID for target game"
		echo -e "-v\tValidate after update"
		exit 1
	fi
	check_library "$1"
	return 0
}

function main() {
	local library="$1"
	local appid="$2"
	local validate=$([ "${3-false}" = "-v" ] && echo "validate" || true)

	# Find the owners for this game
	local owners="$("$GS" steam get_owners "$appid")"

	if [ -z "$owners" ]; then
		>&2 echo "Could not find an owner for $appid"
		exit 2
	else
		for owner in $owners; do
			# Run steamcmd + update the game
			echo "Attempting to update with user $owner"
			if "$GS" steam _run_container "$library" "$owner" +app_update "$appid" "$validate"; then
				echo "Update successful"
				exit 0
			else
				>&2 echo "Failed to update with user $owner"
			fi
		done
		echo "Failed to update $appid"
		return 0
	fi
}

check_args $*
main $*
