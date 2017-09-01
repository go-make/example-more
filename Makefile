#------------------------------------------------
#
#	setup environment
#
#------------------------------------------------

export GOPATH:=$(realpath $(shell pwd)/../../../..)

#------------------------------------------------
#
#	standard rules
#
#------------------------------------------------

# The first target defined is the default if no target is
# specified on the command line.  Make sure this doesn't
# take too long to run, so that people will run it on every
# build.
.PHONY: fast
fast: build coverage-short lint-fast

# Also define the "full fat" rule that does everything
.PHONY: all build
all: build coverage lint-full

#
#  See https://gopkg.in/make.v4 for a list of
#  versions and http://gopkg.in for more info.
#
GOMAKE:=gopkg.in/make.v4
-include $(GOPATH)/src/$(GOMAKE)/batteries.mk
-include $(GOPATH)/src/$(GOMAKE)/pkg/proto/protobuf-gogo.mk
-include $(GOPATH)/src/$(GOMAKE)/pkg/proto/protobuf-cs.mk
-include $(GOPATH)/src/$(GOMAKE)/pkg/proto/protobuf-py.mk
$(GOPATH)/src/$(GOMAKE)/%:
	go get $(GOMAKE)/...

#------------------------------------------------
#
#	now to actually build stuff...
#
#------------------------------------------------

# first some protobuf definitions

PROTO_FILES:=\
	helloworld/helloworld.proto

GENERATED_GRPC_GO:=$(PROTO_FILES:.proto=.pb.go)
GENERATED_GRPC_CS:=$(PROTO_FILES:.proto=.pb.cs)
GENERATED_GRPC_PY:=$(PROTO_FILES:.proto=_pb2.py)

GENERATED_GRPC:=\
	$(GENERATED_GRPC_GO) \
	$(GENERATED_GRPC_CS) \
	$(GENERATED_GRPC_PY)

# uncomment the following lines to use gogo-proto - see https://github.com/gogo/protobuf
#
# $(GENERATED_GRPC_GO): $(PROTOC_GEN_GOFAST)
# $(GENERATED_GRPC_GO): PROTOC_GO_OUT=--gofast_out=$(PROTOC_PARAMS):$(dir $@)

$(GENERATED_GRPC_PY): $(GRPC_PYTHON_TOOLS)
$(GENERATED_GRPC_CS): $(GRPC_CSHARP_PLUGIN)

clobber::
	rm -f $(GENERATED_GRPC)

# then the binaries

BASENAME_BINARY:=\
	example-multi

BUILD_BINARIES:=\
	$(BASENAME_BINARY).exe \
	$(BASENAME_BINARY).mac \
	$(BASENAME_BINARY).linux

build: $(BUILD_BINARIES) docker-build

%.exe: GOOS=windows
%.mac: GOOS=darwin
%.linux: GOOS=linux

.PHONY: $(BUILD_BINARIES)
$(BUILD_BINARIES): vendor $(GENERATED_GRPC) $(CMD_LINKFLAGS)
	$(call PROMPT,Building $@)
	GOOS=$(GOOS) CGO_ENABLED=0 $(GO) build -o $@

clean::
	rm -f $(BUILD_BINARIES)

#------------------------------------------------
#
#	docker support
#
#------------------------------------------------

# the dockerfile needs some stuff build/downloaded before the image is built
docker-build: ca-bundle.crt $(BASENAME_BINARY).linux

clobber::
	rm -f ca-bundle.crt

DOCKER_ORGANISATION:=go-make

GOMAKE_DOCKER:=gopkg.in/go-make/docker.v0
-include $(GOPATH)/src/$(GOMAKE_DOCKER)/Makefile
$(GOPATH)/src/$(GOMAKE_DOCKER)/%:
	go get $(GOMAKE_DOCKER)/...

