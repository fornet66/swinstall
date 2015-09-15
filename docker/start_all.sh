
docker run -d -p 2376:2375 --name swarm -v $(pwd)/cluster:/tmp/cluster swarm manage file:///tmp/cluster
docker -H 127.0.0.1:2376 info

docker -H 10.1.234.28:5555 restart gogs
docker -H 10.1.234.28:5555 restart mariadb
docker -H 10.1.234.28:5555 restart scm
docker -H 10.1.234.29:5555 restart sonaruqbe

# nginx
docker run -d --name=nginx -p 80:80 --restart=on-failure:3 nginx
# gogs
docker -H 10.1.234.28:5555 run -d --name=gogs -t -p 3000:3000 -v /etc/localtime:/etc/localtime:ro -v /git:/git --restart=on-failure:3 gogs
# mariadb
docker -H 10.1.234.28:5555 run -d --name=mariadb -t -p 3306:3306 -v /etc/localtime:/etc/localtime:ro -v /mariadb:/mariadb --restart=on-failure:3 mariadb
# soanrqube
docker -H 10.1.234.29:5555 run -d --name=sonarqube -t -p 9000:9000 -v /etc/localtime:/etc/localtime:ro --restart=on-failure:3 sonarqube

