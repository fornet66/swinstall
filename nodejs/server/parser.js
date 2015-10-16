
exports.parse = function(input){ 
	if(null == input || '' == input) return {};
	var str = removeSlashAtEnd(input), resIndex = str.indexOf('resources');
	if(resIndex == -1 || resIndex == str.length -9) return {}; 

	queryStrs = str.substr(resIndex + 10).split('/');
	if(queryStrs.length % 2 != 0){
		queryStrs.push('0');
	}
	console.log('ss : ' + queryStrs[0]);
	console.log('id : ' + queryStrs[1]);
	return  {
		resource : queryStrs[0], 
				 id : queryStrs[1] 
	};

	function removeSlashAtEnd(str){
		if(str.charAt(str.length -1) == '/'){
			return str.substring(0, str.length -1);
		}
		return str;
	}
};

