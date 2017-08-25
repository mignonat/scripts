#!/bin/sh

export NQI_VERSION=6_0
export NQI_REP=/nqi/dev/orchestra/${NQI_VERSION}/nqi

cd $NQI_REP/orchestra/orchestra-dbms
./create-dbms.sh
STATUS=$?
if ! [ $STATUS -eq 0 ]; then
	echo "Script generation failed !!!"
	exit 2
fi
