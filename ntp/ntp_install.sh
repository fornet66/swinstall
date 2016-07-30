
use pool found in http://www.pool.ntp.org/ as ntp.conf

modify /etc/ntp.conf
add following lines as public server
server 0.us.pool.ntp.org
server 1.us.pool.ntp.org
server 2.us.pool.ntp.org
server 3.us.pool.ntp.org

add log config
logfile /var/log/ntp.log

yum install ntp -y
yum install nmap -y
tzselect
cp -f /usr/share/zoneinfo/Asia/Shanghai /etc/localtime
hwclock -w
date -s 12/04/2014
date -s 10:38
ntpq -c version
ntpq -p

client crontab add
10 * * * * /usr/sbin/ntpdate 10.1.1.222

# jvm use /etc/sysconfig/clock for time calc
cat << EOF >> /etc/sysconfig/clock
ZONE="Asia/Shanghai"
UTC=false
ARC=false
EOF

