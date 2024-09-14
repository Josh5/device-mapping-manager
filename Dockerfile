# syntax=docker/dockerfile:1

FROM golang:1.19

ENV DEBIAN_FRONTEND=noninteractive

WORKDIR /go/src/github.com/allfro/device-volume-driver

COPY . .

RUN CGO_ENABLED=1 GOOS=linux go build -ldflags "-linkmode external -extldflags -static" -o /dvd

FROM docker:latest

RUN apk add bash

WORKDIR /

COPY --from=0 /dvd /dvd
COPY /entrypoint.sh /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
