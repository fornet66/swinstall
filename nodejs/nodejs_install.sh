
npm install json
npm install mysql
npm install express

curl http://10.1.234.29:3000
curl http://10.1.234.29:3000/resources/group
curl -H "Content-Type: application/x-www-form-urlencoded" -X POST \
	--data 'name=group2&location=location2&size=2' \
	http://10.1.234.29:3000/resources/group/2
curl -H "Content-Type: application/x-www-form-urlencoded" -X PUT \
	--data 'name=group22&location=location22&size=22' \
	http://10.1.234.29:3000/resources/group/2
curl -X DELETE --data '{"id":"2"}' http://10.1.234.29:3000/resources/group/2

curl http://cmcssm.asiainfo.com/rest/resources/group/1
curl -H "Content-Type: application/x-www-form-urlencoded" -X POST \
	--data 'name=group2&location=location2&size=2' \
	http://cmcssm.asiainfo.com/rest/resources/group/2
curl -H "Content-Type: application/x-www-form-urlencoded" -X PUT \
	--data 'name=group22&location=location22&size=22' \
	http://cmcssm.asiainfo.com/rest/resources/group/2
curl -X DELETE --data '{"id":"2"}' http://cmcssm.asiainfo.com/rest/resources/group/2

