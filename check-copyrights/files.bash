#!/usr/bin/env bash

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

[ -f "$EXCLUDES" ] || touch "$EXCLUDES"
echo "excludes=$(cd "$(dirname "$EXCLUDES")" && pwd)/$(basename "$EXCLUDES")" >>$GITHUB_OUTPUT

case "$THE_PROFILE" in
    "ASL")
        echo "config=$GITHUB_ACTION_PATH/profiles/rat_asl20.xml" >>$GITHUB_OUTPUT ;;
    "GPL3")
        echo "config=$GITHUB_ACTION_PATH/profiles/rat_gpl3.xml" >>$GITHUB_OUTPUT ;;
    "")
        if [ -f "$GITHUB_ACTION_PATH/profiles/$CFG" -a -r "$GITHUB_ACTION_PATH/profiles/$CFG" ]; then
            echo "config=$GITHUB_ACTION_PATH/profiles/$CFG" >>$GITHUB_OUTPUT
        else
            # User contributed profile?
            echo "config=$CFG" >> $GITHUB_OUTPUT
        fi ;;
    *)
        echo "::error title=Bad Profile::Unsupported profile ID '$THE_PROFILE'; must be ASL, GPL3 or left blank"
        exit 1 ;;
esac
