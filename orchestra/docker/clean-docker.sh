#!/bin/bash

echo "removing all containers and images"
docker rm -f $(docker ps -a -q) && docker rmi -f $(docker images -q) && docker rmi -f $(docker images -a -q)

echo "stopping docker service"
service docker stop

echo "emptying docker aufs directory"
rm -rf /var/lib/docker/aufs

echo "emptying docker images/aufs directory"
rm -rf /var/lib/docker/image/aufs

echo "deleting docker linkgraph.db file"
rm -f /var/lib/docker/linkgraph.db

echo "starting docker service again"
service docker start

echo "docker aufs directory cleaned"