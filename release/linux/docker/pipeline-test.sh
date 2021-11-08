#!/usr/bin/env bash

#------------------------------------------------------------------------------
# Copyright (c) Microsoft Corporation. All rights reserved.
#------------------------------------------------------------------------------

# Description:
#
# Instructions to be invoked under the build CI pipeline in AzureDevOps.
#
# Kickoff docker image test:
#
# Usage:
#
# $ pipeline-test.sh

set -exv

: "${REPO_ROOT_DIR:=`cd $(dirname $0); cd ../../; pwd`}"

CLI_VERSION=`cat src/azdata-cli-core/azdata/cli/core/__version__.py | \
   grep __version__ | \
   sed s/' '//g | \
   sed s/'__version__='// | \
   sed s/\"//g | \
   sed "s/^'\(.*\)'$/\1/"`

BUILD_ARTIFACTSTAGINGDIRECTORY=${BUILD_ARTIFACTSTAGINGDIRECTORY:=${REPO_ROOT_DIR}/output}/docker
IMAGE_NAME=microsoft/go-mssqltools${BUILD_BUILDNUMBER:=''}:latest
TAR_FILE=${BUILD_ARTIFACTSTAGINGDIRECTORY}/docker-go-mssqltools-${CLI_VERSION}.tar

echo "=========================================================="
echo "CLI_VERSION: ${CLI_VERSION}"
echo "BUILD_ARTIFACTSTAGINGDIRECTORY: ${BUILD_ARTIFACTSTAGINGDIRECTORY}"
echo "Image name: ${IMAGE_NAME}"
echo "Docker image file: ${TAR_FILE}"
echo "=========================================================="

docker load < ${TAR_FILE}
docker run ${IMAGE_NAME} /bin/bash -c "sqlcmd && sqlcmd --version" || exit 1
