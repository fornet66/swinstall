
yum install ntp -y
yum install nmap -y
tzselect
cp -f /usr/share/zoneinfo/Asia/Shanghai /etc/localtime
hwclock -w
date -s 12/04/2014
date -s 10:38
ntpq -c version
ntpq -p

