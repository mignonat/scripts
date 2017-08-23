#!/bin/bash

pgimagename="orchestra-postgres"
pgcontainername="orchestra-pg-ctn"
orchestraimagename="orchestra-app"
orchestracontainername="orchestra-app-ctn"

get_container_id_by_tag() {
    containertag=$1
    echo $(docker ps -aqf "name=$containertag")
}

stop_container_if_running_by_tag() {
    containerid=$(get_container_id_by_tag $1)
    if [ -z "$containerid" ]; then
        return 0
    fi
    isrunning=$(docker inspect -f '{{.State.Running}}' $containerid)
    #echo "Container with tag name '$1' has id ="$containerid
    if [ "$isrunning" == "true" ]; then
        echo "Stopping container $1 ..."
        echo "$1 stopped (id="$(docker stop $containerid)")"
    fi
    echo "Removing container $1 (id="$(docker rm $containerid)")"
}

# Ask for variables
prompt=">"
variable=""

# *** DB PORT ***
echo "Enter Postgres port : [default 5432] "
read -p "$prompt" variable
dbport="5432"
if [ ! -z "$variable" ]; then
    dbport=$variable
fi
echo "Postgres port is '$dbport'"

# *** DB NAME ***
echo "Enter postgres db name : [default nqidb] "
read -p "$prompt" variable
dbname="nqidb"
if [ ! -z "$variable" ]; then
    dbname=$variable
fi
echo "Postgres db name is '$dbname'"

# Starting postgres image
stop_container_if_running_by_tag $pgcontainername
docker run --net=host -it -d -e POSTGRES_DB=$dbname -e POSTGRES_PASSWORD=$dbpassword --name $pgcontainername $pgimagename
echo "Postgres container successfuly started"

# Waiting for postgres container accepting connection
pg_isready -h "127.0.0.1" -p "$dbport" > /dev/null 2> /dev/null
while [ $? != 0 ]; do
    echo "Waiting to postgres to be up ..."
    sleep 2
    pg_isready -h "127.0.0.1" -p "$dbport" > /dev/null 2> /dev/null
done

# Starting Orchestra image
stop_container_if_running_by_tag $orchestracontainername
docker run -d --net=host -p 7001:8080 --name $orchestracontainername $orchestraimagename
echo "Orchestra container successfuly started"

echo "All containers have been started !"