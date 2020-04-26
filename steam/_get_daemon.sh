#!/usr/bin/env bash
set -euo pipefail

. "$GSDIR/steam/_common.sh"

function check_args() {
	if [ $# -ne 2 ]; then
		echo "Usage: $(basename "$0") library user"
		echo -e "library\t\tLibrary name"
		echo -e "user\t\tSteam user name"
		exit 1
	fi
	check_library "$1"
	return 0
}

function cleanup() {
	echo "quit" > "$inpipe"
	wait $dockerpid
	kill $inlockerpid
	rm "$LOCKS_DIR/$library".*.std{in,out}
}

function read_output() {
	while read -r line; do
		if echo "$line" | grep -i 'two-factor code'; then
			read -p "Steam Guard token required, input it now " steam_token
			echo "$steam_token" > "$inpipe"
		elif echo "$line" | grep -i 'login failure'; then
			echo "$line" | grep -io 'login failure.*' >&2
			cleanup
			return 3
		elif echo "$line" | grep -i 'failed'; then
			>&2 echo "2FA failed"
			cleanup
			return 4
		elif echo "$line" | grep -i 'Steam>'; then
			return 0
		fi
	done < "$outpipe"
}

function main() {
	local library="$1"
	local user="$2"
	local steamapps="$("$GS" steam _get_steamapps "$library")"

	# Get user password
	local password="$("$GS" steam _get_user "$user" | cut -d' ' -f4-)"

	if [ -z "$password" ]; then
		>&2 echo "Could not find user $user"
		exit 2
	fi

	local pipename="$LOCKS_DIR/$library.$user"
	local inpipe="$pipename.stdin"
	local outpipe="$pipename.stdout"

	# Stop if a lock already exists for this process
	if [ -e "$LOCKS_DIR/$library.$user.stdin" ]; then
		echo "$inpipe" "$outpipe"
		exit 0
	fi

	# Create FIFO pipes
	mkfifo "$inpipe"
	mkfifo "$outpipe"

	# Keep the in pipe open
	nohup cat /dev/null > "$inpipe" &

	# Start container in background but detached (nohup)
	local inlockerpid=$!
	nohup docker run -i --rm \
		--name "steamcmd_$library" \
		--mount type=bind,source="$STEAMCMD_DIR",target=/root/Steam \
		--mount type=bind,source="$steamapps",target=/root/Steam/steamapps \
		steamcmdpersist \
		+@sSteamCmdForcePlatformType windows > "$outpipe" 2>&1 < "$inpipe"  &
	local dockerpid=$!

	read_output &
	local readpid=$!

	# Echo something into the pipes to kick steamcmd
	echo "login $user $password" > "$inpipe"

	wait $readpid
	echo "$inpipe" "$outpipe"
	return 0
}

check_args $*
main $*
