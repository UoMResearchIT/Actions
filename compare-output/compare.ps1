# Copyright (c) 2024-2025 The University of Manchester
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

$ErrorActionPreference = 'Stop'
if ($Env:INIT) {
    Invoke-Expression $Env:INIT
}

$actual = (Invoke-Expression $Env:COMMAND)

$C = "$([char] 27)[0;33m"
$NC = "$([char] 27)[0m"
Write-Host "${C}actual:${NC}   $actual"
Write-Host "${C}expected:${NC} $Env:EXPECTED"

if ($actual -ne $Env:EXPECTED) {
    exit 1
}
