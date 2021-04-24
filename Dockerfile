FROM alpine:latest AS build

ENV VERSION=1.13
ENV SRC_URL=https://github.com/emikulic/darkhttpd/archive/refs/tags/v${VERSION}.tar.gz \
    SRC_SHA256SUM=1d88c395ac79ca9365aa5af71afe4ad136a4ed45099ca398168d4a2014dc0fc2

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
  -mindirect-branch=thunk                 \
  -mfunction-return=thunk                 \
"

WORKDIR /darkhttpd/build

# Download source tarball
RUN { \
  set -e ; \
  wget "${SRC_URL}" ; \
  if [[ "$SRC_SHA256SUM" != "$(sha256sum "v${VERSION}.tar.gz" | cut -c0-64 -)" ]]; then \
    echo -e '\n\n*** ERROR: SOURCE FAILED INTEGRITY CHECK! ***\n\n' ; \
    exit 1 ; \
  fi ; \
  tar -xzf "v${VERSION}.tar.gz" ; \
  apk --no-cache add gcc musl-dev ; \
  gcc ${CFLAGS} -static -o ../darkhttpd "darkhttpd-${VERSION}/darkhttpd.c" ; \
  rm -r /darkhttpd/build ; \
  apk del gcc musl-dev ; \
}

FROM scratch

ARG VCS_REF
ARG BUILD_DATE

LABEL org.label-schema.schema-version="1.13" \
      org.label-schema.description="Serve static files with statically-linked darkhttpd." \
      org.label-schema.name="kugland/darkhttpd" \
      org.label-schema.url="https://hub.docker.com/r/kugland/darkhttpd" \
      org.label-schema.vcs-url="https://github.com/kugland/docker-darkhttpd" \
      org.label-schema.build-date=$BUILD_DATE \
      org.label-schema.vcs-ref=$VCS_REF

VOLUME [ "/www" ]

EXPOSE 80

COPY --chown=0:0 [ "./passwd", "./group", "./mime.types", "/etc/" ]
COPY --chown=0:0 --from=build /darkhttpd/darkhttpd /bin/darkhttpd

ENTRYPOINT [ "/bin/darkhttpd" ]

CMD [ "/www", "--chroot", "--port", "80", "--uid", "nobody", "--gid", "nobody", "--no-server-id", "--no-listing", "--mimetypes", "/etc/mime.types" ]
