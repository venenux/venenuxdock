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
if [ -n "$2" ]; then export DOCKER_NAME=${2}; else export DOCKER_NAME=venenux/debian-${DIST}-base; fi
DEBIAN_ARCH="$(dpkg-architecture -qDEB_BUILD_ARCH)"
if [ -n "$3" ]; then export DEBIAN_ARCH=${3}; else export DEBIAN_ARCH=${DEBIAN_ARCH}; fi
export DEBIAN_STAGE1=${4:-testing}

EXTRAREPO=""
APT_OPTIONS="-o Acquire::AllowDowngradeToInsecureRepositories=true -o Acquire::AllowInsecureRepositories=true -o APT::Get::AllowUnauthenticated=true "
# check target distro docker mirror detection
case ${DIST} in
    etch|lenny|squeeze|wheezy|jessie|stretch)
DEBIAN_MIRROR="http://archive.debian.org/debian"
    ;;
    *)
DEBIAN_MIRROR="http://ftp.br.debian.org/debian"
    ;;
esac
# check base distro docker on older cases if targeted
case ${DEBIAN_STAGE1} in
    etch|lenny|squeeze|wheezy|jessie|stretch)
DEBIAN_MIRROR_BASE=${DEBIAN_MIRROR}
    ;;
    *)
DEBIAN_MIRROR_BASE="http://ftp.br.debian.org/debian"
    ;;
esac
# so then configure the repository inside stage1 docker base
EXTRAREPO="/bin/echo -e \"deb ${DEBIAN_MIRROR_BASE} ${DEBIAN_STAGE1} main contrib non-free\ndeb ${DEBIAN_MIRROR_BASE} ${DEBIAN_STAGE1}-backports main contrib non-free\ndeb ${DEBIAN_MIRROR_BASE}-security ${DIST}/updates main contrib non-free\" > /etc/apt/sources.list &&"


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
RUN ${EXTRAREPO} \
    apt-get ${APT_OPTIONS} update || true && \
    apt-get ${APT_OPTIONS} install -y --force-yes cdebootstrap qemu-user-static
ENTRYPOINT [ "/bin/bash", "-c" ]
EOF

    rm -f cif || true
    docker run \
           --privileged \
           --cidfile=cif \
           debian-archived-builder \
           "mkdir '/debian-${DIST}-${DEBIAN_ARCH}' \
           && cdebootstrap --verbose --exclude=exim4 --arch=${DEBIAN_ARCH} --flavour=minimal --allow-unauthenticated --foreign 'Debian/${DIST}' '/debian-${DIST}-${DEBIAN_ARCH}' '${DEBIAN_MIRROR}' \
           && /bin/echo \"debian:${DIST}:${DEBIAN_ARCH}\" > /debian-${DIST}-${DEBIAN_ARCH}/etc/os-version.txt \
           && /bin/echo -e \"deb ${DEBIAN_MIRROR} ${DIST} main contrib non-free\ndeb ${DEBIAN_MIRROR} ${DIST}-backports main contrib non-free\ndeb ${DEBIAN_MIRROR}-security ${DIST}/updates main contrib non-free\" > /etc/apt/sources.list && apt-get update || true"

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
ENTRYPOINT [ "/bin/sh" ]
EOF
    docker rm "${STAGE1_ID}"


