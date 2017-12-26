#!/usr/bin/env bash
set -euo pipefail

STEAM_DATASET='zstorage/steam'
SHARE_PREFIX='steam_'

function check_args() {
    if [ $# -ne 2 ]; then
        echo "Usage: $(basename $0) username snapshot"
        echo -e "username\tUser to create library for"
        echo -e "snapshot\tFull name for the parent ZFS snapshot"
        exit 1
    elif [ "$1" = "master" ]; then
        echo "master is not a valid username"
        exit 1
    fi
    return 0
}

function main() {

    # Create
    if [ ! -d "/$STEAM_DATASET/$1" ]; then
        local snapshot=$2
        zfs clone $snapshot $STEAM_DATASET/$1
        echo "Library mounted"
    else
        echo "Library already mounted"
    fi

    # Share
    if [ -z "$(net usershare info $SHARE_PREFIX$1)" ]; then
        net usershare add "$SHARE_PREFIX$1" "/$STEAM_DATASET/$1" "$1 Steamtank library" Everyone:F guest_ok=y
        echo "Library shared as $SHARE_PREFIX$1"
    else
        echo "Library already shared"
    fi
    return 0
}

check_args $*
main $*

# TODO Test
