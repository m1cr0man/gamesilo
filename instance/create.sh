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
	local share="$library\_$name"
	local fullname="$root/$name"

	# Create
	if [ -d "/$fullname" ]; then
		echo "Instance already exists"
	else
		local snapshot="$("$GS" _snapshot get "$library")"
		zfs clone "$snapshot" "$fullname"
		echo "Instance created"
	fi

	# Share
	if [ -z "$(net usershare info "$share")" ]; then
		net usershare add "$share" "/$fullname" "Gamesilo: $library $name instance" Everyone:F guest_ok=y
		echo "Instance shared as $share"
	else
		echo "Instance already shared"
	fi
	return 0
}

check_args $*
main $*

# TODO Test
