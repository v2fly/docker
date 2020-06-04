#!/bin/bash

COREREPO=$1
if [[ -z $COREREPO ]]; then
	COREREPO=../core
fi

if [[ ! -d $COREREPO ]]; then
	echo "$0 path/to/core/gitrepo"
	exit 1
fi

pushd $COREREPO
LATESTHASH=$(git rev-parse --short HEAD)
popd
CURRHASH=$(cat ReleaseHash)

echo "Prev Rev: ${CURRHASH}, repo Hash: ${LATESTHASH}"

if [[ x${CURRHASH} == x${LATESTHASH} ]]; then
	echo "they are the same"
	exit 1;
fi

read -p "Update rev: ${LATESTHASH}? (y/n) " confirm
if [[ x$confirm == "xy" ]]; then 
	echo ${LATESTHASH} > ReleaseHash
fi

