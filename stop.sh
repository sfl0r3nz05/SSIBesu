#!/bin/bash -u

NO_LOCK_REQUIRED=false

. ./.env
. ./.common.sh

echo "${bold}*************************************"
echo "Quorum Dev Quickstart "
echo "*************************************${normal}"
echo "Stopping network"
echo "----------------------------------"

docker-compose stop
sleep 60

if [ -f "docker-compose-deps.yml" ]; then
    echo "Stopping dependencies..."
    docker-compose -f docker-compose-deps.yml stop
fi

