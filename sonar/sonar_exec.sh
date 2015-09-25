#!/bin/bash
getconfig() {
  FILE=$1
  KEY=$2
  readline=`awk -F '=' '$1~/'$KEY'/{print $2;exit}' $FILE`
  echo ${readline}
}
lines_stat() {
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
    STEP=$(($STEP + 1))
  done
}
PRG="$0"
if [ -h "$PRG" ] ; then
  # resolve symlinks
  PRG=$(readlink -f "$PRG")
fi
PRG_HOME=$(dirname "$PRG")
CONFIG=$PRG_HOME/conf/check.Properties
BASE_DIR=$PRG_HOME/data
BASE_LOG=$BASE_DIR/sonar_exec.log
if [ ! -f "$CONFIG" ]; then
  echo "config file does not exist"
  exit 0
fi
export JAVA_HOME=`getconfig $CONFIG "JAVA_HOME"`
export SONAR_RUNNER_HOME=`getconfig $CONFIG "SONAR_RUNNER_HOME"`
export PATH=$JAVA_HOME/bin:$SONAR_RUNNER_HOME/bin:$PATH
export CLASSPATH=$CLASSPATH:$JAVA_HOME/lib:$JAVA_HOME/jre/lib
export SONAR_RUNNER_OPTS="-Xmx512m -XX:MaxPermSize=512m"
while true
do
  for dir in `find -L $BASE_DIR -maxdepth 1 -type d -name "pre-commit*"`
  do
    echo `date +%Y%m%d%H%M%S`' ... doing dir ...' $dir >> $BASE_LOG
    chk=$dir/check
    rpt=$dir/report
    (cd $dir; if [ -x ./SONAR ]; then ./SONAR > $dir/sonar.STDERR 2>&1; fi)
    (cd $dir; lines_stat $chk `cat PROJECT` "java" $rpt/lines-report.json)
    (cd $rpt; if [ -x ../STAT ]; then ../STAT > $dir/stat.STDERR  2>&1; fi)
    rm -rf $dir
  done
  sleep 5
done

