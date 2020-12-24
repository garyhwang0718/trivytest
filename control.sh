#!/bin/bash

NDR_PATH="/.data/ndr-management"
IMAGE_TAR="qinfluxdbkapacitor_base.tar"
INSTALL_PATH=${NDR_PATH}/sec-ops/doc/qinfluxdbkapacitor-image
CMD_ECHO="/bin/echo"
CMD_AWK="/usr/bin/awk"
CMD_RM="/bin/rm"
CMD_CUT="/usr/bin/cut"

LOG_FILE="/tmp/control_qinfluxdbkapacitor.log"

exit_with_error_and_clean()
{
	exit 1
}

TARGET_IMAGE=
get_target_image_name() {
    TARGET_IMAGE=`qgetcfg -d no_image --app=qundr "Trap" "Docker_Image"`
    # Make sure the image is loaded
    RET=`docker images --format '{{.Repository}}:{{.Tag}}' | grep ${TARGET_IMAGE}`
    if [ "xno_image" == "x${TARGET_IMAGE}" ] || [ "x0" != "x$?" ]; then
        # Need to load the image from tar
        RET=`"$SCRIPT_PATH/$INIT_SH" load_image 2>&1`
        if [ "x0" != "x$?" ]; then
            echo "${RET}"
            exit 1
        fi
        TARGET_IMAGE=`qgetcfg -d no_image --app=qundr "Trap" "Docker_Image"`
    fi
}

stop_all_containers(){
    OUTPUT=`docker ps -a --format '{{.ID}} {{.Image}} {{.Names}}'`
    if [ "x0" != "x$?" ]; then
        echo "Failed to run docker command"
        exit 1
    fi
    ARRAY=()
    CONTAINERS=`echo "${OUTPUT}" | awk '{print($1, $2, $3)}'`
    while IFS= read -r LINE; do
        CONTAINER_ID=`echo "${LINE}" | awk '{print($1)}'`
        CONTAINER_IMAGE=`echo "${LINE}" | awk '{print($2)}'`
        CONTAINER_NAME=`echo "${LINE}" | awk '{print($3)}'`
        if [ "${CONTAINER_IMAGE}" == "${TARGET_IMAGE}" ]; then
            ARRAY+=(${CONTAINER_NAME})
        fi
    done <<< "${CONTAINERS}"
    for CONTAINER_NAME in ${ARRAY[@]}; do
        IS_RUNNING=`docker inspect -f '{{.State.Running}}' ${CONTAINER_NAME} | tr '[:lower:]' '[:upper:]'`
        if [ "TRUE" == "${IS_RUNNING}" ]; then
            echo "Stop trap container ${CONTAINER_NAME}"
            RET=`docker stop ${CONTAINER_NAME} 2>&1`
            if [ "x0" != "x$?" ]; then
                 echo "Unable to stop trap container: (${CONTAINER_NAME})"
                 echo ${RET}
            fi
        fi
    done
}

load_image()
{
	local ret="$(docker load --input ${INSTALL_PATH}/${IMAGE_TAR})"
	if [ "x0" != "x$?" ] ; then
		echo "docker load --input ${INSTALL_PATH}/${IMAGE_TAR} failure" >> ${LOG_FILE}
		exit 1
	else
		LOADED_IMAGE_NAME="$(echo ${ret} | grep "Loaded image" | cut -d ':' -f 2-3 | xargs)"
		`qsetcfg --app=qundr "Secops" "Docker_Image" ${LOADED_IMAGE_NAME}`
	fi
}

rm_image()
{
	IMAGE_TAG=`qgetcfg --app=qundr "Secops" "Docker_Image"`
	if [ "x" != "x${IMAGE_TAG}" ]; then
		ret="$(docker rmi -f ${IMAGE_TAG} 2>&1)"
		if [ "x0" != "x$?" ]; then
			echo "docker rmi -f ${IMAGE_TAG} failure"
			echo "${ret}"
		fi
	fi
}

case "$1" in
	load_image)
		load_image
		;;
	rm_image)
		rm_image
		;;
        stop)
		stop_all_containers
		;;
	*)
		echo "Usage: $0 {load_image|rm_image}"
		exit 1
esac

exit 0
