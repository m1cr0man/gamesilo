#!/usr/bin/env bash
set -euo pipefail

# nohup docker run -i --rm --name=steamcmd_steam --mount type=bind,source=$(pwd),target=/root/Steam --mount type=bind,source=/zstorage/steam/master/Steam/steamapps,target=/root/Steam/steamapps steamcmdpersist +@sSteamCmdForcePlatformType windows > stdout.sock 2>&1 < stdin.sock

. "$GSDIR/steam/_common.sh"

STDIN_PIPE="$STEAMCMD_DIR/stdin.sock"
STDIN_PIPE="$STEAMCMD_DIR/stdout.sock"

function check_args() {
	if [ $# -ne 1 ]; then
		echo "Usage: $(basename "$0") library"
		echo -e "library\tLibrary name"
		exit 1
	fi
	check_library "$1"
	return 0
}

function check_info() {
	local fname="$1"
	local appid="$(grep -m1 -Eo '[0-9]+' "$fname")"
	local manifest="$steamapps/appmanifest_$appid.acf"

	# Find "branches" section, set b=1
	# Find "public" branch when b=1, set p=1
	# Find "buildid" value when p=1, extract + print builid
	local new_buildid="$(awk -F'"' '/branches/ { b=1 } b==1 && /public/ { p=1 } p==1 && /buildid/ { print $4; exit }' $fname)"

	# Find "buildid", extract + print builid
	local current_buildid="$(awk -F'"' '/buildid/ { print $4; exit }' "$manifest")"

	if [ $new_buildid -gt $current_buildid ]; then
		local name="$(awk -F'"' '/name/ { print $4; exit }' "$manifest")"
		echo "$appid $name needs updating"
	fi
}

function main() {
	local library="$1"
	local steamapps="$("$GS" steam _get_steamapps "$library")"

	# Get a list of installed games
	local appids="$(ls -1 "$steamapps"/appmanifest_*.acf | grep -Eo '[0-9]+' | sort -n)"

	# Map each appid to an owner
	local tmpdir="$(mktemp -d)"
	echo "Mapping games to owners"
	for appid in $appids; do
		local owner="$("$GS" steam get_owners "$appid" | cut -d' ' -f1 || true)"
		if [ -n "$owner" ]; then
			echo "$appid" >> "$tmpdir/$owner"
		else
			>&2 echo "No owner for $appid"
		fi
	done

	# Download info for all games
	for owner in $(ls -1 "$tmpdir"); do
		echo "Getting info for games owned by $owner (total: $(wc -l "$tmpdir/$owner"))"
		if "$GS" steam _run_container "$library" "$owner" $(awk '{ print "+app_info_print", $1 }' "$tmpdir/$owner") > "$tmpdir/$owner.info"; then
			echo "Download successful"

			# Turn the raw steamcmd output into separate files
			local datapath="$tmpdir/${owner}_data"
			mkdir -p "$datapath"

			# Find "AppID :", increment i, set x=1, go to next line
			# When x == 1, write line to "temp$i"
			# "x" stops extraneous output from steamcmd being written to a file
			awk '/AppID \: .*/ { i++;flag=1;next } flag==1 { print > "'"$datapath"/'temp" i }' "$tmpdir/$owner.info"
		else
			>&2 echo "Failed to get info for $owner's games"
			>&2 cat "$tmpdir/$owner.info"
		fi
	done

	# Read each file and print if it needs updating
	for datafile in "$tmpdir"/*_data/*; do
		check_info "$datafile"
	done

	rm -rf "$tmpdir"
	echo "Done!"
	return 0
}

check_args $*
main $*
