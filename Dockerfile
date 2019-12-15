FROM alpine:3.10

RUN apk add alpine-sdk erlang

COPY apkify /apkify

ENTRYPOINT [ "/apkify" ]