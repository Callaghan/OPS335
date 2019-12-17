#!/bin/bash

# check-assn2.bash

# Author: Murray Saul
# Created: October 7, 2017 Updated: October 20, 2018
# Edited by: Peter Callaghan November 10, 2019

# Purpose: To generate data to be mailed to OPS335 instructor in order
#          to mark OPS335 assignment #2

# Error-checking prior to running shell script
# Check that user is logged on as root

if [ `id -u` -ne 0 ]
then
  echo "You must run this shell script as root" >&2
  exit 1
fi

# Check that mailx application has been installed

if ! which mailx > /dev/null 2> /dev/null 
then
  echo "You need to run \"yum install mailx\" prior to running this shell script" >&2
  exit 1
fi

nameserver=australinea
nameserveraddress=172.28.105.2
mailtransferagent=asia
mailtransferaddress=172.28.105.5
mailsubmissionagent=europe
mailsubmissionaddress=172.28.105.6
sambaserver=southamerica
sambaaddress=172.28.105.8
tld=ops
sld=earth
bld=continents

if ! virsh list | egrep -iqs "($nameserver|$mailtransferagent|$mailsubmissionagent|$sambaserver)"
then
  echo "You need to run your \"$nameserver\", \"$mailtransferagent\", \"$mailsubmissionagent\", and \"$sambaserver\" VMs" >&2
  exit 2
fi


# Prompt for username and Full name

read -p "Please enter YOUR FULL NAME: " fullName

read -p "Please enter YOUR SENECA LOGIN USERNAME: " userID

# Generate Evaluation Report

clear
echo "Your Assignment #2 is being evaluated..."
echo "This make take a few minutes to complete..."


cat <<'PPC' > /tmp/check$mailtransferagent.bash
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

echo "postfix:"`systemctl is-active postfix.service`
echo "postfix:"`systemctl is-enabled postfix.service`
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

echo POSTFIX CONFIG
sed -re '/^$/ d' -e '/^[[:space:]]*#/ d' /etc/postfix/main.cf
echo GIFNOC XIFTSOP
echo

yum install -y bind-utils &> /dev/null
echo MAILXCHANGE
dig @172.28.105.2 MX continents.earth.ops. | grep -E "^[^;].*MX"
echo EGNAHCXLIAM
PPC

cat <<'PPC' > /tmp/check$mailsubmissionagent.bash
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

echo "postfix:"`systemctl is-active postfix.service`
echo "postfix:"`systemctl is-enabled postfix.service`
echo

echo "dovecot:"`systemctl is-active dovecot.service 2> /dev/null` 
echo "dovecot:"`systemctl is-enabled dovecot.service 2> /dev/null` 
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

echo POSTFIX CONFIG
sed -re '/^$/ d' -e '/^[[:space:]]*#/ d' /etc/postfix/main.cf
echo GIFNOC XIFTSOP
echo

echo DOVECOT CONFIG
sed -re '/^$/ d' -e '/^[[:space:]]*#/ d' /etc/dovecot/dovecot.conf
sed -re '/^$/ d' -e '/^[[:space:]]*#/ d' /etc/dovecot/conf.d/10-{auth,mail,ssl}.conf
echo GIFNOC TOCEVOD
echo

echo ALIASES
echo root:`postalias -q root hash:/etc/aliases`
PPC

cat <<'PPC' > /tmp/check$sambaserver.bash
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

echo "smb:"`systemctl is-active smb.service`
echo "smb:"`systemctl is-enabled smb.service`
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
echo SELBALTI
echo

echo USERS
pdbedit -L
echo SRUSE
echo

echo SAMBA-CONFIG
testparm -s 2>&1
echo GIFNOC-ABMAS
echo

echo SELinuxSEttings
getsebool -a | grep samba
echo sgnittESxuniLES
echo

echo SELinuxContexts
ls -LZR /supercontinents
echo stxetonCxuniLES
PPC

ssh $mailtransferaddress 'bash ' < /tmp/check$mailtransferagent.bash > /tmp/output-$mailtransferagent.txt 2>&1
ssh $mailsubmissionaddress 'bash ' < /tmp/check$mailsubmissionagent.bash > /tmp/output-$mailsubmissionagent.txt 2>&1
ssh $sambaaddress 'bash ' < /tmp/check$sambaserver.bash > /tmp/output-$sambaserver.txt 2>&1

tar -czf a2.$userID.tgz /tmp/output-$mailtransferagent.txt /tmp/output-$mailsubmissionagent.txt /tmp/output-$sambaserver.txt

rm -f  /tmp/check$mailtransferagent.bash /tmp/check$mailsubmissionagent.bash /tmp/check$sambaserver.bash /tmp/output-$mailtransferagent.txt /tmp/output-$mailsubmissionagent.txt /tmp/output-$sambaserver.txt 2> /dev/null
 
echo "The script created a file called a2.$userID.tgz in the current directory.  Upload that to blackboard for Assignment 2."
