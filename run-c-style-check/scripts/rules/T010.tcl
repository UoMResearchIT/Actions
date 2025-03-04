#!/usr/bin/tclsh
# Identifiers should not be composed of 'l' and 'O' characters only

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

foreach file [getSourceFileNames] {
    foreach t [getTokens $file 1 0 -1 -1 {identifier}] {
        set value [lindex $t 0]
        if {[regexp {^(l|O)+$} $value]} {
            report $file [lindex $t 1] "identifier should not be composed of only 'l' and 'O'"
        }
    }
}
