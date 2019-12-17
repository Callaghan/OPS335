#!/bin/bash
#  OPS335 Lab 7 configuration check
#  Written by: Peter Callaghan
#  Last Modified: 29 Nov, '19
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


#VM4 only
echo "LDAP Configuration"
if [ "`hostname -s`" == "vm4" ]
then
	ldapsearch -x -b 'dc=andrew,dc=ops'
else
#everyone else
	authconfig --test
fi
