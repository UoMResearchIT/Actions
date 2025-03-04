#!/usr/bin/tclsh
# Semicolons should not be isolated by spaces or comments from the rest of the code

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
    foreach t [getTokens $f 1 0 -1 -1 {semicolon}] {
        set line [lindex $t 1]
        set column [lindex $t 2]
        set previousTokens [getTokens $f $line 0 $line $column {}]
        if {$previousTokens == {}} {
            report $f $line "semicolon is isolated from other tokens"
        } else {
            set lastToken [lindex $previousTokens end]
            set lastName [lindex $lastToken 3]
            if {[lsearch {space ccomment} $lastName] != -1} {
                set forTokens [getTokens $f $line 0 $line $column {for leftparen}]
                if {[list [lindex [lindex $forTokens 0] 3] [lindex [lindex $forTokens 1] 3]] != {for leftparen}} {
                    report $f $line "semicolon is isolated from other tokens"
                }
            }
        }
    }
}
