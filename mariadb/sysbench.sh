
sysbench --test=oltp --db-driver=mysql --mysql-engine-trx=yes --mysql-table-engine=innodb --mysql-host=127.0.0.1 --mysql-port=3307 --mysql-user=sbtest --mysql-password=sbpass --mysql-db=sbtest --test='/usr/share/doc/sysbench/tests/db/oltp.lua' --oltp-table-size=10000 prepare


sysbench --test=oltp --db-driver=mysql --mysql-engine-trx=yes --mysql-table-engine=innodb --mysql-host=127.0.0.1 --mysql-port=3307 --mysql-user=sbtest --mysql-password=sbpass --mysql-db=sbtest --test='/usr/share/doc/sysbench/tests/db/oltp.lua' --oltp-table-size=10000 --num-threads=8 run

