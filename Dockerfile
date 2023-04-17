FROM alpine:3.15

RUN apk add --no-cache zip tar sudo alpine-sdk coreutils cmake elixir \
  && adduser -G abuild -g "Alpine Package Builder" -s /bin/ash -D builder \
  && echo "builder ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

COPY . /var/lib/pakman

WORKDIR /var/lib/pakman

RUN mix local.rebar --force
RUN mix local.hex --force
RUN mix deps.get
RUN mix escript.build

USER builder

ENTRYPOINT [ "/var/lib/pakman/bin/pakman" ]