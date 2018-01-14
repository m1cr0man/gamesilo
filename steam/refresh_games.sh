#!/usr/bin/env bash
set -euo pipefail

. "$GSDIR/steam/_common.sh"

tmpdir="/tmp/gamesilo"

function get_games() {
	local token="$1"
	local priority="$2"
	local user="$3"
	local steamid="$4"

	curl -o "$tmpdir/$priority" "https://api.steampowered.com/IPlayerService/GetOwnedGames/v1/?format=json&include_played_free_games=1&key=$token&steamid=$steamid"
	echo -e "\n$user" >> "$tmpdir/$priority"
}

function main() {
	if [ -z "$(cat "$TOKEN_FILE")" ]; then
		>&2 echo "Steam API token not set! Set the token first"
		exit 2
	else
		local token="$(cat "$TOKEN_FILE")"

		echo "Downloading owned games lists"
		mkdir -p $tmpdir
		while read -r userdata; do
			if [ -n "$userdata" ]; then
				# Priority, user, steamID
				local args="$(echo "$userdata" | cut -d' ' -f1-3)"
				get_games "$token" $args &
			fi
		done < "$USERS_DB"
		wait

		echo "Updating games list"
		echo -n "" > "$GAMES_MAP"
		touch "$GAMES_MAP.filter"

		# The use of 'ls' here handles the priority
		for gamelist in $(ls -1 $tmpdir/); do
			local user="$(tail -n 1 "$tmpdir/$gamelist")"

			# Cut out the app IDs.
			# Filter out those we've already covered (from the .filter file)
			# Append new ones to the filter (this is safe because grep before will cache the file)
			# Print app ID and username together
			grep appid "$tmpdir/$gamelist" | grep -Eo '[0-9]+' | grep -vf "$GAMES_MAP.filter" | tee -a "$GAMES_MAP.filter" | awk '{ print $1, "'"$user"'" }' >> "$GAMES_MAP" || true
		done < "$USERS_DB"
		rm -f "$GAMES_MAP.filter"
		rm -rf /tmp/gamesilo

		echo "Done!"
		return 0
	fi
}

main $*
