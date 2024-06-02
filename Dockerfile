FROM --platform=${BUILDPLATFORM:-linux/amd64} golang:1.16 as builder
WORKDIR /workdir
# Get the sources
COPY .tags /tmp/
RUN git clone --depth 1 --branch "v$(sed 's/,.*//' /tmp/.tags)" https://github.com/mittwald/kubernetes-secret-generator.git .

ARG TARGETPLATFORM
ARG BUILDPLATFORM
ARG TARGETOS
ARG TARGETARCH

# Build
RUN CGO_ENABLED=0 GOOS=${TARGETOS} GOARCH=${TARGETARCH} go build -a -o /manager ./cmd/manager/main.go

FROM --platform=${TARGETPLATFORM:-linux/amd64} gcr.io/distroless/static:nonroot
WORKDIR /
COPY --from=builder /manager .
USER 65532:65532

ENTRYPOINT ["/manager"]