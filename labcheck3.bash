#!/bin/bash
#  OPS335 Lab 3 configuration check
#  Written by: Peter Callaghan
#  Last Modified: 25 May, '18
#  This script runs a series of commands to show the current configuration of the machine it is run on
#  Run it on each machine, and attach the output to the lab submission.

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

#Ensure the host name has been set correctly
date
echo
echo "hostname:"`hostname`
echo
echo "SELinux status:"`getenforce`
echo

echo INTERFACES
cat /etc/sysconfig/network-scripts/ifcfg-*
echo
echo "Firewall configuration"
iptables -L -v -n
echo

filesystem=`df | grep centos-root | cut -d' ' -f1`
echo "UUID:"`blkid $filesystem | sed -r 's/^.*UUID="([-a-zA-Z0-9]+)".*$/\1/'`
echo

echo
#DNS configuration, host only
if [ "`hostname -s`" == "host" ]
then
	echo "DNS config"
	ls -l /etc/named.conf
	echo named config
	cat /etc/named.conf
        echo
	echo local config
	cat /var/named/named.localhost
        echo
	echo zone config
	cat /var/named/mydb-for-*
        echo
	echo "named:"`systemctl is-active named.service`
        echo "named:"`systemctl is-enabled named.service`
        echo
fi

echo "hosts"
grep vm /etc/hosts
echo
echo "HISTORY"
grep -Esc "^host " $HOME/.bash_history
grep -Esc "^dig " $HOME/.bash_history
grep -Esc "^nslookup " $HOME/.bash_history
echo
for each in $(ls /home | grep -v "lost+found")
do
	if [ -d /home/$each ]
	then
		echo "hosts queried as $each"
		grep -Esc "^host " /home/${each}/.bash_history
		grep -Esc "^dig " /home/${each}/.bash_history
		grep -Esc "^nslookup " /home/${each}/.bash_history
	else
		echo "Extra files found in /home: " $each
	fi
done

echo FORWARD
for each in host vm1 vm2 vm3
do
	host $each > /dev/null 2>&1
	echo $each:$?
done

octet=`ip a | sed -nr 's/^.*inet 192\.168\.([0-9]{1,3})\.[1-4]\/24.*$/\1/ p' | tail -1`
echo REVERSE
for each in `seq 1 4`
do
	host 192.168.$octet.$each > /dev/null 2>&1
	echo $each:$?
done
