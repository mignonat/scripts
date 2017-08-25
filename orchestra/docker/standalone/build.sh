#!/bin/bash

extractionDir=""
archiveName=""
licenseFound=false
orchestraImage="orchestra-app"
orchestraContainer="orchestra-ctn"
prompt=">"
varbuff=""
language="fr"
installfile="./install.properties"

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

echo "Creating install.properties file"
echo '' > $installfile
echo 'install.directory=/home/postgres/app' >> $installfile
echo 'instance.name=orchestra' >> $installfile
echo 'starting.user=postgres' >> $installfile
echo 'default.language='$language >> $installfile
echo 'DATABASE=postgres' >> $installfile
echo 'db.host=localhost' >> $installfile
echo 'db.port=5432' >> $installfile
echo 'db.instance=nqidb' >> $installfile
echo 'db.user=postgres' >> $installfile
echo 'db.password=postgres' >> $installfile
echo 'disable.initdb=true' >> $installfile
echo 'cpms.hostname=localhost' >> $installfile
echo 'cpms.http.port=8080' >> $installfile
echo 'smtp.host=#' >> $installfile
echo 'smtp.port=25' >> $installfile

echo "Building orchestra image"
docker build --build-arg ARCHIVE_NAME=$archiveName --build-arg LANGUAGE=$language --build-arg PG_VERSION="9.4" -f ./Dockerfile-app -t $orchestraImage . # --no-cache

echo "Removing unneeded files"
rm $installfile
rm -Rf sql

echo "Build finished"
echo ""
echo "To run a container of the image :"
echo "    docker run --rm -p 8080:8080 --name "$orchestraContainer" "$orchestraImage
