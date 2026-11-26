#!/usr/bin/bash

# Copyright (c) 2025 The University of Manchester
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

set -e

# If a full set of args supplied, skip generating them
if [ -z "$Arguments" ]; then
    declare -a opts=()

    # Add if file exists
    if [ -f "$Extra" ]; then
        opts+=( --extra-formats "$Extra" )
    fi

    # Add if file exists
    if [ -f "$Ignore" ]; then
        opts+=( --ignore-file "$Ignore" )
    fi

    #  enable debug
    # Debugging aid: keep --debug available for temporary REUSE troubleshooting.
    # It is useful when diagnosing annotation or lint failures, but it is intentionally
    # commented out instead of removed so future developers can re-enable it quickly
    # without losing the reference. 
    # Normal CI runs should stay quiet, and verbose output should only be 
    # enabled when investigating a real problem.
    # opts+=( --debug )

    # Basic arguments
    opts+=( annotate )
    opts+=( --copyright "$Who" )
    opts+=( --license "$License" )
    opts+=( --recursive )

    # Add if flag set
    if [ "$Merge" == 'true' ]; then
        opts+=( --merge-copyrights )
    fi

    # Add if flag set
    if [ "$Fallback" == 'true' ]; then
        opts+=( --fallback-dot-license )
    fi

    # Add if directory exists, else use fallback
    if [ -d "$Dir" ]; then
        opts+=( "$Dir" )
    else
        opts+=( . )
    fi
    Arguments="${opts[@]@Q}"
fi

echo "args=$Arguments" >>$GITHUB_OUTPUT
