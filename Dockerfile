FROM alpine:latest
LABEL maintainer "V2Fly Community <dev@v2fly.org>"

WORKDIR /root
ARG TARGETVARIANT
ARG TARGETARCH
COPY v2ray-${TARGETARCH}${TARGETVARIANT}.tar.gz /usr/bin/v2ray.tar.gz
RUN mkdir -p /usr/local/share/v2ray
COPY geoip.dat /usr/local/share/v2ray/geoip.dat
COPY geosite.dat /usr/local/share/v2ray/geosite.dat
COPY config.json /etc/v2ray/config.json

RUN set -ex \
	&& apk add --no-cache tzdata ca-certificates \
	&& mkdir -p /etc/v2ray/ /var/log/v2ray \
	&& tar -zxvf /usr/bin/v2ray.tar.gz -C /usr/bin \
	&& rm -fv /usr/bin/v2ray.tar.gz

VOLUME /etc/v2ray
CMD [ "/usr/bin/v2ray", "-config", "/etc/v2ray/config.json" ]