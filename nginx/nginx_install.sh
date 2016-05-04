
# run on 101.234.30
yum install nginx
cp nginx.conf /etc/nginx/nginx.conf
systemctl start nging.service

openssl req -new -newkey rsa:2048 -sha256 -nodes -out yjcloud.csr -keyout yjcloud.key -subj "/C=CN/ST=Beijing/L=Beijing/O=yjcloud/OU=exchanger /CN=yjcloud.com"
openssl x509 -req -days 365 -in yjcloud.csr -signkey yjcloud.key -out yjcloud.crt

# for 10.1.234.28 #gogs
firewall-cmd --permanent --zone=public --add-rich-rule="rule family="ipv4" \
	source address="10.1.234.30/24" \
	port protocol="tcp" port="3000" accept"

# for 10.1.234.28 #scm manager
firewall-cmd --permanent --zone=public --add-rich-rule="rule family="ipv4" \
	source address="10.1.234.30/24" \
	port protocol="tcp" port="8080" accept"

# for 10.1.234.28 #viewvc
firewall-cmd --permanent --zone=public --add-rich-rule="rule family="ipv4" \
	source address="10.1.234.30/24" \
	port protocol="tcp" port="8081" accept"

# for 10.1.234.29 #jenkins
firewall-cmd --permanent --zone=public --add-rich-rule="rule family="ipv4" \
	source address="10.1.234.30/24" \
	port protocol="tcp" port="8080" accept"

# for 10.1.234.29 #sonatype nexus
firewall-cmd --permanent --zone=public --add-rich-rule="rule family="ipv4" \
	source address="10.1.234.30/24" \
	port protocol="tcp" port="8081" accept"

# for 10.1.234.29 #sonarqube
firewall-cmd --permanent --zone=public --add-rich-rule="rule family="ipv4" \
	source address="10.1.234.30/24" \
	port protocol="tcp" port="9000" accept"

# for 10.1.234.29 #mongodb
firewall-cmd --permanent --zone=public --add-rich-rule="rule family="ipv4" \
	source address="10.1.234.30/24" \
	port protocol="tcp" port="28017" accept"

# for 10.1.234.30 # shipyard
firewall-cmd --permanent --zone=public --add-rich-rule="rule family="ipv4" \
	source address="172.17.0.0/24" \
	port protocol="tcp" port="8080" accept"

# for 10.1.234.30 # ssm
firewall-cmd --permanent --zone=public --add-rich-rule="rule family="ipv4" \
	source address="172.17.0.0/24" \
	port protocol="tcp" port="8083" accept"

# for 10.1.234.30 # sonarcheck
firewall-cmd --permanent --zone=public --add-rich-rule="rule family="ipv4" \
	source address="172.17.0.0/24" \
	port protocol="tcp" port="8086" accept"

systemctl restart firewall-cmd

