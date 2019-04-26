#!/bin/bash
#  OPS335 Lab 1 configuration check
#  Written by: Peter Callaghan
#  Last Modified: 23 Jan. '17
#  This script runs a series of commands to show the current configuration of the machine it is run on
#  Run it on each machine, and attach the output to your lab submission.

if [ `getenforce` != "Enforcing" ]
then
	echo "SELinux is not currently enforcing on this machine.  Turn it back on, and do not turn it off again." >&2
	exit 2
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

#Ensure the host name has been set correctly
date
echo
echo "hostname:"`hostname`
echo
echo "SELinux status:"`getenforce`
echo

if [ "$(echo $HOSTNAME | grep -E  "^vm[1-3]" )" == "" ]
then
	ip address show
	echo
	echo "sshd:"`systemctl is-active sshd`
	echo "sshd:"`systemctl is-enabled sshd`
	echo
	echo key
	cat /root/.ssh/id_rsa.pub
	echo
	echo "Cron table"
	crontab -l
	echo
	echo "Cron log"
	cat /tmp/cron.log
	echo
	echo "backup script"
	sed -re 's/^[[:space:]]*$//g' -e '/^$/ d' /root/bin/fullbackup.bash
	echo
	filesystem=`df | grep /var/lib/libvirt/images | cut -d' ' -f1`
	uuid=`blkid $filesystem | sed -r 's/^.*UUID="([-a-zA-Z0-9]+)".*$/\1/'`
else
	ip address show
	echo
	#Check service configuration
	echo "sshd:"`systemctl is-active sshd.service`
	echo "sshd:"`systemctl is-enabled sshd.service`
	echo
	echo key
	cat /root/.ssh/authorized_keys
	echo
	uuid=`blkid $(df | grep centos-root | cut -d' ' -f1) | sed -r 's/^.*UUID="([-a-zA-Z0-9]+)".*$/\1/'`

fi

echo "UUID:$uuid"
echo

for each in $(ls /home | grep -v "lost+found")
do
	if [ ! -d /home/$each ]
	then
		echo "Extra files found in /home: " $each
	fi
done
