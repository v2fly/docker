#!/bin/bash

# Get code
CUR=${PWD}
TAG=$(cat ReleaseTag)
git clone -b ${TAG} https://github.com/v2fly/v2ray-core.git && cp v2ray-core/release/config/*.dat ${CUR} && cp v2ray-core/release/config/config.json ${CUR}
cd v2ray-core

# Build release
ARCHS=( 386 amd64 arm arm64 ppc64le s390x )
ARMS=( 6 7 )
LDFLAGS="-s -w -buildid="

for ARCH in ${ARCHS[@]}; do
    if [ "${ARCH}" = "arm" ]; then
        for ARM in ${ARMS[@]}; do
            echo "Building v2ray-${ARCH}v${ARM}"
            env CGO_ENABLED=0 GOOS=linux GOARCH=${ARCH} GOARM=${ARM} go build -o v2ray -trimpath -ldflags "${LDFLAGS}" ./main
            env CGO_ENABLED=0 GOOS=linux GOARCH=${ARCH} GOARM=${ARM} go build -o v2ctl -trimpath -ldflags "${LDFLAGS}" -tags confonly ./infra/control/main
            chmod +x v2ray v2ctl && tar -zvcf ${CUR}/v2ray-${ARCH}v${ARM}.tar.gz v2ray v2ctl && rm -fv v2ray v2ctl
        done
    else
        echo "Building v2ray-${ARCH}"
        env CGO_ENABLED=0 GOOS=linux GOARCH=${ARCH} go build -o v2ray -trimpath -ldflags "${LDFLAGS}" ./main
        env CGO_ENABLED=0 GOOS=linux GOARCH=${ARCH} go build -o v2ctl -trimpath -ldflags "${LDFLAGS}" -tags confonly ./infra/control/main
        chmod +x v2ray v2ctl && tar -zvcf ${CUR}/v2ray-${ARCH}.tar.gz v2ray v2ctl && rm -fv v2ray v2ctl
    fi
done