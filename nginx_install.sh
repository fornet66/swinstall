
# run on 101.234.30
yum install nginx
cp nginx.conf /etc/nginx/nginx.conf
systemctl start nging.service

# for 10.1.234.29 #ssm
firewall-cmd --permanent --zone=public --add-rich-rule="rule family="ipv4" \
	source address="10.1.234.30/24" \
	port protocol="tcp" port="8080" accept"

# for 10.1.234.28 #gogs
firewall-cmd --permanent --zone=public --add-rich-rule="rule family="ipv4" \
	source address="10.1.234.30/24" \
	port protocol="tcp" port="3000" accept"

# for 10.1.234.28 #svnadmin
firewall-cmd --permanent --zone=public --add-rich-rule="rule family="ipv4" \
	source address="10.1.234.30/24" \
	port protocol="tcp" port="80" accept"

systemctl restart firewall-cmd

