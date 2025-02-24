#!/usr/bin/env bash

# List the files
file_list=$(find "$BASE_DIR" -name "$SKIP" -prune -o -type f -print | egrep "$FILE_PAT")

# Check to see if anything was found
if [ -z "$file_list" ]; then
    echo "::error title=No files to validate::No files found in $BASE_DIR matching pattern."
    printf '\e[0;33mNo files found in %s matching pattern.\e[0m\n' "$BASE_DIR" >&2
    exit 1
fi

# Pass the file list to vera++
exec vera++ --root "$VERA_ROOT" --profile "$VERA_PROFILE.tcl" --error $VERA_OPTIONS <<< "$file_list"
