#!/bin/bash
#  OPS335 Lab 8 configuration check
#  Written by: Peter Callaghan
#  Last Modified: 21 Mar. '18
#  This script runs a series of commands to show the current configuration of the machine it is run on
#  Run it on each of your VMs, and attach the output of each to your lab submission.

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

echo "Firewall"
iptables -L -v -n
echo

if [ "`hostname -s`" == "vm1" ]
then

	echo "webserver status"
	echo "httpd:"`systemctl is-active httpd.service`
	echo "httpd:"`systemctl is-enabled httpd.service`
	echo

	echo "database status"
	echo "mariadb:"`systemctl is-active mariadb.service`
	echo "mariadb:"`systemctl is-enabled mariadb.service`
	echo

	echo "webserver config"
	sed -re "/^$/ d" -e "/^[[:space:]]*#/ d" /etc/httpd/conf/httpd.conf
	echo 

	rounddir=/var/www/html/webmail
	echo "Roundcube Config"
	sed -re '/^($|#|\/\/)/ d' -e '/^\/\*$/,/^\*\/$/ d'  ${rounddir}/config/config.inc.php
	echo

	echo "Roundcube logs"
	cat ${rounddir}/logs/sendmail
	echo
elif [ "`hostname -s`" == "vm2" ]
then
	#postfix status
	echo "postfix:"`systemctl is-active postfix.service`
	echo "postfix:"`systemctl is-enabled postfix.service`
	echo

	echo "postfix configuration"
	sed -re '/^[[:space:]]*#/ d' -e "/^$/ d" /etc/postfix/main.cf | grep tls
	echo

	#certs
	echo "certs"
	ls -l /etc/ssl/private
	ls -l /etc/ssl/certs
	echo
elif [ "`hostname -s`" == "vm3" ]
then
	#dovecot configuration parameters
	echo "Dovecot parameters"
	grep -E '^protocols' /etc/dovecot/dovecot.conf
	grep -E '^(ssl|ssl_cert|ssl_key)' /etc/dovecot/conf.d/10-ssl.conf
	grep -E '^disable_plaintext_auth' /etc/dovecot/conf.d/10-auth.conf
	echo

	#postfix status
	echo "postfix:"`systemctl is-active postfix.service`
	echo "postfix:"`systemctl is-enabled postfix.service`
	echo

	#dovecot status
	echo "dovecot:"`systemctl is-active dovecot.service`
	echo "dovecot:"`systemctl is-enabled dovecot.service`
	echo

	#certs
	echo "certs"
	ls -l /etc/ssl/private
	ls -l /etc/ssl/certs
	echo

else
	echo `hostname`" is not the name any machine involved in this lab is supposed to have." >&2
	exit 3
fi
