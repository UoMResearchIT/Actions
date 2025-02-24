#!/usr/bin/env bash

file="${LOCALNAME:-$(sed 's/#.*$//;s!^.*/!!' <<< "$URL")}"

if [ -z "$file" ]; then
    echo "::error title=Empty file::Target file name is empty. Aborting."
    exit 1
fi
if (( $(tr -cd ' ' <<< "$file" | wc -c) > 0 )); then
    echo "::warning title=Space in filename::Space found in filename '$file'; results may be unpredictable."
fi

echo "file=$file" >> $GITHUB_OUTPUT
