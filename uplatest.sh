#!/bin/bash

LATESTHASH=$(curl --compressed https://api.github.com/repos/v2fly/v2ray-core/commits/master | jq -r .sha)
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

