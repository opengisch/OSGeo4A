#!/usr/bin/env bash

set -e

TAG=$1
# for Docker >= 18 cat ~/.docker_pwd | docker login --username 3nids --password-stdin
docker login --username=3nids --password=$(cat ~/.docker_pwd)
docker build -t opengisch/qfield-sdk:${TAG} .
docker tag opengisch/qfield-sdk:${TAG} opengisch/qfield-sdk:latest
docker push opengisch/qfield-sdk:${TAG}

echo "*** DO NOT FORGET TO TAG ON GIT:"
echo "git tag ${TAG} && git push --tag"


