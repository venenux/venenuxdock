# VenenuX Debian Docker images (older and newers)

Build scripts for making docker VenenuX Debian images uploaded to docker hub

VenenuX is a debian based distro, more focused on mantain older versions and compatibility support!

## Introduction

Docker consists of readable and writable layers on top of (prevous) multiple 
read only layers. The instructions in Dockerfiles are representations of those 
layers, are deltas of previous layers (similar to git commits).

Containers are buch of those layers in a read-write layer, which has a lifespan 
associated with the container.

VenenuX dockers containers are clean layer of base Debian in minimalist install, 
with no recommends activated neither extra packages as minimal base, so will act 
most like Alpine ones, serving as base for others dockers layers with flavoured 
packages objetives like php, node, compilers or etc.

#### about this repository

This script will build releases of debian docker images, olders or newers, 
this means that at 2024 it can build docker images of jessie, stretch, buster, 
but not wheezy, etch, jessie, this because of bug [#875981](https://bugs.debian.org/cgi-bin/bugreport.cgi?bug=875981), 
for that you must boot your kernel with `vsyscall=emulate` parameter!

#### security support

Please  be  aware of  that  since Wheezy images, images, although legacy, 
it still has extended security support through Freexian's ExLTS service, 
on specific (mostly server oriented) packages, for more information check 
the page at [oficial Debian Extended Long Term Support wiki page](https://wiki.debian.org/LTS/Extended).

#### repository packages

These docker images that will be produced will only be valid in their own context, 
based on the previous security paragraph, meaning that older versions use the 
repositories from http://archive.debian.org including debian/security but with 
packages only until the extended support date. Those images just works!

## Status of images

Currently, the following images will [be on Docker hub venenuxdock https://hub.docker.com/r/venenux/](https://hub.docker.com/r/venenux/):

- [ ] Debian 4 Etch    (~2007 (Link to [debian.org](https://www.debian.org/releases/etch/))) Error due kernel bug (use vsyscall:emulate)
- [ ] Debian 5 Lenny   (~2009 (Link to [debian.org](https://www.debian.org/releases/lenny/))) Error due fstab bug (use vsyscall:emulate)
- [ ] Debian 6 Squeeze (~2011 (Link to [debian.org](https://www.debian.org/releases/squeeze/))) Error due kernel bug (use vsyscall:emulate)
- [ ] Debian 7 Wheezy  (~2016 (Link to [debian.org](https://www.debian.org/releases/wheezy/))) Error due kernel bug (use vsyscall:emulate)
- [x] Debian 8 Jessie  (~2015 (Link to [debian.org](https://www.debian.org/releases/jessie/))) Builds fine **venenux/debian-jessie-base:<arch>**
- [x] Debian 9 stretch (~2017 (Link to [debian.org](https://www.debian.org/releases/stretch/))) Builds fine **venenux/debian-stretch-base:<arch>**

Debian VenenuX new generaton images are not build until release comes into oldstable

- [ ] Debian 10 buster (~2020 (Link to [debian.org](https://www.debian.org/releases/buster/))) Builds fine **venenux/debian-buster-base:<arch>**
- [ ] Debian 11 bullseye (~2022 (Link to [debian.org](https://www.debian.org/releases/bullseye/))) Builds fine **venenux/debian-bullseye-base:<arch>**

## Usage

To use the VenenuX images just requested from docker hub:
`docker pull venenux/debian-stretch:i386` and later 
`docker run --rm -it venenux/debian-stretch:i386`
the images has by default the ENTRYPOINT of bash shell to run!

#### Local builds

To build your own new image inside just clone the repo and build it:

```
apt-get install docker.io shellcheck ca-certificates cgroupfs-mount git xz-utils

mkdir ~/Devel && cd Devel && git clone https://codeberg.org/venenux/venenuxdock && cd ~/Devel/venenuxdock

make
```

By default will build a jessie image with native arch! **We do not support external 
docker install or non debian packaged software!** be adware of!

This will produce the docker images listed previously!

#### Options

There is no mandatory argument, but as minimal `DEBIAN_VERSION` is recommended, 
must be parsed `target` if you wants to clean the environment or build to make 
the images!

`make [DEBIAN_VERSION=<dist>] [DEBIAN_STAGE1=<basedist>] [DEBIAN_ARCH=<arch>] [target]]`

* DEBIAN_VERSION must be parsed if not jessie is default! can be etch, squeeze, wheezy, jessie, etc
* DEBIAN_STAGE1 is optional, if not testing is default! can be stretch, buster and bullseye or testing
* DEBIAN_ARCH can be i386, amd64; for arm it depends: armhf/armel since lenny, aarch64 since jessie
* target can be: clean, build, test and push; push requires you previously login to dockerhub

| arch    | image     | vsyscall? | make build command   |
| ------- | --------- | --------- | ------------ |
| i386    | etch      | needed    | `make DEBIAN_VERSION=etch DEBIAN_STAGE1=stretch DEBIAN_ARCH=i386 build` |
| i386    | lenny     | needed    | `make DEBIAN_VERSION=lenny DEBIAN_STAGE1=stretch DEBIAN_ARCH=i386 build` |
| i386    | squeeze   | needed    | `make DEBIAN_VERSION=squeeze DEBIAN_STAGE1=stretch DEBIAN_ARCH=i386 build` |
| i386    | wheezy    | needed    | `make DEBIAN_VERSION=wheezy DEBIAN_STAGE1=stretch DEBIAN_ARCH=i386 build` |
| amd64   | wheezy    | needed    | `make DEBIAN_VERSION=wheezy DEBIAN_STAGE1=stretch DEBIAN_ARCH=amd64 build` |
| i386    | jessie    | no        | `make DEBIAN_VERSION=jessie DEBIAN_STAGE1=stretch DEBIAN_ARCH=i386 build` |
| amd64   | jessie    | no        | `make DEBIAN_VERSION=jessie DEBIAN_STAGE1=stretch DEBIAN_ARCH=amd64 build` |
| armel   | jessie    | needed    | `make DEBIAN_VERSION=jessie DEBIAN_STAGE1=buster DEBIAN_ARCH=armel build` |
| aarch64 | jessie    | needed    | `make DEBIAN_VERSION=jessie DEBIAN_STAGE1=bullseye DEBIAN_ARCH=aarch64 build` |
| amd64   | stretch   | no        | `make DEBIAN_VERSION=stretch DEBIAN_STAGE1=bullseye DEBIAN_ARCH=amd64 build` |
| i386    | stretch   | no        | `make DEBIAN_VERSION=stretch DEBIAN_STAGE1=buster DEBIAN_ARCH=i386 build` |
| armel   | stretch   | maybe     | `make DEBIAN_VERSION=stretch DEBIAN_STAGE1=bullseye DEBIAN_ARCH=armel build` |
| aarch64 | stretch   | maybe     | `make DEBIAN_VERSION=stretch DEBIAN_STAGE1=bullseye DEBIAN_ARCH=aarch64 build` |

With the simple `make`, only a jessie:native image will be build. All the arguments are optional.

## LICENSE

Originally improved from madworx's old debian images, but he never put a LICENSE file, 
so we are not forced to put references but we just mention it here, the new one is 
**CC-BY-SA-NC over this files and products**.

* (c) 2020 Martin Kjellstrand
* (c) 2023-2024 PICCORO Lenz McKAY

