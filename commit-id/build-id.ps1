Write-Output "Using build ID = $env:REPLACEMENT"
(Get-Content $env:BUILD_ID).Replace($env:PATTERN, $env:REPLACEMENT) | Set-Content $env:BUILD_ID
# sed -i -e "s/undefined .dev build./${{ github.sha }}/" $BUILD_ID
