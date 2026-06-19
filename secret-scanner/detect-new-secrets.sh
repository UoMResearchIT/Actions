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

#############################################################
####
#### Set up variables
####
all_secrets_file=$(mktemp)
new_secrets_file=$(mktemp)
command_to_update_baseline_file=$(mktemp)
: "${GITHUB_ACTION_PATH:=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &> /dev/null && pwd)}"
: "${GITHUB_STEP_SUMMARY:=/dev/stderr}"
: "${PYTHON_PATH:=python}"
jobs_summary_link="${GITHUB_SERVER_URL}/${GITHUB_REPOSITORY}/actions/runs/${GITHUB_RUN_ID}/attempts/${GITHUB_RUN_ATTEMPT}"

#############################################################
####
#### Argument construction helper.
####
fetch_flags_from_file() {
    flag_to_add="$1"
    file_to_check="$2"

    flags=()
    if [ -r "$file_to_check" ]; then
        while read line; do
            if [[ "${line::1}" != '#' ]] && [[ ! -z "$line" ]]; then
                flags+=("${flag_to_add}" "${line}")
            fi
        done < "$file_to_check"
    fi

    echo "${flags[@]@Q}"
}

#############################################################
####
#### How to run detect-secrets.
####
scan_new_secrets() {
    excluded_files=$(fetch_flags_from_file '--exclude-files' "${EXCLUDE_FILES_PATH}" 2>/dev/null)
    excluded_secrets=$(fetch_flags_from_file '--exclude-secrets' "${EXCLUDE_SECRETS_PATH}" 2>/dev/null)
    excluded_lines=$(fetch_flags_from_file '--exclude-lines' "${EXCLUDE_LINES_PATH}" 2>/dev/null)
    detect_secret_args="${excluded_files} ${excluded_secrets} ${excluded_lines} ${ADDITIONAL_ARGS}"
    echo "Running detect-secrets with args: ${detect_secret_args}"

    "${PYTHON_PATH}" -m detect-secrets scan ${detect_secret_args} --baseline "${BASELINE_FILE}"
    "${PYTHON_PATH}" -m detect-secrets audit "${BASELINE_FILE}" --report --json > "${all_secrets_file}"
    jq 'map(select(.category == "UNVERIFIED"))' "${all_secrets_file}" > "${new_secrets_file}"
}

#############################################################
####
#### Generate markdown: for log
####
advice_if_none_are_secret_short() {
    cat << EOF
### If none of these are secrets or you don't care about these secrets
1. Visit →→→"$jobs_summary_link"
2. Run the command under \`Command to Update Secrets Baseline\`
3. Push the generated commit to GitHub
EOF
}

#############################################################
####
#### Generate markdown: for job summary
####
advice_if_none_are_secret_verbose() {
    cat << EOF > "$command_to_update_baseline_file"
cat << 'NEW_BASELINE' > '$NEW_BASELINE'
$(jq 'setpath(["results"]; (.results | map_values(. | map_values(setpath(["is_secret"]; (.is_secret // false))))))' "$BASELINE_FILE")
NEW_BASELINE

git commit -m 'Updating baseline file' '$NEW_BASELINE'
EOF

    cat << EOF
### If none of these are secrets or you don't care about these secrets
Replace the file \`$NEW_BASELINE\` with:

<details>
    <summary>Command to Update Secrets Baseline</summary>

\`\`\`sh
EOF
    cat "$command_to_update_baseline_file" << EOF
\`\`\`
</details>
EOF
}

#############################################################
####
#### Generate markdown: common
####
markdown_from_new_secrets() {
    secret_table_body=$(jq -r '.[] | "|\(.filename)|\(.lines | keys)|\(.types)|"' "$new_secrets_file" | tr -d '["]')

    cat << EOF
# Secret Scanner Report
## Potential new secrets discovered
|FILE|LINES|TYPES|
|----|-----|-----|
$secret_table_body

## What you should do
### If any of these are secrets
Secrets pushed to GitHub are not safe to use.

For the secrets you have just compromised (it is _not_ sufficient to rebase to remove the commit), you should:
* Rotate the secret
EOF
}

#############################################################
####
#### Generate markdown: main part of script
####

echo "::add-matcher::${GITHUB_ACTION_PATH}/secret-problem-matcher.json"
if [ -z "${BASELINE_FILE}" ]; then
    export BASELINE_FILE=$(mktemp)
    NEW_BASELINE=.github/secret-scanner/baseline.json
    jq 'del(.results[])' "${GITHUB_ACTION_PATH}/baseline.json" > "${BASELINE_FILE}"
else
    NEW_BASELINE="${BASELINE_FILE}"
fi
scan_new_secrets

if [ "$(cat "${new_secrets_file}")" = "[]" ]; then
    echo "No new secrets found"
    exit 0
fi

markdown_limited_advice=$(markdown_from_new_secrets)
markdown_console_advice=$(advice_if_none_are_secret_short)

# Print a short message to the console
echo "${markdown_limited_advice}"
echo "${markdown_console_advice}"

# Write a more detailed message to the jobs summary
echo "${markdown_limited_advice}" > "${GITHUB_STEP_SUMMARY}"
advice_if_none_are_secret_verbose >> "${GITHUB_STEP_SUMMARY}"

exit 1
