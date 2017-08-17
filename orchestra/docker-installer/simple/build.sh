#!/bin/bash

# Extract sql files from orchestra installer archive
archiveFolder=""
archive=""
for entry in `ls`; do
    startIndex=${#entry}-7 # 7 is the length of ".tar.gz"
    fileNameEnd="${entry:$startIndex:7}"
    if [ "$fileNameEnd" == ".tar.gz" ]; then
        archiveFolder="${entry/".tar.gz"/""}"
        archive=$entry
        echo "Archive found in orchestra directory"
    elif [ "$entry" == "sql" ]; then
        echo "Removing old ./sql directory"
        rm -Rf ./sql
        break
    fi
done

if [ -z "$archive" ]; then
    echo "Archive not found in orchestra directory"
    exit -1
fi

echo "Extracting sql files from archive"
tar -xf $archive $archiveFolder/sql/postgres/sql
mv $archiveFolder/sql/postgres/sql ./sql
rm -Rf $archiveFolder
echo "Directory './sql' have been created"

# Ask for variables
prompt=">"
variable=""

dbname="nqidb"
echo "Enter a database name : [default $dbname] "
read -p "$prompt" variable
if [ ! -z "$variable" ]; then
    dbname=$variable
fi
echo "Database name is '$dbname'"

dbport=5432
echo "Enter database port : [default $dbport] "
read -p "$prompt" variable
if [ ! -z "$variable" ]; then
    dbport=$variable
fi
echo "Database port is '$dbport'"

dbuser=postgres
echo "Enter database username : [default $dbuser] "
read -p "$prompt" variable
if [ ! -z "$variable" ]; then
    dbuser=$variable
fi
echo "Database username is '$dbuser'"

dbpassword=postgres
echo "Enter database password : [default $dbpassword] "
read -p "$prompt" variable
if [ ! -z "$variable" ]; then
    dbpassword=$variable
fi
echo "Database password is set"

orchestraport=7001
echo "Enter orchestra application port : [default $orchestraport] "
read -p "$prompt" variable
if [ ! -z "$variable" ]; then
    orchestraport=$variable
fi
echo "Orchestra port is '$orchestraport'"

echo "Select language :"
select language in "fr" "en"; do
    case $language in
        fr ) echo "Language 'fr' selected"; break;;
        en ) echo "Language 'en' selected"; break;;
    esac
done

#build postgres image
echo "Set .dockerignore file for postgres build"
echo "$archive" > ./.dockerignore
echo "nqi.licence" >> ./.dockerignore
echo "Dockerfile-app" >> ./.dockerignore
echo "Building postgres image 'orchestra-postgres'"
docker build --no-cache -f ./Dockerfile-postgres -t orchestra-postgres .
echo "Postgres image successfuly built"

#build orchestra image
echo "Building orchestra image 'orchestra-app'"
echo "Set .dockerignore file for app build"
echo 'sql' > ./.dockerignore
echo "Dockerfile-postgres" >> ./.dockerignore
echo "Set .install.properties file to copy while building"
echo '' > ./install.properties
echo 'install.directory=/home/orchestra/app' >> ./install.properties
echo 'instance.name=orchestra' >> ./install.properties
echo 'starting.user=orchestra' >> ./install.properties
echo 'default.language='$language >> ./install.properties
echo 'DATABASE=postgres' >> ./install.properties
echo 'db.host=localhost' >> ./install.properties
echo 'db.port='$dbport >> ./install.properties
echo 'db.instance='$dbname >> ./install.properties
echo 'db.user='$dbuser >> ./install.properties
echo 'db.password='$dbpassword >> ./install.properties
echo 'disable.initdb=true' >> ./install.properties
echo 'cpms.hostname=localhost' >> ./install.properties
echo 'cpms.http.port='$orchestraport >> ./install.properties
echo 'smtp.host=#' >> ./install.properties
echo 'smtp.port=25' >> ./install.properties
docker build --no-cache -f ./Dockerfile-app -t orchestra-app .
echo "Orchestra image successfuly built"
rm ./install.properties
echo "Temp file ./install.properties deleted"

echo "Success, all build done, now you can run"
