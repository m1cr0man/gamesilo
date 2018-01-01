#!/usr/bin/env bash
set -euo pipefail

function check_args() {
	if [ $# -lt 2 ]; then
		echo "Usage: $(basename $0) library name [--force]"
		echo -e "library\tLibrary name"
		echo -e "name\tInstance name"
		echo -e "--force\tUpdate even if nothing has changed"
		exit 1
	elif [ "$2" = "master" ]; then
		echo "master is not a valid name"
		exit 1
	fi
	check_instance "$1" "$2"
	return 0
}

function get_temp() {
	local tempdir="${fullname}_temp"

	# Make sure we're not about to obliterate root
	if [ "$tempdir" = "_temp" ]; then
		>&2 echo "Temporary path is empty!"
		exit 2
	elif [ -d "/$tempdir" ]; then
		echo "/$tempdir"
	else
		zfs create -o aclinherit=passthrough "$tempdir"
		chmod $mode "/$tempdir"
		chown $(stat -c '%U:%G' "/$master") "/$tempdir"
		echo "/$tempdir"
	fi
	return 0
}

# Determines if a file needs to be saved or not
# If it does, moves to temp folder
function eval_file() {
	local state=$1
	# Echo here ensures backslashes have been parsed
	local path=$(echo -e "$2")

	if [ "$state" = "+" -a -f "$path" ]; then
		echo -e "\tKeeping $path"
		new_path="$(get_temp)/$(realpath --relative-to="/$fullname" "$path")"
		mkdir -m $mode -p "$(dirname "$new_path")"
		mv "$path" "$new_path"
	fi
}

# Uses zfs diff to scan the library for changes
# Moves new files to the temp folder
function eval_library() {

	# Read to a file to simplify iteration and error handling
	local tempfile=$(mktemp)
	# Prints all output through one line as to not spam up the console
	# The fancy escape clears the line from the cursor back to the start
	zfs diff "$snapshot" "$fullname" | grep -v xattrdir | tee $tempfile \
	 | cut -f2 | xargs -r -L1 realpath --relative-to="/$fullname" | xargs -I % echo -ne '\033[2K\r\tChecking %' || true
	echo
	if [ ! -s $tempfile ]; then
		echo "No differences"
		return 0
	else
		while read -r file_info; do eval_file $file_info; done < $tempfile
	fi
	rm -f $tempfile
}

function restore() {
	local tempdir=$(get_temp)

	# Stop if tempdir is root (don't obliterate root!)
	# Doesn't hurt to double check ;)
	if [ -z "$tempdir" -o "$tempdir" = "/" ]; then
		>&2 echo "Temporary path is not correct!"
		exit 2
	elif [ -d "$tempdir" -a -n "$(ls -A $tempdir)" ]; then
		cp -rvu $tempdir/* "/$fullname/"
	fi

	# Strip leading slash
	zfs destroy $(echo $tempdir | cut -c2-)
}

function main() {
	local library="$1"
	local name="$2"
	local force="${3-false}"
	local root="$("$GS" _config get "$library" root)"
	local master="$("$GS" _config get "$library" master)"
	local snapshot=$("$GS" _snapshot parent "$library" "$name")
	local mode=$(stat -c '%a' "/$master")
	local fullname="$root/$name"

	# Check if the parent snapshot is already up to date
	# TODO unify this check between here and get.sh
	if \
		[ "$force" != "--force" ] && \
		"$GS" _snapshot list "$library" | grep "$snapshot" | grep -E '\b0.\b' > /dev/null 2>&1
	then
		echo "Instance already up to date"
		return 0
	fi

	echo "Saving unique files"
	eval_library
	# It is possible to update the instance without dropping connections - but that's a bad thing
	# If we change the data in a Steam library we could crash the client if changes are made without
	# notification. Forcing connections to close is a good call.
	echo "Re-creating instance"
	"$GS" instance delete "$library" "$name" | xargs -L1 echo -e '\t'
	"$GS" instance create "$library" "$name" | xargs -L1 echo -e '\t'
	echo "Restoring files"
	restore | xargs -L1 echo -e '\t'
	echo "Done"
	return 0
}

check_args $*
main $*
