
# run on 10.1.234.28
yum install mariadb
yum install mariadb-server
yum install mariadb-devel
## start mariadb
cp /usr/local/mysql/my-huge.cnf /etc/my.cnf
#change data_dir to /mariadb/mysql
setenforce 0
# change enforcing to disabled
sed -i "s/SELINUX=enforcing/SELINUX=disabled/" /etc/selinux/config

mysql -u root -p admin

systemctl start mariadb.service
mysql_secure_installation
firewall-cmd --add-service=mysql --permanent

