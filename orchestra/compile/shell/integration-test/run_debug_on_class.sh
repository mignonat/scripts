#!/bin/sh

export NQI_VERSION=6_0
export NQI_REP=/nqi/dev/orchestra/${NQI_VERSION}/nqi
export TEST_CLASS=UIModelLoadTest
export PACKAGE=platform

./create-$PACKAGE-database.sh

cd $NQI_REP/$PACKAGE/$PACKAGE-ejb-test
mvn clean install
STATUS=$?
if ! [ $STATUS -eq 0 ]; then
	echo "{$PACKAGE} clean install failed !"
	exit 2
fi

cd $NQI_REP/$PACKAGE/$PACKAGE-ejb-test
mvn -o -Dmaven.test.skip=false -Dmaven.surefire.debug="-Xdebug -Xrunjdwp:transport=dt_socket,server=y,suspend=y,address=8000 -Xnoagent -Djava.compiler=NONE" test -Dtest=$TEST_CLASS
STATUS=$?
if ! [ $STATUS -eq 0 ]; then
	echo "Debug test on $TEST_CLASS failed !"
	exit 2
fi
