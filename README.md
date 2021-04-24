# docker-httpd

![Docker Cloud Build Status](https://img.shields.io/docker/cloud/build/kugland/darkhttpd) ![Docker Image Size (tag)](https://img.shields.io/docker/image-size/kugland/darkhttpd/latest) ![GitHub](https://img.shields.io/github/license/kugland/docker-darkhttpd)

This image uses [`darkhttpd`](https://unix4lyfe.org/darkhttpd/) to serve static files. This image
is built `FROM scratch` and the `darkhttpd` binary is statically linked, so as to make the image
very small. To use it, just mount your files (preferentially in read-only mode) into `/www` and,
if you like, expose port 80.

## Features

- Image has less than 300kb.
- Uses [mimetype map from nginx](http://hg.nginx.org/nginx/raw-file/default/conf/mime.types).
- Runs as `nobody:nobody` (65534:65534).
- Runs in chroot.
- Directory listing disabled.
- Server ID disabled.
- Hardened binary.

## Example `docker-compose.yml`

```yml
version: '3.8'

services:
  www:
    image: kugland/darkhttpd:latest
    volumes:
      - "./www:/www:ro"
    ports:
      - "127.0.0.1:8000:80"
```

## Credits

This image was created by [André Kugland](https://github.com/kugland/).
