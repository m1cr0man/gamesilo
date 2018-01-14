#!/usr/bin/env bash

export GS="$(readlink -f "$0")"
export GSDIR="$(dirname "$GS")"

function check_args() {
	if [ $# -eq 1 ]; then
		echo "Usage: $(basename $0) $1 action [args]"
		echo -e "action\tOne of the following:"
		basename -a "$GSDIR/$1"/[^_]* | cut -d'.' -f1 | xargs -L1 echo -e '\t'
		echo -e "args\tleave action blank to get a list"
		exit 1
	elif [ $# -lt 2 ]; then
		echo "Usage: $(basename $0) command action [args]"
		echo -e "command\tOne of the following:"
		basename -a "$GSDIR"/[^_]*/ | xargs -L1 echo -e '\t'
		echo -e "action\tLeave command blank to get a list"
		echo -e "args\tLeave action blank to get a list"
		exit 1
	fi
	return 0
}

# Used by actions to verify library
function check_library() {
	if [ -z "$1" ] || ! "$GS" library exists "$1"; then
		>&2 echo "Library does not exist"
		return 1
	fi
}

# Used by actions to verify library and instance
function check_instance() {
	check_library "$1"
	if [ -z "$2" ] || ! "$GS" instance exists "$1" "$2"; then
		>&2 echo "Instance does not exist"
		return 1
	fi
}

export -f check_library
export -f check_instance

function main() {
	$GSDIR/$1/$2.* ${@:3}
}

check_args $*
main $*
