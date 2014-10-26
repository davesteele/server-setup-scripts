#!/bin/bash

if grep -q torproject.org /etc/apt/sources.list ;
then
  echo "Tor installation is already configured"
else
  # https://www.torproject.org/docs/debian.html.en
  echo -n "Which distribution are your running (for apt)?: "
  read dist
  echo "deb   http://deb.torproject.org/torproject.org $dist main" >> /etc/apt/sources.list
  gpg --keyserver keys.gnupg.net --recv 886DDD89
  gpg --export A3C4F0F979Caa22CDBA8F512EE8CBC9E886DDD89 | apt-key add -
fi

apt-get -y update
apt-get install deb.torproject.org-keyring
apt-get install tor
