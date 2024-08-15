# https://hub.docker.com/_/golang
FROM --platform=$BUILDPLATFORM golang:1.23-bookworm as vscode

ARG TARGETPLATFORM
ARG BUILDPLATFORM
ARG TARGETOS
ARG TARGETARCH
ARG REGION=ap-northeast-1
ENV REGION=${REGION}
ARG TZ=UTC
ENV TZ=${TZ}
WORKDIR /workspace
COPY . /workspace
RUN apt-get update && apt-get install -y unzip && \
    wget https://github.com/mauricioabreu/golings/archive/refs/heads/main.zip && \
    unzip main.zip && \
    rm main.zip

FROM --platform=$BUILDPLATFORM golang:1.23-bookworm as build
ARG TARGETPLATFORM
ARG BUILDPLATFORM
ARG TARGETOS
ARG TARGETARCH
ARG REGION=ap-northeast-1
ENV REGION=${REGION}
WORKDIR /workspace
COPY . /workspace
RUN CGO_ENABLED=0 GOOS=${TARGETOS} GOARCH=${TARGETARCH} go build -o app main.go && \
    apt-get update && apt-get install -y unzip wget && \
    wget https://github.com/mauricioabreu/golings/archive/refs/heads/main.zip && \
    unzip main.zip && \
    rm main.zip

FROM --platform=linux/amd64 public.ecr.aws/lambda/provided:al2023
ARG LAYER_URL
ARG REGION=ap-northeast-1
ENV REGION=${REGION}
ARG TZ=UTC
ENV TZ=${TZ}
WORKDIR /workspace
COPY --chown=${USERNAME}:${GROUPNAME} --chmod=555 data /opt
COPY --chown=${USERNAME}:${GROUPNAME} --from=build /workspace/app /workspace/app
COPY --chown=${USERNAME}:${GROUPNAME} --from=build /workspace/golings-main /workspace/golings-main
USER ${USERNAME}
ENTRYPOINT [ "./app" ]
