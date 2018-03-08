#!/bin/sh

REPO=nothingdocker
IMAGE_NAME=`basename $PWD`
DOCKER_NAME=${1:-dev}

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
	-p 9022:22 \
        -p 9090:8080 \
        -p 9379:2379 \
        -p 8554:8554 \
        -p 15672:5672 \
        -p 15673:15672 \
        -p 9717:27017 \
	$REPO/$IMAGE_NAME
docker exec -it $DOCKER_NAME bash
