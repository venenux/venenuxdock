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

export DIST=${1:-etch}
export DOCKER_NAME=${2:-venenux/venenuxdock}
export DEBIAN_MIRROR=${DEBIAN_MIRROR:="http://archive.debian.org/debian/"}

# Check if rebuild is needed:
LASTMOD=$(curl -sI "${DEBIAN_MIRROR}/dists/${DIST}/main/binary-amd64/Packages.gz" | \
                 sed -n 's#^last-modified: *##pi' | \
                 sed -e 's#[^a-zA-Z0-9: -]##g')

echo "Last modification of source: ${LASTMOD}"

docker pull "${DOCKER_NAME}:${DIST}" 2>/dev/null 1>&2 || true
CURRENTLAST="$(docker inspect --format='{{ index .Config.Labels "last_modified_src"}}' \
                      "${DOCKER_NAME}:${DIST}" 2>/dev/null||echo 'non-existent')"

# check if you will have bugs with bootstrap recent kernels respect glibc/dietlibc
case $(uname -m) in
  x86_64*)
        echo "Your kernel must be boot with  vsyscall=emulate to work this docker builds (ENTER TO CONTINUE AND IGNORE)";
        read -rt 50
    ;;
  *)
    ;;
esac

if [ "${CURRENTLAST}" == "${LASTMOD}" ] ; then
    echo "Rebuild not needed - upstream has last modification ${LASTMOD}. DO YOU STILL WANTS TO BUILD?"
    read -rt 50
    # We cannot build in one step, since the debootstrap process needs
    # --privilege.
    #
    docker build -t debian-archived-builder . -f - <<EOF
FROM debian:testing
ENV DEBIAN_FRONTEND noninteractive
RUN apt-get update && \
    apt-get install -y debootstrap
ENTRYPOINT [ "/bin/bash", "-c" ]
EOF

    rm -f cif || true
    docker run \
           --privileged \
           --cidfile=cif \
           debian-archived-builder \
           "mkdir '/debian-${DIST}' \
           && debootstrap --verbose --no-check-gpg --no-check-certificate \
           '${DIST}' '/debian-${DIST}' \
           '${DEBIAN_MIRROR}'"

    STAGE1_ID="$(cat cif ; rm cif)"
    STAGE2_ID="$(docker commit "${STAGE1_ID}")"

    docker build \
           -t "${DOCKER_NAME}:${DIST}" \
           --label "last_modified_src=${LASTMOD}" \
           . \
           -f - <<EOF
FROM ${STAGE2_ID} AS build
FROM scratch
COPY --from=build /debian-${DIST} /
ENV DEBIAN_FRONTEND noninteractive
ENV LC_ALL C
ENV LANGUAGE C
LABEL maintainer="VenenuX"
RUN echo "debian:${DIST}" > /etc/os-version.txt
RUN echo "deb http://archive.debian.org/debian/ ${DIST} main contrib non-free\ndeb http://archive.debian.org/debian/ ${DIST}-backports main contrib non-free\ndeb http://archive.debian.org/debian-security/ ${DIST}/updates main contrib non-free" > /etc/apt/sources.list && apt-get update
ENTRYPOINT [ "/bin/sh" ]
EOF
    docker rm "${STAGE1_ID}"
fi


