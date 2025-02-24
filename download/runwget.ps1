$ErrorActionPreference = 'Stop'
$wget = 'C:\msys64\usr\bin\wget.exe'
$opts = (Select-String \S+ -input $env:OPTIONS -allmatches | ForEach-Object {$_.matches.value})
& $wget --config=$env:GITHUB_ACTION_PATH\wgetrc -O $env:FILE @opts -- $env:URL
