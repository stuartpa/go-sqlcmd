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

# Download Python source code
PYTHON_SRC_DIR=$(mktemp -d)
wget -qO- https://www.python.org/ftp/python/${PYTHON_VERSION}/Python-${PYTHON_VERSION}.tgz | tar -xz -C "${PYTHON_SRC_DIR}"

# Bootstrap: build and install python
if [[ "${WORKDIR}/python_env" ]]; then
   rm -rf ${WORKDIR}/python_env
fi

pushd ${PYTHON_SRC_DIR}
./*/configure --srcdir ${PYTHON_SRC_DIR}/* --prefix ${WORKDIR}/python_env
make
make install
popd
ln ${WORKDIR}/python_env/bin/python3 ${WORKDIR}/python_env/bin/python
ln ${WORKDIR}/python_env/bin/pip3 ${WORKDIR}/python_env/bin/pip

# Locale
sed -i -e 's/# en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /etc/locale.gen && \
    dpkg-reconfigure --frontend=noninteractive locales && \
    update-locale LANG=en_US.UTF-8

export LANG=en_US.UTF-8
export PATH=${WORKDIR}/python_env/bin:$PATH

# Lay down azdata-cli and dependencies, this is the "sandbox site-packages" for
# the release: package then install
${WORKDIR}/scripts/package.sh ${WORKDIR} || exit 1
find ${WORKDIR}/output/packages/python -name '*.whl' | xargs pip install

# -- install any pre-installed extensions --
if [[ "${CLI_PRE_INSTALLED_EXTENSION_LIST}" ]]; then
    EXTENSION_DIR=${WORKDIR}/azdata-cli-extensions

    if [[ -d "${EXTENSION_DIR}" ]]; then
        echo "=========================================================="
        echo "CLI_PRE_INSTALLED_EXTENSION_LIST: ${CLI_PRE_INSTALLED_EXTENSION_LIST}"
        echo "Install ${EXTENSION_DIR}/requirements.txt"
        cat ${EXTENSION_DIR}/requirements.txt
        echo "=========================================================="
        pip install -r ${EXTENSION_DIR}/requirements.txt
    else
        echo "=========================================================="
        echo "Skipping extension installation, directory not found:"
        echo ${EXTENSION_DIR}
        echo "Assert directory exists and holds all the extension whls."
        echo "=========================================================="
    fi
fi

# Verify
azdata
azdata --version
azdata extension list

mkdir /opt/stage
cp -r ${WORKDIR}/python_env/ /opt/stage

# Create create directory for debian build
mkdir -p ${WORKDIR}/debian
${WORKDIR}/release/debian/prepare-rules.sh ${WORKDIR}/debian ${WORKDIR}

cd ${WORKDIR}
mv Makefile Makefile.bk
dpkg-buildpackage -us -uc
mv Makefile.bk Makefile

debPkg=${WORKDIR}/../azdata-cli_${CLI_VERSION}-${CLI_VERSION_REVISION:=1}_all.deb
cp ${debPkg} /mnt/output/

# cleanup in mount
#rm -rf ${WORKDIR}/python_env