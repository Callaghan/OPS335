#!/bin/bash

# check-assn1-p2.bash

# Author: Murray Saul
# Created: February 17, 2017   Updated: October 12, 2018
# Edited by: Peter Callaghan July 1, 2019

# Purpose: To generate data to be mailed to OPS335 instructor in order
#          to mark second portion of OPS335 assignment #1 - Part 2

# Error-checking prior to running shell script
# Check that user is logged on as root

primaryserver=wendys
primaryaddress=172.21.5.2
secondaryserver=harveys
secondaryaddress=172.21.5.3
tld=ops
sld=fastfood
bld=restaurant

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

if ! virsh list | egrep -iqs "($secondaryserver|$primaryserver)"
then
  echo "You need to run your \"$secondaryserver\", and \"$primaryserver\" VMs" >&2
  exit 2
fi



# Prompt for username and Full name

read -p "Please enter YOUR FULL NAME: " fullName

read -p "Please enter YOUR SENECA LOGIN USERNAME: " userID

profemail="peter.callaghan@senecacollege.ca"
#done=1
#while [ $done -ne 0 ]
#do
#	read -p "Enter your section:" section
#	case $section in
#		a|A)	profemail="chris.johnson@senecacollege.ca"
#			done=0
#			;;
#		b|B)
#			profemail="andres.lombo@senecacollege.ca"
#			done=0
#			;;
#		c|C)
#			profemail="peter.callaghan@senecacollege.ca"
#			done=0
#			;;
#		d|D)
#			profemail="ahad.mammadov@senecacollege.ca"
#			done=0
#			;;
#		*) echo "That is not a current section."
#			;;
#	esac
#done

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


echo "DOMAIN:"`grep -E "^DOMAIN=\"?$bld\.$sld\.$tld\"?$" /etc/sysconfig/network-scripts/ifcfg-*`
echo "DOMAINNAME:"`grep -E "^DOMAINNAME=\"?$bld\.$sld\.$tld\"?$" /etc/sysconfig/network`
echo "SEARCH:"`grep -E "^search $bld\.$sld\.$tld" /etc/resolv.conf`
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

echo "DOMAIN:"`grep -E "^DOMAIN=\"?$bld\.$sld\.$tld\"?$" /etc/sysconfig/network-scripts/ifcfg-*`
echo "DOMAINNAME:"`grep -E "^DOMAINNAME=\"?$bld\.$sld\.$tld\"?$" /etc/sysconfig/network`
echo "SEARCH:"`grep -E "^search $bld\.$sld\.$tld" /etc/resolv.conf`
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


# Send report information to instructor

cat > message.txt <<+
If you have received this e-mail message, then
you have successfully submitted the remaining
information for your OPS335 assignment 1 (part 2)
+

mail -s "OPS335-a1p2-$fullName" -a /tmp/output-$primaryserver.txt -a /tmp/output-$secondaryserver.txt $profemail < message.txt
tries=0
sent=0
while [ $tries -lt 10 ]
do
        sent=`tail /var/log/maillog | grep -cE "to=<${profemail}>.*status=sent" 2>/dev/null`
        if [ $sent -gt 0 ]
        then
                tries=10
        else
                tries=$[$tries+1]
                sleep 10
        fi
done

if [ $sent -gt 0 ]
then
	mail -s "OPS335-a1p2-confirmation" "$userID@myseneca.ca"  < message.txt
	cat message.txt
else
	echo "The email was not sent.  This script must be run on campus, or Seneca's email servers will not accept the email.  If you are on campus try again in a few minutes or ask your professor for help." >&2
fi

rm -f  /tmp/check$primaryserver.bash /tmp/check$secondaryserver.bash /tmp/output-$primaryserver.txt /tmp/output-$secondaryserver.txt message.txt 2> /dev/null
