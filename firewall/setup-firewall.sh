#!/bin/bash
# setup-firewall.sh
#
#
# Set up a simple persistent default firewall.
#
# Note that the iptables-persistent install may ask questions. Default to 'y'.
#

TCPPORTS="22"
UDPPORTS=""
EXTINT="eth0"

apt-get -y update
apt-get -y install iptables-persistent
apt-get -y install vim


if ! /sbin/iptables -C INPUT -i lo -j ACCEPT; then
    /sbin/iptables -A INPUT -i lo -j ACCEPT;
fi

if ! /sbin/iptables -C INPUT -p icmp --icmp-type 8 -j ACCEPT ; then
    /sbin/iptables -A INPUT -p icmp --icmp-type 8 -j ACCEPT
fi

if ! /sbin/iptables -C INPUT -i $EXTINT -m state --state ESTABLISHED,RELATED -j ACCEPT ; then
    /sbin/iptables -A INPUT -i $EXTINT -m state --state ESTABLISHED,RELATED -j ACCEPT
fi


for PORT in $TCPPORTS ; do
    if ! iptables -C INPUT -i $EXTINT -p tcp --destination-port $PORT --syn -j ACCEPT; then
        iptables -A INPUT -i $EXTINT -p tcp --destination-port $PORT --syn -j ACCEPT;
    fi
done

for PORT in $UDPPORTS ; do
    if ! iptables -C INPUT -i $EXTINT -p UDP --destination-port $PORT -j ACCEPT; then
        iptables -A INPUT -i $EXTINT -p UDP --destination-port $PORT -j ACCEPT;
    fi
done

/sbin/iptables -P INPUT DROP

iptables-save >/etc/iptables/rules.v4

