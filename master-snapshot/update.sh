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
	local current_snapshot=$($(dirname $0)/get.* $1)
	local new_snapshot=$($(dirname $0)/create.* $1 | tail -n1)
	local user_instances=$($(dirname $0)/../list.* "$current_snapshot")
	for user in $user_instances; do
    	echo "Updating $user"
		$(dirname $0)/../instance/update.* $(basename $user) "$new_snapshot" | xargs -L1 echo -e '\t'
	done
	# Cannot use master-snapshot delete here because it assumes there is only 1
	zfs destroy "$current_snapshot"
	echo "Master snapshot and related libraries updated"
}

check_args $*
main $*
