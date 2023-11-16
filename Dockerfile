FROM alpine:latest AS build

ARG VERSION=1.14

# Hardening GCC opts taken from these sources:
# https://developers.redhat.com/blog/2018/03/21/compiler-and-linker-flags-gcc/
# https://security.stackexchange.com/q/24444/204684
ENV CFLAGS=" \
  -static                                 \
  -O2                                     \
  -flto                                   \
  -D_FORTIFY_SOURCE=2                     \
  -fstack-clash-protection                \
  -fstack-protector-strong                \
  -pipe                                   \
  -Wall                                   \
  -Werror=format-security                 \
  -Werror=implicit-function-declaration   \
  -Wl,-z,defs                             \
  -Wl,-z,now                              \
  -Wl,-z,relro                            \
  -Wl,-z,noexecstack                      \
"

WORKDIR /darkhttpd/build

COPY ./v${VERSION}.tar.gz ./

# Download source tarball
RUN { \
  set -eux ; \
  tar -xzf "v${VERSION}.tar.gz" ; \
  apk --no-cache add gcc musl-dev ; \
  gcc ${CFLAGS} -static -o ../darkhttpd "darkhttpd-${VERSION}/darkhttpd.c" ; \
  rm -r /darkhttpd/build ; \
  apk del gcc musl-dev ; \
}


FROM scratch

LABEL org.opencontainers.image.title="kugland/darkhttpd" \
      org.opencontainers.image.description="Serve static files with statically-linked darkhttpd." \
      org.opencontainers.image.version="1.13" \
      org.opencontainers.image.url="https://hub.docker.com/r/kugland/darkhttpd" \
      org.opencontainers.image.source="https://github.com/kugland/docker-darkhttpd"

VOLUME [ "/www" ]

EXPOSE 80

COPY --chown=0:0 [ "./passwd", "./group", "./mime.types", "/etc/" ]
COPY --chown=0:0 --from=build /darkhttpd/darkhttpd /bin/darkhttpd

ENTRYPOINT [ "/bin/darkhttpd" ]

CMD [ "/www", "--chroot", "--port", "80", "--uid", "nobody", "--gid", "nobody", "--no-server-id", "--no-listing", "--mimetypes", "/etc/mime.types" ]
