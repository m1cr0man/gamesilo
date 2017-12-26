#!/usr/bin/env bash
set -euo pipefail

STEAM_DATASET='zstorage/steam'
SHARE_PREFIX='steam_'

function check_args() {
    if [ $# -ne 1 ]; then
        echo "Usage: $(basename $0) snapshot"
        echo -e "snapshot\tFull name for the parent ZFS snapshot"
        exit 1
    fi
    return 0
}

function main() {
    # "master\t" makes sure that the master dataset is filtered but not libraries
    # because "master" will be in the snapshot name
    zfs list -Ho name,origin | grep $1 | grep -v 'master\t' | cut -f1
}

check_args $*
main $*
