#!/bin/bash
#
# SVN Syntax Check Hook Script
# Copyright (c) 2015, xienan <xienan@asiainfo.com>, AsiaInfo Inc.
#
# This script provides language independent sonar checking
# functionality intended to be invoked from a subversion pre-commit
# hook.
#
# Invocation: /path/to/svn_sonar_pre.sh $1 $2
#         or: source svn_sonar_pre.sh
#
# Requires bash 3.x or higher.
#
getconfig() {
  FILE=$1
  KEY=$2
  readline=`awk -F '=' '$1~/'$KEY'/{print $2;exit}' $FILE`
  echo ${readline}
}

syntaxclean() {
  [ -d $1 ] && rm -rf $1
}

syntaxexit() {
  echo $1 >> /dev/stderr

  # save working dir and debug files
  if [ -d $WORKING ]; then
    [ -n "$DIFF" ] && echo $"$DIFF" > $WORKING/patch
    [ -n "$LOG" ] && echo $"$LOG" > $WORKING/svnlog
    [ -n "$CHANGED" ] && echo $"$CHANGED" > $WORKING/changed
    mv $WORKING $WORKING.failed
  fi

  # clean working dir if specified
  [ -n $2 ] && syntaxclean $2
  exit 1
}

PRG="$0"
if [ -h "$PRG" ] ; then
  # resolve symlinks
  PRG=$(readlink -f "$PRG")
fi
PRG_HOME=$(dirname "$PRG")
CONFIG=$PRG_HOME/conf/check.Properties
if [ ! -f "$CONFIG" ]; then
	echo "config file does not exist"
	exit 0
