#!/usr/bin/tclsh
# No trailing whitespace

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

set strictMode [getParameter "strict-trailing-space" 0]

foreach f [getSourceFileNames] {
    set lineNumber 1
    set previousIndent ""

    # Special hack: skip files that cause a failure in low-level parsing
    if {[catch {getAllLines $f} lines]} continue

    foreach line $lines {
        if {[regexp {^.*\r$} $line]} {
            report $f $lineNumber "CRLF line ending"
            set line [string range $line 0 end-1]
        }
        if {[regexp {^.*[[:space:]]+$} $line]} {
            if {$strictMode || [string trim $line] != "" || $line != $previousIndent} {
                report $f $lineNumber "trailing whitespace"
            }
        }

        regexp {^([[:space:]]*).*$} $line dummy previousIndent
        incr lineNumber
    }
}
