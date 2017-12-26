#!/usr/bin/env bash

DIRNAME=$(dirname $(readlink -f $0))

function check_args() {
	if [ $# -eq 1 ]; then
		echo "Usage: $(basename $0) $1 action [args]"
		echo -e "action\tOne of the following:"
		ls -1 -d $DIRNAME/$1/* | xargs -L1 basename | cut -d'.' -f1 | xargs -L1 echo -e '\t'
		echo -e "args\tleave action blank to get a list"
		exit 1
	elif [ $# -lt 2 ]; then
		echo "Usage: $(basename $0) command action [args]"
		echo -e "command\tOne of the following:"
		ls -1 -d $DIRNAME/*/ | xargs -L1 basename | xargs -L1 echo -e '\t'
		echo -e "action\tLeave command blank to get a list"
		echo -e "args\tLeave action blank to get a list"
		exit 1
	fi
	return 0
}

function main() {
	$DIRNAME/$1/$2.* ${@:3}
}

check_args $*
main $*
