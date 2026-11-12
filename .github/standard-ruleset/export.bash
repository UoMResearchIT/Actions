#!/bin/bash
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

# Exports the branch rules defined by the template repository itself into the
# standard ruleset file used by the check-ruleset reusable workflow.
#
# Usage: bash .github/standard-ruleset/export.bash [OUTPUT_FILE]
#
# Environment:
#   GH_TOKEN         token that can read the template repository's rules
#   TEMPLATE_REPO    defaults to UoMResearchIT/RSE-Repository-Template
#   TEMPLATE_BRANCH  defaults to main
#
# Only rules whose source is the template repository are kept; rules inherited
# from the organisation or enterprise are dropped, as are the source metadata
# fields, because check-ruleset-containment only compares type and parameters.

set -euo pipefail

TEMPLATE_REPO=${TEMPLATE_REPO:-UoMResearchIT/RSE-Repository-Template}
TEMPLATE_BRANCH=${TEMPLATE_BRANCH:-main}
OUTPUT_FILE=${1:-$(dirname "$0")/ruleset.json}
TEMP_FILE=$(mktemp)
trap 'rm -f "$TEMP_FILE"' EXIT

gh api "repos/$TEMPLATE_REPO/rules/branches/$TEMPLATE_BRANCH" \
    | jq --arg source "$TEMPLATE_REPO" '
        map(select(.ruleset_source_type == "Repository" and .ruleset_source == $source)
            | {type, parameters})
        | sort_by(.type)
    ' > "$TEMP_FILE"

if [[ $(jq length "$TEMP_FILE") -eq 0 ]]; then
    echo "::error title=No Standard Rules::No rules defined by $TEMPLATE_REPO were found on branch $TEMPLATE_BRANCH; not overwriting $OUTPUT_FILE."
    exit 1
fi

cp "$TEMP_FILE" "$OUTPUT_FILE"
echo "Wrote $(jq length "$OUTPUT_FILE") rules from $TEMPLATE_REPO ($TEMPLATE_BRANCH) to $OUTPUT_FILE"
