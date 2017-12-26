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
	local current_snapshot=$($(dirname $0)/get.*)
	if [ $? -ne 0 -o -z "$current_snapshot" ]; then
        echo "Master snapshot does not exist"
	else
		echo "Deleting snapshot $current_snapshot"
		zfs destroy $current_snapshot
	fi
	return 0
}

check_args $*
main $*
