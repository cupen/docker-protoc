FROM golang:1.18.1-bullseye AS build

ARG protoc_version=3.19.4
ARG protoc_url=https://github.com/protocolbuffers/protobuf/releases/download/v${protoc_version}/protoc-${protoc_version}-linux-x86_64.zip
ARG goproxy=direct

# install protoc
RUN apt-get update
RUN apt-get install unzip
ADD ${protoc_url} /protoc_bin/protoc.zip
RUN cd /protoc_bin/ && unzip protoc.zip && rm protoc.zip

# install go code generator.
# https://developers.google.com/protocol-buffers/docs/reference/go/faq
RUN export GOPROXY=${goproxy} \
    && export GOPATH=/gopath/ \
    && mkdir /gopath/ \
    && go install google.golang.org/protobuf/cmd/protoc-gen-go@latest \
    && go install github.com/asynkron/protoactor-go/protobuf/protoc-gen-gograinv2@dev


FROM debian:buster-slim AS runtime
COPY --from=build /protoc_bin/         /usr/
COPY --from=build /gopath/bin/protoc-gen-* /usr/bin/


# install third-party protos
ADD https://raw.githubusercontent.com/asynkron/protoactor-go/dev/actor/actor.proto  /usr/include/github.com/asynkron/protoactor-go/actor/actor.proto
ADD https://raw.githubusercontent.com/asynkron/protoactor-go/dev/remote/remote.proto  /usr/include/github.com/asynkron/protoactor-go/remote/remote.proto
# ADD https://raw.githubusercontent.com/gogo/protobuf/v1.3.2/gogoproto/gogo.proto        /usr/include/github.com/gogo/protobuf/gogoproto/gogo.proto


ENTRYPOINT ["/usr/bin/protoc", "-I=/usr/include"] 
