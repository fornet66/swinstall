
# docker daemon -H unix:///var/run/docker.sock -H tcp://0.0.0.0:2375 --group="docker" --graph="/docker"

docker -H 10.1.234.28:2375 restart scm
docker -H 10.1.234.28:2375 restart gogs
docker -H 10.1.234.28:2375 restart mariadb
docker -H 10.1.234.29:2375 restart nexus
docker -H 10.1.234.29:2375 restart jenkins
docker -H 10.1.234.29:2375 restart sonaruqbe
docker -H 10.1.234.29:2375 restart ansible
docker -H 10.1.234.29:2375 restart nodejs
docker -H 10.1.234.29:2375 restart robotframework
docker -H 10.1.234.30:2375 restart nginx

# redis
docker run -d --name=redis -h redis -ti -p 6379:6379 -v /etc/localtime:/etc/localtime:ro \
    -v /data/redis:/redis --restart=on-failure:3 redis /redis/6379.conf
# mongodb
docker run -d --name=mongodb -h mongodb -ti -p 27017:27017 \
    -v /etc/localtime:/etc/localtime:ro -v /data/mongodb:/data/db \
    --restart=on-failure:3 tutum/mongodb
# owncloud
docker run -d --name=owncloud -h owncloud -ti -v /etc/localtime:/etc/localtime:ro \
    -v /data/owncloud:/var/www/html --restart=on-failure:3 owncloud
# scm
docker -H 10.1.234.28:2375 run -d --name=scm -ti -p 8080:8080 -v /etc/localtime:/etc/localtime:ro -v /home/svnroot/scm-data:/home/svnroot/scm-data -v /svnroot:/svnroot --restart=on-failure:3 scm
# gogs
docker -H 10.1.234.28:2375 run -d --name=gogs -ti -p 3000:3000 -v /etc/localtime:/etc/localtime:ro -v /git:/git --restart=on-failure:3 gogs
# mariadb
docker -H 10.1.234.28:2375 run -d --name=mariadb -ti -p 3306:3306 -v /etc/localtime:/etc/localtime:ro -v /mariadb:/mariadb --restart=on-failure:3 mariadb
# sonatype nexus
docker -H 10.1.234.29:2375 run -d --name=nexus -ti -p 8081:8081 -v /etc/localtime:/etc/localtime:ro -v /home/nexus/sonatype-work:/home/nexus/sonatype-work --restart=on-failure:3 nexus
# jenkins
docker -H 10.1.234.29:2375 run -d --name=jenkins -ti -p 8080:8080 -v /etc/localtime:/etc/localtime:ro -v /home/jenkins/jenkins-work:/home/jenkins/jenkins-work -v /home/jenkins/jenkins-backup:/home/jenkins/jenkins-backup --restart=on-failure:3 jenkins
# soanrqube
docker -H 10.1.234.29:2375 run -d --name=sonarqube -ti -p 9000:9000 -v /etc/localtime:/etc/localtime:ro --restart=on-failure:3 sonarqube
# nginx
docker -H 10.1.234.30:2375 run -d --name=nginx -ti -p 80:80 -p 443:443 -v /etc/localtime:/etc/localtime:ro --restart=always nginx
# rethinkdb
docker run \
	-ti \
	-d \
	--restart=always \
	--name shipyard-rethinkdb \
	rethinkdb
# swarm
docker run \
	-ti \
	-d \
	--restart=always \
	--name shipyard-swarm \
	--link shipyard-proxy:proxy \
	--volumes-from=shipyard-certs \
	-v $(pwd)/cluster:/tmp/cluster \
	swarm:latest \
	manage --host tcp://0.0.0.0:3375 file:///tmp/cluster
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
	--docker tcp://swarm:3375

# mac
sudo docker-machine start default
sudo docker-machine stop default
sudo docker-machine env default
sudo docker -H 192.168.99.100:2376 --tls=true --tlsverify=true --tlscacert=/Users/xienan/.docker/machine/machines/default/ca.pem --tlscert=/Users/xienan/.docker/machine/machines/default/cert.pem --tlskey=/Users/xienan/.docker/machine/machines/default/key.pem images

