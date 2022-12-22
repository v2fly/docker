FROM --platform=${TARGETPLATFORM} alpine:latest
LABEL maintainer="V2Fly Community <dev@v2fly.org>"

WORKDIR /root
ARG TARGETPLATFORM
ARG TAG
COPY v2ray.sh /root/v2ray.sh
COPY v4-forward.conf /etc/sysctl.d/v4-forward.conf
COPY rules.v4 /etc/iptables/rules.v4
COPY entrypoint.sh /opt/entrypoint.sh

RUN set -ex \
	&& apk add --no-cache tzdata openssl ca-certificates iptables \
	&& mkdir -p /etc/v2ray /usr/local/share/v2ray /var/log/v2ray \
	&& chmod +x /root/v2ray.sh \
    && chmod +x /opt/entrypoint.sh \
	&& /root/v2ray.sh "${TARGETPLATFORM}" "${TAG}"

ENTRYPOINT ["/opt/entrypoint.sh"]