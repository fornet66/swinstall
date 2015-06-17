
yum install mariadb
yum install mariadb-server
yum install mariadb-devel
## start mariadb
cp /usr/local/mysql/my-huge.cnf /etc/my.cnf
#change data_dir to /mariadb/mysql
setenforce 0
vi /etc/sysconfig/selinux   # change enforcing to disabled
systemctl start mariadb.service
mysql_secure_installation
firewall-cmd --add-service=mysql --permanent

