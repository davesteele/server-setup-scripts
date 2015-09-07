#!/bin/bash
# setup-snmpd.sh
#
#
# Set up snmpd daemonsshd on an alternate port.
#
# This uses http://www.unixmen.com/cacti-monitor-linux-servers-using-snmp/
# for guidance, yielding a read/write environment for SNMP V1 & 2.
#
# This does not modify the agentAddress string, meaning access is limited to
# 'localhost'.
#

confl='/etc/snmp/snmpd.conf'

echo -n "Public community string? (e.g. public): "
read public

echo -n "Private community string? (e.g. private, leave blank to disable writes): "
read private

apt-get -y update
apt-get -y install snmpd

# Comment out V1/2 default community definitions
sed -i 's/^ \(rocommunity\)\+/#\1/' $confl
sed -i 's/^ \(rwcommunity\)\+/#\1/' $confl

# Define a view that shows all available SNMP variables
if ! grep -q "view all included .1 80" $confl ; then
    echo " view all included .1 80" >> $confl
fi

# Add the definitions for ro and rw communities
echo " rocommunity $public default -V all" >>$confl
if [ -n "$private" ] ; then
    echo " rwcommunity $private default -V all" >>$confl
fi

# By default, SNMP network parameters are only updated once every 3 seconds.
# Change that to once every second. The change is transient.

setcmd="snmpset -c $private -v 1 127.0.0.1 NET-SNMP-AGENT-MIB::nsCacheTimeout.1.3.6.1.2.1.2.2 i 1"

if ! grep -q "$setcmd" /etc/init.d/snmpd ; then
    sed -i "s/\(log_progress_msg \" snmpd\"\)/\1\n$setcmd/" /etc/init.d/snmpd >/dev/null
fi

# No firewall changes are needed for localhost access

# make a stab at restarting the service
service snmpd restart

sleep 3

$setcmd
