#!/bin/bash

# check-assn1-p1.bash

# Author: Murray Saul
# Created: January 20, 2017  Revised: September 16, 2018
# Edited by: Peter Callaghan January 13, 2019

# Purpose: To generate data to be mailed to OPS335 instructor in order
#          to mark OPS335 assignment #1 - Part 1

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

if ! virsh list | grep -iqs blofeld
then
  echo "You need to run your cloning-source \"blofeld\" VM" >&2
  exit 2
fi

# Prompt for username and Full name

read -p "Please enter YOUR FULL NAME: " fullName

read -p "Please enter YOUR SENECA LOGIN ID (username): " userID

profemail=""
done=1
while [ $done -ne 0 ]
do
	read -p "Enter your section:" section
	case $section in
		a|A)	profemail="chris.johnson@senecacollege.ca"
			done=0
			;;
		b|B)
			profemail="andres.lombo@senecacollege.ca"
			done=0
			;;
		c|C)
			profemail="peter.callaghan@senecacollege.ca"
			done=0
			;;
		d|D)
			profemail="ahad.mammadov@senecacollege.ca"
			done=0
			;;
		*) echo "That is not a current section."
			;;
	esac
done

cat <<'PPC' > /tmp/checkblofeld.bash
#!/bin/bash

#Ensure the host name has been set correctly
echo "Hostname:"`hostname`
echo

echo "SELinux status:"`getenforce`
echo

echo "DOMAIN:"`grep -E "^DOMAIN=\"?bond\.villains\.ops\"?$" /etc/sysconfig/network-scripts/ifcfg-*`
echo "DOMAINNAME:"`grep -E "^DOMAINNAME=\"?bond\.villains\.ops\"?$" /etc/sysconfig/network`
echo "SEARCH:"`grep -E "^search bond\.villains\.ops" /etc/resolv.conf`
echo

ping -c1 -q 142.204.140.90 &> /dev/null
echo PING:$?

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

echo "firewalld:"`systemctl is-active firewalld.service`
echo "firewalld:"`systemctl is-enabled firewalld.service`
echo

echo "iptables:"`systemctl is-active iptables.service`
echo "iptables:"`systemctl is-enabled iptables.service`
echo

echo USERS
grep /home /etc/passwd | wc -l
echo SRESU

echo IPTABLES
iptables -L -v -n
echo
PPC

cat <<'PPC' > /tmp/checkhost.bash
#!/bin/bash

echo BACKUPSCRIPT
cat /root/bin/assnBackup.bash 2> /dev/null
echo TPIRCSPUKCAB
echo

ping -c1 -q 172.19.1.100 > /dev/null 2>&1
echo PING:$? 

echo CRON
crontab -l
echo NORC
echo

echo ACTIVE
last | grep reboot
echo EVITCA
echo

echo FULLBACKUP
ls -l /backup/full
echo PUKCABLLUF
echo

echo incremental:`ls -1 /backup/incremental | grep -v 'vm' | wc -l`
echo
PPC

address=172.19.1.100
ssh $address 'bash ' < /tmp/checkblofeld.bash > /tmp/output-blofeld.txt 2>&1

bash /tmp/checkhost.bash > /tmp/output-host.txt 2>&1



# Send report information to instructor

cat > message.txt <<+
If you have received this e-mail message, then
you have successfully submitted the remaining
information for your OPS335 assignment 1 (part 1)

+



mail -s "OPS335-a1p1-$fullName" -a /tmp/output-blofeld.txt -a /tmp/output-host.txt $profemail < /dev/null
mail -s "OPS335-a1p1-confirmation" "$userID@myseneca.ca"  < message.txt

rm /tmp/output-blofeld.txt /tmp/checkblofeld.bash 2> /dev/null

cat <<+

Submission of OPS335 assignment 1 (part 1) completed.
A confirmation message should have been sent to your
Seneca email account. If you did NOT receive a confirmation
message, please check that you install the mailx package
or otherwise, contact your OPS335 instructor.

+