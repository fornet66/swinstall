
# ./mysql_install_db \
# --basedir=/home/yjcloud/soft/mysql-5.6.30-linux-glibc2.5-x86_64 \
# --datadir=/data/mysql

# run on 10.1.234.28
yum install mariadb
yum install mariadb-server
yum install mariadb-devel
mysql_install_db
## start mariadb
cp /usr/local/mysql/my-huge.cnf /etc/my.cnf
echo "max_connections=500" >> my.cnf
echo "default-storage-engine=INNODB" >> my.cnf
echo "lower_case_table_names=1" >> my.cnf
echo "mysql_install_db" >> my.cnf
echo "init_connect=\'set autocommit=0\'" >> my.cnf
echo "transaction_isolation = READ-COMMITTED" >> my.cnf
#change data_dir to /mariadb/mysql
setenforce 0
# change enforcing to disabled
sed -i "s/SELINUX=enforcing/SELINUX=disabled/" /etc/selinux/config

mysql -u root -p as1a1nf0
grant all privileges on *.* to 'root'@'%' identified by 'admin' with grant option;
flush all privileges;
SELECT @@global.tx_isolation;
SELECT @@session.tx_isolation;
SET AUTOCOMMIT = 0;
set global init_connect="set autocommit=0";

systemctl start mariadb.service
mysql_secure_installation
firewall-cmd --add-service=mysql --permanent

CREATE DATABASE aitest DEFAULT CHARACTER SET utf8;
create user 'aitest'@'%' identified by 'aitest';
grant all privileges on aitest.* to 'aitest'@'%';
flush privileges;

