FROM alpine:3.10

RUN apk add alpine-sdk elixir \
  && adduser -G abuild -g "Alpine Package Builder" -s /bin/ash -D builder \
  && echo "builder ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

COPY . /var/lib/apkify

WORKDIR /var/lib/apkify
RUN mix escript.build

USER builder

ENTRYPOINT [ "/var/lib/apkify/bin/apkify" ]