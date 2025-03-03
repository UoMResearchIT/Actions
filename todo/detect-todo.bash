#!/usr/bin/env bash

# ----------------------------------------------------------------------------
# Find, excluding in directories .git and .github, files and search
# them for TODO comments. Any TODO comments are converted into a form that are
# exported specially by the Github UI, as are any FIXME comments (those also
# trigger an error exit).
# ----------------------------------------------------------------------------

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

# Find files and apply a little awk script
find . \
    -type d \( -name ".git" -o -name ".github" \) -prune \
    -o -type f -print0 | xargs -0 awk -f $GITHUB_ACTION_PATH/detect-todo.awk
    