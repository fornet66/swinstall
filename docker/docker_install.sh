
usermod -G wheel xienan
wget -qO- https://get.docker.com/ | sh
sudo usermod -aG docker xienan
yum install -y device_mapper

docker run hello-world

#modify /usr/lib/systemd/system/docker.service
systemctl daemon-reload
systemctl start docker.service
docker run -d --name mysql1 mysql
PID=`docker  inspect  --format "{{ .State.Pid }}"  mysql1`
nsenter --target $PID --mount --uts --ipc --net --pid
docker attach `docker ps -q -a`

firewall-cmd --permanent --add-port=5555/tcp

