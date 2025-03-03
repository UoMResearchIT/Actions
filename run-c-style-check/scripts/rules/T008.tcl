#!/usr/bin/tclsh
# Keywords catch, for, if and while should be followed by a single space

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
    set pp_line -1
    foreach t [getTokens $f 1 0 -1 -1 {catch for if switch while pp_pragma pp_error}] {
        set keyword [lindex $t 0]
        set line [lindex $t 1]
        set column [lindex $t 2]
        set type [lindex $t 3]
        if {($type == "pp_pragma") || ($type == "pp_error")} {
            set pp_line $line
        } elseif {$pp_line != $line} {
            set followingTokens [getTokens $f $line [expr {$column + [string length $keyword]}] [expr {$line + 1}] -1 {}]
            if {[llength $followingTokens] < 2} {
                report $f $line "keyword '${keyword}' not followed by a single space"
            } else {
                if {[list [lindex [lindex $followingTokens 0] 0] [lindex [lindex $followingTokens 1] 0]] != [list " " "("]} {
                    report $f $line "keyword '${keyword}' not followed by a single space"
                }
            }
        }
    }
}
