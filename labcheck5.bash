#!/bin/bash
#  OPS335 Lab 5 configuration check
#  Written by: Peter Callaghan
#  Last Modified: 16 Mar, '17
#  This script runs a series of commands to show the current configuration of the machine it is run on
#  Run it on your host and vm2, and attach the output of each to your lab submission.

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

if [ `hostname -s` == "vm2" ]
then
	#VM2 only
	filesystem=`df | grep -E "(centos-)?root" | cut -d' ' -f1`
	echo "UUID:"`blkid $filesystem | sed -r 's/^.*UUID="([-a-zA-Z0-9]+)".*$/\1/'`
	echo
	echo "Firewall"
	iptables -L -v -n
	echo
	echo "Configuration - samba"
	sed -e "/^#/ d" -e "/^$/ d" -e "/^;/ d" /etc/samba/smb.conf
	echo
	echo "samba:"`systemctl is-active smb.service`
	echo "samba:"`systemctl is-enabled smb.service`
	echo
	echo "testparm"
	testparm -s 2>&1
	echo
	echo "sebool"
	getsebool samba_enable_home_dirs
	echo
else
	#Host only
	filesystem=`df | grep /var/lib/libvirt/images | cut -d' ' -f1`
	uuid=`blkid $filesystem | sed -r 's/^.*UUID="([-a-zA-Z0-9]+)".*$/\1/'`
	echo "UUID:$uuid"
	echo
	echo "iptables"
	iptables -t nat -L PREROUTING -v -n
	echo
	iptables -L FORWARD -v -n
	echo
fi
