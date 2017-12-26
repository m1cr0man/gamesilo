#!/usr/bin/env bash
set -euo pipefail

STEAM_DATASET='zstorage/steam'
SHARE_PREFIX='steam_'

function check_args() {
    if [ $# -ne 1 ]; then
        echo "Usage: $(basename $0) username"
        echo -e "username\tUser to delete library of"
        exit 1
    elif [ "$1" = "master" ]; then
        echo "master is not a valid username"
        exit 1
    fi
    return 0
}

function main() {

    # Unshare
    local share="$SHARE_PREFIX$1"
    if [ -n "$(net usershare info $share)" ]; then
        echo "Attempting to unshare library"
        net usershare delete $share
        sleep 1

        # If there's a connection still open to the share, terminate it
        # Usershare will be automagically removed when all connections die
        if smbstatus | grep $share > /dev/null 2>&1; then
            smbcontrol smbd close-share $share
        fi

        echo "Library unshared"
    else
        echo "Library was not shared"
    fi

    # Delete
    if [ -d "/$STEAM_DATASET/$1" ]; then
        zfs destroy $STEAM_DATASET/$1
        echo "Library deleted"
    else
        echo "Library did not exist"
    fi
    return 0
}

check_args $*
main $*
