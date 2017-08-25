#!/bin/sh

export NQI_VERSION=6_0
export NQI_ROOT=/nqi/dev/orchestra/${NQI_VERSION}/nqi

cd ${NQI_ROOT}/orchestra/applications
rm -Rf cpms.ear
STATUS=$?
if ! [ $STATUS -eq 0 ]; then
	echo "rm -Rf on /orchestra/applications/cpms.ear failed !"
	exit 2
fi

cd ${NQI_ROOT}
mvn clean install
STATUS=$?
if ! [ $STATUS -eq 0 ]; then
	echo "mvn clean install on nqi failed !"
	exit 2
fi

cd ${NQI_ROOT}/platform
mvn install
STATUS=$?
if ! [ $STATUS -eq 0 ]; then
	echo "mvn install on platform failed !"
	exit 2
fi

cd ${NQI_ROOT}/orchestra/jboss
mvn install
STATUS=$?
if ! [ $STATUS -eq 0 ]; then
	echo "mvn install on jboss failed !"
	exit 2
fi

cd ${NQI_ROOT}/..
./cp-database-file.sh
