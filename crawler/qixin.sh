#!/usr/bin/bash
COOKIE='Cookie: aliyungf_tc=AQAAAJvYF0ugnA4Asizsc6NBpTAgnFWl; hide-download-panel=1; sid=s%3AtQzkv2-n-FTzRPEiSVqXrgT9XdDrgzyn.7DqmYAUXyiqoNcUDJfyUZeoLSYgwmyJ1hO1zqefnV0A; responseTimeline=101; _zg=%7B%22uuid%22%3A%20%22157dc22f64d210-0bfeb4b446c45b-37687a03-fa000-157dc22f64ed7%22%2C%22sid%22%3A%201477406851.469%2C%22updated%22%3A%201477410041.992%2C%22info%22%3A%201476867061335%2C%22cuid%22%3A%20%228c6930d9-a152-4f99-93af-1281e7e1dc8b%22%7D'
HXNORMALIZE='/home/xienan/html-xml-utils-7.1/hxnormalize'
HXSELECT='/home/xienan/html-xml-utils-7.1/hxselect'
HXWLS='/home/xienan/html-xml-utils-7.1/hxwls'

gettime() {
	dd=`date +%s%N`
	ti=`expr $dd / 1000000`
	echo $ti
}

urlencode() {
	old_lang=$LANG
	LANG=C
	old_lc_collate=$LC_COLLATE
	LC_COLLATE=C
	local length="${#1}"
	for (( i = 0; i < length; i++ )); do
		local c="${1:i:1}"
		case $c in
			[a-zA-Z0-9.~_-]) printf "$c" ;;
		    *) printf '%%%02X' "'$c" ;;
	    esac
    done
    LANG=$old_lang
    LC_COLLATE=$old_lc_collate
}

urldecode() { : "${*//+/ }"; echo -e "${_//%/\\x}"; }

host='localhost'
port='3306'
user='yjcloud'
pass='yjyjs123'
db='portrait'
MYSQL="mysql -s -h $host -P $port -u $user -p$pass -D $db"
mysqldelete() {
	key=$1
	table=$2
$MYSQL << EOF
    delete from $table where zjh="$key";
EOF
}
mysqlinsert() {
	table=$1
	value=$2
$MYSQL << EOF
    insert into $table values ($value);
EOF
}

name=$1
encode=`urlencode $name`

#找到列表第一个
url='http://www.qixin.com/search?key='$encode'&type=enterprise'
res=`curl -s $url -H 'If-None-Match: W/"F4bvXAgNdKBeQTIU8Zz1RQ=="' -H 'DNT: 1' -H 'Accept-Encoding: gzip, deflate, sdch' -H 'Accept-Language: zh-CN,zh;q=0.8,en-US;q=0.6,en;q=0.4' -H 'Upgrade-Insecure-Requests: 1' -H 'User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10_12_1) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/53.0.2785.143 Safari/537.36' -H 'Accept: text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8' -H 'Cache-Control: max-age=0' -H "$COOKIE" -H 'Connection: keep-alive' --compressed`
tmp=`echo $res|$HXNORMALIZE -x -d|$HXSELECT 'div.search-list-bg'|$HXSELECT 'div.search-ent-left-content'|$HXSELECT 'a'`
name=`echo $tmp|$HXNORMALIZE -x|$HXSELECT 'a:first-child'|w3m -dump -T 'text/html'`
link=`echo $tmp|$HXNORMALIZE -x|$HXSELECT 'a:first-child'|$HXWLS|awk '{print $1}'`
company=${link:9}
encode=`urlencode $name`
timer=`gettime`
referer='Referer: http://www.qixin.com/company/'$company
echo $name
echo $company

#基本信息
url='http://www.qixin.com/company/'$company
res=`curl -s $url -H "$COOKIE" -H 'DNT: 1' -H 'Accept-Encoding: gzip, deflate, sdch' -H 'Accept-Language: zh-CN,zh;q=0.8,en-US;q=0.6,en;q=0.4' -H 'User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10_12_1) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/54.0.2840.71 Safari/537.36' -H 'Content-Type: application/json; charset=utf-8' -H 'Accept: application/json, text/javascript, */*; q=0.01' -H "$referer" -H 'X-Requested-With: XMLHttpRequest' -H 'Connection: keep-alive' --compressed`
tmp=`echo $res|$HXNORMALIZE -x|$HXSELECT 'div.basic-info'|w3m -dump -cols 2000 -T 'text/html'`
info=`echo $tmp|awk 'BEGIN{OFS="|"}{gsub(/^[ \t]+/, "", $2); gsub(/[ \t]+$/, "", $2); gsub(/^[ \t]+/, "", $4); gsub(/[ \t]+$/, "", $4); print $2,$4,$6,$8,$10,$12,$14,$17,$21 $22,$24,$26,$28,$30}'`
zjh=`echo $info|awk -F "|" '{print $3}'`
value=`echo "\"$zjh\",\"$name\","$(echo $info|awk -F "|" '{printf("\"%s\",\"%s\",\"%s\",\"%s\",\"%s\",\"%s\",\"%s\",\"%s\",\"%s\",\"%s\",\"%s\",\"%s\"", $1,$2,$4,$5,$6,$7,$8,$9,$10,$11,$12,$13)}')`
table='yj_qy'
mysqldelete "$zjh" "$table"
mysqlinsert "$table" "$value"

