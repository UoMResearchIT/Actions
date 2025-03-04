#!/usr/bin/tclsh
# control structures should have complete curly-braced block of code

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
    set state "start"
    set prev ""
    set pp_line -1
    foreach token [getTokens $fileName 1 0 -1 -1 {for if while do else leftparen rightparen leftbrace rightbrace semicolon pp_pragma pp_error}] {
        set type [lindex $token 3]
        set line [lindex $token 1]

        if {$state == "control"} {
            if {$type == "leftparen"} {
                incr parenCount
            } elseif {$type == "rightparen"} {
                incr parenCount -1
                if {$parenCount == 0} {
                    set state "expectedblock"
                }
            }

        } elseif {$state == "expectedblock"} {
            if {$prev == "else" && $type == "if" } {
                # skip
            } elseif {$type != "leftbrace"} {
                set line [lindex $token 1]
                report $fileName $line "full block {} expected in the control structure"
            }
            set state "block"
        }

        if {($type == "pp_pragma") || ($type == "pp_error")} {
            set pp_line $line
        } elseif {$pp_line != $line} {
            if {$type == "for" || $type == "if"} {
                set parenCount 0
                set state "control"
            } elseif {$type == "do" || $type == "else"} {
                set state "expectedblock"
            } elseif {$type == "while" && $prev != "rightbrace"} {
                set parenCount 0
                set state "control"
            }
        }
        set prev $type
    }
}
