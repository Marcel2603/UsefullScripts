#!/bin/bash
VERSION=$1
OPTDIR=~/.local/opt/aws-vault/bin
BINFOLDER=~/.local/bin
BINDIR=$BINFOLDER/aws-vault
TEMPDIR=aws-vault-temp
FILENAME=aws-vault

if [[ -z $VERSION ]]; then echo "pls insert version like 6.3.1"  && exit 1;fi

if [[ -d $TEMPDIR ]]; then echo "$TEMPDIR exists, pls remove i" && exit 1; else echo "creating TEMPDIR: $TEMPDIR" && mkdir --parents $TEMPDIR; fi

if [[ -d $OPTDIR ]]; then echo "install aws-vault in $OPTDIR"; else echo "$OPTDIR does not exists" && mkdir --parents $OPTDIR; fi

if [[ -d $BINFOLDER ]]; then echo "install aws-vault in $BINFOLDER"; else echo "$BINFOLDER does not exists" && mkdir --parents $BINFOLDER; fi

if [[ -f $BINDIR ]]; then echo "remove $BINDIR with info:" && ls -la $BINDIR && rm $BINDIR; fi

cd $TEMPDIR || exit 1

wget -q --show-progress "https://github.com/99designs/aws-vault/releases/download/v$VERSION/aws-vault-linux-amd64" -O $FILENAME
mv $FILENAME "$OPTDIR"
chmod +x $OPTDIR/$FILENAME
# verlink k9s with user
ln -s "$OPTDIR/$FILENAME" "$BINDIR"
rm -rf $TEMPDIR