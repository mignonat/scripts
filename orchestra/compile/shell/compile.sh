#!/bin/sh

export NQI_VERSION=6_0
export NQI_ROOT=/nqi/dev/orchestra/${NQI_VERSION}/nqi

cd $NQI_ROOT
mvn -o install
STATUS=$?
if ! [ $STATUS -eq 0 ]; then
	echo "mvn -PfastPom -o install failed !"
	exit 2
fi

cd ${NQI_ROOT}/orchestra/jboss
mvn -o install
STATUS=$?
if ! [ $STATUS -eq 0 ]; then
	echo "mvn install failed !"
	exit 2
fi

cd ${NQI_ROOT}/..
./cp-database-file.sh

