# ----------------------------------------------------------------------------
# Find, excluding in directories .git, .github and 3rdparty, files and search
# them for TODO comments. Any TODO comments are converted into a form that are
# exported specially by the Github UI, as are any FIXME comments (those also
# trigger an error exit).
# ----------------------------------------------------------------------------

# Find files and apply a little awk script
find . -type d \( -name ".git*" \) -prune -o -type f -print0 | xargs -0 awk '
BEGIN {
    todocounter = 0;
    fixmecounter = 0;
}
BEGINFILE {
    filename = FILENAME
    sub(/^\.\//, "", filename)
    printf "Scanning %s...\n", filename
}
{
    if (match($0, /(TODO.*|NotImplementedException)/, m)) {
        printf "::warning file=%s,line=%s::%s\n", filename, FNR, m[0];
        todocounter++;
    }
    if (match($0, /(FIXME.*|Auto-generated method stub)/, m)) {
        printf "::error file=%s,line=%s::%s\n", filename, FNR, m[0];
        fixmecounter++;
    }
}
END {
    if (fixmecounter > 0) {
        printf "\033[0;31mFound %s FIXMEs\033[0m\n", fixmecounter
    }
    if (todocounter > 0) {
        printf "\033[0;33mFound %s TODOs\033[0m\n", todocounter
    }
    if (fixmecounter > 0) {
        exit 1
    }
    # No FIXMEs were found if at this point.
    if (todocounter < 1) {
        printf "No problems found.\n"
    }
}
'
