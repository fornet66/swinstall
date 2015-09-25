#!/bin/bash
stat() {
	STEP=1
	WORKING=$1
	PROJECT=$2
	TYPE=$3
	FILE=$4
	cd $WORKING
	NUM=`find ./$PROJECT -name "*.$TYPE" | wc -l`
	for FNAME in `find ./$PROJECT -name "*.$TYPE"`
	do
		LINES=`cat $FNAME | grep -v "^$" | wc -l`
		if [ $STEP -eq 1 ]; then
			echo '{ "lines report": [' > $FILE
		fi
		if [ $STEP -eq $NUM ]; then
			echo '{ "file":"'${FNAME#*/}'", "lines":"'${LINES}'" }' >> $FILE
			echo ']}' >> $FILE
		else
			echo '{ "file":"'${FNAME#*/}'", "lines":"'${LINES}'" },' >> $FILE
		fi
		STEP=$(( $STEP + 1 ))
	done
}
FILE=`pwd`/lines-report.json
stat $1 $2 $3 $FILE

