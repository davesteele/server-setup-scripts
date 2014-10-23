#!/bin/sh
# setup-pptpd.sh
#
# This will request a CHAP password.
# The iptables-persistent install may query - say 'y'
#
# Once complete, there are opportunities to tighten things up in
# /etc/ppp/chap-secrets.
#

apt-get -y update
apt-get -y install pptpd
apt-get -y install iptables-persistent
apt-get -y install vim

#set username and password
if grep -q CONFIGURED /etc/ppp/chap-secrets ;
then
  echo "CHAP is configured already";
else
  echo -n "Enter CHAP password: ";
  read pw;
  echo "# CONFIGURED" >>/etc/ppp/chap-secrets;
  # Note that this set a password valid from and to all hosts
  echo "* * $pw *" >> /etc/ppp/chap-secrets;
fi

#set the pptpd address
if grep -q 10.0.0.1 /etc/pptpd.conf ;
then
  echo "pptpd is configured already";
else
  echo "localip 10.0.0.1" >> /etc/pptpd.conf
  echo "localip 10.0.0.100-200" >> /etc/pptpd.conf
fi

#set the dns address
if grep -q 8.8.8.8 /etc/ppp/pptpd-options ;
then
  echo "dns is configured already";
else
  echo "ms-dns 8.8.8.8" >> /etc/ppp/pptpd-options
  echo "ms-dns 8.8.4.4" >> /etc/ppp/pptpd-options
fi

echo net.ipv4.ip_forward=1 >/etc/sysctl.d/ip_forward.conf

/sbin/iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE
iptables-save >/etc/iptables/rules.v4

sysctl -p /etc/sysctl.d/ip_forward.conf
/etc/init.d/pptpd restart

