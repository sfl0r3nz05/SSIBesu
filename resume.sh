#!/bin/bash -u

NO_LOCK_REQUIRED=false

. ./.env
. ./.common.sh

echo "${bold}*************************************"
echo "Quorum Dev Quickstart "
echo "*************************************${normal}"
echo "Resuming network..."
echo "----------------------------------"

if [ -f "docker-compose-deps.yml" ]; then
    echo "Starting dependencies..."
    docker-compose -f docker-compose-deps.yml start
    sleep 60
fi

docker-compose start

