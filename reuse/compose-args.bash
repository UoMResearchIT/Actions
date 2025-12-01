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
    # Basic arguments
    Arguments="annotate --copyright \"$Who\" -license '$License' --recursive"

    # Add if flag set
    if [ "$Merge" == 'true' ]; then
        Arguments="$Arguments --merge-copyrights"
    fi

    # Add if flag set
    if [ "$Fallback" == 'true' ]; then
        Arguments="$Arguments --fallback-dot-license"
    fi

    # Add if file exists
    if [ -f "$Extra" ]; then
        Arguments="$Arguments --extra-formats '$Extra'"
    fi

    # Add if file exists
    if [ -f "$Ignore" ]; then
        Arguments="$Arguments --ignore-file '$Ignore'"
    fi

    # Add if directory exists, else use fallback
    if [ -d "$Dir" ]; then
        Arguments="$Arguments '$Dir'"
    else
        Arguments="$Arguments ."
    fi
fi

echo "args=$Arguments" >>$GITHUB_OUTPUT
