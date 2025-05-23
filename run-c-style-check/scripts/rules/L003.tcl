#!/usr/bin/tclsh
# No leading and no trailing empty lines

# Copyright (c) 2017-2025 The University of Manchester
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

foreach f [getSourceFileNames] {
    set lineCount [getLineCount $f]
    if {$lineCount > 0} {
        set firstLine [getLine $f 1]
        if {[string trim $firstLine] == ""} {
            report $f 1 "leading empty line(s)"
        }

        set lastLine [getLine $f $lineCount]
        if {[string trim $lastLine] == ""} {
            report $f $lineCount "trailing empty line(s)"
        }
    }
}
