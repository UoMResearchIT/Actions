#!/usr/bin/tclsh
# Keywords break and continue should be immediately followed by a semicolon

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
    foreach t [getTokens $f 1 0 -1 -1 {break continue}] {
        set keyword [lindex $t 0]
        set line [lindex $t 1]
        set column [lindex $t 2]
        set semicolons [getTokens $f $line [expr {$column + [string length $keyword]}] [expr {$line + 1}] 0 {semicolon}]
        if {$semicolons == {}} {
            report $f $line "keyword '${keyword}' not immediately followed by a semicolon"
        } else {
            set semColumn [lindex [lindex $semicolons 0] 2]
            if {$semColumn != $column + [string length $keyword]} {
                report $f $line "keyword '${keyword}' not immediately followed by a semicolon"
            }
        }
    }
}
