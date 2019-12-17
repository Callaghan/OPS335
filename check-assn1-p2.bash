#!/bin/bash

# check-assn1-p2.bash

# Author: Murray Saul
# Created: February 17, 2017   Updated: October 12, 2018
# Edited by: Peter Callaghan September 22, 2019

# Purpose: To generate data to be mailed to OPS335 instructor in order
#          to mark second portion of OPS335 assignment #1 - Part 2

# Error-checking prior to running shell script
# Check that user is logged on as root

primaryserver=australinea
primaryaddress=172.28.105.2
secondaryserver=antarctica
secondaryaddress=172.28.105.3
tld=ops
sld=earth
bld=continents

if [ `id -u` -ne 0 ]
then
  echo "You must run this shell script as root" >&2
  exit 1
fi

if ! virsh list | egrep -iqs "($secondaryserver|$primaryserver)"
then
  echo "You need to run your \"$secondaryserver\", and \"$primaryserver\" VMs" >&2
  exit 2
fi



# Prompt for username and Full name

read -p "Please enter YOUR FULL NAME: " fullName

read -p "Please enter YOUR SENECA LOGIN USERNAME: " userID

# Generate Evaluation Report

clear
echo "Your Assignment #1 - Part 2 is being evaluated..."
echo "This make take a few minutes to complete..."

cat <<'PPC' > /tmp/check$primaryserver.bash
#!/bin/bash

#Ensure the host name has been set correctly
echo "Hostname:"`hostname`
echo

echo "SELinux status:"`getenforce`
echo

echo "DOMAIN:"`grep -E "^[[:space:]]*DOMAIN=" /etc/sysconfig/network-scripts/ifcfg-*`
echo "DOMAINNAME:"`grep -E "^^[[:space:]]*DOMAINNAME=" /etc/sysconfig/network`
echo "SEARCH:"`grep -E "^^[[:space:]]*search" /etc/resolv.conf`
echo

echo "IP ADDRESS"
ip addr show
echo

echo INTERFACES
for interface in `ls /etc/sysconfig/network-scripts/ifcfg-*`
do
	echo $interface
	cat $interface
	echo
done

echo "sshd:"`systemctl is-active sshd.service`
echo "sshd:"`systemctl is-enabled sshd.service`
echo

echo "named:"`systemctl is-active named.service`
echo "named:"`systemctl is-enabled named.service`
echo

echo "firewalld:"`systemctl is-active firewalld.service`
echo "firewalld:"`systemctl is-enabled firewalld.service`
echo

echo "iptables:"`systemctl is-active iptables.service`
echo "iptables:"`systemctl is-enabled iptables.service`
echo

echo "RELEASE:"`uname -r`
echo

echo "LAST CHANGE"
last | sed -rne '/still running$/ d' -e '/^reboot[[:space:]]+system boot/ p'
echo

echo UUIDS
for links in `ip link show | grep -E "([a-fA-F0-9]{2}:){5}([a-fA-F0-9]{2})" | sed -rne "s/^.*(([a-fA-F0-9]{2}:){5}[a-fA-F0-9]{2}) brd.*/\1/" -e "/ff:ff:ff:ff:ff:ff/ d" -e "/00:00:00:00:00:00/ d" -e "p"`; do echo $links; done
echo

echo BLKID
blkid | sed -r 's/^.*UUID=\"([a-zA-Z0-9\-]+)\".*$/\1/'
echo

echo IFCFG
sed -n -r -e '/^#?UUID=/ p' -e '/^#?HWADDR=/ p' /etc/sysconfig/network-scripts/ifcfg-* | cut -d'=' -f2
echo

echo IPTABLES
iptables -L -v -n
echo

echo NAMED CONFIG
sed -re '/^$/ d' -e '/^[[:space:]]*#/ d' /etc/named.conf
echo

echo ZONE FILES
for file in `ls /var/named`
do
	if [ -f /var/named/$file -a $file != named.ca -a $file != named.empty -a $file != named.localhost -a $file != named.loopback ]
	then
		echo STARTING /var/named/$file
		cat /var/named/$file
		echo ENDING /var/named/$file
		echo
	fi
