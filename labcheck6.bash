#!/bin/bash
#  OPS335 Lab 6 configuration check
#  Written by: Peter Callaghan
#  Last Modified: 21 Mar. '18
#  This script runs a series of commands to show the current configuration of the machine it is run on
#  Run it on your host and vm1, and attach the output to your lab submission.

if [ `getenforce` != "Enforcing" ]
then
	echo "SELinux is not currently enforcing on this machine.  Turn it back on, and do not turn it off again." >&2
	exit 2
fi

if [ `systemctl is-active iptables` != "active" ]
then
	echo "This machine does not have a running firewall.  Turn it back on, and do not turn it off again." >&2
	exit 3
elif [ `iptables -L INPUT | wc -l` -le 2 -a `iptables -L INPUT | grep -c "policy ACCEPT"` -gt 0 ]
then
	echo "The firewall on this machine is allowing all incoming traffic.  It should not be.  Fix this." >&2
	exit 4
fi

date
echo
echo "hostname:"`hostname`
echo

echo "Static Addressing"
for each in /etc/sysconfig/network-scripts/ifcfg-*
do
	echo "Static configuration for $each"
	cat $each
	echo
done

#iptables
echo "Firewall"
iptables -L -v -n
echo

if [ "`hostname -s`" == "vm1" ]
then
	filesystem=`df | grep -E "(centos-)?root" | cut -d' ' -f1`
	echo "UUID:"`blkid $filesystem | sed -r 's/^.*UUID="([-a-zA-Z0-9]+)".*$/\1/'`
	echo

	echo "webserver status"
	echo "httpd:"`systemctl is-active httpd.service`
	echo "httpd:"`systemctl is-enabled httpd.service`
	echo

	echo "database status"
	echo "mariadb:"`systemctl is-active mariadb.service`
	echo "mariadb:"`systemctl is-enabled mariadb.service`
	echo

	echo "webserver config"
	sed -re "/^$/ d" -e "/^[[:space:]]*#/ d" /etc/httpd/conf/httpd.conf
	echo

	echo "php config"
	php -m

	echo "webpage on $HOSTNAME"
	cat /var/www/html/private/index.php
	echo

	rounddir=/var/www/html/webmail

	echo "Roundcube Config"
	sed -re '/^($|#|\/\/)/ d' -e '/^\/\*$/,/^\*\/$/ d'  ${rounddir}/config/config.inc.php
	echo

	echo "Roundcube logs"
	cat ${rounddir}/logs/sendmail
	echo
else
	filesystem=`df | grep /var/lib/libvirt/images | cut -d' ' -f1`
	uuid=`blkid $filesystem | sed -r 's/^.*UUID="([-a-zA-Z0-9]+)".*$/\1/'`
	echo "UUID:$uuid"
	echo

	echo Nating
	iptables -L -v -n -t nat
	echo
fi
