#!/bin/bash
VERSION=$1
OPTDIR=~/.local/opt/aws-vault/bin
BINDIR=~/.local/bin/aws-vault
TEMPDIR=aws-vault-temp
FILENAME=aws-vault
if [[ -z $VERSION ]]; then echo "pls insert version like 6.3.1"  && exit 1;fi
#if [[ -d $OPTDIR ]]; then echo "install k9s in $OPTDIR"; else echo "$OPTDIR does not exists" && mkdir --parents $OPTDIR; fi

if [[ -d $TEMPDIR ]]; then echo "$TEMPDIR exists, pls remove i" && exit 1; else echo "creating TEMPDIR: $TEMPDIR" && mkdir --parents $TEMPDIR; fi

cd $TEMPDIR || exit 1

wget -q --show-progress "https://github.com/99designs/aws-vault/releases/download/v$VERSION/aws-vault-linux-amd64" -O $FILENAME
mv $FILENAME "$OPTDIR"
chmod +x $OPTDIR/$FILENAME
if [[ -f $BINDIR ]]; then echo "remove $BINDIR with info:" && ls -la $BINDIR && rm $BINDIR; fi
# verlink k9s with user
ln -s "$OPTDIR/$FILENAME" "$BINDIR"
rm -rf $TEMPDIR