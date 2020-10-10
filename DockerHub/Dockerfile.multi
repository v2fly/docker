FROM alpine:latest
LABEL maintainer "V2Fly Community <dev@v2fly.org>"

WORKDIR /root
ARG TARGETVARIANT
ARG TARGETARCH
COPY v2ray-${TARGETARCH}${TARGETVARIANT}.tar.gz /usr/bin/v2ray.tar.gz
COPY geoip.dat /usr/bin/geoip.dat
COPY geosite.dat /usr/bin/geosite.dat
COPY config.json /etc/v2ray/config.json

RUN set -ex \
	&& apk add --no-cache tzdata ca-certificates \
	&& mkdir -p /etc/v2ray/ /var/log/v2ray \
	&& tar -zxvf /usr/bin/v2ray.tar.gz -C /usr/bin \
	&& rm -fv /usr/bin/v2ray.tar.gz

VOLUME /etc/v2ray
CMD [ "/usr/bin/v2ray", "-config", "/etc/v2ray/config.json" ]