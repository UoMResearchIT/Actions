#!/usr/bin/env bash
eval $INIT

actual=`$COMMAND`

C='\033[0;33m'
NC='\033[0m'
echo -e "${C}actual:${NC}   $actual"
echo -e "${C}expected:${NC} $EXPECTED"
[ "$actual" = "$EXPECTED" ] || exit 1
