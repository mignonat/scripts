#!/bin/bash

# Extract sql files from orchestra installer archive
archiveFolder=""
archive=""
for entry in `ls ./orchestra/`; do
    startIndex=${#entry}-7 # 7 is the length of ".tar.gz"
    fileNameEnd="${entry:$startIndex:7}"
    if [ $fileNameEnd == ".tar.gz" ]; then
        archiveFolder="${entry/".tar.gz"/""}"
        archive=$entry
        echo "Archive found in orchestra directory"
    fi
done

if [ -z "$archive" ]; then
    echo "Archive not found in orchestra directory"
    exit -1
fi

for entry in `ls postgres`; do
    if [ $entry == "sql" ]; then
        echo "Removing old postgres/sql directory"
        rm -Rf ./postgres/sql
        break
    fi
done

echo "Extracting sql files from archive"
tar -xf ./orchestra/$archive $archiveFolder/sql/postgres/sql
mv $archiveFolder/sql/postgres/sql ./postgres/sql
rm -Rf $archiveFolder
echo "Directory 'postgres/sql' have been created"

# Ask for variables
prompt=">"
variable=""
echo "Enter a database name : [default nqidb] "
read -p "$prompt" variable
dbname="nqidb"
if [ ! -z "$variable" ]; then
    dbname=$variable
fi
echo "Database name is '$dbname'"

echo "Enter database port : [default 5432] "
read -p "$prompt" variable
dbport=5432
if [ ! -z "$variable" ]; then
    dbport=$variable
fi
echo "Database port is '$dbport'"

echo "Enter database username : [default postgres] "
read -p "$prompt" variable
dbuser=postgres
if [ ! -z "$variable" ]; then
    dbuser=$variable
fi
echo "Database username is '$dbuser'"

echo "Enter database password : [default postgres] "
read -p "$prompt" variable
dbpassword=postgres
if [ ! -z "$variable" ]; then
    dbpassword=$variable
fi
echo "Database password is set"

echo "Select language :"
select language in "fr" "en"; do
    case $language in
        fr ) echo "Language 'fr' selected"; break;;
        en ) echo "Language 'en' selected"; break;;
    esac
done

#build postgres image
echo "Building postgres image 'orchestra-postgres'"
cd postgres
if [ ! -d "data" ]; then
  mkdir data
  echo "Data directory created"
fi
docker build -t orchestra-postgres .
echo "Postgres image built"

#build orchestra image
echo "Building orchestra image 'orchestra-app'"
cd ../orchestra
docker build -t orchestra-app .
echo "Orchestra image built"

#TODO : apply variable in the build ...

#containerId = $(docker run --name orchestra-postgres -e POSTGRES_PASSWORD=postgres -p 5432:5432 -d postgres:9.4)
#get db ip : => docker inspect --format '{{ .NetworkSettings.IPAddress }}' <container_id>

echo "Script processed successfully !"