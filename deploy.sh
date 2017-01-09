#!/usr/bin/env bash

set -e

eval $(docker-machine env $DOCKER_MACHINE_NAME)
docker network create --driver bridge nginx-proxy || true
docker-compose pull
docker-compose up -d --force-recreate --no-build
docker-compose ps
eval $(docker-machine env -u)
