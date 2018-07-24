#!/usr/bin/env bash

if [ "$IS_PULL_REQUEST" == "true" ]; then
    echo "This is a pull request so skipping deployment."
    exit
fi

DOCKER_IMAGE=atulpundhir/spring-web:${BRANCH}.${BUILD_NUMBER}
APTIBLE_EMAIL=atul.pundhir@saama.com
DOCKERHUB_USERNAME=atulpundhir

aptible login --email="${APTIBLE_EMAIL}" --password="${APTIBLE_PWD}" --lifetime=600s

if [ "$BRANCH" == "test" ]; then
    export JAVA_ENV="test"
    APP_NAME=docker-test-app
elif [ "$BRANCH" == "stage" ]; then
    export JAVA_ENV="stage"
    APP_NAME=demo-stage
elif [ "$BRANCH" == "master" ]; then
    export JAVA_ENV="production"
    APP_NAME=docker-test-app
else
    echo "Unsupported branch ($BRANCH) found."
    exit
fi

OUTCOME="Failed"
LEVEL="warning"
if aptible deploy --git-detach --app ${APP_NAME} --docker-image "$DOCKER_IMAGE" --private-registry-username "$DOCKERHUB_USERNAME" --private-registry-password "$DOCKERHUB_PASSWORD"; then
    OUTCOME="Successful"
    LEVEL="good"
fi
