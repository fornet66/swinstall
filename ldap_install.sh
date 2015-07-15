
# run on 10.1.234.28
yum install openldap
yum install openladp-server
yum install openldap-clients

ldapsearch -h ldap.asiainfo.com -LLL -D 'ai\xienan' -W -b 'ou=asiainfo-users,dc=ai,dc=com'

