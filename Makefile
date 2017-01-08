.RECIPEPREFIX +=
SHELL = /bin/bash

deploy:
    eval $$(docker-machine env $(DOCKER_MACHINE_NAME))
    docker network create --driver bridge nginx-proxy || true
    docker-compose pull
    docker-compose up -d --force-recreate --no-build
    eval $$(docker-machine env -u)

ps:
    eval $$(docker-machine env $(DOCKER_MACHINE_NAME))
    docker-compose ps
    eval $$(docker-machine env -u)

logs:
    eval $$(docker-machine env $(DOCKER_MACHINE_NAME))
    docker-compose logs
    eval $$(docker-machine env -u)
