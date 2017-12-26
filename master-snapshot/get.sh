#!/usr/bin/env bash
set -euo pipefail

function check_args() {
    if [ $# -ne 1 ]; then
        echo "Usage: $(basename $0) master"
        echo -e "master\tFull name of master ZFS dataset"
        exit 1
    fi
    return 0
}

function main() {
    zfs list -t snapshot -Ho name | grep "$1"
    return 0
}

check_args $*
main $*
