#!/bin/bash
INSTALL_PATH="/usr/share/doc/qinfluxdbkapacitor-image"
DOCKER_FILE="Dockerfile"
TARGET_IMG_NAME="qinfluxdbkapacitor_base"
TAG_ENV_FILE=".env"


if [ -f "./$TAG_ENV_FILE" ]; then
    TAG=`cat "$TAG_ENV_FILE" |grep "QINFLUXDBKAPACITOR_TAG=" |cut -d '=' -f 2`
    `docker rmi $TARGET_IMG_NAME:$TAG >/dev/null 2>&1`
else
    echo "not found ./$TAG_ENV_FILE"
fi


if [ ! -f  ${DOCKER_FILE} ]; then
    echo "${DOCKER_FILE}not find"
    exit 1
fi

if [ ! -d ${INSTALL_PATH} ]; then
    echo "Dir ${INSTALL_PATH} not exist"
else
    `cp ${INSTALL_PATH}/*.deb ./`
    if [ "x$?" != "x0" ]; then
        echo "cp ${INSTALL_PATH}/*.deb failure"
        exit 1
    fi
fi

TIMESTAMP=`date +"%Y-%m-%d_%H-%M-%S"`
# Use cache to build faster
#docker build --no-cache=true -t ${TARGET_IMG_NAME}:${TIMESTAMP} .
docker build -t ${TARGET_IMG_NAME}:${TIMESTAMP} .
if [ "x$?" != "x0" ]; then
    echo "build ${TARGET_IMG_NAME}:${TIMESTAMP} failure"
    exit 1
fi

`echo "QINFLUXDBKAPACITOR_TAG="$TIMESTAMP"" > "$TAG_ENV_FILE"`
`echo "IMAGE_TAG=$TARGET_IMG_NAME:$TIMESTAMP" >> "$TAG_ENV_FILE"`
`echo "NDR_PATH=/.data/qne-qundr" >> "$TAG_ENV_FILE"`
`echo "SEC_OPS_PATH=sec-ops" >> "$TAG_ENV_FILE"`
docker save ${TARGET_IMG_NAME}:${TIMESTAMP} > ${TARGET_IMG_NAME}.tar
docker rmi ${TARGET_IMG_NAME}:${TIMESTAMP}
if [ ! -f "${TARGET_IMG_NAME}.tar" ]; then
    echo "Not find "$TARGET_IMG_NAME".tar"
    exit 1
fi

