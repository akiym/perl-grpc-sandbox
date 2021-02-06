# syntax = docker/dockerfile:1.2
FROM perl:5.32

RUN apt-get update && apt-get install -y \
    libgrpc-dev \
    libprotobuf-dev \
    libprotoc-dev \
  && rm -rf /var/lib/apt/lists/*

ARG PROTOC_VERSION=3.14.0

RUN curl -sSLO https://github.com/protocolbuffers/protobuf/releases/download/v${PROTOC_VERSION}/protoc-${PROTOC_VERSION}-linux-x86_64.zip && \
    unzip -q protoc-${PROTOC_VERSION}-linux-x86_64.zip -d protoc && \
    mv protoc/bin/* /usr/local/bin/ && \
    mv protoc/include/* /usr/local/include/ && \
    rm -rf protoc-${PROTOC_VERSION}-linux-x86_64.zip protoc

RUN --mount=type=cache,target=/root/.cpanm cpanm -n App::cpm Carton

WORKDIR /app

COPY cpanfile cpanfile.snapshot ./

RUN --mount=type=cache,target=/root/.cpm --mount=type=cache,target=/root/.perl-cpm cpm install

COPY . ./

ENV PERL5LIB=/app/lib:/app/local/lib/perl5
ENV PATH=/app/local/bin:$PATH
