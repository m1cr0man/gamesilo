#!/usr/bin/env bash
set -euo pipefail

. $GSDIR/_config/_common.sh

function main() {
	basename $CONFIG_ROOT/*$EXT | grep -v '*' | sed "s/$EXT//g" || echo 'No libraries added'
	return 0
}

main $*
