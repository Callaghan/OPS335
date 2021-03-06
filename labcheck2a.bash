#!/bin/bash
#  OPS335 Lab 2a configuration check
#  Written by: Peter Callaghan
#  Last Modified: 19 May, '16
#  This script runs a series of commands to show the current configuration of the machine it is run on
#  Run it on your host, and attach the output to the lab submission.

if [ `getenforce` != "Enforcing" ]
then
	echo "SELinux is not currently enforcing on this machine.  Turn it back on, and do not turn it off again." >&2
	exit 2
fi

if [ "`systemctl is-active iptables`" != "active" ]
then
	echo "Your host does not have a running firewall.  Turn it back on, and do not turn it off again." >&2
	exit 3
elif [ `iptables -L INPUT | wc -l` -le 2 -a `iptables -L INPUT | grep -c "policy ACCEPT"` -gt 0 ]
then
	echo "The firewall on your host is allowing all incoming traffic.  It should not be.  Fix this." >&2
	exit 4
fi

#Ensure the host name has been set correctly
date
echo
echo "Hostname:"`hostname`
echo
echo "SELinux status:"`getenforce`
echo
filesystem=`df | grep /var/lib/libvirt/images | cut -d' ' -f1`
uuid=`blkid $filesystem | sed -r 's/^.*UUID="([-a-zA-Z0-9]+)".*$/\1/'`
echo "UUID:$uuid"
echo

#check host
ip addr list
echo
echo "firewalld:"`systemctl is-active firewalld.service`
echo "firewalld:"`systemctl is-enabled firewalld.service`
echo
echo "iptables:"`systemctl is-active iptables.service`
echo "iptables:"`systemctl is-enabled iptables.service`
echo
echo "before:"`find / -name before.txt 2> /dev/null | grep -c "^\/"`
echo "after:"`find / -name after.txt 2> /dev/null | grep -c "^\/"`
echo

iptables -L -v -n
echo

for each in $(ls /home | grep -v "lost+found")
do
	if [ ! -d /home/$each ]
	then
		echo "Extra files found in /home: " $each
	fi
done
