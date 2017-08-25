#!/bin/bash

pgcontainername="orchestra-pg-ctn"
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
    echo "Container with tag name '$1' has id ="$containerid
    if [ "$isrunning" == "true" ]; then
        echo "Stopping container $1 (id="$(docker stop $containerid)")"
    fi
    echo "Removing container $1 (id="$(docker rm $containerid)")"
}

stop_container_if_running_by_tag $orchestracontainername
stop_container_if_running_by_tag $pgcontainername

echo "All containers have been stopped !"