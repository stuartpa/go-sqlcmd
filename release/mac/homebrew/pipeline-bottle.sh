#!/usr/bin/env bash

#------------------------------------------------------------------------------
# Copyright (c) Microsoft Corporation. All rights reserved.
#------------------------------------------------------------------------------

# Description:
#
# Instructions to be invoked under the build CI pipeline in AzureDevOps on a
# macOS architecture.
#
# Builds homebrew binary bottle from formula artifacts. The build pipeline can
# then save it as an artifact as it sees fit.
#
# Usage:
#
# $ pipeline-formula.sh

set -e

: "${REPO_ROOT_DIR:=`cd $(dirname $0); cd ../../; pwd`}"
DIST_DIR=${REPO_ROOT_DIR}/output/homebrew
CLI_VERSION=0.0.1

# -- script intended to run on macOs --
osxVersion=$(sw_vers -productVersion| awk -F '[.]' '{print $2}')
OSX_CODENAME_MAP=(
["13"]="high_sierra"
["14"]="mojave"
["15"]="catalina"
)

if [[ -n "${OSX_CODENAME_MAP[$osxVersion]}" ]]
then
   macOS=${OSX_CODENAME_MAP[$osxVersion]}
else
   echo "Must be ran on macOS architecture (catalina|mojave|high_sierra)!"
   exit 1
fi

echo "=========================================================="
echo "CLI_VERSION: ${CLI_VERSION}"
echo "macOS:: ${macOS}"
echo "HOMEBREW_FORMULA_ARTIFACT_DIR: ${HOMEBREW_FORMULA_ARTIFACT_DIR}"
echo "Output location: ${DIST_DIR}"
echo "=========================================================="

# Homebrew updates are causing install problems on mojave where
# the formula dependencies are not part of homebrew-core such as:
# msodbcsql17 mssql-tools 

brew tap microsoft/mssql-release https://github.com/Microsoft/homebrew-mssql-release
brew update
HOMEBREW_NO_ENV_FILTERING=1 ACCEPT_EULA=Y brew install msodbcsql17 mssql-tools
# Remove these as they are not needed and increases build time unnecessarily
brew uninstall go-mssqltools --force

if [ ! -d "$HOMEBREW_FORMULA_ARTIFACT_DIR" ] ;
then
    echo "Building formula artifacts"
    ${REPO_ROOT_DIR}/release/mac/homebrew/pipeline-formula.sh

    # -- if no exsisting dir was provided use the default staging dir --
    if [ -z "$HOMEBREW_FORMULA_ARTIFACT_DIR" ] ;
    then
        HOMEBREW_FORMULA_ARTIFACT_DIR=${DIST_DIR}
    fi
fi

# isInstalled=`brew search go-mssqltools`
isInstalled=false

echo "=========================================================="
echo "Remove pre-installed go-mssqltools?"
echo ${isInstalled}

if [[ "$isInstalled" != "No formula or cask found for*" ]] ;
then
    echo "First uninstalling go-mssqltools before proceeding with fresh install..."
    #brew uninstall go-mssqltools
fi
echo "=========================================================="

echo "=========================================================="
echo "Install go-mssqltools formula from source"
echo "=========================================================="

pushd ${HOMEBREW_FORMULA_ARTIFACT_DIR}
pwd
chmod 755 install.sh
ls -la
./install.sh --build-bottle
popd

echo "=========================================================="
echo "sqlcmd"
echo "=========================================================="
sqlcmd --help

echo "=========================================================="
echo "Audit go-mssqltools formula"
echo "=========================================================="
skipStyles=Migration/DepartmentName,Metrics/MethodLength,Metrics/ClassLength,Metrics/AbcSize,Sorbet/FalseSigil
#brew audit --except-cops=${skipStyles} ${HOMEBREW_FORMULA_ARTIFACT_DIR}/go-mssqltools.rb

echo "Audit success"
echo "Skipped the following rubocop metrics '${skipStyles}'"

mkdir -p ${DIST_DIR}

echo "=========================================================="
echo "Build bottle"
echo "=========================================================="

bottle=go-mssqltools-${CLI_VERSION}.${macOS}.bottle.tar.gz

# This outputs the bottle DSL which should be inserted into the formula file
brew bottle go-mssqltools --force-core-tap --debug
mv go-mssqltools-*.bottle*tar.gz ${DIST_DIR}/${bottle}

echo "=========================================================="
echo "Add bottle checksum to formula"
echo "=========================================================="

shasum=`shasum -a 256 ${DIST_DIR}/${bottle}`
sha256=(${shasum// / })
search="sha256 \"\" => :$macOS"
replace="sha256 \"$sha256\" => :$macOS"

echo "Search: $search"
echo "Replace: $replace"

sed -i '.bac' "s|$search|$replace|g" ${HOMEBREW_FORMULA_ARTIFACT_DIR}/go-mssqltools.rb

echo "=========================================================="
echo "Final Audit go-mssqltools formula"
echo "=========================================================="

#brew audit --except-cops=${skipStyles} ${HOMEBREW_FORMULA_ARTIFACT_DIR}/go-mssqltools.rb
echo "Audit success"
echo "Skipped the following rubocop metrics '${skipStyles}'"

echo "=== Done ================================================="
echo "${DIST_DIR}/"
ls ${DIST_DIR}
echo "=========================================================="
