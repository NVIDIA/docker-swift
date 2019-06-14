#!/bin/bash

docker login -u $DOCKER_USER -p $DOCKER_PASS
export TAG=`git describe --all|cut -d / -f2-`
docker tag $REPO:$COMMIT $REPO:$TAG
if [ "$TRAVIS_BRANCH" == "master" ]; then
    docker tag $REPO:$COMMIT $REPO:latest
fi
docker tag $REPO:$COMMIT $REPO:travis-$TRAVIS_BUILD_NUMBER
docker push $REPO
