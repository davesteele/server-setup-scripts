#!/bin/bash

# The hinet domain can be the source of an obscene amount of spam smtp traffic. These rules
# mostly eliminates that.


apt-get -y update
apt-get -y install iptables-persistent
apt-get -y install vim

# Chain INPUT (policy DROP 150K packets, 15M bytes)
# 10972  527K DROP       tcp  --  eth0   *       114.43.240.0/20      0.0.0.0/0            tcp dpt:25
#  3891  200K DROP       tcp  --  eth0   *       114.45.0.0/16        0.0.0.0/0            tcp dpt:25
# 13959  670K DROP       tcp  --  eth0   *       114.0.0.0/11         0.0.0.0/0            tcp dpt:25
# 45987 2213K DROP       tcp  --  eth0   *       118.160.0.0/13       0.0.0.0/0            tcp dpt:25
#  5088  262K DROP       tcp  --  eth0   *       1.164.192.0/20       0.0.0.0/0            tcp dpt:25
#  8024  385K DROP       tcp  --  eth0   *       1.160.0.0/14         0.0.0.0/0            tcp dpt:25
#  7693  369K DROP       tcp  --  eth0   *       111.249.32.0/21      0.0.0.0/0            tcp dpt:25
#  5501  264K DROP       tcp  --  eth0   *       114.37.184.0/21      0.0.0.0/0            tcp dpt:25
#    29  1392 DROP       tcp  --  eth0   *       114.24.0.0/20        0.0.0.0/0            tcp dpt:25
#  6769  325K DROP       tcp  --  eth0   *       111.243.48.0/20      0.0.0.0/0            tcp dpt:25
#    39  1776 DROP       tcp  --  eth0   *       114.24.0.0/20        0.0.0.0/0            tcp dpt:25
# 12176  626K DROP       tcp  --  eth0   *       220.136.0.0/13       0.0.0.0/0            tcp dpt:25
# 34541 1673K DROP       tcp  --  eth0   *       36.224.0.0/11        0.0.0.0/0            tcp dpt:25
#     3   144 DROP       tcp  --  eth0   *       36.225.32.0/21       0.0.0.0/0            tcp dpt:25
#    12   576 DROP       tcp  --  eth0   *       36.230.252.0/22      0.0.0.0/0            tcp dpt:25
#    21  1008 DROP       tcp  --  eth0   *       36.231.252.0/22      0.0.0.0/0            tcp dpt:25
#  3199  154K DROP       tcp  --  eth0   *       111.241.144.0/20     0.0.0.0/0            tcp dpt:25

nets="
114.43.240.0/20 \
114.45.0.0/16   \
114.0.0.0/11    \
118.160.0.0/13  \
1.164.192.0/20  \
1.160.0.0/14    \
111.249.32.0/21 \
114.37.184.0/21 \
114.24.0.0/20   \
111.243.48.0/20 \
114.24.0.0/20   \
220.136.0.0/13  \
36.224.0.0/11   \
36.225.32.0/21  \
36.230.252.0/22 \
36.231.252.0/22 \
111.241.144.0/20\
"

for net in $nets ; do
  if ! iptables -C INPUT -s $net -p tcp --destination-port smtp -j DROP 2> /dev/null; then
    echo "Blocking $net"
    iptables -I INPUT -s $net -p tcp --destination-port smtp -j DROP
  fi
done

iptables-save >/etc/iptables/rules.v4
