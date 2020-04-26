. "$GSDIR/_config/_common.sh"

USERS_ROOT="$CONFIG_ROOT/steam/users"
USERS_DB="$USERS_ROOT/users.list"
GAMES_MAP="$USERS_ROOT/games.list"
TOKEN_FILE="$USERS_ROOT/steam.token"
STEAMCMD_DIR="/home/steamcmd"

mkdir -p "$USERS_ROOT"
touch "$USERS_DB"
touch "$GAMES_MAP"
touch "$TOKEN_FILE"

function get_password() {
	# Get user password
	local password="$("$GS" steam _get_user "$user" | cut -d' ' -f4-)"

	if [ -z "$password" ]; then
		>&2 echo "Could not find user $user"
		exit 2
	fi
}
