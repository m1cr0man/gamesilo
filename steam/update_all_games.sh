#!/usr/bin/env bash
set -euo pipefail

. "$GSDIR/steam/_common.sh"

function check_args() {
	if [ $# -lt 1 ]; then
		echo "Usage: $(basename "$0") library [-v]"
		echo -e "library\tLibrary name"
		echo -e "-v\tValidate after update"
		exit 1
	fi
	check_library "$1"
	return 0
}

function main() {
	local library="$1"
	local validate="$([ "${2-false}" = "-v" ] && echo "validate" || true)"
	local steamapps="$("$GS" steam _get_steamapps "$library")"

	# Get a list of installed games
	local appids="$(ls -1 "$steamapps"/appmanifest_*.acf | grep -Eo '[0-9]+' | sort -n)"

	# Map each appid to an owner
	local tmpdir="$(mktemp -d)"
	echo "Mapping games to owners"
	for appid in $appids; do
		local owner="$("$GS" steam get_owners "$appid" | cut -d' ' -f1)"
		echo "$appid" >> "$tmpdir/$owner"
	done

	# Update each user's games
	for owner in $(ls -1 "$tmpdir"); do
		echo "Updating all games owned by $owner (total: $(wc -l "$tmpdir/$owner"))"
		if "$GS" steam _run_container "$library" "$owner" $(awk '{ print "+app_update", $1, "'"$validate"'" }' "$tmpdir/$owner"); then
			echo "Update successful"
		else
			>&2 echo "Failed to update $owner's games"
		fi
	done

	rm -rf "$tmpdir"
	echo "Done!"
	return 0
}

check_args $*
main $*