#股东信息
holder=`echo $res|$HXNORMALIZE -x|$HXSELECT 'div#info div div.panel:nth-child(2) div.panel-body table tbody'`
if [ -n "$holder" ];then
	count=0
	tr=`echo $holder|$HXNORMALIZE -x|$HXSELECT 'tr:first-child'`
	while [ -n "$tr" ]
	do
		lx[$count]=`echo $tr|$HXSELECT 'td:nth-child(1)'|w3m -dump -T 'text/html'`
		gd[$count]=`echo $tr|$HXSELECT 'td:nth-child(2)'|w3m -dump -T 'text/html'`
		rj[$count]=`echo $tr|$HXSELECT 'td:nth-child(3)'|w3m -dump -T 'text/html'`
		sj[$count]=`echo $tr|$HXSELECT 'td:nth-child(4)'|w3m -dump -T 'text/html'`
		let count=count+1
		let child=count+1
		tr=`echo $holder|$HXSELECT "tr:nth-child($child)"`
	done
	table='yj_qygdxx'
	mysqldelete "$zjh" "$table"
	length=${#lx[@]}
	for ((i=0; i<$length; i++))
	do
		value=`echo "\"$zjh\",\"${lx[$i]}\",\"${gd[$i]}\",\"${rj[$i]}\",\"${sj[$i]}\""`
		mysqlinsert "$table" "$value"
	done
fi

#主要人员
person=`echo $res|$HXNORMALIZE -x|$HXSELECT 'ul.major-person-list'|w3m -dump_source -cols 2000 -T 'text/html'`
if [ -n "$person" ];then
	count=0
	zwtmp=`echo $person|$HXSELECT 'ul li:first-child span.job-title'|w3m -dump -T 'text/html'`
	xmtmp=`echo $person|$HXSELECT 'ul li:first-child span.links a span.company-basic-info-name'|w3m -dump -T 'text/html'`
	while [ -n "$zwtmp" ]
	do
		zw[$count]=$zwtmp
		xm[$count]=$xmtmp
		let count=count+1
		let child=count+1
		zwtmp=`echo $person|$HXSELECT "ul li:nth-child($child) span.job-title"|w3m -dump -T 'text/html'`
		xmtmp=`echo $person|$HXSELECT "ul li:nth-child($child) span.links a span.company-basic-info-name"|w3m -dump -T 'text/html'`
	done
	table='yj_qyzyry'
	mysqldelete "$zjh" "$table"
	length=${#zw[@]}
	for ((i=0; i<$length; i++))
	do
		value=`echo "\"$zjh\",\"${zw[$i]}\",\"${xm[$i]}\""`
		mysqlinsert "$table" "$value"
	done
fi

#分支机构
branch=`echo $res|$HXNORMALIZE -x|$HXSELECT 'div#info div div.panel:nth-child(4) div.panel-body table tbody'|$HXNORMALIZE -x|$HXSELECT 'tbody:first-child'`
if [ -n "$branch" ];then
	count=0
	tr=`echo $branch|$HXNORMALIZE -x|$HXSELECT 'tr:first-child'`
	while [ -n "$tr" ]
	do
		gsmc[$count]=`echo $tr|$HXSELECT 'td:nth-child(1)'|w3m -dump -T 'text/html'`
		fddbr[$count]=`echo $tr|$HXSELECT 'td:nth-child(2)'|w3m -dump -T 'text/html'`
		zczb[$count]=`echo $tr|$HXSELECT 'td:nth-child(3)'|w3m -dump -T 'text/html'`
		clrq[$count]=`echo $tr|$HXSELECT 'td:nth-child(4)'|w3m -dump -T 'text/html'`
		let count=count+1
		let child=count+1
		tr=`echo $branch|$HXSELECT "tr:nth-child($child)"`
	done
	table='yj_qyfzjg'
	mysqldelete "$zjh" "$table"
	length=${#gsmc[@]}
	for ((i=0; i<$length; i++))
	do
		value=`echo "\"$zjh\",\"${gsmc[$i]}\",\"${fddbr[$i]}\",\"${zczb[$i]}\",\"${clrq[$i]}\""`
		mysqlinsert "$table" "$value"
	done
fi
exit 0

url='http://www.qixin.com/service/getRiskInfo?eid='$company'&_='$timer
res=`curl -s $url -H "$COOKIE" -H 'DNT: 1' -H 'Accept-Encoding: gzip, deflate, sdch' -H 'Accept-Language: zh-CN,zh;q=0.8,en-US;q=0.6,en;q=0.4' -H 'User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10_12_1) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/54.0.2840.71 Safari/537.36' -H 'Content-Type: application/json; charset=utf-8' -H 'Accept: application/json, text/javascript, */*; q=0.01' -H "$referer" -H 'X-Requested-With: XMLHttpRequest' -H 'Connection: keep-alive' --compressed`
#变更记录
size=`echo $res|jq '.data.changerecords.items|length'`
i=0
while [ $i -lt $size ]
do
	echo $res|jq --arg i $i '.data.changerecords.items[$i|tonumber]'
    i=`expr $i + 1`
done
#法院判决
size=`echo $res|jq '.data.lawsuits.items|length'`
i=0
while [ $i -lt $size ]
do
	echo $res|jq --arg i $i '.data.lawsuits.items[$i|tonumber]'
    i=`expr $i + 1`
done
#被执行人信息
size=`echo $res|jq '.data.executionPerson.items|length'`
i=0
while [ $i -lt $size ]
do
	echo $res|jq --arg i $i '.data.executionPerson.items[$i|tonumber]'
    i=`expr $i + 1`
done
#经营异常
size=`echo $res|jq '.data.abnormal.items|length'`
i=0
while [ $i -lt $size ]
do
	echo $res|jq --arg i $i '.data.abnormal.items[$i|tonumber]'
    i=`expr $i + 1`
done

url='http://www.qixin.com/service/getAbilityInfo?eid='$company'&_='$timer
res=`curl -s $url -H "$COOKIE" -H 'DNT: 1' -H 'Accept-Encoding: gzip, deflate, sdch' -H 'Accept-Language: zh-CN,zh;q=0.8,en-US;q=0.6,en;q=0.4' -H 'User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10_12_1) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/54.0.2840.71 Safari/537.36' -H 'Content-Type: application/json; charset=utf-8' -H 'Accept: application/json, text/javascript, */*; q=0.01' -H "$referer" -H 'X-Requested-With: XMLHttpRequest' -H 'Connection: keep-alive' --compressed`
#商标
size=`echo $res|jq '.data.trademark.items|length'`
i=0
while [ $i -lt $size ]
do
	echo $res|jq --arg i $i '.data.trademark.items[$i|tonumber]'
	i=`expr $i + 1`
done
#专利信息
size=`echo $res|jq '.data.patent.items|length'`
i=0
while [ $i -lt $size ]
do
	echo $res|jq --arg i $i '.data.patent.items[$i|tonumber]'
	i=`expr $i + 1`
done
#著作权
size=`echo $res|jq '.data.copyright.items|length'`
i=0
while [ $i -lt $size ]
do
	echo $res|jq --arg i $i '.data.copyright.items[$i|tonumber]'
	i=`expr $i + 1`
done
#软件著作权
size=`echo $res|jq '.data.softwarecopyright.items|length'`
i=0
while [ $i -lt $size ]
do
	echo $res|jq --arg i $i '.data.softwarecopyright.items[$i|tonumber]'
	i=`expr $i + 1`
done
#域名
size=`echo $res|jq '.data.domain.items|length'`
i=0
while [ $i -lt $size ]
do
	echo $res|jq --arg i $i '.data.domain.items[$i|tonumber]'
	i=`expr $i + 1`
done
#资质认证
size=`echo $res|jq '.data.certification.items|length'`
i=0
while [ $i -lt $size ]
do
	echo $res|jq --arg i $i '.data.certification.items[$i|tonumber]'
	i=`expr $i + 1`
done

url='http://www.qixin.com/service/getOperationInfo?eid='$company'&ename='$encode'&_='$timer
res=`curl -s $url -H "$COOKIE" -H 'DNT: 1' -H 'Accept-Encoding: gzip, deflate, sdch' -H 'Accept-Language: zh-CN,zh;q=0.8,en-US;q=0.6,en;q=0.4' -H 'User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10_12_1) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/54.0.2840.71 Safari/537.36' -H 'Content-Type: application/json; charset=utf-8' -H 'Accept: application/json, text/javascript, */*; q=0.01' -H "$referer" -H 'X-Requested-With: XMLHttpRequest' -H 'Connection: keep-alive' --compressed`
#招聘信息
size=`echo $res|jq '.data.job.items|length'`
i=0
while [ $i -lt $size ]
do
	echo $res|jq --arg i $i '.data.job.items[$i|tonumber]'
	i=`expr $i + 1`
done
#招投标
size=`echo $res|jq '.data.bidding.items|length'`
i=0
while [ $i -lt $size ]
do
	echo $res|jq --arg i $i '.data.bidding.items[$i|tonumber]'
	i=`expr $i + 1`
done

