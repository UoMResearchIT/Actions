#!/usr/bin/tclsh
# Some keywords should be followed by a single space

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

set keywords {
    case
    class
    enum
    explicit
    extern
    goto
    new
    struct
    union
    using
}

proc isKeyword {s} {
    global keywords
    return [expr {[lsearch $keywords $s] != -1}]
}

set state "other"
foreach f [getSourceFileNames] {
    foreach t [getTokens $f 1 0 -1 -1 {}] {
        set tokenValue [lindex $t 0]
        set tokenName [lindex $t 3]
        if {$state == "keyword"} {
            if {$tokenName == "space" && $tokenValue == " "} {
                set state "space"
            } else {
                report $f $lineNumber "keyword \'${keywordValue}\' not followed by a single space"
                set state "other"
            }
        } elseif {$state == "space"} {
            if {$tokenName == "newline"} {
                report $f $lineNumber "keyword \'${keywordValue}\' not followed by a single space"
            }
            set state "other"
        } else {
            if {[isKeyword $tokenName]} {
                set state "keyword"
                set lineNumber [lindex $t 1]
                set keywordValue [lindex $t 0]
            }
        }
    }
}
