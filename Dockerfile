FROM alpine:3.10

RUN apk add alpine-sdk elixir

COPY . /var/lib/apkify

RUN adduser -G abuild -g "Alpine Package Builder" -s /bin/sh -D builder
RUN echo "builder ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

WORKDIR /var/lib/apkify
RUN mix escript.build

ENTRYPOINT [ "/var/lib/apkify/bin/apkify" ]