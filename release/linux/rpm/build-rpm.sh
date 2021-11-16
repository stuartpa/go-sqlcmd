#!/usr/bin/env bash

#---------------------------------------------------------------------------------
# Copyright (c) Microsoft Corporation. All rights reserved.
#---------------------------------------------------------------------------------

# Description:
#
# Build a rmp go-mssqltools package. This script is intended to be ran in a
# container with the respective distro/image laid down.
#
# Usage:
# $ build-rpm.sh

set -exv

: "${CLI_VERSION:?CLI_VERSION environment variable not set.}"
: "${CLI_VERSION_REVISION:?CLI_VERSION_REVISION environment variable not set.}"

yum update -y
yum install -y postgresql-devel wget rpm-build gcc gcc-c++ libffi-devel python3-devel python3-virtualenv openssl-devel \
         make bash coreutils diffutils patch perl \
         unixODBC unixODBC-devel zeromq zeromq-devel krb5-devel

export LC_ALL=en_US.UTF-8
export REPO_ROOT_DIR=`cd $(dirname $0); cd ../../; pwd`

rpmbuild -v -bb --clean ${REPO_ROOT_DIR}/release/rpm/go-mssqltools.spec && cp /root/rpmbuild/RPMS/x86_64/* /mnt/output