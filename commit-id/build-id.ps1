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
Write-Output "Using build ID = $env:REPLACEMENT"
(Get-Content $env:BUILD_ID).Replace($env:PATTERN, $env:REPLACEMENT) | Set-Content $env:BUILD_ID
# sed -i -e "s/undefined .dev build./${{ github.sha }}/" $BUILD_ID
