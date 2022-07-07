FROM golang:1.18.3-bullseye AS build

ARG protoc_version=3.17.3
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
    && go install google.golang.org/protobuf/cmd/protoc-gen-go@latest


# install go code generator(compatibility).
RUN git clone https://github.com/cupen/protoactor-go -b master --depth=1
RUN export GOPROXY=${goproxy} \
    && export GOPATH=/gopath/ \
    && cd ./protoactor-go/protobuf/protoc-gen-gograinv2 \
    && mkdir -p /root/go/bin/ \
    && make install \
    && go install github.com/gogo/protobuf/protoc-gen-gogoslick@v1.3.2



FROM debian:buster-slim AS runtime
COPY --from=build /protoc_bin/         /usr/
COPY --from=build /gopath/bin/protoc-gen-* /usr/bin/


# install third-party protos
ADD https://raw.githubusercontent.com/asynkron/protoactor-go/dev/actor/actor.proto    /usr/include/github.com/asynkron/protoactor-go/actor/actor.proto
ADD https://raw.githubusercontent.com/asynkron/protoactor-go/dev/remote/remote.proto  /usr/include/github.com/asynkron/protoactor-go/remote/remote.proto

# install third-party protos (compatibility)
ADD https://raw.githubusercontent.com/asynkron/protoactor-go/dev/actor/actor.proto    /usr/include/github.com/AsynkronIT/protoactor-go/actor/actor.proto
ADD https://raw.githubusercontent.com/asynkron/protoactor-go/dev/actor/actor.proto    /usr/include/github.com/AsynkronIT/protoactor-go/actor/protos.proto
ADD https://raw.githubusercontent.com/asynkron/protoactor-go/dev/remote/remote.proto  /usr/include/github.com/AsunkronIT/protoactor-go/remote/remote.proto
ADD https://raw.githubusercontent.com/gogo/protobuf/v1.3.2/gogoproto/gogo.proto       /usr/include/github.com/gogo/protobuf/gogoproto/gogo.proto

ENTRYPOINT ["/usr/bin/protoc", "-I=/usr/include"] 
