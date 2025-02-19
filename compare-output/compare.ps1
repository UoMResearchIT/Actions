if ($Env:INIT) {
    Invoke-Expression $Env:INIT
}

$actual = (Invoke-Expression $Env:COMMAND)

$C = "$([char] 27)[0;33m"                       
$NC = "$([char] 27)[0m"
Write-Host "${C}actual:${NC}   $actual"
Write-Host "${C}expected:${NC} $Env:EXPECTED"

if ($actual -ne $Env:EXPECTED) {
    exit 1
}
