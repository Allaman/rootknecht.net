ARG ARCH=
FROM ${ARCH}alpine:3.17 as builder

# config
ENV HUGO_VERSION=0.107.0

ARG TARGETOS
ARG TARGETARCH

RUN wget --quiet -O - https://github.com/gohugoio/hugo/releases/download/v${HUGO_VERSION}/hugo_extended_${HUGO_VERSION}_${TARGETOS}-${TARGETARCH}.tar.gz | tar -xz -C /tmp \
    && mv /tmp/hugo /usr/local/bin/ \
    && rm -rf /tmp/*

# libc dependencies
RUN apk add --update libc6-compat libstdc++

RUN mkdir /src
WORKDIR /src

COPY . .

RUN hugo --minify


FROM caddy:2.6-alpine as page

COPY --from=builder /src/public/ /usr/share/caddy/

EXPOSE 1313

CMD ["caddy", "file-server", "--root", "/usr/share/caddy", "--listen", ":1313"]
