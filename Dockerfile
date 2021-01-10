FROM golang:1.15.6-alpine3.12 AS geoip

LABEL maintainer="Takeru Sato <type.in.type@gmail.com>"
LABEL maintainer2="Simone M. Zucchi <simone.zucchi@gmail.com>"

ARG CURL_VER=7.69.1-r3
ARG GCC_VER=9.3.0-r2
ARG MAKE_VER=4.3-r0
ARG LIBC_DEV_VER=0.7.2-r3
ARG GIT_VER=2.26.2-r0

ARG GEOIP_UPDATE_URL=https://github.com/maxmind/geoipupdate.git
ARG GEOIP_UPDATE_VER=v4.6.0

# https://github.com/golang/go/wiki/GoArm
ENV GOARCH=arm64

WORKDIR /app

RUN apk add --no-cache \
      gcc=${GCC_VER} \
      make=${MAKE_VER} \
      libc-dev=${LIBC_DEV_VER} \
      git=${GIT_VER} && \
    git clone ${GEOIP_UPDATE_URL} && \
    git clone ${SIGIL_URL}

WORKDIR /app/geoipupdate

RUN git checkout tags/${GEOIP_UPDATE_VER} && \
    make build/geoipupdate && \
    chmod +x build/geoipupdate

########## My Image
FROM alpine:3.12 AS image

ARG CA_CERTIFICATES_VER=20191127-r4
ARG TZDATA_VER=2020c-r1

ENV GEOIP_CONF_FILE /usr/local/etc/GeoIP.conf
ENV GEOIP_DB_DIR    /usr/share/GeoIP
ENV SCHEDULE        "55 20 * * *"

COPY GeoIP.conf.tmpl ${GEOIP_CONF_FILE}.tmpl
COPY run-geoipupdate /usr/local/bin/run-geoipupdate
COPY run /usr/local/bin/
COPY --from=builder /app/geoipupdate/build/geoipupdate /usr/local/bin/
COPY sigil /usr/local/bin/

RUN apk add --no-cache \
      ca-certificates=${CA_CERTIFICATES_VER} && \
    apk --no-cache add \
      tzdata=${TZDATA_VER} && \
    cp /usr/share/zoneinfo/Europe/Rome /etc/localtime && \
    echo "Europe/Rome" > /etc/timezone && \
    apk del tzdata

ENTRYPOINT [ "run" ]
