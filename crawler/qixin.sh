#!/usr/bin/bash
COOKIE='Cookie: Hm_lvt_52d64b8d3f6d42a2e416d59635df3f71=1478010711; tencentSig=114552832; aliyungf_tc=AQAAAJpKmwIPPAwAzQhs2jJx3CDjgEuo; _qddamta_800809556=3-0; sid=s%3AJI8Njd12mgXI_ErKEFYIFv5UrdDujyXe.So8wcLD3dChtJmyCkuPeNoN4C4jhBFydIPb6vLHUv%2F8; hide-download-panel=1; _qddac=3-2-1.1.27ykve.ivw7ipyc; _zg=%7B%22uuid%22%3A%20%22157dc22f64d210-0bfeb4b446c45b-37687a03-fa000-157dc22f64ed7%22%2C%22sid%22%3A%201479982753.876%2C%22updated%22%3A%201479983476.232%2C%22info%22%3A%201479982753890%2C%22cuid%22%3A%20%228fcc2de7-be87-4de2-9200-6f8f358e203a%22%7D; responseTimeline=148; _qddaz=QD.314g1q.303xpc.ivkkb23d; _qdda=3-1.1; _qddab=3-27ykve.ivw7ipyc'
HXNORMALIZE='/home/xienan/html-xml-utils-7.1/hxnormalize'
HXSELECT='/home/xienan/html-xml-utils-7.1/hxselect'
HXWLS='/home/xienan/html-xml-utils-7.1/hxwls'
ECHO="echo -e"
OUTPUT_GREEN="\033[32m"
OUTPUT_RESET="\033[0m"

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
db='newportrait'
MYSQL="mysql -s -h $host -P $port -u $user -p$pass -D $db"
mysqlselect() {
	table=$1
	key=$2
$MYSQL << EOF 2>/dev/null
	select count(*) from $table where qymc like "%$key%";
EOF
}
mysqldeleteqy() {
	key=$1
	table=$2
$MYSQL << EOF 2>/dev/null
	delete from $table where uuid="$key";
EOF
}
mysqldelete() {
	key=$1
	table=$2
$MYSQL << EOF 2>/dev/null
    delete from $table where zjh="$key";
EOF
}
mysqlinsert() {
	table=$1
	value=$2
$MYSQL << EOF 2>/dev/null
    insert into $table values ($value);
EOF
}

name=$1
encode=`urlencode $name`
count=`mysqlselect "yj_qy" "$name"`
if [ $count -gt 0 ]; then
	echo "企业($name)已经处理完毕";
	exit 0;
fi

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
$ECHO $OUTPUT_GREEN '企业名称:' $name '企业唯一号:' $company $OUTPUT_RESET

sleep 5
#基本信息
url='http://www.qixin.com/company/'$company
res=`curl -s $url -H "$COOKIE" -H 'DNT: 1' -H 'Accept-Encoding: gzip, deflate, sdch' -H 'Accept-Language: zh-CN,zh;q=0.8,en-US;q=0.6,en;q=0.4' -H 'User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10_12_1) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/54.0.2840.71 Safari/537.36' -H 'Content-Type: application/json; charset=utf-8' -H 'Accept: application/json, text/javascript, */*; q=0.01' -H "$referer" -H 'X-Requested-With: XMLHttpRequest' -H 'Connection: keep-alive' --compressed`
tmp=`echo $res|$HXNORMALIZE -x|$HXSELECT 'div.basic-info'|w3m -dump -cols 2000 -T 'text/html'`
info=`echo $tmp|awk 'BEGIN{OFS="|"}{gsub(/^[ \t]+/, "", $2); gsub(/[ \t]+$/, "", $2); gsub(/^[ \t]+/, "", $4); gsub(/[ \t]+$/, "", $4); print $2,$4,$6,$8,$10,$12,$14,$17,$21 $22,$24,$26,$28,$30}'`
zjh=`echo $info|awk -F "|" '{print $3}'`
value=`echo "\"$company\",\"$zjh\",\"$name\","$(echo $info|awk -F "|" '{printf("\"%s\",\"%s\",\"%s\",\"%s\",\"%s\",\"%s\",\"%s\",\"%s\",\"%s\",\"%s\",\"%s\",\"%s\"", $1,$2,$4,$5,$6,$7,$8,$9,$10,$11,$12,$13)}')`
table='yj_qy'
mysqldeleteqy "$company" "$table"
mysqlinsert "$table" "$value"
$ECHO $OUTPUT_GREEN '分析企业基本信息完成' $OUTPUT_RESET

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
$ECHO $OUTPUT_GREEN '分析企业股东信息完成' $OUTPUT_RESET

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
$ECHO $OUTPUT_GREEN '分析企业主要人员完成' $OUTPUT_RESET

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
$ECHO $OUTPUT_GREEN '分析企业分支机构完成' $OUTPUT_RESET