done
echo SELIF ENOZ
PPC

cat <<'PPC' > /tmp/check$secondaryserver.bash
#!/bin/bash

#Ensure the host name has been set correctly
echo "Hostname:"`hostname`
echo

echo "SELinux status:"`getenforce`
echo

echo "DOMAIN:"`grep -E "^[[:space:]]*DOMAIN=" /etc/sysconfig/network-scripts/ifcfg-*`
echo "DOMAINNAME:"`grep -E "^^[[:space:]]*DOMAINNAME=" /etc/sysconfig/network`
echo "SEARCH:"`grep -E "^^[[:space:]]*search" /etc/resolv.conf`
echo

echo "IP ADDRESS"
ip addr show
echo

echo INTERFACES
for interface in `ls /etc/sysconfig/network-scripts/ifcfg-*`
do
	echo $interface
	cat $interface
	echo
done
echo SECAFRENTI

echo "sshd:"`systemctl is-active sshd.service`
echo "sshd:"`systemctl is-enabled sshd.service`
echo

echo "firewalld:"`systemctl is-active firewalld.service`
echo "firewalld:"`systemctl is-enabled firewalld.service`
echo

echo "iptables:"`systemctl is-active iptables.service`
echo "iptables:"`systemctl is-enabled iptables.service`
echo

echo "named:"`systemctl is-active named.service`
echo "named:"`systemctl is-enabled named.service`
echo

echo "RELEASE:"`uname -r`
echo

echo "LAST CHANGE"
last | sed -rne '/still running$/ d' -e '/^reboot[[:space:]]+system boot/ p'
echo

echo UUIDS
for links in `ip link show | grep -E "([a-fA-F0-9]{2}:){5}([a-fA-F0-9]{2})" | sed -rne "s/^.*(([a-fA-F0-9]{2}:){5}[a-fA-F0-9]{2}) brd.*/\1/" -e "/ff:ff:ff:ff:ff:ff/ d" -e "/00:00:00:00:00:00/ d" -e "p"`; do echo $links; done
echo

echo BLKID
blkid | sed -r 's/^.*UUID=\"([a-zA-Z0-9\-]+)\".*$/\1/'
echo

echo IFCFG
sed -n -r -e '/^#?UUID=/ p' -e '/^#?HWADDR=/ p' /etc/sysconfig/network-scripts/ifcfg-* | cut -d'=' -f2
echo

echo IPTABLES
iptables -L -v -n
echo

echo NAMED CONFIG
sed -re '/^$/ d' -e '/^[[:space:]]*#/ d' /etc/named.conf
echo

echo ZONE FILES
for file in `ls /var/named`
do
	if [ -f /var/named/$file -a $file != named.ca -a $file != named.empty -a $file != named.localhost -a $file != named.loopback ]
	then
		echo STARTING /var/named/$file
		cat /var/named/$file
		echo ENDING /var/named/$file
		echo
	fi
done
echo SELIF ENOZ
echo

echo SLAVE FILES
ls -l /var/named/slaves
echo

rm -f /var/named/slaves/*
systemctl restart named
sleep 20

echo SLAVE FILES AFTER RESET
ls -l /var/named/slaves
echo
PPC

ssh $primaryaddress 'bash ' < /tmp/check$primaryserver.bash > /tmp/output-$primaryserver.txt 2>&1
ssh $secondaryaddress 'bash ' < /tmp/check$secondaryserver.bash > /tmp/output-$secondaryserver.txt 2>&1

tar -czf a1p2.$userID.tgz /tmp/output-$primaryserver.txt /tmp/output-$secondaryserver.txt

rm -f  /tmp/check$primaryserver.bash /tmp/check$secondaryserver.bash /tmp/output-$primaryserver.txt /tmp/output-$secondaryserver.txt message.txt 2> /dev/null

echo "The script created a file called a1p2.$userID.tgz in the current directory.  Upload that to blackboard for Assignment 1 Part 2."
