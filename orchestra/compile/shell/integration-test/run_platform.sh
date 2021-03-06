#!/bin/sh

export NQI_VERSION=6_0
export NQI_REP=/nqi/dev/orchestra/${NQI_VERSION}/nqi

./generate-script.sh
./create-platform-database.sh

cd $NQI_REP/platform/platform-ejb-test
mvn clean install
STATUS=$?
if ! [ $STATUS -eq 0 ]; then
	echo "Platform clean install failed !"
	exit 2
fi

cd $NQI_REP/platform/platform-ejb-test
mvn -Dmaven.test.skip=false test 
STATUS=$?
if ! [ $STATUS -eq 0 ]; then
	echo "Platform test failed !"
	exit 2
fi
