#!/bin/bash

set -e

echo "delete from celery_taskmeta; delete from celery_tasksetmeta;" | sqlite3 db/backend.db

for f in flask nginx rabbitmq;
  do
    pushd $f || exit 1
    ./build.sh
    popd || exit 1
  done

# create a docker network named my_network if one doesn't already exist
docker network create --driver bridge my_network || true

# create the four docker containers
docker run -d -it --name my_rabbitmq_container -v "$(pwd)"/document_root:/document_root -v "$(pwd)"/db:/db --network my_network my_rabbitmq
docker run -d -it --name my_flask_container    -v "$(pwd)"/document_root:/document_root -v "$(pwd)"/db:/db --network my_network my_flask
docker run -d -it --name my_celery_container   -v "$(pwd)"/document_root:/document_root -v "$(pwd)"/db:/db --network my_network my_celery
docker run -d -it --name my_nginx_container    -v "$(pwd)"/document_root:/document_root -v "$(pwd)"/db:/db --network my_network -p 8000:80 my_nginx
