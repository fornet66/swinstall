
# use bash to install oracle, must not set DISPLAY var
mkdir -p app/product/11.2.0
export TMP=/tmp;
export TMPDIR=$TMP;
export ORACLE_BASE=/home/oracle;
export ORACLE_HOME=$ORACLE_BASE/app/product/11.2.0;
export ORACLE_SID=AISSM;
export ORACLE_TERM=xterm;
export NLS_LANG=AMERICAN_AMERICA.ZHS16GBK
export PATH=$ORACLE_HOME/bin:$PATH
export LD_LIBRARY_PATH=$ORACLE_HOME/lib:$LD_LIBRARY_PATH

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

yum install compat-libstdc++-33
yum install compat-libstdc++-33
yum install compat-gcc-44-c++
yum install elfutils-libelf-devel
yum install libaio-devel
yum install libXp
yum install glibc-kernheaders
yum install compat-db
yum install control-center
yum install unixODBC

./runInstaller -silent -ignorePrereq -ignoreSysPrereqs -responseFile /tmp/db_install.rsp

