
usermod -G wheel xienan
wget -qO- https://get.docker.com/ | sh
sudo usermod -aG docker xienan
yum install -y device_mapper_libs

docker run hello-world

