#!/bin/sh

REPO=nothingdocker
IMAGE_NAME=`basename $PWD`
TAG=${1:-latest}
echo $IMAGE_NAME:$TAG
docker build -t $REPO/$IMAGE_NAME:$TAG .
#docker push $REPO/$IMAGE_NAME:$TAG
