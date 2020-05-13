FROM alpine

LABEL maintainer "V2Fly Community <vcptr@v2fly.org>"

ARG TARGETPLATFORM
ARG TARGETOS
ARG TARGETARCH
ARG TARGETVARIANT

ARG BUILDPLATFORM
ARG BUILDOS
ARG BUILDARCH
ARG BUILDVARIANT

RUN echo "Image target platform details :: "
RUN echo "TARGETPLATFORM    : $TARGETPLATFORM"
RUN echo "TARGETOS          : $TARGETOS"
RUN echo "TARGETARCH        : $TARGETARCH"
RUN echo "TARGETVARIANT     : $TARGETVARIANT"

RUN echo "Image build platform details :: "
RUN echo "BUILDPLATFORM     : $BUILDPLATFORM"
RUN echo "BUILDOS           : $BUILDOS"
RUN echo "BUILDARCH         : $BUILDARCH"
RUN echo "BUILDVARIANT      : $BUILDVARIANT"


COPY v2ray-${TARGETARCH}${TARGETVARIANT}.tgz /tmp/v2ray.tgz
RUN apk update && apk add ca-certificates && \
    mkdir -p /usr/bin/v2ray && \
    tar xvfz /tmp/v2ray.tgz -C /usr/bin/v2ray

ENV PATH /usr/bin/v2ray:$PATH
CMD ["v2ray", "-config=/etc/v2ray/config.json"]
