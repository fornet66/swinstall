
# run on 10.1.234.28
yum install mariadb
yum install mariadb-server
yum install mariadb-devel
## start mariadb
cp /usr/local/mysql/my-huge.cnf /etc/my.cnf
echo "init_connect=\'set autocommit=0\'" >> my.cnf
echo "transaction_isolation = READ-COMMITTED" >> my.cnf
#change data_dir to /mariadb/mysql
setenforce 0
# change enforcing to disabled
sed -i "s/SELINUX=enforcing/SELINUX=disabled/" /etc/selinux/config

mysql -u root -p mariadb_admin
grant all privileges on *.* to 'root'@'%' identified by 'admin' with grant option;
flush all privileges;
SELECT @@global.tx_isolation;
SELECT @@session.tx_isolation;
SET AUTOCOMMIT = 0;
set global init_connect="set autocommit=0";

systemctl start mariadb.service
mysql_secure_installation
firewall-cmd --add-service=mysql --permanent

