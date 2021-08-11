#!/bin/bash

VERSION=$1
OPTDIR=~/.local/opt/k9s/bin
BINDIR=~/.local/bin/k9s

set -e

if [[ -z $VERSION ]]; then echo "pls insert version like 0.24.10" && exit 1; fi

if [[ -d $OPTDIR ]]; then echo "install k9s in $OPTDIR"; else echo "$OPTDIR does not exists" && mkdir --parents $OPTDIR; fi

URL="https://github.com/derailed/k9s/releases/download/v${VERSION}/k9s_Linux_x86_64.tar.gz"
echo "$URL"
wget -q --show-progress "$URL" -O k9s.tar.gz

tar -xf k9s.tar.gz

mv k9s "$OPTDIR"

if [[ -f $BINDIR ]]; then echo "remove $BINDIR with info:" && ls -la $BINDIR && rm $BINDIR; fi
# link k9s with path
ln -s "$OPTDIR/k9s" "$BINDIR"

rm README.md LICENSE k9s.tar.gz
