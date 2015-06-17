
yum install golang
wget https://github.com/gogits/gogs/releases/download/v0.6.1/linux_amd64.zip
unzip linux_amd64.zip
cp app.ini /home/git/gogs/custom/conf/app.ini
gogs web


