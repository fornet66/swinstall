
curl -X GET http://yjcloud:yjyjs123@114.55.52.254:8080/manager/text/list

curl -X GET http://yjcloud:yjyjs123@114.55.52.254:8080/manager/text/stop?path=/messageagent

curl -X GET http://yjcloud:yjyjs123@114.55.52.254:8080/manager/text/undeploy?path=/messageagent

curl -X PUT --upload-file "messageagent.war" http://yjcloud:yjyjs123@114.55.52.254:8080/manager/text/deploy?path=/messageagent

curl -X GET http://yjcloud:yjyjs123@114.55.52.254:8080/manager/text/start?path=/messageagent

