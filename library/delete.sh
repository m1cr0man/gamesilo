#!/usr/bin/env bash
set -euo pipefail

function check_args() {
	if [ $# -ne 1 ]; then
		echo "Usage: $(basename "$0") library"
		echo -e "library\tLibrary name"
		exit 1
	# Check library exists (exit 0 if not)
	elif ! check_library "$1"; then
		exit 0
	fi

	return 0
}

function main() {
	local library="$1"
	local root="$("$GS" _config get "$1" root)"
	local master="$("$GS" _config get "$1" master)"

	# Ask the user for confirmation
	echo "WARNING"
	echo "This will destroy all instances and the master copy of $library"
	echo "ALL game data will be lost if not backed up already"
	read -p "Are you sure (Y/[n])? " -r ans
	if ! [ "$ans" = "y" -o "$ans" = "Y" ]; then
		echo "Cancelling"
		exit 0
	fi
	echo

	# Delete all the instances
	"$GS" instance list "$library" | grep -Eo "$root/[^ ]+" | rev | cut -d'/' -f1 | rev | xargs -r -L1 "$GS" instance delete "$library" || true

	# Unshare the master
	local share="${library}_master"
	if [ -n "$(net usershare info "$share")" ]; then
		echo "Attempting to unshare master"
		net usershare delete "$share"
		sleep 1

		# If there's a connection still open to the share, terminate it
		# Usershare will be automagically removed when all connections die
		if smbstatus | grep "$share" > /dev/null 2>&1; then
			smbcontrol smbd close-share "$share"
			echo "Note: Connections terminated"
		fi

		echo "Master unshared"
	fi

	zfs destroy "$master"
	zfs destroy "$root"
	"$GS" _config delete "$library"
	echo "Library deleted"
	return 0
}

check_args $*
main $*
