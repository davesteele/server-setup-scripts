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
# TODO - a systemd version of this is needed.

setcmd="snmpset -c $private -v 1 127.0.0.1 NET-SNMP-AGENT-MIB::nsCacheTimeout.1.3.6.1.2.1.2.2 i 1"

if ! grep -q "$setcmd" /etc/rc.local ; then
    sed -i "s/\(exit 0\)/$setcmd\n\1/" /etc/rc.local
fi

## Alternate method to override the 3 second update,
## per https://www.fineconnection.com/how_to_set_the_net-snmp_agent_update_or_counter_refresh_interval/
## (Doesn't work)
#
#overcmd=" override .1.3.6.1.4.1.8072.1.5.3.1.2.1.3.6.1.2.1.2.2 integer 1"
#if ! grep -q "$overcmd" $confl ; then
#    echo "$overcmd" >>$confl
#fi

# No firewall changes are needed for localhost access

# make a stab at restarting the service
service snmpd restart
systemctl restart snmpd

sleep 3

$setcmd
