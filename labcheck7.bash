#!/bin/bash
#  OPS335 Lab 7 configuration check
#  Written by: Peter Callaghan
#  Last Modified: 04 Jul, '17
#  This script runs a series of commands to show the current configuration of the machine it is run on
#  Run it on each of your machines, and attach the output from all of them to your lab submission.

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
echo "SELinux status:"`getenforce`
echo

echo "Static Addressing"
for each in /etc/sysconfig/network-scripts/ifcfg-*
do
	echo "Static configuration for $each"
	cat $each
	echo
done


#host only
if [ "`hostname -s`" == "host" ]
then
	filesystem=`df | grep /var/lib/libvirt/images | cut -d' ' -f1`
	uuid=`blkid $filesystem | sed -r 's/^.*UUID="([-a-zA-Z0-9]+)".*$/\1/'`
	echo "UUID:$uuid"
	echo
	echo "firewall"
	iptables -L -v -n
	echo
	echo "exportfs"
	exportfs
	echo
	echo "/etc/sysconfig/network"
	cat /etc/sysconfig/network
	echo
	echo "nisdomain:"`nisdomainname`
	echo
	echo "/var/yp/securenets"
	cat /var/yp/securenets
	echo
	echo "nfs-server:"`systemctl is-active nfs-server.service`
	echo "nfs-server:"`systemctl is-enabled nfs-server.service`
	echo "ypserv:"`systemctl is-active ypserv.service`
	echo "ypserv:"`systemctl is-enabled ypserv.service`
	echo "rhel-domainname:"`systemctl is-active rhel-domainname.service`
	echo "rhel-domainname:"`systemctl is-enabled rhel-domainname.service`
else
#vms only
	filesystem=`df | grep -E "(centos-)?root" | cut -d' ' -f1`
	echo "UUID:"`blkid $filesystem | sed -r 's/^.*UUID="([-a-zA-Z0-9]+)".*$/\1/'`
	echo
	echo "Configuration - nsswitch"
	sed -e "/^#/ d" -e "/^$/ d" /etc/nsswitch.conf
	echo
	echo "Configuration - yp.conf"
	sed -e "/^#/ d" -e "/^$/ d" /etc/yp.conf
	echo
	echo "ypbind:"`systemctl is-active ypbind.service`
	echo "ypbind:"`systemctl is-enabled ypbind.service`
	echo
	echo Bound to:`ypwhich`
	echo
	echo "maps - passwd"
	ypcat passwd
	echo
	echo "Mounts"
	mount | grep /home
fi
