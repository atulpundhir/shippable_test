
#!/usr/bin/env bash

if [ "$IS_PULL_REQUEST" == "true" ]; then
    echo "This is a pull request so skipping deployment."
    exit
fi

DOCKER_IMAGE=atulpundhir/spring-web:${BRANCH}.${BUILD_NUMBER}
APTIBLE_EMAIL=atul.pundhir@saama.com
DOCKERHUB_USERNAME=apundhir   
# Note: DOCKERHUB_PASSWORD and APTIBLE_PASSWORD are set in 'secure' section of shippable.yml

TOOLKIT_URL=$(wget -qO- https://www.aptible.com/support/toolbelt/ | grep -Eo '(http|https)://.*.deb' | grep ubuntu | tail -1)

wget -q "${TOOLKIT_URL}"
sudo dpkg -i ./*.deb
aptible login --email="${APTIBLE_EMAIL}" --password="${APTIBLE_PASSWORD}" --lifetime=600s

if [ "$BRANCH" == "develop" ]; then
    export JAVA_ENV="development"
    APP_NAME=demo-dev
elif [ "$BRANCH" == "master" ]; then
    export JAVA_ENV="production"
    APP_NAME=demo-prd
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
