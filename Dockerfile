FROM alpine:3.10

RUN apk add alpine-sdk erlang

COPY bin/apkify /usr/local/bin/apkify

ENTRYPOINT [ "/usr/local/bin/apkify" ]