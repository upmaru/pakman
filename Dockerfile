FROM alpine:3.10

RUN apk add alpine-sdk elixir

COPY . /var/lib/apkify

WORKDIR /var/lib/apkify
RUN mix escript.build

ENTRYPOINT [ "/var/lib/apkify/bin/apkify" ]