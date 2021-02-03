FROM alpine:3.11

RUN apk add sudo alpine-sdk elixir coreutils cmake \
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