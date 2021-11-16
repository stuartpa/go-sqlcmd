#!/usr/bin/env bash

#---------------------------------------------------------------------------------
# Copyright (c) Microsoft Corporation. All rights reserved.
#---------------------------------------------------------------------------------

# Description:
#
# Build a debian/ubuntu go-mssqltools package. This script is intended to be ran in a
# container with the respective disto/image laid down.
#
# Usage:
# $ build-pkg.sh

set -exv

: "${CLI_VERSION:?CLI_VERSION environment variable not set.}"
: "${CLI_VERSION_REVISION:?CLI_VERSION_REVISION environment variable not set.}"

WORKDIR=`cd $(dirname $0); cd ../../; pwd`
PYTHON_VERSION="3.6.5"

ls -la ${WORKDIR}

apt-get -y update || exit 1
export DEBIAN_FRONTEND=noninteractive
apt-get install -y \
  build-essential \
  libpq-dev \
  libbz2-dev \
  libncursesw5-dev \
  libgdbm-dev \
  liblzma-dev \
  tk-dev \
  libssl-dev \
  libffi-dev \
  python3-dev \
  debhelper \
  zlib1g-dev \
  wget \
  locales \
  libsqlite3-dev \
  libreadline-dev \
  unixodbc \
  unixodbc-dev \
  freetds-dev \
  freetds-bin \
  tdsodbc \
  libkrb5-dev || exit 1

# Locale
sed -i -e 's/# en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /etc/locale.gen && \
    dpkg-reconfigure --frontend=noninteractive locales && \
    update-locale LANG=en_US.UTF-8

export LANG=en_US.UTF-8
export PATH=${WORKDIR}/python_env/bin:$PATH

# Verify
/mnt/workspace/SqlcmdLinux/sqlcmd --help

mkdir /opt/stage
cp /mnt/workspace/SqlcmdLinux/sqlcmd /opt/stage/sqlcmd

# Create create directory for debian build
mkdir -p ${WORKDIR}/debian
${WORKDIR}/release/debian/prepare-rules.sh ${WORKDIR}/debian ${WORKDIR}

cd ${WORKDIR}
dpkg-buildpackage -us -uc

debPkg=${WORKDIR}/../go-mssqltools_${CLI_VERSION}-${CLI_VERSION_REVISION:=1}.deb
cp ${debPkg} /mnt/output/

# cleanup in mount
#rm -rf ${WORKDIR}/python_env