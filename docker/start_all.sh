
# docker daemon -H unix:///var/run/docker.sock -H tcp://0.0.0.0:5555 --group="docker" --graph="/docker"

docker -H 10.1.234.28:5555 restart scm
docker -H 10.1.234.28:5555 restart gogs
docker -H 10.1.234.28:5555 restart mariadb
docker -H 10.1.234.29:5555 restart nexus
docker -H 10.1.234.29:5555 restart jenkins
docker -H 10.1.234.29:5555 restart sonaruqbe
docker -H 10.1.234.30:5555 restart nginx

# scm
docker -H 10.1.234.28:5555 run -d --name=scm -t -p 8080:8080 -v /etc/localtime:/etc/localtime:ro -v /home/svnroot/scm-data:/home/svnroot/scm-data -v /svnroot:/svnroot --restart=on-failure:3 scm
# gogs
docker -H 10.1.234.28:5555 run -d --name=gogs -t -p 3000:3000 -v /etc/localtime:/etc/localtime:ro -v /git:/git --restart=on-failure:3 gogs
# mariadb
docker -H 10.1.234.28:5555 run -d --name=mariadb -t -p 3306:3306 -v /etc/localtime:/etc/localtime:ro -v /mariadb:/mariadb --restart=on-failure:3 mariadb
# sonatype nexus
docker -H 10.1.234.29:5555 run -d --name=nexus -t -p 8081:8081 -v /etc/localtime:/etc/localtime:ro -v /home/nexus/sonatype-work:/home/nexus/sonatype-work --restart=on-failure:3 nexus
# jenkins
docker -H 10.1.234.29:5555 run -d --name=jenkins -t -p 8080:8080 -v /etc/localtime:/etc/localtime:ro -v /home/jenkins/jenkins-work:/home/jenkins/jenkins-work -v /home/jenkins/jenkins-backup:/home/jenkins/jenkins-backup --restart=on-failure:3 jenkins
# soanrqube
docker -H 10.1.234.29:5555 run -d --name=sonarqube -t -p 9000:9000 -v /etc/localtime:/etc/localtime:ro --restart=on-failure:3 sonarqube
# nginx
docker run -d --name=nginx -p 80:80 --restart=always nginx
# swarm
docker run -d --name shipyard-swarm -v $(pwd)/cluster:/tmp/cluster swarm manage file:///tmp/cluster
docker run \
	-ti \
	-d \
	--restart=always \
	--name shipyard-swarm \
	--link shipyard-proxy:proxy \
	--volumes-from=shipyard-certs \
	-v $(pwd)/cluster:/tmp/cluster \
	swarm:latest \
	manage --host tcp://0.0.0.0:3375 proxy:2375 \
	file:///tmp/cluster

# shipyard
docker run \
	-ti \
	-d \
	--restart=always \
	--name shipyard-controller \
	--link shipyard-rethinkdb:rethinkdb \
	--link shipyard-swarm:swarm \
	-p 8080:8080 \
	--volumes-from=shipyard-certs \
	shipyard/shipyard:latest \
	server \
	--docker tcp://swarm:2375

# mac
sudo docker-machine start default
sudo docker-machine stop default
sudo docker-machine env default
sudo docker -H 192.168.99.100:2376 --tls=true --tlsverify=true --tlscacert=/Users/xienan/.docker/machine/machines/default/ca.pem --tlscert=/Users/xienan/.docker/machine/machines/default/cert.pem --tlskey=/Users/xienan/.docker/machine/machines/default/key.pem images

