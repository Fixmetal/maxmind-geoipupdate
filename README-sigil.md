# How to build sigil
Sigil is a dependancy of GeoIP in this image. Since it uses [glu](https://github.com/gliderlabs/glu) which necessarly needs docker.sock you have to build it and copy the builded exec.

```
docker run --name glusucks -it --entrypoint ash -v /var/run/docker.sock:/var/run/docker.sock:ro golang:1.15.6-alpine3.12
```

THen:
```
mkdir /app && \
cd /app && \
apk add --no-cache \
      gcc \
      make \
      libc-dev \
      git && \
git clone https://github.com/gliderlabs/sigil.git && \
cd sigil
git checkout tags/v0.4.0 && \
sed -i 's/ARCHITECTURE = amd64/ARCHITECTURE = \$\/(shell uname -m\)/' Makefile && \
make deps && \
glu build linux ./cmd
```

At this time you can get it:

```
docker cp glusucks:/app/sigil/build/Linux/sigil .
```
