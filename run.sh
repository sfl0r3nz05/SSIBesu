#!/bin/bash -u

NO_LOCK_REQUIRED=true

. ./.env
. ./.common.sh

# Build and run containers and network
echo "docker-compose.yml" > ${LOCK_FILE}

echo "${bold}*************************************"
echo "Besu Dev Quickstart"
echo "*************************************${normal}"
echo "Start network"
echo "--------------------"

if [ -f "docker-compose-deps.yml" ]; then
    echo "Starting dependencies..."
    docker-compose -f docker-compose-deps.yml up --detach
    sleep 60
fi

echo "Starting network..."
docker-compose build --pull
docker-compose up --detach

#list services and endpoints
./list.sh

