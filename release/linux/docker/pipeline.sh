#!/usr/bin/env bash

#------------------------------------------------------------------------------
# Copyright (c) Microsoft Corporation. All rights reserved.
#------------------------------------------------------------------------------

# Description:
#
# Instructions to be invoked under the build CI pipeline in AzureDevOps.
#
# Build and save the `go-mssqltools` image into the bundle:
# `docker-go-mssqltools-${CLI_VERSION}.tar`
#
# Usage:
#
# export BUILD_NUMBER=12345  (optional - used to identify the IMAGE_NAME)
# $ pipeline.sh

: "${REPO_ROOT_DIR:=`cd $(dirname $0); cd ../../../; pwd`}"
DIST_DIR=${BUILD_STAGINGDIRECTORY:=${REPO_ROOT_DIR}/output/docker}
IMAGE_NAME=microsoft/go-mssqltools${BUILD_BUILDNUMBER:=''}

CLI_VERSION=${CLI_VERSION:=0.0.1}

echo "=========================================================="
echo "CLI_VERSION: ${CLI_VERSION}"
echo "CLI_COMMAND_EXCLUSION_LIST: ${CLI_COMMAND_EXCLUSION_LIST}"
echo "CLI_PRE_INSTALLED_EXTENSION_LIST: ${CLI_PRE_INSTALLED_EXTENSION_LIST}"
echo "IMAGE_NAME: ${IMAGE_NAME}"
echo "Output location: ${DIST_DIR}"
echo "=========================================================="

docker build --no-cache \
             --build-arg BUILD_DATE="`date -u +"%Y-%m-%dT%H:%M:%SZ"`" \
             --build-arg CLI_VERSION=${CLI_VERSION} \
             --build-arg CLI_COMMAND_EXCLUSION_LIST=${CLI_COMMAND_EXCLUSION_LIST} \
             --build-arg CLI_PRE_INSTALLED_EXTENSION_LIST=${CLI_PRE_INSTALLED_EXTENSION_LIST} \
             --build-arg GO_MSSQLTOOLS_PIPELINE_RUN_NUMBER=${GO_MSSQLTOOLS_PIPELINE_RUN_NUMBER} \
             --tag ${IMAGE_NAME}:latest \
             ${REPO_ROOT_DIR}

echo "=========================================================="
echo "Done - docker build"
echo "=========================================================="

mkdir -p ${DIST_DIR} || exit 1
docker save -o "${DIST_DIR}/docker-go-mssqltools-${CLI_VERSION}.tar" ${IMAGE_NAME}:latest

echo "=========================================================="
echo "Done - docker save"
echo "=========================================================="

echo "=== Done ================================================="
docker rmi -f ${IMAGE_NAME}:latest
ls ${DIST_DIR}
echo "=========================================================="
