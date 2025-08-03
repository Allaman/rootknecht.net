ARG ARCH=
FROM ${ARCH}alpine:3.18 AS builder

# config
ENV HUGO_VERSION=0.112.0

ARG TARGETOS
ARG TARGETARCH

RUN wget --quiet -O - https://github.com/gohugoio/hugo/releases/download/v${HUGO_VERSION}/hugo_extended_${HUGO_VERSION}_${TARGETOS}-${TARGETARCH}.tar.gz | tar -xz -C /tmp \
    && mv /tmp/hugo /usr/local/bin/ \
    && rm -rf /tmp/*

# dependencies
RUN apk add --update libc6-compat libstdc++ gcompat

RUN mkdir /src
WORKDIR /src

COPY . .

RUN hugo --minify


FROM caddy:2.6-alpine AS page

COPY --from=builder /src/public/ /usr/share/caddy/

EXPOSE 1313

CMD ["caddy", "file-server", "--root", "/usr/share/caddy", "--listen", ":1313"]
