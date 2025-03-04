#!/usr/bin/tclsh
# Source files should not use the '\r' (CR) character

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

foreach fileName [getSourceFileNames] {
    if { $fileName == "-" } {
        # can't check the content from stdin
        continue
    }
    set file [open $fileName "r"]
    fconfigure $file -translation lf
    set line [gets $file]
    set lineCounter 1
    while {![eof $file]} {
        set pos [string first "\r" $line]
        if {$pos != -1 && $pos != [string length $line] - 1} {
            report $fileName $lineCounter "\\r (CR) detected in isolation at position ${pos}"
        }
        set line [gets $file]
        incr lineCounter
    }
    close $file
}
