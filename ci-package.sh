#!/usr/bin/env bash
# Bash3 Boilerplate. Copyright (c) 2014, kvz.io

set -o errexit
set -o pipefail
set -o nounset
# set -o xtrace

trap 'echo -e "Aborted, error $? in command: $BASH_COMMAND"; trap ERR; exit 1' ERR

# Set magic variables for current file & dir
__dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
__file="${__dir}/$(basename "${BASH_SOURCE[0]}")"
__base="$(basename ${__file} .sh)"
__root="$(cd "$(dirname "${__dir}")" && pwd)" # <-- change this as it depends on your app
black() { echo -e "$(tput setaf 0)$*$(tput setaf 9)"; }
red() { echo -e "$(tput setaf 1)$*$(tput setaf 9)"; }
green() { echo -e "$(tput setaf 2)$*$(tput setaf 9)"; }
yellow() { echo -e "$(tput setaf 3)$*$(tput setaf 9)"; }
blue() { echo -e "$(tput setaf 4)$*$(tput setaf 9)"; }
magenta() { echo -e "$(tput setaf 5)$*$(tput setaf 9)"; }
cyan() { echo -e "$(tput setaf 6)$*$(tput setaf 9)"; }
white() { echo -e "$(tput setaf 7)$*$(tput setaf 9)"; }

NOW=$(date '+%Y%m%d-%H%M%S')
TMP=$(mktemp -d)
SRCDIR=$(pwd)

CODENAME="user"
BUILDNAME=$NOW
VERSIONTAG=$(cat ReleaseTag)
GOPATH=$(go env GOPATH)

cleanup () { rm -rf $TMP; }
trap cleanup INT TERM ERR

get_source() {
	yellow ">>> Getting v2ray sources ..."
	go get -insecure -v -t v2ray.com/core/...
	SRCDIR="$GOPATH/src/v2ray.com/core"
}

build_v2() {
	pushd $SRCDIR
	LDFLAGS="-s -w -X v2ray.com/core.codename=${CODENAME} -X v2ray.com/core.build=${BUILDNAME} -X v2ray.com/core.version=${VERSIONTAG}"

	yellow ">>> Compile v2ray ..."
	env CGO_ENABLED=0 go build -o $TMP/v2ray${EXESUFFIX} -ldflags "$LDFLAGS" ./main
	if [[ $GOOS == "windows" ]];then
	  env CGO_ENABLED=0 go build -o $TMP/wv2ray${EXESUFFIX} -ldflags "-H windowsgui $LDFLAGS" ./main
	fi

	yellow ">>> Compile v2ctl ..."
	env CGO_ENABLED=0 go build -o $TMP/v2ctl${EXESUFFIX} -tags confonly -ldflags "$LDFLAGS" ./infra/control/main
	popd
}

build_dat() {
        CACHE=$__dir
        if [[ ! -f $CACHE/geoip.dat ]]; then
                yellow ">>> Downloading lastest geoip ..."
		pushd $CACHE
                wget -qO - https://api.github.com/repos/v2ray/geoip/releases/latest \
                | jq -r '.assets[] | .browser_download_url' \
                | wget -i -
                if ! sha256sum -c geoip.dat.sha256sum; then
		  red "geoip.dat checksum error"
		  exit 1
		fi
		popd
        fi

        if [[ ! -f $CACHE/dlc.dat ]]; then
                yellow ">>> Downloading latest geosite ..."
		pushd $CACHE
                wget -qO - https://api.github.com/repos/v2ray/domain-list-community/releases/latest \
                | jq -r '.assets[] | .browser_download_url' \
                | wget -i -
                if ! sha256sum -c dlc.dat.sha256sum; then
		  red "dlc.dat checksum error"
		  exit 1
		fi
		popd
        fi

        cp -v $CACHE/geoip.dat $TMP/geoip.dat
        cp -v $CACHE/dlc.dat $TMP/geosite.dat
}


copyconf() {
	yellow ">>> Copying config..."
	pushd $SRCDIR/release/config
	tar c --exclude "*.dat" . | tar x -C $TMP
}

packzip() {
	yellow ">>> Generating zip package"
	pushd $TMP
	local PKG=${__dir}/v2ray-custom-${GOARCH}-${GOOS}-${PKGSUFFIX}${NOW}.zip
	zip -r $PKG .
	yellow ">>> Generated: $(basename $PKG)"
}

packtgz() {
	yellow ">>> Generating tgz package"
	pushd $TMP
	local PKG=${__dir}/v2ray-custom-${GOARCH}-${GOOS}-${PKGSUFFIX}${NOW}.tar.gz
	tar cvfz $PKG .
	yellow ">>> Generated: $(basename $PKG)"
}

packtgzAbPath() {
	local ABPATH="$1"
	yellow ">>> Generating tgz package at $ABPATH"
	pushd $TMP
	tar cvfz $ABPATH .
	yellow ">>> Generated: $ABPATH"
}


pkg=zip
nosource=0
nodat=0
noconf=0
GOOS=linux
GOARCH=amd64
GOARM=
EXESUFFIX=
PKGSUFFIX=

for arg in "$@"; do
case $arg in
	arm64)
		GOARCH=arm64
		;;
	arm7)
		GOARM=7
		GOARCH=arm
		;;
	mips*)
		GOARCH=$arg
		;;
	386)
		GOARCH=386
		;;
	windows)
		GOOS=windows
		EXESUFFIX=.exe
		;;
	darwin)
		GOOS=$arg
		;;
	nodat)
		nodat=1
		PKGSUFFIX=${PKGSUFFIX}nodat-
		;;
	noconf)
		noconf=1
		;;
	nosource)
		nosource=1
		;;
	tgz)
		pkg=tgz
		;;
	abpathtgz=*)
		pkg=${arg##abpathtgz=}
		;;
	codename=*)
		CODENAME=${arg##codename=}
		;;
	buildname=*)
		BUILDNAME=${arg##buildname=}
		;;
esac
done

if [[ $nosource != 1 ]]; then
  get_source	
fi

export GOOS GOARCH
green "Build ARGS: GOOS=${GOOS} GOARCH=${GOARCH} CODENAME=${CODENAME} BUILDNAME=${BUILDNAME}"
if [[ $GOARCH == "arm" ]]; then
  green "Build ARGS: GOARM=${GOARM}"
  export GOARM
fi

green "PKG ARGS: pkg=${pkg}"
build_v2

if [[ $nodat != 1 ]]; then
  build_dat
fi

if [[ $noconf != 1 ]]; then
  copyconf 
fi

if [[ $pkg == "zip" ]]; then
  packzip
elif [[ $pkg == "tgz" ]]; then
  packtgz
else
	packtgzAbPath $pkg
fi


cleanup

