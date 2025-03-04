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

# Initialise counters
BEGIN {
    todocounter = 0;
    fixmecounter = 0;
}

# Clean up the file name
BEGINFILE {
    filename = FILENAME
    sub(/^\.\//, "", filename)
    printf "Scanning %s...\n", filename
}

# For each line, find TODOs and FIXMEs
{
    if (match($0, /(TODO.*|NotImplementedException)/, m)) {
        printf "::warning title=TODO,file=%s,line=%s::%s\n", filename, FNR, m[0];
        todocounter++;
    }
    if (match($0, /(FIXME.*|Auto-generated method stub)/, m)) {
        printf "::error title=FIXME,file=%s,line=%s::%s\n", filename, FNR, m[0];
        fixmecounter++;
    }
}

# Summarise once everything done
END {
    if (fixmecounter > 0) {
        printf "\033[0;31mFound %s FIXMEs\033[0m\n", fixmecounter
    }
    if (todocounter > 0) {
        printf "\033[0;33mFound %s TODOs\033[0m\n", todocounter
    }
    if (fixmecounter > 0) {
        exit 1
    }
    # No FIXMEs were found if at this point.
    if (todocounter < 1) {
        printf "No problems found.\n"
    }
}
