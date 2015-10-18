
# run on 101.234.30
yum install nginx
cp nginx.conf /etc/nginx/nginx.conf
systemctl start nging.service

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

# for 10.1.234.30 # jenkins
#firewall-cmd --permanent --zone=public --add-rich-rule="rule family="ipv4" \
#	source address="172.17.0.0/24" \
#	port protocol="tcp" port="8080" accept"

# for 10.1.234.30 # nexus
#firewall-cmd --permanent --zone=public --add-rich-rule="rule family="ipv4" \
#	source address="172.17.0.0/24" \
#	port protocol="tcp" port="8081" accept"

# for 10.1.234.30 # sonarqube
#firewall-cmd --permanent --zone=public --remove-rich-rule="rule family="ipv4" \
#	source address="172.17.0.0/24" \
#	port protocol="tcp" port="8082" accept"

# for 10.1.234.30 # ssm
firewall-cmd --permanent --zone=public --add-rich-rule="rule family="ipv4" \
	source address="172.17.0.0/24" \
	port protocol="tcp" port="8083" accept"

# for 10.1.234.30 # docsys
#firewall-cmd --permanent --zone=public --add-rich-rule="rule family="ipv4" \
#	source address="172.17.0.0/24" \
#	port protocol="tcp" port="8085" accept"

# for 10.1.234.30 # sonarcheck
firewall-cmd --permanent --zone=public --add-rich-rule="rule family="ipv4" \
	source address="172.17.0.0/24" \
	port protocol="tcp" port="8086" accept"

systemctl restart firewall-cmd

