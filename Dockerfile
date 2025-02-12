FROM docker.io/library/golang:1.20.4-alpine3.17 as builder
RUN apk add --no-cache btrfs-progs-dev lvm2-dev make build-base
WORKDIR /go/src/csi-driver-image
COPY go.mod go.sum ./
RUN go mod download
COPY cmd ./cmd
COPY pkg ./pkg
COPY Makefile ./
RUN make build
RUN make install-util

FROM scratch as install-util
COPY --from=builder /go/src/csi-driver-image/_output/warm-metal-csi-image-install /

FROM alpine:3.17
RUN apk add --no-cache btrfs-progs-dev lvm2-dev
WORKDIR /
COPY --from=builder /go/src/csi-driver-image/_output/csi-image-plugin /usr/bin/
ENTRYPOINT ["csi-image-plugin"]
