
# run on every machine
hostnamectl set-hostname "ssmdb"
hostnamectl status

fdisk -l
fdisk /dev/vdb
cat /proc/partitions
partprobe /dev/vdb

echo "- - -" > /sys/class/scsi_host/host2/scan
pvcreate /dev/vdb1 /dev/vdb2
pvdisplay
pvs
vgcreate -s 16M dbvg /dev/vdb1
vgcreate -s 16M scmvg /dev/vdb2
lvcreate -L 50G -n dblv1 dbvg
lvcreate -l 100%FREE -n dblv2 dbvg
lvcreate -L 50G -n scmlv1 scmvg
lvcreate -l 100%FREE -n scmlv2 scmvg
mkfs.ext4 /dev/dbvg/dblv1
mkfs.ext4 /dev/dbvg/dblv2
mkfs.ext4 /dev/scmvg/scmlv1
mkfs.ext4 /dev/scmvg/scmlv2
mkdir mariadb oracle git svnroot

mount /dev/dbvg/dblv1 /mysql
mount /dev/dbvg/dblv2 /oracle
mount /dev/scmvg/scmlv1 /git
mount /dev/scmvg/scmlv2 /svnroot

useradd oracle
useradd git
useradd svnroot
echo "as1a1nf0" | passwd --stdin oracle
echo "as1a1nf0" | passwd --stdin git
echo "as1a1nf0" | passwd --stdin svnroot


chown mysql:mysql /mariadb
chown oracle:oracle /oracle
chown git:git /git
chown svnroot:svnroot /svnroot
chmod 700 /mysql /oracle /git /svnroot

cat << EOF >> /etc/fstab
/dev/mapper/dbvg-dblv1  /mariadb                ext4    defaults        1 3
/dev/mapper/dbvg-dblv2  /oracle                 ext4    defaults        1 4
/dev/mapper/scmvg-scmlv1        /git        ext4    defaults        1 5
/dev/mapper/scmvg-scmlv2        /svnroot        ext4    defaults        1 6
EOF

yum install epel-release
yum install cvs
yum install subversion
yum install git
yum install gcc
yum install gcc-c++
yum install tcl
yum install uuid
yum install pcre
yum install telnet
yum install java-1.7.0

systemctl --failed

uncomment /home/pam.d/su   auth            required        pam_wheel.so use_uid to disable su command
useradd xienan
usermod -G wheel xienan
echo "as1a1nf0" | passwd --stdin xienan


10.1.234.47/48/49		root/cucqc@123
10.1.234.50/51/52/54	root/robot@123


tar czf - unibss | openssl des3 -salt -k unibss_dev -out /home/cvsroot/cvsbak/rd2_unibss_$DATE.tgz

# change jvm time
cat << EOF >> /etc/sysconfig/clock
ZONE="Asia/Shanghai"
UTC=false
ARC=false
EOF

