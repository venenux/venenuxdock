# VenenuX Debian Docker images (older and newers)

Currently, the following images will [be on Docker hub venenux-debianok](https://hub.docker.com/r/venenux/venenux-debianok):

  * Debian 4 Etch    (~2007 (Link to [debian.org](https://www.debian.org/releases/etch/)))
  * Debian 5 Lenny   (~2009 (Link to [debian.org](https://www.debian.org/releases/lenny/)))
  * Debian 6 Squeeze (~2011 (Link to [debian.org](https://www.debian.org/releases/squeeze/)))
  * Debian 7 Wheezy  (~2016 (Link to [debian.org](https://www.debian.org/releases/wheezy/)))
  * Debian 8 Jessie  (~2015 (Link to [debian.org](https://www.debian.org/releases/jessie/)))
  * Debian 9 stretch (~2017 (Link to [debian.org](https://www.debian.org/releases/stretch/)))

Later releases are readily available for the [official Debian repo at Docker Hub](https://hub.docker.com/_/debian/).

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
general@venenux:~$ docker run --rm -it venenux/venenux-debianok:etch
sh-3.1# cat /etc/debian_version
4.0
```

To build your own new image inside just clone the repo and build it:

```
apt-get install docker.io shellcheck ca-certificates cgroupfs-mount git xz-utils
mkdir ~/Devel && cd Devel && git clone https://codeberg.org/venenux/venenuxdock && cd ~/Devel/venenuxdock
make
```

## LICENSE

Originally improved from madworx's old debian images, but he never put a LICENSE file, 
so we are not forced to put references but we just mention it here, the new one is 
**CC-BY-SA-NC over this files and GPLv3 over the products (Docker images)**.

* (c) 2020 Martin Kjellstrand
* (c) 2023+ PICCORO Lenz McKAY

