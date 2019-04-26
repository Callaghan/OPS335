#!/bin/bash

# check-assn2.bash

# Author: Murray Saul
# Created: October 7, 2017 Updated: October 20, 2018
# Edited by: Peter Callaghan February 12, 2019

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


if ! virsh list | egrep -iqs "(wint|carver|drax|zorin)"
then
  echo "You need to run your \"wint\", \"carver\", \"drax\", and \"zorin\" VMs" >&2
  exit 2
fi


# Prompt for username and Full name

read -p "Please enter YOUR FULL NAME: " fullName

read -p "Please enter YOUR SENECA LOGIN USERNAME: " userID

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

# Generate Evaluation Report

clear
echo "Your Assignment #2 is being evaluated..."
echo "This make take a few minutes to complete..."


cat <<'PPC' > /tmp/checkcarver.bash
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
dig @172.19.1.2 MX bond.villains.ops. | grep -E "^[^;].*MX"
echo EGNAHCXLIAM
PPC

cat <<'PPC' > /tmp/checkdrax.bash
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

cat <<'PPC' > /tmp/checkzorin.bash
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
PPC

address=172.19.1.5
ssh $address 'bash ' < /tmp/checkcarver.bash > /tmp/output-carver.txt 2>&1
address=172.19.1.6
ssh $address 'bash ' < /tmp/checkdrax.bash > /tmp/output-drax.txt 2>&1
address=172.19.1.8
ssh $address 'bash ' < /tmp/checkzorin.bash > /tmp/output-zorin.txt 2>&1

# Send report information to instructor

cat > message.txt <<+
If you have received this e-mail message, then
you have successfully submitted the remaining
information for your OPS335 assignment 2

+

mail -s "OPS335-a2-$fullName" -a /tmp/output-carver.txt -a /tmp/output-drax.txt -a /tmp/output-zorin.txt $profemail < message.txt


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
	mail -s "OPS335-a2-confirmation" "$userID@myseneca.ca"  < message.txt
cat <<+
Submission of OPS335 assignment 2 completed.
A confirmation message should have been sent to your
Seneca email account.
+
else
	echo "The email was not sent.  This script must be run on campus, or Seneca's email servers will not accept the email.  If you are on campus try again in a few minutes or ask your professor for help." >&2
fi

rm -f  /tmp/checkcarver.bash /tmp/checkdrax.bash /tmp/checkzorin.bash /tmp/output-carver.txt /tmp/output-drax.txt /tmp/output-zorin.txt message.txt 2> /dev/null






