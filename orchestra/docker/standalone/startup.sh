#!/bin/bash
#will be launch in /home/docker/app/orchestra/bin

#run postgres
/usr/lib/postgresql/9.3/bin/postgres -D /var/lib/postgresql/9.3/main -c config_file=/etc/postgresql/9.3/main/postgresql.conf &

pg_isready -h localhost -p "5432" > /dev/null 2> /dev/null
attempt=0
res=$?
while [ ! $res -eq 0 ]; do
echo 'Waiting to postgres to be up ... (code='\$res')'
sleep 3
  pg_isready -h localhost -p "5432" > /dev/null 2> /dev/null
  res=$?
  ((attempt++))
  if [ $attempt > 5 ]; then
    echo 'Max attempt reached, exit ...'
    exit 1
  fi
done
./nqi-service run