sleep 5
url='http://www.qixin.com/service/getRiskInfo?eid='$company'&_='$timer
res=`curl -s $url -H "$COOKIE" -H 'DNT: 1' -H 'Accept-Encoding: gzip, deflate, sdch' -H 'Accept-Language: zh-CN,zh;q=0.8,en-US;q=0.6,en;q=0.4' -H 'User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10_12_1) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/54.0.2840.71 Safari/537.36' -H 'Content-Type: application/json; charset=utf-8' -H 'Accept: application/json, text/javascript, */*; q=0.01' -H "$referer" -H 'X-Requested-With: XMLHttpRequest' -H 'Connection: keep-alive' --compressed`
#工商变更
table='yj_qygsbg'
mysqldelete $zjh $table
size=`echo $res|jq '.data.changerecords.items|length'`
i=0
while [ $i -lt $size ]
do
	record=`echo $res|jq --arg i $i '.data.changerecords.items[$i|tonumber]'`
	bgrq=`echo $record|jq '.change_date'`
	bgsx=`echo $record|jq '.change_item'|sed s/[[:space:]]//g`
	bgq=`echo $record|jq '.before_content'|sed s/[[:space:]]//g`
	bgh=`echo $record|jq '.after_content'|sed s/[[:space:]]//g`
	value=`echo "\"$zjh\",$bgrq,$bgsx,$bgq,$bgh"`
	mysqlinsert $table $value
    i=`expr $i + 1`
done
$ECHO $OUTPUT_GREEN '分析企业工商变更完成' $OUTPUT_RESET

#法院判决
nil='null'
table='yj_lass'
mysqldelete $zjh $table
size=`echo $res|jq '.data.lawsuits.items|length'`
i=0
while [ $i -lt $size ]
do
	record=`echo $res|jq --arg i $i '.data.lawsuits.items[$i|tonumber]'`
	pjsj=`echo $record|jq '.date'`
	sf=`echo $record|jq '.role'`
	pjjg=`echo $record|jq '.result'|sed s/[[:space:]]//g`
	pjs=`echo $record|jq '.title'|sed s/[[:space:]]//g`
	value=`echo "\"$zjh\",$nil,$nil,$nil,$nil,$nil,$sf,$nil,$nil,$nil,$pjsj,$nil,$nil,$nil,$pjjg,$nil,$nil"`
	mysqlinsert $table $value
    i=`expr $i + 1`
done
$ECHO $OUTPUT_GREEN '分析企业法院判决完成' $OUTPUT_RESET

#被执行人信息
nil='null'
table='yj_zxxx'
mysqldelete $zjh $table
size=`echo $res|jq '.data.executionPerson.items|length'`
i=0
while [ $i -lt $size ]
do
	record=`echo $res|jq --arg i $i '.data.executionPerson.items[$i|tonumber]'`
	lasj=`echo $record|jq '.case_date'`
	ah=`echo $record|jq '.case_number'`
	zxbd=`echo $record|jq '.amount'`
	zxfy=`echo $record|jq '.court'`
	zxzt=`echo $record|jq '.status'`
	value=`echo "\"$zjh\",$lasj,$ah,$zxbd,$zxfy,$zxzt,$nil,$nil,$nil,$nil"`
	mysqlinsert $table $value
    i=`expr $i + 1`
done
$ECHO $OUTPUT_GREEN '分析企业被执行人信息完成' $OUTPUT_RESET

#经营异常
table='yj_qyjyyc'
mysqldelete $zjh $table
size=`echo $res|jq '.data.abnormal.items|length'`
i=0
while [ $i -lt $size ]
do
	record=`echo $res|jq --arg i $i '.data.abnormal.items[$i|tonumber]'`
	zcjdjg=`echo $record|jq '.department'`
	lrrq=`echo $record|jq '.in_date'`
	lrjyycmlyy=`echo $record|jq '.in_reason'|sed s/[[:space:]]//g`
	ycrq=`echo $record|jq '.out_date'`
	ycjyycmlyy=`echo $record|jq '.out_reason'|sed s/[[:space:]]//g`
	value=`echo "\"$zjh\",$zcjdjg,$lrrq,$lrjyycmlyy,$ycrq,$ycjyycmlyy"`
	mysqlinsert $table $value
    i=`expr $i + 1`
