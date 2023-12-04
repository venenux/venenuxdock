# VenenuX Debian Docker images (older and newers)

Build scripts for making docker VenenuX Debian images uploaded to docker hub

Please  be  aware of  that  Etch to Squeeze images  represent  legacy
versions  of   said  operating  system,  and   *do*  contain  security
issues. Please  do not  use these  images for  anything else  than O/S
research, testing etc.

Please  be  aware of  that  since Wheezy images, images, although legacy, 
it still has extended security support through Freexian's ExLTS service, 
on specific (mostly server oriented) packages, for more information check 
the page at [oficial Debian Extended Long Term Support wiki page](https://wiki.debian.org/LTS/Extended).

## Usage

To use the VenenuX images just requested from docker hub:

```
general@venenux:~$ docker run --rm -it venenux/venenuxdock:jessie
sh-3.1# cat /etc/debian_version
8.11
```

To build your own new image inside just clone the repo and build it:

```
apt-get install docker.io shellcheck ca-certificates cgroupfs-mount git xz-utils
mkdir ~/Devel && cd Devel && git clone https://codeberg.org/venenux/venenuxdock && cd ~/Devel/venenuxdock
make
```

## Status of images

Currently, the following images will [be on Docker hub venenuxdock](https://hub.docker.com/r/venenux/venenuxdock):

- [ ] Debian 4 Etch    (~2007 (Link to [debian.org](https://www.debian.org/releases/etch/))) Error due kernel bug
- [ ] Debian 5 Lenny   (~2009 (Link to [debian.org](https://www.debian.org/releases/lenny/))) Error due fstab bug
- [ ] Debian 6 Squeeze (~2011 (Link to [debian.org](https://www.debian.org/releases/squeeze/))) Error due kernel bug
- [ ] Debian 7 Wheezy  (~2016 (Link to [debian.org](https://www.debian.org/releases/wheezy/))) Error due kernel bug
- [x] Debian 8 Jessie  (~2015 (Link to [debian.org](https://www.debian.org/releases/jessie/))) Builds fine **venenux/venenuxdock:jessie**
- [x] Debian 9 stretch (~2017 (Link to [debian.org](https://www.debian.org/releases/stretch/))) Builds fine **venenux/venenuxdock:stretch**

Debian VenenuX new generaton images are not build until release comes into oldstable

- [ ] Debian 10 buster (~2020 (Link to [debian.org](https://www.debian.org/releases/buster/))) Builds fine **venenux/venenuxdock:buster**
- [ ] Debian 11 bullseye (~2022 (Link to [debian.org](https://www.debian.org/releases/bullseye/))) Builds fine **venenux/venenuxdock:bullseye**

## LICENSE

Originally improved from madworx's old debian images, but he never put a LICENSE file, 
so we are not forced to put references but we just mention it here, the new one is 
**CC-BY-SA-NC over this files and GPLv3 over the products (Docker images)**.

* (c) 2020 Martin Kjellstrand
* (c) 2023+ PICCORO Lenz McKAY