fi
export JAVA_HOME=`getconfig $CONFIG "JAVA_HOME"`
export SONAR_RUNNER_HOME=`getconfig $CONFIG "SONAR_RUNNER_HOME"`
export PATH=$PATH:$JAVA_HOME/bin:$SONAR_RUNNER_HOME/bin
export CLASSPATH=$CLASSPATH:$JAVA_HOME/lib:$JAVA_HOME/jre/lib
export SONAR_RUNNER_OPTS="-Xmx512m -XX:MaxPermSize=512m"
DEPARTMENT=`getconfig $CONFIG "DEPARTMENT"`
PROJECT_LIST=`getconfig $CONFIG "PROJECT_LIST"`
PROJECT_ARRAY=(${PROJECT_LIST//|/ })

MODE="-t"
REPOS="$1"
TXN="$2"
FLANG=JAVA,CPP
FPATTERN="\.\(java\)$"
[ -z "$SVNLOOK" ] && SVNLOOK=/bin/svnlook
[ -z "$LOG" ] && LOG=`$SVNLOOK log $MODE "$TXN" "$REPOS"`
[ -z "$DIFF" ] && DIFF=`$SVNLOOK diff $MODE "$TXN" "$REPOS"`
[ -z "$AUTHOR" ] && AUTHOR=`$SVNLOOK author $MODE "$TXN" "$REPOS"`
[ -z "$CHANGEDFILES" ] && CHANGEDFILES=`$SVNLOOK changed $MODE "$TXN" "$REPOS"`
[ -z "$SYNTAXENABLED" ] && SYNTAXENABLED="1"

# sonar check
SYNTAX_CMD=$SONAR_RUNNER_HOME/bin/sonar-runner
SYNTAX_ARGS="-Dsonar.analysis.mode=preview"

# lines check
LRPT_FILE=lines-report.json

# stat indb
STAT_CMD=$JAVA_HOME/bin/java
STAT_ARGS="-Ddepartment=$DEPARTMENT"
STAT_ARGS=$STAT_ARGS" -Dauthor=$AUTHOR"
STAT_JAR="-jar $PRG_HOME/AnalysisReportplugin-1.0.jar"

if [ "$SYNTAXENABLED" == "1" ]; then
  # allow selective bypass of syntax check for commits
  #[[ "$LOG" =~ "$BYPASSPW" ]] && return;

  # get changed file list and count
  NUMMATCHCHANGED=0
  if [ -n "$CHANGEDFILES" ]; then
    MATCHCHANGED=`echo $"$CHANGEDFILES" | grep "$FPATTERN"`
    [ -n "$MATCHCHANGED" ] && NUMMATCHCHANGED=`echo $"$MATCHCHANGED" | wc -l`
  fi

  # make sure matched files were changed
  if [ $NUMMATCHCHANGED -gt 0 ]; then
    # create temporary working directory
    WORKING=/tmp/$(basename $0).$$
    [ -d $WORKING ] && rm -rf $WORKING
    mkdir $WORKING || syntaxexit "failed to create temp dir for syntax check: $WORKING"
    cd $WORKING
    SYNTAX_ARGS=$SYNTAX_ARGS" -Dsonar.projectBaseDir="${WORKING}"/check"
    SYNTAX_ARGS=$SYNTAX_ARGS" -Dsonar.sources=."
    SYNTAX_ARGS=$SYNTAX_ARGS" -Dsonar.working.directory="${WORKING}"/report"

    STEP=1
    # export changed files (no dirs) from local repo (speed)
    IFS=$'\n'
    for LINE in $MATCHCHANGED; do
      IFS=' '
      WORDS=($LINE)
      FSTATUS=${WORDS[0]}
      FNAME=${WORDS[1]}
      # only export modified and deleted files. new files wont exist in repo yet
      if [ "$FSTATUS" == "U" ] || [ "$FSTATUS" == "UU" ] || [ "$FSTATUS" == "A" ]; then
        if [ -z "$PROJECT_KEY" ]; then
          fkey=${FNAME%%/*}
          for i in ${PROJECT_ARRAY[@]}
          do
            key=${i%:*}
            ver=${i#*:}
            if [ "$fkey" == "$key" ]; then
              PROJECT_KEY=$key
              PROJECT_VER=$ver
              SYNTAX_ARGS=$SYNTAX_ARGS" -Dsonar.projectKey="$PROJECT_KEY
              SYNTAX_ARGS=$SYNTAX_ARGS" -Dsonar.projectName="$PROJECT_KEY
              SYNTAX_ARGS=$SYNTAX_ARGS" -Dsonar.projectVersion="$PROJECT_VER
              STAT_ARGS=$STAT_ARGS" -Dproject="$PROJECT_KEY
              STAT_ARGS=$STAT_ARGS" -Dversion="$PROJECT_VER
              break;
            fi
          done
        fi
        FILEDIR=$(dirname $FNAME)
        mkdir -p check/$FILEDIR
        $SVNLOOK cat $MODE "$TXN" "$REPOS" $FNAME > $WORKING/check/$FNAME
        LINES=`cat $WORKING/check/$FNAME | wc -l`
        if [ $STEP -eq 1 ]; then
          echo '{ "lines report": [' >> $LRPT_FILE
        fi
        if [ $STEP -eq $NUMMATCHCHANGED ]; then
          echo '{ "file":"'${FNAME}'", "lines":"'${LINES}'" }' >> $LRPT_FILE
          echo ']}' >> $LRPT_FILE
        else
          echo '{ "file":"'${FNAME}'", "lines":"'${LINES}'" },' >> $LRPT_FILE
        fi
        STEP=$(( $STEP + 1 ))
      fi
    done

    echo $PROJECT_KEY > $WORKING/PROJECT
    echo $PROJECT_VER > $WORKING/VERSION
    echo $AUTHOR > $WORKING/AUTHOR
    echo $SYNTAX_CMD $SYNTAX_ARGS > $WORKING/SONAR
    echo $STAT_CMD $STAT_ARGS $STAT_JAR > $WORKING/STAT

    cd $WORKING
    SYNTAXERROR=`$SYNTAX_CMD $SYNTAX_ARGS 2> $WORKING/sonar.STDERR`
    mv $WORKING/$LRPT_FILE $WORKING/report/$LRPT_FILE
    cd $WORKING/report
    SYNTAXERROR=`$STAT_CMD $STAT_ARGS $STAT_JAR 2> $WORKING/stat.STDERR`
    SYNTAXRETURN=$?
  fi
  syntaxclean $WORKING
fi