done
$ECHO $OUTPUT_GREEN '分析企业经营异常完成' $OUTPUT_RESET

sleep 5
url='http://www.qixin.com/service/getAbilityInfo?eid='$company'&_='$timer
res=`curl -s $url -H "$COOKIE" -H 'DNT: 1' -H 'Accept-Encoding: gzip, deflate, sdch' -H 'Accept-Language: zh-CN,zh;q=0.8,en-US;q=0.6,en;q=0.4' -H 'User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10_12_1) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/54.0.2840.71 Safari/537.36' -H 'Content-Type: application/json; charset=utf-8' -H 'Accept: application/json, text/javascript, */*; q=0.01' -H "$referer" -H 'X-Requested-With: XMLHttpRequest' -H 'Connection: keep-alive' --compressed`
#商标
table='yj_qysb'
mysqldelete $zjh $table
size=`echo $res|jq '.data.trademark.items|length'`
i=0
while [ $i -lt $size ]
do
	record=`echo $res|jq --arg i $i '.data.trademark.items[$i|tonumber]'`
	sbm=`echo $record|jq '.name'|sed s/[[:space:]]//g`
	zt=`echo $record|jq '.status'`
	sqsj=`echo $record|jq '.apply_date'`
	zch=`echo $record|jq '.reg_num'`
	lb=`echo $record|jq '.type_name'`
	image_url=`echo $record|jq '.image_url'`
	value=`echo "\"$zjh\",$sbm,$zt,$sqsj,$zch,$lb,$image_url"`
	mysqlinsert $table $value
	i=`expr $i + 1`
done
$ECHO $OUTPUT_GREEN '分析企业商标完成' $OUTPUT_RESET

#专利信息
table='yj_zlxx'
mysqldelete $zjh $table
size=`echo $res|jq '.data.patent.items|length'`
i=0
while [ $i -lt $size ]
do
	record=`echo $res|jq --arg i $i '.data.patent.items[$i|tonumber]'`
	zlm=`echo $record|jq '.patent_name'|sed s/[[:space:]]//g`
	zllx=`echo $record|jq '.category_num'`
	lxmc=`echo $record|jq '.type_name'`
	sqh=`echo $record|jq '.request_num'`
	fbrq=`echo $record|jq '.outhor_date'`
	zy=`echo $record|jq '.brief'|sed s/[[:space:]]//g`
	value=`echo "\"$zjh\",$zlm,$zllx,$lxmc,$sqh,$fbrq,$zy"`
	mysqlinsert $table $value
	i=`expr $i + 1`
done
$ECHO $OUTPUT_GREEN '分析企业专利信息完成' $OUTPUT_RESET

#著作权
table='yj_qyzzq'
mysqldelete $zjh $table
size=`echo $res|jq '.data.copyright.items|length'`
i=0
while [ $i -lt $size ]
do
	record=`echo $res|jq --arg i $i '.data.copyright.items[$i|tonumber]'`
	zpmc=`echo $record|jq '.name'|sed s/[[:space:]]//g`
	djh=`echo $record|jq '.number'`
	lb=`echo $record|jq '.type_name'`
	czwcrq=`echo $record|jq '.first_date'`
	djrq=`echo $record|jq '.approval_date'`
	scfbrq=`echo $record|jq '.success_date'`
	value=`echo "\"$zjh\",$zpmc,$djh,$lb,$czwcrq,$djrq,$scfbrq"`
	mysqlinsert $table $value
	i=`expr $i + 1`
done
$ECHO $OUTPUT_GREEN '分析企业著作权完成' $OUTPUT_RESET

#软件著作权
table='yj_qyrjzzq'
mysqldelete $zjh $table
size=`echo $res|jq '.data.softwarecopyright.items|length'`
i=0
while [ $i -lt $size ]
do
	record=`echo $res|jq --arg i $i '.data.softwarecopyright.items[$i|tonumber]'`
	rjmc=`echo $record|jq '.name'|sed s/[[:space:]]//g`
	djh=`echo $record|jq '.number'`
	bbh=`echo $record|jq '.version'`
	flh=`echo $record|jq '.type_num'`
	djpzrq=`echo $record|jq '.approval_date'`
	rjjc=`echo $record|jq '.short_name'|sed s/[[:space:]]//g`
	value=`echo "\"$zjh\",$rjmc,$djh,$bbh,$flh,$djpzrq,$rjjc"`
	mysqlinsert $table $value
	i=`expr $i + 1`
