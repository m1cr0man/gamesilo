#!/usr/bin/env bash
set -euo pipefail

function check_args() {
	if [ $# -ne 2 ]; then
		echo "Usage: $(basename $0) library name"
		echo -e "library\tLibrary name"
		echo -e "name\tInstance name"
		exit 1
	elif [ "$1" = "master" ]; then
		echo "master is not a valid name"
		exit 1
	fi
	return 0
}

function main() {
	local library="$1"
	local name="$2"
	local root="$("$GS" _config get "$library" root)"
	local share="${library}_$name"
	local fullname="$root/$name"

	# Unshare
	if [ -z "$(net usershare info "$share")" ]; then
		echo "Instance not shared"
	else
		echo "Attempting to unshare instance"
		net usershare delete "$share"
		sleep 1

		# If there's a connection still open to the share, terminate it
		# Usershare will be automagically removed when all connections die
		if smbstatus | grep "$share" > /dev/null 2>&1; then
			smbcontrol smbd close-share "$share"
			echo "Note: Connections terminated"
		fi

		echo "Instance unshared"
	fi

	# Delete
	if [ -d "/$fullname" ]; then
		zfs destroy "$fullname"
		echo "Instance deleted"
		"$GS" _snapshot prune "$library"
	else
		echo "Instance does not exist"
	fi
	return 0
}

check_args $*
main $*
