#!/bin/bash

LATESTTAG=$(curl --compressed https://api.github.com/repos/v2fly/v2ray-core/releases/latest | jq -r .tag_name)
CURRTAG=$(cat ReleaseTag)

if [[ -z $LATESTTAG ]]; then
  echo "cant retrive latesttag"
  exit 1
fi

echo "Prev Rev: ${CURRTAG}, repo Hash: ${LATESTTAG}"

if [[ x${CURRTAG} == x${LATESTTAG} ]]; then
	echo "they are the same"
	exit 1;
fi

read -p "Update rev: ${LATESTTAG}? (y/n) " confirm
if [[ x$confirm == "xy" ]]; then 
	echo ${LATESTTAG} > ReleaseTag
fi

