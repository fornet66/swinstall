#!/bin/bash
#
# SVN Syntax Check Hook Script
# Copyright (c) 2015, xienan <xienan@asiainfo.com>, AsiaInfo Inc.
#
# This script provides language independent sonar checking
# functionality intended to be invoked from a subversion pre-commit
# hook.
#
# Invocation: /path/to/SonarCheck $1 $2
#         or: source SonarCheck
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

export JAVA_HOME=`getconfig "/tmp/sonar.ini" "JAVA_HOME"`
export SONAR_RUNNER_HOME=`getconfig "/tmp/sonar.ini" "SONAR_RUNNER_HOME"`
export SONAR_RUNNER_OPTS="-Xmx512m -XX:MaxPermSize=512m"
SYNTAX_CMD=$SONAR_RUNNER_HOME/bin/sonar-runner
SYNTAX_ARGS="-Dsonar.analysis.mode=incremental"
SYNTAX_ARGS=$SYNTAX_ARGS" -Dsonar.sources=./"
SYNTAX_ARGS=$SYNTAX_ARGS" -Dsonar.issuesReport.html.enable=true"
SYNTAX_ARGS=$SYNTAX_ARGS" -Dsonar.issuesReport.lightModeOnly"
SYNTAX_ARGS=$SYNTAX_ARGS" -Dsonar.issuesReport.html.location=./"
SYNTAX_ARGS=$SYNTAX_ARGS" -Dsonar.issuesReport.html.name="$PROJECT_KEY".html"
SYNTAX_ARGS=$SYNTAX_ARGS" -Dsonar.projectKey="$PROJECT_KEY
SYNTAX_ARGS=$SYNTAX_ARGS" -Dsonar.projectName="$PROJET_KEY
SYNTAX_ARGS=$SYNTAX_ARGS" -Dsonar.projectVersion=1.0"

MODE="-t"
REPOS="$1"
TXN="$2"
FLANG=JAVA
FPATTERN="\.\(java\)$"
[ -z "$SVNLOOK" ] && SVNLOOK=/bin/svnlook
[ -z "$LOG" ] && LOG=`$SVNLOOK log $MODE "$TXN" "$REPOS"`
[ -z "$DIFF" ] && DIFF=`$SVNLOOK diff $MODE "$TXN" "$REPOS"`
[ -z "$AUTHOR" ] && AUTHOR=`$SVNLOOK author $MODE "$TXN" "$REPOS"`
[ -z "$CHANGEDFILES" ] && CHANGEDFILES=`$SVNLOOK changed $MODE "$TXN" "$REPOS"`
[ -z "$SYNTAXENABLED" ] && SYNTAXENABLED="1"

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

    SYNTAX_ARGS=$SYNTAX_ARGS"-Dsonar.projectBaseDir=/tmp/"$WORKING

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
          pos=`expr index $str "/"`
          pos=`expr pos - 1`
          PROJECT_KEY=echo ${FNAME:0:pos}
        fi
        FILEDIR=$(dirname $FNAME)
	mkdir -p $FILEDIR
        $SVNLOOK cat $MODE "$TXN" "$REPOS" $FNAME > $WORKING/$FNAME
      fi
    done

	echo $AUTHOR > $WORKING/AUTHOR
    SYNTAXERROR=`$SYNTAX_CMD $SYNTAX_ARGS 2> $WORKING/sonar.STDERR`
    SYNTAXRETURN=$?
  fi
#  syntaxclean $WORKING
fi

