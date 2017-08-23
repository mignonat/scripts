#!/bin/bash

extractionDir=""
archiveName=""
licenseFound=false

prompt=">"
varbuff=""
dbname="nqidb"
dbport=5432
dbuser="postgres"
dbpassword="postgres"
orchestraport=7001

installfile="./install.properties"
composefile="./docker-compose.yml"
postgresdockerfile="./Dockerfile-postgres"
dbhostname="database"

# for each file in the current dir
for entry in `ls`; do
    if [ "$entry" == "sql" ]; then
        echo "Removing old ./sql directory"
        rm -Rf ./sql
        continue
    elif [ "$entry" == "nqi.license" ]; then
        echo "File nqi.license found in directory"
        licenseFound=true
        continue
    fi

    startIndex=${#entry}-7 # 7 is the length of ".tar.gz"
    fileNameEnd="${entry:$startIndex:7}"
    if [ "$fileNameEnd" == ".tar.gz" ]; then
        # the archive file used is the last found ...
        extractionDir="${entry/".tar.gz"/""}"
        archiveName=$entry
        echo "Archive found in directory"
    fi
done

if [ -z "$archiveName" ]; then
    echo "Archive not found in directory !"
    exit -1
elif [ licenseFound == false ]; then
    echo "File nqi.license not found in directory !"
    exit -2
fi

# Ask for variables

echo "Enter a database name : [default $dbname] "
read -p "$prompt" varbuff
if [ ! -z "$varbuff" ]; then
    dbname=$varbuff
fi
echo "Database name is '$dbname'"

echo "Enter database port : [default $dbport] "
read -p "$prompt" varbuff
if [ ! -z "$varbuff" ]; then
    dbport=$varbuff
fi
echo "Database port is '$dbport'"

echo "Enter database username : [default $dbuser] "
read -p "$prompt" varbuff
if [ ! -z "$varbuff" ]; then
    dbuser=$varbuff
fi
echo "Database username is '$dbuser'"

echo "Enter database password : [default $dbpassword] "
read -p "$prompt" varbuff
if [ ! -z "$varbuff" ]; then
    dbpassword=$varbuff
fi
echo "Database password is set"

echo "Enter orchestra application port : [default $orchestraport] "
read -p "$prompt" varbuff
if [ ! -z "$varbuff" ]; then
    orchestraport=$varbuff
fi
echo "Orchestra port is '$orchestraport'"

echo "Select language :"
select language in "fr" "en"; do
    case $language in
        fr ) echo "Language 'fr' selected"; break;;
        en ) echo "Language 'en' selected"; break;;
    esac
done

echo "Extracting sql files from archive"
tar -xf $archiveName $extractionDir/sql/postgres/sql
mv $extractionDir/sql/postgres/sql ./sql
rm -Rf $extractionDir
echo "Directory './sql' have been created"

echo "Creating .dockerignore file for postgres build"
echo "$archiveName" > ./.dockerignore
echo "nqi.licence" >> ./.dockerignore
echo "Dockerfile-app" >> ./.dockerignore

echo "Creating postgres dockerfile"
echo "FROM postgres:9.4" > $postgresdockerfile
echo "COPY ./sql/create-all.sql /docker-entrypoint-initdb.d/10-create-all.sql" >> $postgresdockerfile
echo "COPY ./sql/init-all-$language.sql /docker-entrypoint-initdb.d/20-init-all.sql" >> $postgresdockerfile
echo "RUN chmod -Rf 777 /docker-entrypoint-initdb.d" >> $postgresdockerfile

echo "Building postgres image"
docker build --no-cache -f $postgresdockerfile -t orchestra-postgres . # --no-cache

echo "Creating .dockerignore file for orchestra build"
echo 'sql' > ./.dockerignore
echo "Dockerfile-postgres" >> ./.dockerignore

echo "Creating install.properties file"
echo '' > $installfile
echo 'install.directory=/home/orchestra/app' >> $installfile
echo 'instance.name=orchestra' >> $installfile
echo 'starting.user=orchestra' >> $installfile
echo 'default.language='$language >> $installfile
echo 'DATABASE=postgres' >> $installfile
echo 'db.host='$dbhostname >> $installfile
echo 'db.port='$dbport >> $installfile
echo 'db.instance='$dbname >> $installfile
echo 'db.user='$dbuser >> $installfile
echo 'db.password='$dbpassword >> $installfile
echo 'disable.initdb=true' >> $installfile
echo 'cpms.hostname=localhost' >> $installfile
echo 'cpms.http.port='$orchestraport >> $installfile
echo 'smtp.host=#' >> $installfile
echo 'smtp.port=25' >> $installfile

echo "Building orchestra image"
docker build --build-arg DB_PORT=$dbport --build-arg DB_HOST_NAME=$dbhostname -f ./Dockerfile-app -t orchestra-app . # --no-cache

echo "Removing unneeded files"
rm $installfile
rm .dockerignore
rm $postgresdockerfile
rm -Rf sql

echo "Creating docker compose file"
echo 'version: "3"' > $composefile
echo 'services:' >> $composefile
echo '  database:' >> $composefile
echo '    image: orchestra-postgres' >> $composefile
echo '    ports:' >> $composefile
echo '      - "'$dbport':5432"' >> $composefile
echo '    environment:' >> $composefile
echo '      - POSTGRES_USER='$dbuser >> $composefile
echo '      - POSTGRES_PASSWORD='$dbpassword >> $composefile
echo '      - POSTGRES_DB='$dbname >> $composefile
echo '  orchestra:' >> $composefile
echo '    image: orchestra-app' >> $composefile
echo '    ports:' >> $composefile
echo '      - "'$orchestraport':8080"' >> $composefile
echo '    depends_on:' >> $composefile
echo '      - "database"' >> $composefile

echo "Success, to run => docker-compose up, to stop docker-compose down"
