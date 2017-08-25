#!/bin/sh

export NQI_VERSION=6_0
export NQI_REP=/nqi/dev/orchestra/${NQI_VERSION}/nqi
export DB_NAME=localhost-6-0

cp -f /nqi/dev/db-config/${DB_NAME}-nqidb-ds.xml ${NQI_REP}/orchestra/jboss/orchestra/deploy/nqidb-ds.xml
cp -f /nqi/dev/db-config/${DB_NAME}-nqidb-ds.xml ${NQI_REP}/orchestra/orchestra-ejb-test/target/test-classes/jboss-embedded/deploy/nqidb-ds.xml
cp -f /nqi/dev/db-config/${DB_NAME}-nqidb-ds.xml ${NQI_REP}/platform/platform-ejb-test/target/test-classes/jboss-embedded/deploy/nqidb-ds.xml
printf "${NQI_REP}/orchestra/jboss/orchestra/deploy/nqidb-ds.xml Created\r\n\r\n"
printf "Application version : ${NQI_VERSION}\r\n\r\n"
printf "Database in use : ${DB_NAME}\r\n"
