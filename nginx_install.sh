
yum install nginx
cp nginx.conf /etc/nginx/nginx.conf
systemctl start nging.service

firewall-cmd --permanent --zone=public --add-rich-rule="rule family="ipv4" \
	source address="10.1.234.29/24" \
	port protocol="tcp" port="8080" accept"

