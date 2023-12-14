DOCKER_NAME := venenux/venenuxdock
DEBIAN_ARCH := amd64

all: build test

build:
	shellcheck -s ksh ./build-archived-debian-image.sh
	./build-archived-debian-image.sh $(DEBIAN_VERSION) $(DOCKER_NAME)

test: build
	docker run $(DOCKER_NAME):$(DEBIAN_VERSION) -c 'echo `cat /etc/os-version.txt` ok'

push: test
	docker push $(DOCKER_NAME):$(DEBIAN_VERSION)
