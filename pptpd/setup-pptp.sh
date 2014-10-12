#!/bin/sh
# setup-pptpd.sh
#
# This will request a CHAP password.
# Once complete, there are opportunities to tighten things up in
# /etc/ppp/chap-secrets.
#

apt-get -y update
apt-get -y install pptpd
apt-get -y install netfilter-persistent

#set username and password
if grep -q CONFIGURED /etc/ppp/chap-secrets ;
then
  echo "CHAP is configured already";
else
  echo -n "Enter CHAP password: ";
  read pw;
  echo "# CONFIGURED" >>/etc/ppp/chap-secrets;
  # Note that this set a password valid from and to all hosts
  echo "* * $pw" >> /etc/ppp/chap-secrets;
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


#config IPV4 forwarding
if grep -q "net.ipv4.ip_forward=1" /etc/sysctl.conf ;
then
  echo 'IP forwarding configured already';
else
  echo "net.ipv4.ip_forward=1" >> /etc/sysctl.conf
fi

cat <<EOF >/usr/share/netfilter-persistent/plugins.d/mypptpd
#!/bin/sh

case "\$1" in
  start)
    /sbin/iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE
  ;;
  flush)
    /sbin/iptables -t nat -D POSTROUTING -o eth0 -j MASQUERADE || /bin/true
  ;;
  save)
    echo
  ;;
  *)
    echo "Usage: mypptpd.sh [start|flush|save]" >&2
  ;;
esac
EOF

chmod 755 /usr/share/netfilter-persistent/plugins.d/mypptpd

sysctl -p
/etc/init.d/pptpd restart
netfilter-persistent start

