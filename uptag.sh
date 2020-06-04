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
LATESTTAG=$(git describe --tags)
popd
CURRTAG=$(cat ReleaseTag)

echo "Prev Rev: ${CURRTAG}, repo Hash: ${LATESTTAG}"

if [[ x${CURRTAG} == x${LATESTTAG} ]]; then
	echo "they are the same"
	exit 1;
fi

read -p "Update rev: ${LATESTTAG}? (y/n) " confirm
if [[ x$confirm == "xy" ]]; then 
	echo ${LATESTTAG} > ReleaseTag
fi

