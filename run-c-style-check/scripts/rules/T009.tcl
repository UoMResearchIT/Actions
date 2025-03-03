#!/usr/bin/tclsh
# Comma should not be preceded by whitespace, but should be followed by one

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
    foreach t [getTokens $f 1 0 -1 -1 {comma}] {
        set line [lindex $t 1]
        set column [lindex $t 2]
        set preceding [getTokens $f $line 0 $line $column {}]
        if {$preceding == {}} {
            report $f $line "comma should not be preceded by whitespace"
        } else {
            set lastPreceding [lindex [lindex $preceding end] 3]
            if {$lastPreceding == "space"} {
                report $f $line "comma should not be preceded by whitespace"
            }
        }
        set following [getTokens $f $line [expr {$column + 1}] [expr {$line + 1}] -1 {}]
        if {$following != {}} {
            set firstFollowing [lindex [lindex $following 0] 3]
            if {$firstFollowing != "space" && $firstFollowing != "newline" &&
                    !($lastPreceding == "operator" && $firstFollowing == "leftparen")} {
                report $f $line "comma should be followed by whitespace"
            }
        }
    }
}
