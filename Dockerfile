FROM alpine:3.10

RUN apk add alpine-sdk elixir

RUN useradd --system -s /sbin/nologin builder

COPY . /var/lib/apkify

WORKDIR /var/lib/apkify
RUN mix escript.build

USER builder

ENTRYPOINT [ "/var/lib/apkify/bin/apkify" ]