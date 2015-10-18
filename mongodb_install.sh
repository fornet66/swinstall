
yum install -y mongodb

mongod --dbpath=/mongodb/master --port 27017 --fork \
	--directoryperdb --httpinterface \
	--logpath=/mongodb/logs/master.log --logappend --master --auth
mongod --dbpath=/mongodb/master --shutdown

mongo 127.0.0.1
use admin;
db.createUser(
{
	user: "root",
	pwd: "mongodb_admin",
	roles: [ "dbOwner" , "clusterAdmin" ]
}
);

use aissm;
db.createUser(
{
	user: "aissm",
	pwd: "aissm",
	roles: [ "readWrite" ]
}
);

use local;
db.createUser(
{
	user: "repl",
	pwd: "repl",
	roles: [ "clusterManager" ]
}
);


mongod --dbpath=/mongodb/slave --port 37017 --fork \
	--directoryperdb --auth \
	--logpath=/mongodb/logs/slave.log --slave --source 127.0.0.1:27017 --autoresync
mongod --dbpath=/mongodb/slave --shutdown


