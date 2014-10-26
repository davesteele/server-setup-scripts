#!/bin/bash

# Note - this will ask for your distribution name (e.g. sid),
# and traffic quota

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
apt-get -y install deb.torproject.org-keyring
apt-get -y install tor
apt-get -y install pwgen
apt-get -y install vim

if grep -q "#SocksPolicy reject *" /etc/tor/torrc;
then
  sed -i 's/#SocksPolicy reject/SocksPolicy reject/' /etc/tor/torrc;
  echo -n "Daily traffic quota (e.g. '15 GB'): ";
  read quota;
  echo >>/etc/tor/torrc;
  echo "AccountingMax $quota" >>/etc/tor/torrc
  echo "AccountingStart day 00:00" >>/etc/tor/torrc
  export name=`pwgen -A0 8 -N 1`
  echo "Nickname $name" >>/etc/tor/torrc
  echo "I dub this relay $name (in /etc/tor/torrc)"
  echo "ORPort 9001" >>/etc/tor/torrc
  echo "ExitPolicy reject *:*" >> /etc/tor/torrc

  echo "Check in /var/log/tor/log for the ORPort reachable test"
  echo "https://www.torproject.org/docs/tor-doc-relay.html.en#check"
else
  echo "torrc already configured";
fi

service tor restart

