#!/bin/sh

REPO=nothingdocker
IMAGE_NAME=`basename $PWD`
DOCKER_NAME=${1:-dev}
BASE_PORT=$2

docker rm -f $DOCKER_NAME
docker run -d --restart=always --privileged \
	--name $DOCKER_NAME \
	-v /sys/fs/cgroup:/sys/fs/cgroup:ro \
	-v /data/share:/data/share \
	-v /data/share/npm-global:/root/.npm-global \
	-v /data/src/tms:/data/src \
        -v /data/platform/$DOCKER_NAME/config:/data/config \
        -v /data/platform/$DOCKER_NAME/config/nginx:/etc/nginx \
        -v /data/platform/$DOCKER_NAME/config/supervisor:/etc/supervisord.d \
        -v /data/platform/$DOCKER_NAME/mongo/db:/var/lib/mongo \
        -v /data/platform/$DOCKER_NAME/mongo/logs:/var/log/mongodb \
	-p $[$BASE_PORT+22]:22 \
        -p $[$BASE_PORT+90]:8080 \
        -p $[$BASE_PORT+379]:2379 \
        -p $[$BASE_PORT+554]:8554 \
        -p $[$BASE_PORT+555]:8555 \
        -p $[$BASE_PORT+556]:8556 \
        -p $[$BASE_PORT+672]:5672 \
        -p $[$BASE_PORT+673]:15672 \
        -p $[$BASE_PORT+717]:27017 \
	$REPO/$IMAGE_NAME
docker exec -it $DOCKER_NAME bash
