#!/bin/sh

export NQI_VERSION=6_0
export NQI_ROOT=/nqi/dev/orchestra/${NQI_VERSION}/nqi

touch ${NQI_ROOT}/orchestra/orchestra-war/src/main/webapp/css/less/orchestra.less
touch ${NQI_ROOT}/orchestra/orchestra-war/build.xml
touch ${NQI_ROOT}/orchestra/build.xml
cd ${NQI_ROOT}/orchestra/orchestra-war/
mvn lesscss:compile
STATUS=$?
if ! [ $STATUS -eq 0 ]; then
	echo "mvn lesscss:compile failed !"
	exit 2
fi

cd ${NQI_ROOT}/orchestra
ant
if ! [ $STATUS -eq 0 ]; then
	echo "ant failed !"
	exit 2
fi
