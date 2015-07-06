
# run on 10.1.234.28
yum install httpd
yum install php
yum install subversion
yum install mod_dav_svn
unzip svnadmin.zip
mv svnadmin.zip /var/www/html
chmod 777 /var/www/html/svnadmin/data
firewall-cmd --add-port=3690/tcp --permanent

