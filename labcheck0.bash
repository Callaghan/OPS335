#!/bin/bash
#  OPS335 Lab 0 configuration check
#  Written by: Peter Callaghan
#  Last Modified: 10 May. '18
#  This script runs a series of commands to show the current configuration of the machine it is run on
#  Run it as root on each of your machines, and attach the output to the lab submission.

#check if history was updated
command=`tail -1 ~/.bash_history`
if [ "$command" != "history -a" ]
then
	echo "Make sure you run history -a before running this script, otherwise your recent commands will not be present in the .bash_history file" >&2
	exit 1
fi

if [ `getenforce` != "Enforcing" ]
then
	echo "SELinux is not currently enforcing on this machine.  Turn it back on, and do not turn it off again." >&2
	exit 2
fi

if [ "$(echo $HOSTNAME | grep "^vm" )" == "" ]
then
	if [ `mount | grep '/var/lib/libvirt/images' | wc -l` -ne 1 ]
	then
		echo "You don't seem to have a separate filesystem for /var/lib/libvirt/images" >&2
		exit 5
	else
		if [ `df | grep /var/lib/libvirt/images | awk '{print $2;}'` -lt 80000000 ]
		then 
			echo "Your /var/lib/libvirt/images filesystem is smaller than 80GB, that's too small." >&2
			exit 6
		else
			echo "Your /var/lib/libvirt/images filesystem seems to be OK." >&2
			filesystem=`df | grep /var/lib/libvirt/images | cut -d' ' -f1`
			uuid=`blkid $filesystem | sed -r 's/^.*UUID="([-a-zA-Z0-9]+)".*$/\1/'`
		fi
	fi
else
	filesystem=`df | grep centos-root | cut -d' ' -f1`
	uuid=`blkid $filesystem | sed -r 's/^.*UUID="([-a-zA-Z0-9]+)".*$/\1/'`
fi

if [ "`systemctl is-active iptables`" != "active" ]
then
	if [ "`systemctl is-active firewalld`" == "active" ]
	then
		echo "This machine should be running iptables, not firewalld." >&2
	else
		echo "This machine does not have a running firewall.  Turn iptables on, and do not turn it off again." >&2
	fi
	exit 3
fi

date
echo
echo "hostname:"`hostname`
echo
echo "SELinux status:"`getenforce`
echo
echo release:`uname -r`
echo
echo "UUID:$uuid"
echo
if [ "$(echo $HOSTNAME | grep "^vm" )" == "" ]
then
	echo "Users"
	grep home /etc/passwd
	echo
	echo "libvirtd:"`systemctl is-active libvirtd`
	echo "libvirtd:"`systemctl is-enabled libvirtd`
	echo
fi

echo "Boot sessions"
last | grep "system boot" | sed -r 's/[[:space:]]+/ /g'
echo

echo "Commands as root"
cat ~/.bash_history
echo

for each in $(ls /home | grep -v "lost+found")
do
	if [ -d /home/$each ]
	then
		echo "Commands as $each"
		cat /home/$each/.bash_history
		echo
	else
		echo "Extra files found in /home: " $each
	fi
done
echo

echo crontab
crontab -l 2>/dev/null | sed -e '/^$/ d' -e '/^#/ d'
