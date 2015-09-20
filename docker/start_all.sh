
docker run -d -p 2376:2375 --name swarm -v $(pwd)/cluster:/tmp/cluster swarm manage file:///tmp/cluster
docker -H 127.0.0.1:2376 info

docker -H 10.1.234.28:5555 restart scm
docker -H 10.1.234.28:5555 restart gogs
docker -H 10.1.234.28:5555 restart mariadb
docker -H 10.1.234.28:5555 restart scm
docker -H 10.1.234.29:5555 restart sonaruqbe

# scm
docker -H 10.1.234.28:5555 run -d --name=scm -t -p 8080:8080 -v /etc/localtime:/etc/localtime:ro -v /home/svnroot/scm-data:/home/svnroot/scm-data -v /svnroot:/svnroot --restart=on-failure:3 scm
# gogs
docker -H 10.1.234.28:5555 run -d --name=gogs -t -p 3000:3000 -v /etc/localtime:/etc/localtime:ro -v /git:/git --restart=on-failure:3 gogs
# mariadb
docker -H 10.1.234.28:5555 run -d --name=mariadb -t -p 3306:3306 -v /etc/localtime:/etc/localtime:ro -v /mariadb:/mariadb --restart=on-failure:3 mariadb
# soanrqube
docker -H 10.1.234.29:5555 run -d --name=sonarqube -t -p 9000:9000 -v /etc/localtime:/etc/localtime:ro --restart=on-failure:3 sonarqube
# jenkins
docker -H 10.1.234.29:5555 run -d --name=jenkins -t -p 8080:8080 -v /etc/localtime:/etc/localtime:ro -v /home/jenkins/jenkins-work:/home/jenkins/jenkins-work -v /home/jenkins/jenkins-backup:/home/jenkins/jenkins-backup --restart=on-failure:3 jenkins
# nginx
docker run -d --name=nginx -p 80:80 --restart=on-failure:3 nginx




# mac
sudo docker-machine start default
sudo docker-machine stop default
sudo docker-machine env default
sudo docker -H 192.168.99.100:2376 --tls=true --tlsverify=true --tlscacert=/Users/xienan/.docker/machine/machines/default/ca.pem --tlscert=/Users/xienan/.docker/machine/machines/default/cert.pem --tlskey=/Users/xienan/.docker/machine/machines/default/key.pem images

