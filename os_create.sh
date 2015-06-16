
hostnamectl set-hostname "ssmdb"
hostnamectl status

fdisk -l
fdisk /dev/vdb

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
mkdir mysql oracle githome svnroot

mount /dev/dbvg/dblv1 /mysql
mount /dev/dbvg/dblv2 /oracle
mount /dev/scmvg/scmlv1 /githome
mount /dev/scmvg/scmlv2 /svnroot

useradd mysql
useradd oracle
useradd githome
useradd svnroot

chown mysql:mysql /mysql
chown oracle:oracle /oracle
chown githome:githome /githome
chown svnroot:svnroot /svnroot
chmod 700 /mysql /oracle /githome /svnroot

cat << EOF >> /etc/fstab
/dev/mapper/dbvg-dblv1  /mysql                  ext4    defaults        1 3
/dev/mapper/dbvg-dblv2  /oracle                 ext4    defaults        1 4
/dev/mapper/scmvg-scmlv1        /githome        ext4    defaults        1 5
/dev/mapper/scmvg-scmlv2        /svnroot        ext4    defaults        1 6
EOF

yum install cvs
yum install git
yum install gcc
yum install gcc-c++
yum install tcl
yum install ruby
yum install uuid

