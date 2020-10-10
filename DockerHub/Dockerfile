FROM alpine:latest
LABEL maintainer "V2Fly Community <admin@v2fly.org>"

WORKDIR /root
ARG TARGETVARIANT
ARG TARGETARCH
COPY v2ray-${TARGETARCH}${TARGETVARIANT}.tar.gz /usr/bin/v2ray.tar.gz

RUN set -ex \
	&& apk add --no-cache tzdata ca-certificates \
	&& mkdir -p /etc/v2ray/ /var/log/v2ray \
	&& tar -zxvf /usr/bin/v2ray.tar.gz -C /usr/bin \
	&& rm -fv /usr/bin/v2ray.tar.gz \
	&& wget -O /etc/v2ray/config.json https://raw.githubusercontent.com/v2fly/v2ray-core/master/release/config/config.json \
	&& wget -O /usr/bin/geosite.dat https://github.com/v2fly/domain-list-community/releases/latest/download/dlc.dat \
	&& wget -O /usr/bin/geoip.dat https://github.com/v2fly/geoip/releases/latest/download/geoip.dat

VOLUME /etc/v2ray
ENV TZ=Asia/Shanghai
CMD [ "/usr/bin/v2ray", "-config", "/etc/v2ray/config.json" ]
