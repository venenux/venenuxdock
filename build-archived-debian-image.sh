#!/bin/bash

set -eE
set -o pipefail

if ! command -v docker > /dev/null; then
    echo "[ERROR] Docker is not installed, cannot continue! make apt-get install docker.io"
    exit 1
fi

if ! command -v shellcheck > /dev/null; then
    echo "[ERROR] Shellcheck is not installed, cannot continue! make apt-get install shellcheck"
    exit 1
fi

if ! command -v dpkg-architecture > /dev/null; then
    echo "[ERROR] dpkg-dev is not installed, cannot continue! make apt-get install dpkg-dev"
    exit 1
fi

export DIST=${1:-jessie}
if [ -n "$2" ]; then export DOCKER_NAME=${2}; else export DOCKER_NAME=venenux/venenuxdock-${DIST}; fi
export DEBIAN_MIRROR=${DEBIAN_MIRROR:="http://archive.debian.org/debian/"}
DEBIAN_ARCH="$(dpkg-architecture -qDEB_BUILD_ARCH)"
if [ -n "$3" ]; then export DEBIAN_ARCH=${3}; else export DEBIAN_ARCH=${DEBIAN_ARCH}; fi
export DEBIAN_STAGE1=${4:-testing}

# Check if rebuild is needed:
LASTMOD=$(curl -sI "${DEBIAN_MIRROR}/dists/${DIST}/main/binary-${DEBIAN_ARCH}/Packages.gz" | \
                 sed -n 's#^last-modified: *##pi' | \
                 sed -e 's#[^a-zA-Z0-9: -]##g')

echo "Last modification of source: ${LASTMOD} of ${DOCKER_NAME}:${DEBIAN_ARCH}"

docker pull "${DOCKER_NAME}:${DEBIAN_ARCH}" 2>/dev/null 1>&2 || true
CURRENTLAST="$(docker inspect --format='{{ index .Config.Labels "last_modified_src"}}' \
                      "${DOCKER_NAME}:${DEBIAN_ARCH}" 2>/dev/null||echo 'non-existent')"

# check if you will have bugs with bootstrap recent kernels respect glibc/dietlibc
case $(uname -m) in
  x86_64)
        if [ "${DEBIAN_ARCH}" == "amd64" ] ; then
        echo "Your kernel must be boot with  vsyscall=emulate to work this docker builds, don try to run inside windoser stupid OS";
        read -rt 90
        fi
    ;;
  *)
    ;;
esac

if [ "${CURRENTLAST}" == "${LASTMOD}" ] ; then
    echo "Rebuild not needed - upstream has last modification ${LASTMOD}. DO YOU STILL WANTS TO BUILD?"
    read -rt 50
fi
    #
    # We cannot build in one step, since the debootstrap process needs
    # --privilege.
    #
    docker build -t debian-archived-builder . -f - <<EOF
FROM debian:${DEBIAN_STAGE1}
ENV DEBIAN_FRONTEND noninteractive
RUN apt-get update && \
    apt-get install -y --force-yes cdebootstrap qemu-user-static
ENTRYPOINT [ "/bin/bash", "-c" ]
EOF

    rm -f cif || true
    docker run \
           --privileged \
           --cidfile=cif \
           debian-archived-builder \
           "mkdir '/debian-${DIST}-${DEBIAN_ARCH}' \
           && cdebootstrap --verbose --exclude=exim4 --arch=${DEBIAN_ARCH} --flavour=minimal --allow-unauthenticated --foreign \
           'Debian/${DIST}' '/debian-${DIST}-${DEBIAN_ARCH}' \
           '${DEBIAN_MIRROR}'"

    STAGE1_ID="$(cat cif ; rm cif)"
    STAGE2_ID="$(docker commit "${STAGE1_ID}")"

    docker build \
           -t "${DOCKER_NAME}:${DEBIAN_ARCH}" \
           --label "last_modified_src=${LASTMOD}" \
           . \
           -f - <<EOF
FROM ${STAGE2_ID} AS build
FROM scratch
COPY --from=build /debian-${DIST}-${DEBIAN_ARCH} /
ENV DEBIAN_FRONTEND noninteractive
ENV LC_ALL C
ENV LANGUAGE C
LABEL maintainer="VenenuX"
RUN /bin/echo "debian:${DIST}:${DEBIAN_ARCH}" > /etc/os-version.txt
RUN /bin/echo -e "deb http://archive.debian.org/debian/ ${DIST} main contrib non-free\ndeb http://archive.debian.org/debian/ ${DIST}-backports main contrib non-free\ndeb http://archive.debian.org/debian-security/ ${DIST}/updates main contrib non-free" > /etc/apt/sources.list && apt-get update
ENTRYPOINT [ "/bin/sh" ]
EOF
    docker rm "${STAGE1_ID}"


