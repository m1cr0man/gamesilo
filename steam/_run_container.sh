#!/usr/bin/env bash
set -euo pipefail

. "$GSDIR/steam/_common.sh"

function check_args() {
	if [ $# -lt 2 ]; then
		echo "Usage: $(basename "$0") library user [arguments...]"
		echo -e "library\t\tLibrary name"
		echo -e "user\t\tSteam user name"
		echo -e "arguments\tArguments passed to steamcmd"
		exit 1
	fi
	check_library "$1"
	return 0
}

function main() {
	local library="$1"
	local user="$2"
	local args="${@:3}"
	local steamapps="$("$GS" steam _get_steamapps "$library")"

	# Get user password
	local password="$("$GS" steam _get_user "$user" | cut -d' ' -f4-)"

	if [ -z "$password" ]; then
		>&2 echo "Could not find user $user"
		exit 2
	fi

	docker run -it --rm \
		--name "steamcmd_$library" \
		--mount type=bind,source="$STEAMCMD_DIR",target=/root/Steam \
		--mount type=bind,source="$steamapps",target=/root/Steam/steamapps \
		steamcmdpersist +login "$user" "$password" \
		+@sSteamCmdForcePlatformType windows $args +quit
}

check_args $*
main $*
