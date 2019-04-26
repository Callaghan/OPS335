#!/bin/bash
#  OPS335 Lab 4a configuration check
#  Written by: Peter Callaghan
#  Last Modified: 15 Sep, '16
#  This script runs a series of commands to show the current configuration of the machine it is run on
#  Run it on your VM02 and VM03, and attach the output to the lab submission.

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

echo "Firewall configuration"
iptables -L -v -n
echo

filesystem=`df | grep -E "(centos-)?root" | cut -d' ' -f1`
echo "UUID:"`blkid $filesystem | sed -r 's/^.*UUID="([-a-zA-Z0-9]+)".*$/\1/'`
echo

#postfix configuration parameters
echo "Postfix parameters"
grep -E "^(my(hostname|domain|origin|destination)|inet_interfaces)" /etc/postfix/main.cf
echo
#postfix status
echo "postfix:"`systemctl is-active postfix.service`
echo "postfix:"`systemctl is-enabled postfix.service`
echo

echo "Messages sent as root"
grep -aE "^mail[[:space:]]+" $HOME/.bash_history
echo

for each in $(ls /home | grep -v "lost+found")
do
	echo "Messages sent as $each"
	grep -aE "^mail[[:space:]]+" /home/$each/.bash_history 2> /dev/null
	echo
done

echo "mail log"
(cat /var/log/maillog-* 2> /dev/null; cat /var/log/maillog) | grep postfix
echo

