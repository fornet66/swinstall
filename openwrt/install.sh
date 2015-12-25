
http://blog.phpgao.com/xiaomi_router.html

curl 'http://ftp.apnic.net/apnic/stats/apnic/delegated-apnic-latest' | grep ipv4 | grep CN | awk -F\| '{ printf("%s/%d\n", $4, 32-log($5)/log(2)) }' > /etc/chinadns_chnroute.txt

/usr/bin/ss-redir -b0.0.0.0 -l7070 -s47.88.5.218 -p5139 -kSsgogogO -maes-256-cfb -t60 -f /var/run/ss-redir-go.pid

