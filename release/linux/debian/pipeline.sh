#!/usr/bin/env bash

#------------------------------------------------------------------------------
# Copyright (c) Microsoft Corporation. All rights reserved.
#------------------------------------------------------------------------------

# Description:
#
# Instructions to be invoked under the build CI pipeline in AzureDevOps.
#
# Kickoff debian package build in docker and copy the .deb package artifact
# back to the local filesystem. The build pipeline can then save it as an
# artifact as it sees fit.
#
# Note: Intended to be ran under ubuntu.
#
# Usage:
# -----------------------------------
# buster  - Debian 10
# stretch - Debian 9
# jessie  - Debian 8
# -----------------------------------
# focal  - Ubuntu 20.04
# bionic - Ubuntu 18.04
# xenial - Ubuntu 16.04
# -----------------------------------
#
# Example:
#
# export DISTRO=xenial
# export DISTRO_IMAGE=ubuntu:xenial
#
# $ pipeline.sh

set -exv

: "${DISTRO:?DISTRO environment variable not set.}"
: "${DISTRO_BASE_IMAGE:?DISTRO_BASE_IMAGE environment variable not set.}"
: "${REPO_ROOT_DIR:=`cd $(dirname $0); cd ../../; pwd`}"
DIST_DIR=${BUILD_STAGINGDIRECTORY:=${REPO_ROOT_DIR}/output/debian}

CLI_VERSION=0.0.1

echo "=========================================================="
echo "CLI_VERSION: ${CLI_VERSION}"
echo "CLI_VERSION_REVISION: ${CLI_VERSION_REVISION:=1}"
echo "CLI_COMMAND_EXCLUSION_LIST: ${CLI_COMMAND_EXCLUSION_LIST}"
echo "CLI_PRE_INSTALLED_EXTENSION_LIST: ${CLI_PRE_INSTALLED_EXTENSION_LIST}"
echo "Distribution: ${DISTRO}"
echo "Distribution Image: ${DISTRO_BASE_IMAGE}"
echo "=========================================================="

mkdir -p ${DIST_DIR} || exit 1

docker run --rm \
           -v "${REPO_ROOT_DIR}":/mnt/repo \
           -v "${DIST_DIR}":/mnt/output \
           -e CLI_VERSION=${CLI_VERSION} \
           -e CLI_VERSION_REVISION=${CLI_VERSION_REVISION:=1}~${DISTRO} \
           -e CLI_COMMAND_EXCLUSION_LIST=${CLI_COMMAND_EXCLUSION_LIST} \
           -e CLI_PRE_INSTALLED_EXTENSION_LIST=${CLI_PRE_INSTALLED_EXTENSION_LIST} \
           -e GO_MSSQLTOOLS_PIPELINE_RUN_NUMBER=${GO_MSSQLTOOLS_PIPELINE_RUN_NUMBER} \
           "${DISTRO_BASE_IMAGE}" \
           /mnt/repo/release/linux/debian/build-pkg.sh
