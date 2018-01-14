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

function eval_library() {

	# ZFS diff prints paths with octal escape sequences in them (eg \0040)
	# Solution: Pass it as an arg to echo -e
	# All the output will be buffered and outputted at once though... ah well
	echo "Generating diff (this may take a while on old instances)"
	echo -e "$(zfs diff "$snapshot" "$fullname" | grep -v xattrdir | grep '^\+' | cut -f2)" > "$tempfile"

	return 0
}

function backup() {
	local tempdir=$(get_temp)

	if [ -s "$tempfile" ]; then
		# Save the files
		while read -r path; do
			# Get the file relative to the instance
			rel_path="$(realpath -m --relative-to="/$fullname" "$path")"
			new_path="$tempdir/$rel_path"

			if [ -f "$path" ]; then
				echo -e "\tKeeping $rel_path"
				mkdir -m $mode -p "$(dirname "$new_path")"
				mv "$path" "$new_path"
			fi
		done < "$tempfile"
	else
		echo "No differences"
	fi
	return 0
}

function restore() {
	local tempdir=$(get_temp)

	if [ -s "$tempfile" ]; then
		# Restore the files
		while read -r path; do
			# Get the file relative to the instance
			rel_path="$(realpath -m --relative-to="/$fullname" "$path")"
			new_path="$tempdir/$rel_path"

			if [ -f "$new_path" ]; then
				echo -e "\tRestoring $rel_path"
				mkdir -m $mode -p "$(dirname "$path")"
				mv -u "$new_path" "$path"
			fi
		done < "$tempfile"
	fi

	# Strip leading slash
	zfs destroy $(echo "$tempdir" | cut -c2-)
	return 0
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
	local tempfile="$(mktemp)"

	# Verify permissions on the master
	"$GS" instance _verify_perms "$library" master

	# Check if the parent snapshot is already up to date
	# TODO unify this check between here and get.sh
	if \
		[ "$force" != "--force" ] && \
		"$GS" _snapshot list "$library" | grep "$snapshot" | cut -f2 | grep '0B' > /dev/null 2>&1
	then
		echo "Instance already up to date"
		return 0
	fi

	echo "Saving unique files"
	eval_library
	backup
	# It is possible to update the instance without dropping connections - but that's a bad thing
	# If we change the data in a Steam library we could crash the client if changes are made without
	# notification. Forcing connections to close is a good call.
	echo "Re-creating instance"
	"$GS" instance delete "$library" "$name" | xargs -L1 echo -e '\t'
	"$GS" instance create "$library" "$name" -s | xargs -L1 echo -e '\t'
	echo "Restoring files"
	restore
	rm -rf "$tempfile"
	echo "Done"
	return 0
}

check_args $*
main $*
