# Initialise counters
BEGIN {
    todocounter = 0;
    fixmecounter = 0;
}

# Clean up the file name
BEGINFILE {
    filename = FILENAME
    sub(/^\.\//, "", filename)
    printf "Scanning %s...\n", filename
}

# For each line, find TODOs and FIXMEs
{
    if (match($0, /(TODO.*|NotImplementedException)/, m)) {
        printf "::warning title=TODO,file=%s,line=%s::%s\n", filename, FNR, m[0];
        todocounter++;
    }
    if (match($0, /(FIXME.*|Auto-generated method stub)/, m)) {
        printf "::error title=FIXME,file=%s,line=%s::%s\n", filename, FNR, m[0];
        fixmecounter++;
    }
}

# Summarise once everything done
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
