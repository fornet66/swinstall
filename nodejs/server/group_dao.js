
var Group = require('./group').group,
	mysql = require('mysql');

function group_dao(){
	var dbConnection = mysql.createConnection({
		host     : '10.1.234.28',
		user     : 'root',
		password : 'mariadb_admin',
		database : 'aitest',
		port     : 3306,
	});

	this.retrieve = function(id, params, callback){
		var groups = [];		
		dbConnection.query('SELECT * FROM groups where id = ?', [id], function(err, rows, fields) {
			if (err) throw err;
			for(var i=0; i<rows.length; i++){
				var group = new Group(rows[i].id, rows[i].name, rows[i].location, rows[i].size);
				groups.push(group);
			}
			callback(groups);
			dbConnection.end();
		});	
	};

	this.list = function(id, params, callback){
		var groups = [];		
		dbConnection.query('SELECT * FROM groups', function(err, rows, fields) {
			if (err) throw err;
			for(var i=0; i<rows.length; i++){
				var group = new Group(rows[i].id, rows[i].name, rows[i].location, rows[i].size);
				groups.push(group);
			}
			callback(groups);
			dbConnection.end();
		});	
	};

	this.postMember = function(id, params, callback){
		if(arguments.length >= 2){
			var newId = arguments[0];
			var params = arguments[1];
			dbConnection.query('INSERT INTO groups SET ?', {id: newId, name: params.name, location: params.location, size: params.size} , function(err, result) {
				if (err) throw err;
				callback({id: newId});
				dbConnection.end();
			});
		}
	};

	this.update = function(id, params, callback){
		if(arguments.length >= 2){
			var newId = arguments[0];
			var params = arguments[1];
			dbConnection.query('UPDATE groups SET name = ?, location=?, size=? where id = ?', [params.name,  params.location, params.size, id] , function(err, result) {
				if (err) throw err;
				callback({id: newId});
				dbConnection.end();
			});	
		}
	};

	this.deleteMember = function(id, params, callback){
		dbConnection.query('DELETE FROM groups where id = ?', [id] , function(err, result) {
			if (err) throw err;
			callback({id: id});
			dbConnection.end();
		});
	};
}

exports.dao = group_dao;

