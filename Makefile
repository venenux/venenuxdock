DOCKER_NAME := venenux/venenuxdock

all: build test

build:
	./build-archived-debian-image.sh $(DEBIAN_VERSION) $(DOCKER_NAME) $(DEBIAN_ARCH)

test:
	shellcheck -s ksh ./build-archived-debian-image.sh
	docker run $(DOCKER_NAME):$(DEBIAN_VERSION) -c 'echo `cat /etc/os-version.txt` ok'

push: test
	docker push $(DOCKER_NAME):$(DEBIAN_VERSION)