done
$ECHO $OUTPUT_GREEN '分析企业软件著作权完成' $OUTPUT_RESET

#域名
table='yj_qyym'
mysqldelete $zjh $table
size=`echo $res|jq '.data.domain.items|length'`
i=0
while [ $i -lt $size ]
do
	record=`echo $res|jq --arg i $i '.data.domain.items[$i|tonumber]'`
	wz=`echo $record|jq '.domain'`
	wzmc=`echo $record|jq '.site_name'`
	wzba=`echo $record|jq '.number'`
	djpzrq=`echo $record|jq '.check_date'`
	value=`echo "\"$zjh\",$wz,$wzmc,$wzba,$djpzrq"`
	mysqlinsert $table $value
	i=`expr $i + 1`
done
$ECHO $OUTPUT_GREEN '分析企业域名完成' $OUTPUT_RESET

#资质认证
table='yj_qyzzrz'
mysqldelete $zjh $table
size=`echo $res|jq '.data.certification.items|length'`
i=0
while [ $i -lt $size ]
do
	record=`echo $res|jq --arg i $i '.data.certification.items[$i|tonumber]'`
	zslx=`echo $record|jq '.type'`
	zsbh=`echo $record|jq '.num'`
	fzrq=`echo $record|jq '.issue_date'`
	yxqx=`echo $record|jq '.validity_end'`
	zszt=`echo $record|jq '.status'`
	bz=`echo $record|jq '.remarks'|sed s/[[:space:]]//g`
	value=`echo "\"$zjh\",$zslx,$zsbh,$fzrq,$yxqx,$zszt,$bz"`
	mysqlinsert $table $value
	i=`expr $i + 1`
done
$ECHO $OUTPUT_GREEN '分析企业资质认证完成' $OUTPUT_RESET

sleep 5
url='http://www.qixin.com/service/getOperationInfo?eid='$company'&ename='$encode'&_='$timer
res=`curl -s $url -H "$COOKIE" -H 'DNT: 1' -H 'Accept-Encoding: gzip, deflate, sdch' -H 'Accept-Language: zh-CN,zh;q=0.8,en-US;q=0.6,en;q=0.4' -H 'User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10_12_1) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/54.0.2840.71 Safari/537.36' -H 'Content-Type: application/json; charset=utf-8' -H 'Accept: application/json, text/javascript, */*; q=0.01' -H "$referer" -H 'X-Requested-With: XMLHttpRequest' -H 'Connection: keep-alive' --compressed`
#招聘信息
table='yj_qyzpxx'
mysqldelete $zjh $table
size=`echo $res|jq '.data.job.items|length'`
i=0
while [ $i -lt $size ]
do
	record=`echo $res|jq --arg i $i '.data.job.items[$i|tonumber]'`
	zw=`echo $record|jq '.title'`
	xz=`echo $record|jq '.salary'`
	jy=`echo $record|jq '.years'`
	dd=`echo $record|jq '.location'|sed s/[[:space:]]//g`
	xl=`echo $record|jq '.education'`
	fbrq=`echo $record|jq '.date'`
	zwms=`echo $record|jq '.description'|sed s/[[:space:]]//g`
	value=`echo "\"$zjh\",$zw,$xz,$jy,$dd,$xl,$fbrq,$zwms"`
	mysqlinsert $table $value
	i=`expr $i + 1`
done
$ECHO $OUTPUT_GREEN '分析企业招聘信息完成' $OUTPUT_RESET

table='yj_qyztb'
mysqldelete $zjh $table
#招投标
size=`echo $res|jq '.data.bidding.items|length'`
i=0
while [ $i -lt $size ]
do
	record=`echo $res|jq --arg i $i '.data.bidding.items[$i|tonumber]'`
	mc=`echo $record|jq '.title'|sed s/[[:space:]]//g`
	ms=`echo $record|jq '.brief'|sed s/[[:space:]]//g`
	hy=`echo $record|jq '.industry'`
	fbsj=`echo $record|jq '.issue_time'`
	ssdq=`echo $record|jq '.area'`
	xmfl=`echo $record|jq '.type'`
	value=`echo "\"$zjh\",$mc,$ms,$hy,$fbsj,$ssdq,$xmfl"`
	mysqlinsert $table $value
	i=`expr $i + 1`
done
$ECHO $OUTPUT_GREEN '分析企业招投标完成' $OUTPUT_RESET

