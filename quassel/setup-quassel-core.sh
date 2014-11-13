#!/bin/bash
# setup-quassel-core.sh
#
#
# Set up a quassel server, which will maintain continuous IRC client
# sessions.
#

PORT=4242

apt-get -y update
apt-get -y install quassel-core
apt-get -y install quassel-client
apt-get -y install vim

if ! iptables -C INPUT -p tcp --destination-port $PORT -j ACCEPT; then
    iptables -A INPUT -p tcp --destination-port $PORT -j ACCEPT;
fi

iptables-save >/etc/iptables/rules.v4

service quasselcore restart

echo <<EOL
The first account created with a Quassel client will have admin privileges.
EOL

