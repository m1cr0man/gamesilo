#!/usr/bin/env bash
set -euo pipefail

function check_args() {
	if [ $# -lt 2 ]; then
		echo "Usage: $(basename $0) library name [-s]"
		echo -e "library\tLibrary name"
		echo -e "name\tInstance name"
		echo -e "-s\tSkip permissions check"
		exit 1
	elif [ "$2" = "master" ]; then
		echo "master is not a valid name"
		exit 1
	fi
	check_library "$1"
	return 0
}

function main() {
	local library="$1"
	local name="$2"
	local perms_check="${3-false}"
	local root="$("$GS" _config get "$library" root)"
	local share="${library}_$name"
	local fullname="$root/$name"

	# Create
	if [ -d "/$fullname" ]; then
		echo "Instance already exists"
	else
		if [ "$perms_check" != "-s" ]; then
			# Verify permissions on the master
			"$GS" instance _verify_perms "$library" master
		fi

		local snapshot="$("$GS" _snapshot get "$library")"
		# ACLs, group, user and permissions will be copied from master
		zfs clone -o aclinherit=passthrough "$snapshot" "$fullname"
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
