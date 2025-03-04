#!/usr/bin/env bash

# Copyright (c) 2020-2025 The University of Manchester
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     https://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

# List the files
file_list=$(find "$BASE_DIR" -name "$SKIP" -prune -o -type f -print | egrep "$FILE_PAT")

# Check to see if anything was found
if [ -z "$file_list" ]; then
    echo "::error title=No files to validate::No files found in $BASE_DIR matching pattern."
    printf '\e[0;33mNo files found in %s matching pattern.\e[0m\n' "$BASE_DIR" >&2
    exit 1
fi

# Pass the file list to vera++
exec vera++ --root "$GITHUB_ACTION_PATH" --profile "$VERA_PROFILE.tcl" --error $VERA_OPTIONS <<< "$file_list"
