#!/bin/sh

export NQI_VERSION=6_0
export NQI_REP=/nqi/dev/orchestra/${NQI_VERSION}/nqi

cd ${NQI_REP}/platform/test
mvn -Dmaven.test.skip=false test
STATUS=$?
if ! [ $STATUS -eq 0 ]; then
	echo "mvn platform test failed !"
	exit 2
fi

