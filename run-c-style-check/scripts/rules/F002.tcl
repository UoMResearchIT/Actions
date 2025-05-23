#!/usr/bin/tclsh
# File names should be well-formed

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

set maxDirectoryDepth [getParameter "max-directory-depth" 8]
set maxDirnameLength [getParameter "max-dirname-length" 31]
set maxFilenameLength [getParameter "max-filename-length" 60]
set maxPathLength [getParameter "max-path-length" 200]

foreach fileName [getSourceFileNames] {
    if {[string length $fileName] > $maxPathLength} {
        report $fileName 1 "path name too long"
    }

    set dirDepth 0
    foreach dir [file split [file dirname $fileName]] {
        if {$dir == "/" || $dir == "." || $dir == ".."} {
            continue
        }

        incr dirDepth

        if {[string length $dir] > $maxDirnameLength} {
            report $fileName 1 "directory name component too long"
            break
        }

        set first [string index $dir 0]
        if {[string is alpha $first] == 0 && $first != "_"} {
            report $fileName 1 "directory name should start with alphabetic character or underscore"
            break
        }

        if {[string first "." $dir] != -1} {
            report $fileName 1 "directory name should not contain a dot"
            break
        }
    }

    if {$dirDepth >= $maxDirectoryDepth} {
        report $fileName 1 "directory structure too deep"
    }

    set leafName [file tail $fileName]
    if {[string length $leafName] > $maxFilenameLength} {
        report $fileName 1 "file name too long"
    }

    set first [string index $leafName 0]
    if {[string is alpha $first] == 0 && $first != "_"} {
        report $fileName 1 "file name should start with alphabetic character or underscore"
    }

    if {[llength [split $leafName .]] > 2} {
        report $fileName 1 "file name should not contain more than one dot"
    }
}
