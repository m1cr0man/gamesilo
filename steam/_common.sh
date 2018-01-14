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
