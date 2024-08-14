# https://hub.docker.com/_/golang
FROM --platform=$BUILDPLATFORM golang:1.23-bookworm as vscode

ARG TARGETPLATFORM
ARG BUILDPLATFORM
ARG TARGETOS
ARG TARGETARCH
ENV TZ Asia/Tokyo
WORKDIR /workspace
COPY . /workspace
RUN  ln -sf /usr/share/zoneinfo/Asia/Tokyo /etc/localtime

FROM --platform=$BUILDPLATFORM golang:1.23-bookworm as build
ARG TARGETPLATFORM
ARG BUILDPLATFORM
ARG TARGETOS
ARG TARGETARCH
WORKDIR /workspace
COPY . /workspace
RUN CGO_ENABLED=0 GOOS=${TARGETOS} GOARCH=${TARGETARCH} go build -o app cmd/main.go

FROM --platform=$BUILDPLATFORM public.ecr.aws/lambda/provided:al2023
COPY --chown=${USERNAME}:${GROUPNAME} --from=build /workspace/app /app
ENV TZ Asia/Tokyo
USER ${USERNAME}
ENTRYPOINT [ "/app" ]
