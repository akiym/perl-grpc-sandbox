#!/bin/bash
set -eu

protoc \
    -Ithird_party/gapic-showcase/schema/api-common-protos \
    -Ithird_party/gapic-showcase/schema \
    --perl-gpd_out=package=GrpcSandbox.PB:lib \
    --perl-gpd_opt=client_services=grpc_xs \
    third_party/gapic-showcase/schema/google/showcase/v1beta1/echo.proto \
    $(find third_party/gapic-showcase/schema/api-common-protos/google -name '*.proto') \
    $(find /usr/local/include/google -name '*.proto')
