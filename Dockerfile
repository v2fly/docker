FROM --platform=${TARGETPLATFORM} alpine:latest
LABEL org.opencontainers.image.authors="V2Fly Community <dev@v2fly.org>"

WORKDIR /root
ARG TARGETPLATFORM
ARG TAG
COPY v2ray.sh /root/v2ray.sh

RUN set -ex \
	&& apk add --no-cache ca-certificates openssl tzdata unzip wget \
	&& chmod +x /root/v2ray.sh \
	&& /root/v2ray.sh "${TAG}" "${TARGETPLATFORM}"

CMD [ "/usr/bin/v2ray", "-config", "/etc/v2ray/config.json" ]
