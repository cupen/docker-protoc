FROM golang:1.16.6-buster AS build

ARG protoc_version=3.17.3
ARG protoc_url=https://github.com/protocolbuffers/protobuf/releases/download/v${protoc_version}/protoc-${protoc_version}-linux-x86_64.zip
ADD ${protoc_url} /google-protoc/protoc.zip
RUN apt-get update
RUN apt-get install unzip
RUN cd /google-protoc/ && unzip protoc.zip && ls -ahl


FROM golang:1.16.6-buster AS runtime
ARG goproxy=direct
COPY --from=build /google-protoc/ /usr/
RUN /usr/bin/protoc && ls -ahl /usr/include/google

# install third-party protos
## gogo/protobuf
## usage: import "github.com/gogo/protobuf/gogoproto/gogo.proto";
ADD https://raw.githubusercontent.com/gogo/protobuf/v1.3.2/gogoproto/gogo.proto        /usr/include/github.com/gogo/protobuf/gogoproto/gogo.proto

## AsynkronIT/protoactor-go
## usage: import "github.com/AsynkronIT/protoactor-go/actor/protos.proto";
ADD https://raw.githubusercontent.com/AsynkronIT/protoactor-go/dev/actor/protos.proto  /usr/include/github.com/AsynkronIT/protoactor-go/actor/protos.proto
# NOTE: You don't need to use protos of remote/cluster directly
ADD https://raw.githubusercontent.com/AsynkronIT/protoactor-go/dev/remote/protos.proto  /usr/include/github.com/AsynkronIT/protoactor-go/remote/protos.proto
ADD https://raw.githubusercontent.com/AsynkronIT/protoactor-go/dev/cluster/protos.proto  /usr/include/github.com/AsynkronIT/protoactor-go/cluster/protos.proto


# install go code generator.
RUN export GOPROXY=${goproxy} \
    && go get github.com/gogo/protobuf@v1.3.2 \
    && go get github.com/gogo/protobuf/protoc-gen-gogoslick@v1.2.1 \
    && go get github.com/AsynkronIT/protoactor-go/protobuf/protoc-gen-gograin \
    && go get github.com/AsynkronIT/protoactor-go/protobuf/protoc-gen-gograinv2

ENTRYPOINT ["/usr/bin/protoc", "-I=/usr/include"] 
