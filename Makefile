DEBIAN_ARCH := amd64
DEBIAN_VERSION := jessie
DOCKER_NAME := venenux/venenuxdock-$(DEBIAN_VERSION)

all: clean build test

full: clean build test push

build:
	shellcheck -s ksh ./build-archived-debian-image.sh
	./build-archived-debian-image.sh $(DEBIAN_VERSION) $(DOCKER_NAME) $(DEBIAN_ARCH)

test: build
	docker run $(DOCKER_NAME):$(DEBIAN_ARCH) -c 'echo `cat /etc/os-version.txt` ok'

push:
	docker push $(DOCKER_NAME):$(DEBIAN_ARCH)

clean:
	docker image prune -a -f && docker rmi -f $(DOCKER_NAME):$(DEBIAN_ARCH)