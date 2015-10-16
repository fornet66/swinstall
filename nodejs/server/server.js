
var http = require('http'),
	router = require('./router'),
	parser = require('./parser'),
	parse = require('url').parse,
	util = require('util'),
	formidable = require('formidable');

http.createServer(function (req, res) {
	var url = parse(req.url), pathname = url.pathname;
	console.log('Request URL: http://0.0.0.0:3000' + url.href);
	console.log('Request path: ' + url.pathname);
	req.resource = parser.parse(pathname);
	if(req.resource.id){
		res.writeHead(200, {'Content-Type': 'text/plain'});
		router.router(req, res, function(stringfyResult){
			res.end(stringfyResult);
		});
	}else{
		res.writeHead(200, {'Content-Type': 'text/plain'});
		console.log('Request URL is not in RESTful style!');
		res.end('Request URL is not in RESTful style!');
	}
}).listen(3000, '0.0.0.0');

console.log('Server running at http://0.0.0.0:3000/');

