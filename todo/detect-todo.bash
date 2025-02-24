#!/usr/bin/env bash

# ----------------------------------------------------------------------------
# Find, excluding in directories .git and .github, files and search
# them for TODO comments. Any TODO comments are converted into a form that are
# exported specially by the Github UI, as are any FIXME comments (those also
# trigger an error exit).
# ----------------------------------------------------------------------------

# Find files and apply a little awk script
find . \
    -type d \( -name ".git" -o -name ".github" \) -prune \
    -o -type f -print0 | xargs -0 awk -f $GITHUB_ACTION_PATH/detect-todo.awk
