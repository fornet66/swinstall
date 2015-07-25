
# use bash to install oracle, must not set DISPLAY var
mkdir -p app/product/11.2.0
cat << EOF >> .bash_profile
export TMP=/tmp
export TMPDIR=$TMP
export ORACLE_BASE=/home/oracle
export ORACLE_HOME=$ORACLE_BASE/app/product/11.2.0
export ORACLE_SID=aissm
export ORACLE_TERM=xterm
export NLS_LANG=AMERICAN_AMERICA.ZHS16GBK
export PATH=$ORACLE_HOME/bin:$PATH
export LD_LIBRARY_PATH=$ORACLE_HOME/lib:$LD_LIBRARY_PATH
umask 022
EOF

cat << EOF >> /etc/security/limits.conf
oracle soft nproc 2047
oracle hard nproc 16384 
oracle soft nofile 1024
oracle hard nofile 65536 
oracle soft stack 102405
EOF

cat << EOF >> /etc/sysctl.conf
fs.aio-max-nr = 1048576
fs.file-max = 6815744
kernel.shmall = 2097152
kernel.shmmax = 536870912
kernel.shmmni = 4096
kernel.sem = 250 32000 100 128 
net.ipv4.ip_local_port_range = 9000 65500
net.core.rmem_default = 262144
net.core.rmem_max = 4194304
net.core.wmem_default = 262144
net.core.wmem_max = 1048576
EOF

yum install glibc.i686 -y
yum install glibc-devel.i686 -y
yum install compat-libstdc++-33 -y
yum install compat-libstdc++-33.i686 -y
yum install compat-gcc-44-c++ -y
yum install libgcc.i686 -y
yum install elfutils-libelf-devel -y
yum install libaio-devel -y
yum install libaio.i686 -y
yum install libaio-devel.i686 -y
yum install libXp -y
yum install glibc-kernheaders -y
yum install compat-db -y
yum install control-center -y
yum install unixODBC -y
yum install unixODBC-devel -y
yum install unixODBC.i686 -y
yum install unixODBC-devel.i686 -y
wget http://mirror.centos.org/centos/5/os/x86_64/CentOS/pdksh-5.2.14-37.el5_8.1.x86_64.rpm
yum localinstall pdksh-5.2.14-37.el5_8.1.x86_64.rpm -y


systemctl stop firewalld.service
runInstaller -silent -responseFile /tmp/db_install.rsp
dbca -silent -generateScripts -gdbName aissm -scriptDest /tmp/aissm -templateName /home/oracle/app/product/11.2.0/assistants/dbca/templates/General_Purpose.dbc
netca -silent -responseFile /tmp/netca.rsp

create tablespace tbsaissm datafile '/oracle/aissm/aissm01.dbf' size 2048M autoextend off EXTENT MANAGEMENT LOCAL;
create user aissm identified by aissm default tablespace tbsaissm temporary tablespace temp;
grant create session to aissm;
grant dba to aissm;
systemctl start firewalld.service
firewall-cmd --permanent --add-port=1521/tcp
firewall-cmd --reload

