#!/bin/bash
#
# SVN Syntax Check Hook Script
# Copyright (c) 2015, xienan <xienan@asiainfo.com>, AsiaInfo Inc.
#
# This script provides language independent sonar checking
# functionality intended to be invoked from a subversion pre-commit
# hook.
#
# Invocation: /path/to/svn_pre.sh $1 $2
#         or: source svn_pre.sh
#
# Requires bash 3.x or higher.
#
function running() {
  count=`ps -ef|grep $2|grep -v "vi"|grep -v "grep $2"|wc -l`
  if [ 0 == $count ]; then
    $1/$2 2>/dev/null 1>&2 &
  fi
}

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
BASE_DIR=$PRG_HOME/data
if [ ! -f "$CONFIG" ]; then
  echo "config file does not exist"
  exit 0
fi
running $PRG_HOME sonar_exec
export JAVA_HOME=`getconfig $CONFIG "JAVA_HOME"`
export SONAR_RUNNER_HOME=`getconfig $CONFIG "SONAR_RUNNER_HOME"`
export PATH=$JAVA_HOME/bin:$SONAR_RUNNER_HOME/bin:$PATH
export CLASSPATH=$CLASSPATH:$JAVA_HOME/lib:$JAVA_HOME/jre/lib
export SONAR_RUNNER_OPTS="-Xmx512m -XX:MaxPermSize=512m"
DEPARTMENT=`getconfig $CONFIG "DEPARTMENT"`
PROJECT_ROOT=`getconfig $CONFIG "PROJECT_ROOT"`
PROJECT_LIST=`getconfig $CONFIG "PROJECT_LIST"`
PROJECT_ARRAY=(${PROJECT_LIST/|/ })

MODE="-t"
REPOS="$1"
TXN="$2"
FLANG=JAVA,C,CPP,JS,HTML,CSS
ROOT_LENGTH=(${#PROJECT_ROOT})
FPATTERN="\.\(java\)$"
[ -z "$SVNLOOK" ] && SVNLOOK=/usr/bin/svnlook
[ -z "$LOG" ] && LOG=`$SVNLOOK log $MODE "$TXN" "$REPOS"`
[ -z "$DIFF" ] && DIFF=`$SVNLOOK diff $MODE "$TXN" "$REPOS"`
[ -z "$AUTHOR" ] && AUTHOR=`$SVNLOOK author $MODE "$TXN" "$REPOS"`
[ -z "$CHANGEDFILES" ] && CHANGEDFILES=`$SVNLOOK changed $MODE "$TXN" "$REPOS"`
[ -z "$SYNTAXENABLED" ] && SYNTAXENABLED="1"

# sonar check
SYNTAX_CMD=$SONAR_RUNNER_HOME/bin/sonar-runner
SYNTAX_ARGS="-Dsonar.analysis.mode=preview"

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
    MATCHCHANGED=`echo $"$CHANGEDFILES" | grep -v "^D" | grep "$FPATTERN"`
    [ -n "$MATCHCHANGED" ] && NUMMATCHCHANGED=`echo $"$MATCHCHANGED" | wc -l`
  fi

  # make sure matched files were changed
  if [ $NUMMATCHCHANGED -gt 0 ]; then
    # create temporary working directory
    WORKING=$BASE_DIR/$(basename $0).`date +%s%N`
    [ -d $WORKING ] && rm -rf $WORKING
    mkdir $WORKING || syntaxexit "failed to create temp dir for syntax check: $WORKING"
    cd $WORKING
    SYNTAX_ARGS=$SYNTAX_ARGS" -Dsonar.projectBaseDir="${WORKING}"/check"
    SYNTAX_ARGS=$SYNTAX_ARGS" -Dsonar.sources=."
    SYNTAX_ARGS=$SYNTAX_ARGS" -Dsonar.language=java"
    SYNTAX_ARGS=$SYNTAX_ARGS" -Dsonar.sourceEncoding=UTF-8"
    SYNTAX_ARGS=$SYNTAX_ARGS" -Dsonar.working.directory="${WORKING}"/report"

    # export changed files (no dirs) from local repo (speed)
    IFS=$'\n'
    for LINE in $MATCHCHANGED; do
      IFS=' '
      WORDS=($LINE)
      FSTATUS=${WORDS[0]}
      FNAME=${WORDS[1]}
      if [ $ROOT_LENGTH -gt 0 ]; then
        RNAME_LENGTH=$(($ROOT_LENGTH + 1))
      else
        RNAME_LENGTH=0
      fi
      RNAME=(${FNAME:$RNAME_LENGTH})
      # only export modified and deleted files. new files wont exist in repo yet
      if [ "$FSTATUS" == "U" ] || [ "$FSTATUS" == "UU" ] || [ "$FSTATUS" == "A" ]; then
        if [ -z "$PROJECT_KEY" ]; then
          fkey=${RNAME%%/*}
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
        FILEDIR=$(dirname $RNAME)
        mkdir -p check/$FILEDIR
        $SVNLOOK cat $MODE "$TXN" "$REPOS" $FNAME > $WORKING/check/$RNAME
      fi
    done

    if [ -n "$PROJECT_KEY" ]; then
      mkdir -p report
      echo $PROJECT_KEY > $WORKING/PROJECT
      echo $PROJECT_VER > $WORKING/VERSION
      echo $AUTHOR > $WORKING/AUTHOR
      echo $SYNTAX_CMD $SYNTAX_ARGS > $WORKING/SONAR
      echo $STAT_CMD $STAT_ARGS $STAT_JAR > $WORKING/STAT
      chmod a+x $WORKING/SONAR
      chmod a+x $WORKING/STAT
      SYNTAXRETURN=$?
    else
      syntaxclean $WORKING
    fi
  fi
fi

