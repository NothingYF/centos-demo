#!/bin/sh

REPO=nothingdocker
IMAGE_NAME=`basename $PWD`
DOCKER_NAME=${1:-dev}
docker rm -f $DOCKER_NAME
docker run -d --privileged \
	--name $DOCKER_NAME \
	-v /sys/fs/cgroup:/sys/fs/cgroup:ro \
	-v /data/src:/root/src \
	--net=host \
	$REPO/$IMAGE_NAME
docker exec -it $DOCKER_NAME bash
