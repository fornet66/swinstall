
# run on 10.1.234.28
yum install openldap
yum install openladp-server
yum install openldap-clients
yum install nss-pam-ldapd
yum install nscd
yum install nslcd
systemctl start nscd
systemctl start nslcd
echo "session     required      pam_mkhomedir.so skel=/etc/skel/ umask=0077" >> /etc/pam.d/system-auth
echo "session     optional      pam_ldap.so" >> /etc/pam.d/system-auth

ldapsearch -h ldap.asiainfo.com -x -b 'ou=asiainfo-users,dc=ai,dc=com' -LLL "(sAMAccountName=gaohn)" -D 'ai\xienan' -w xienan
authconfig --enableldap --enableldapauth --ldapserver=ldap.asiainfo.com \
	--ldapbasedn="ou=asiainfo-users,dc=ai,dc=com" --update

