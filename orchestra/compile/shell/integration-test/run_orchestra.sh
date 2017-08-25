#!/bin/sh

export NQI_VERSION=6_0
export NQI_REP=/nqi/dev/orchestra/${NQI_VERSION}/nqi

./generate-script.sh
./create-orchestra-database.sh

cd $NQI_REP/orchestra/orchestra-ejb-test
mvn clean install
STATUS=$?
if ! [ $STATUS -eq 0 ]; then
	echo "Orchestra clean install failed !"
	exit 2
fi

cd $NQI_REP/orchestra/orchestra-ejb-test
mvn -Dmaven.test.skip=false test 
STATUS=$?
if ! [ $STATUS -eq 0 ]; then
	echo "Orchestra test failed !"
	exit 2
fi
