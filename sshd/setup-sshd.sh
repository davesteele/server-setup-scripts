#!/bin/bash
# setup-sshd.sh
#
#
# Set up sshd on an alternate port.
#
#

EXTINT="eth0"

apt-get -y update
apt-get -y install openssh-server

echo -n "Port to use for ssh: "

read port

sed -i 's/^Port 22$/#Port 22/' /etc/ssh/sshd_config

sed -i "/Port 22/a Port $port" /etc/ssh/sshd_config

if ! /sbin/iptables -C INPUT -p tcp -i $EXTINT --dport $port -j ACCEPT ; then
    /sbin/iptables -A INPUT -p tcp -i $EXTINT --dport $port -j ACCEPT;
fi

if ! /sbin/iptables -C INPUT -p tcp -i $EXTINT --dport 22 -j DROP ; then
    /sbin/iptables -I INPUT -p tcp -i $EXTINT --dport 22 -j DROP;
fi

iptables-save >/etc/iptables/rules.v4

service ssh restart

