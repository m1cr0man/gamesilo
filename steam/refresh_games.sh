#!/usr/bin/env bash
set -euo pipefail

. "$GSDIR/steam/_common.sh"

tmpdir="/tmp/gamesilo"

function get_games() {
	local token="$1"
	local priority="$2"
	local user="$3"
	local steamid="$4"

	curl -o "$tmpdir/$priority.tmp" "https://api.steampowered.com/IPlayerService/GetOwnedGames/v1/?format=json&include_played_free_games=1&key=$token&steamid=$steamid"
	# Cut out the app IDs
	grep appid "$tmpdir/$priority.tmp" | grep -Eo '[0-9]+' > "$tmpdir/$priority"
	echo -e "$user" >> "$tmpdir/$priority"
	rm "$tmpdir/$priority.tmp"
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

		# The use of 'ls' here handles the priority
		for gamelist in $(ls -1 $tmpdir/); do
			echo "$gamelist"
			local user="$(tail -n 1 "$tmpdir/$gamelist")"

			while read -r appid; do
				if [ "$appid" != "$user" ]; then
					if ! grep "^$appid " "$GAMES_MAP" > /dev/null; then
						# Add appid + owner
						echo "$appid $user" >> "$GAMES_MAP"
					else
						# Append owner
						sed -i "/^$appid /s/$/ $user/" "$GAMES_MAP"
					fi
				fi
			done < "$tmpdir/$gamelist"
		done
		# Sort the output
		sort -n "$GAMES_MAP" > "$GAMES_MAP.sorted"
		mv "$GAMES_MAP.sorted" "$GAMES_MAP"
		rm -rf /tmp/gamesilo

		echo "Done!"
		return 0
	fi
}

main $*
