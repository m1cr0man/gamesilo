#!/usr/bin/env bash
set -euo pipefail

STEAM_DATASET='zstorage/steam'
SHARE_PREFIX='steam_'

function check_args() {
    if [ $# -ne 2 ]; then
        echo "Usage: $(basename $0) username new_snapshot"
        echo -e "username\tUser to create mount for"
        echo -e "new_snapshot\tFull name for the new ZFS snapshot"
        exit 1
    elif [ "$1" = "master" ]; then
        echo "master is not a valid username"
        exit 1
    elif [ ! -d "/$STEAM_DATASET/$1" ]; then
        echo "$1 is not a valid username (no such library)"
        exit 1
    fi
    return 0
}

function get_temp() {
    # No need to go through the bother of creating a new dataset
    # The parent dataset will do fine
    local path="/$STEAM_DATASET/$1_temp"

    # Make sure we're not about to obliterate root
    if [ -z "$path" ]; then
        >&2 echo "Temporary path is empty!"
        exit 2
    elif [ -d "$path" ]; then
        echo $path
    else
        zfs create -o aclinherit=passthrough "$STEAM_DATASET/$1_temp"
        chmod $(stat -c '%a' "/$STEAM_DATASET") "/$STEAM_DATASET/$1_temp"
        chown $(stat -c '%U:%G' "/$STEAM_DATASET") "/$STEAM_DATASET/$1_temp"
        echo $path
    fi
    return 0
}

# Determines if a file needs to be saved or not
# If it does, moves to temp folder
function eval_file() {
    local state=$2
    # Echo here ensures backslashes have been parsed
    local path=$(echo -e "$3")

    if [ "$state" = "+" -a -f "$path" ]; then
        echo "Keeping $path"
        new_path="$(get_temp $1)/$(realpath --relative-to="/$STEAM_DATASET/$1" "$path")"
        mkdir -m `stat -c '%a' "/$STEAM_DATASET"` -p $(dirname "$new_path")
        mv "$path" "$new_path"
    fi
}

# Uses zfs diff to scan the library for changes
# Moves new files to the temp folder
function eval_library() {

    # Get parent snapshot of the current clone
    local snapshot=$(zfs list -Ho origin $STEAM_DATASET/$1)

    # Read to a file to simplify iteration and error handling
    local tempfile=$(mktemp)
    zfs diff "$snapshot" "$STEAM_DATASET/$1" | grep -v xattrdir > $tempfile || true
    if [ ! -s $tempfile ]; then
        echo "No differences"
        return 0
    else
        while read -r file_info; do eval_file $1 $file_info; done < $tempfile
    fi
    rm -f $tempfile
}

function restore() {
    local tempdir=$(get_temp $1)

    # Stop if tempdir is root (don't obliterate root!)
    # Doesn't hurt to double check ;)
    if [ -z "$tempdir" -o "$tempdir" = "/" ]; then
        >&2 echo "Temporary path is not correct!"
        exit 2
    elif [ -d "$tempdir" -a -n "$(ls -A $tempdir)" ]; then
        mv -vb $tempdir/* "/$STEAM_DATASET/$1/"
    fi
    # Strip leading slash
    zfs destroy $(echo $tempdir | cut -c2-)
}

function main() {
    echo "Saving unique files"
    eval_library "$1"
    # It is possible to update the library without dropping connections - but that's a bad thing
    # If we change the data in a Steam library we could crash the client if changes are made without
    # notification. Forcing connections to close is a good call.
    echo "Deleting"
    steamtank library delete "$1"
    echo "Creating"
    steamtank library create "$1" "$2"
    echo "Restoring files"
    restore "$1"
    echo "Done"
    return 0
}

check_args $*
main $*
