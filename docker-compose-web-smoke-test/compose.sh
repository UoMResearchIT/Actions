#!/usr/bin/env bash
# Copyright (c) 2026 The University of Manchester
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

# Runs "docker compose" with the action's compose-files input (one file per
# line, in COMPOSE_FILES) passed as COMPOSE_FILE. If no files are given,
# Compose uses its defaults (compose.yaml plus compose.override.yaml).
# COMPOSE_FILE is only set when there are files, as an empty value breaks
# Compose.

set -euo pipefail

files="$(sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//' <<< "${COMPOSE_FILES:-}" \
  | grep -v '^$' | paste -sd: - || true)"
if [ -n "$files" ]; then
  export COMPOSE_FILE="$files"
fi

exec docker compose "$@"
