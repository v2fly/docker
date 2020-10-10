#!/bin/bash

# Get code
CUR=${PWD}
TAG=$(wget -qO- https://api.github.com/repos/v2fly/v2ray-core/tags | grep 'name' | cut -d\" -f4 | head -n1)
git clone -b ${TAG} https://github.com/v2fly/v2ray-core.git && cd v2ray-core

# Build release
ARCHS=( 386 amd64 arm arm64 ppc64le s390x )
ARMS=( 6 7 )
for ARCH in ${ARCHS[@]}; do
    if [ "${ARCH}" = "arm" ]; then
        for ARM in ${ARMS[@]}; do
            echo "Building v2ray-${ARCH}v${ARM}"
            env CGO_ENABLED=0 GOOS=linux GOARCH=${ARCH} GOARM=${ARM} go build -o v2ray -trimpath -ldflags "-s -w" ./main
            env CGO_ENABLED=0 GOOS=linux GOARCH=${ARCH} GOARM=${ARM} go build -o v2ctl -trimpath -ldflags "-s -w" -tags confonly ./infra/control/main
            chmod +x v2ray v2ctl && tar -zvcf ${CUR}/v2ray-${ARCH}v${ARM}.tar.gz v2ray v2ctl && rm -fv v2ray v2ctl
        done
    else
        echo "Building v2ray-${ARCH}"
        env CGO_ENABLED=0 GOOS=linux GOARCH=${ARCH} go build -o v2ray -trimpath -ldflags "-s -w" ./main
        env CGO_ENABLED=0 GOOS=linux GOARCH=${ARCH} go build -o v2ctl -trimpath -ldflags "-s -w" -tags confonly ./infra/control/main
        chmod +x v2ray v2ctl && tar -zvcf ${CUR}/v2ray-${ARCH}.tar.gz v2ray v2ctl && rm -fv v2ray v2ctl
    fi
done
