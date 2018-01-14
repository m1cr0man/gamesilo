#!/usr/bin/env bash
set -euo pipefail

. "$GSDIR/steam/_common.sh"

function check_args() {
	if [ $# -lt 2 ]; then
		echo "Usage: $(basename "$0") library appid [-v]"
		echo -e "library\tLibrary name"
		echo -e "appid\tSteam App ID for target game"
		echo -e "-v\tVerify after update"
		exit 1
	fi
	check_library "$1"
	return 0
}

function main() {
	local library="$1"
	local appid="$2"
	local verify=$([ "${3-false}" = "-v" ] && echo "+verify" || true)

	# Find the owner for this game
	local owner="$("$GS" steam get_owner "$appid")"

	if [ -z "$owner" ]; then
		>&2 echo "Could not find an owner for $appid"
		exit 2
	else
		# Run steamcmd + update the game
		"$GS" steam _run_container "$library" "$owner" +app_update "$appid" "$verify"
		return 0
	fi
}

check_args $*
main $*
