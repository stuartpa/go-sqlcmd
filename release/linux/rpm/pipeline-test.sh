#!/usr/bin/env bash

#------------------------------------------------------------------------------
# Copyright (c) Microsoft Corporation. All rights reserved.
#------------------------------------------------------------------------------

# Description:
#
# Instructions to be invoked under the build CI pipeline in AzureDevOps.
#
# Kickoff rpm package tests against versions:
#
# -----------------------------------
# centos:centos8
# centos:centos7
# -----------------------------------
# fedora:31
# fedora:30
# fedora:29
# -----------------------------------
# opensuse/leap:latest
# -----------------------------------
#
# Usage:
# $ pipeline-test.sh

set -exv

: "${REPO_ROOT_DIR:=`cd $(dirname $0); cd ../../; pwd`}"

CLI_VERSION=`cat src/azdata-cli-core/azdata/cli/core/__version__.py | \
   grep __version__ | \
   sed s/' '//g | \
   sed s/'__version__='// | \
   sed s/\"//g | \
   sed "s/^'\(.*\)'$/\1/"`

CLI_VERSION_REVISION=${CLI_VERSION_REVISION:=1}
BUILD_ARTIFACTSTAGINGDIRECTORY=${BUILD_ARTIFACTSTAGINGDIRECTORY:=${REPO_ROOT_DIR}/output}/rpm

YUM_DISTRO_BASE_IMAGE=( centos:centos7 centos:centos8 fedora:29 fedora:30 fedora:31 )
YUM_DISTRO_SUFFIX=( el7 el7 fc29 fc29 fc29 )

ZYPPER_DISTRO_BASE_IMAGE=( opensuse/leap:latest )
ZYPPER_DISTRO_SUFFIX=( el7 )

DISTROS_NEEDING_EPEL_TO_TEST=( centos:centos7 )

echo "=========================================================="
echo "__CLI_VERSION: ${CLI_VERSION}"
echo "CLI_VERSION_REVISION: ${CLI_VERSION_REVISION}"
echo "BUILD_ARTIFACTSTAGINGDIRECTORY: ${BUILD_ARTIFACTSTAGINGDIRECTORY}"
echo "Distribution: ${YUM_DISTRO_BASE_IMAGE} ${ZYPPER_DISTRO_BASE_IMAGE}"
echo "=========================================================="

# -- zypper installs --
for i in ${!ZYPPER_DISTRO_BASE_IMAGE[@]}; do
    image=${ZYPPER_DISTRO_BASE_IMAGE[$i]}
    suffix=${ZYPPER_DISTRO_SUFFIX[$i]}

    echo "=========================================================="
    echo "Test rpm package on ${image} .${suffix}"
    echo "=========================================================="
    rpmPkg=go-mssqltools-${CLI_VERSION}-${CLI_VERSION_REVISION}.${suffix}.x86_64.rpm
    # If testing locally w/o signing, use `--allow-unsigned-rpm` but do not commit:
    # zypper --non-interactive install --allow-unsigned-rpm /mnt/artifacts/${rpmPkg} && \

    script="zypper --non-interactive install curl && \
            rpm -v --import https://packages.microsoft.com/keys/microsoft.asc && \
            zypper --non-interactive install /mnt/artifacts/${rpmPkg} && \
            sqlcmd && \
            sqlcmd --version"

    docker pull ${image}
    docker run --rm -v ${BUILD_ARTIFACTSTAGINGDIRECTORY}:/mnt/artifacts \
               ${image} \
               /bin/bash -c "${script}"

    echo ""
done

# -- yum installs --
for i in ${!YUM_DISTRO_BASE_IMAGE[@]}; do
    image=${YUM_DISTRO_BASE_IMAGE[$i]}
    suffix=${YUM_DISTRO_SUFFIX[$i]}

    echo "=========================================================="
    echo "Test rpm package on ${image} .${suffix}"
    echo "=========================================================="
    rpmPkg=go-mssqltools-${CLI_VERSION}-${CLI_VERSION_REVISION}.${suffix}.x86_64.rpm

    # centos7/RHEL7
    # -------------
    # Note that go-mssqltools YUM repository depends on EPEL repository for some
    # packages on centos7/RHEL7. users should install EPEL repo RPM along with
    # azdata-cli repo RPMs to satisfy dependencies.
    # `yum install -y epel-release && go-mssqltools"
    dep=""
    for d in ${!DISTROS_NEEDING_EPEL_TO_TEST[@]}; do
        if [[ "${DISTROS_NEEDING_EPEL_TO_TEST[$d]}" == "${image}" ]]; then
            dep=" yum install epel-release -y && "
        fi
    done

   script="rpm --import https://packages.microsoft.com/keys/microsoft.asc && \
           yum update -y && ${dep} \
           yum localinstall /mnt/artifacts/${rpmPkg} -y && \
           sqlcmd && \
           sqlcmd --version &&"

    docker pull ${image}
    docker run --rm -v ${BUILD_ARTIFACTSTAGINGDIRECTORY}:/mnt/artifacts \
               ${image} \
               /bin/bash -c "${script}"

    echo ""
done
