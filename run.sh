#!/bin/sh

REPO=nothingdocker
IMAGE_NAME=centos-demo
TAG=mongodb-redis-rmq
DOCKER_NAME=${1:-demo}

docker stop $DOCKER_NAME
docker rm -f $DOCKER_NAME
docker run -d --restart=always --privileged --net=host\
	--name $DOCKER_NAME \
	-v /sys/fs/cgroup:/sys/fs/cgroup:ro \
	-v /data/server:/data/server \
        -v /data/config:/data/config \
        -v /data/config/nginx:/etc/nginx \
        -v /data/config/supervisor:/etc/supervisord.d \
        -v /data/mongo/db:/var/lib/mongo \
        -v /data/mongo/logs:/var/log/mongodb \
	$REPO/$IMAGE_NAME:$TAG
docker exec -it $DOCKER_NAME bash
