#!/usr/bin/env bash

#------------------------------------------------------------------------------
# Copyright (c) Microsoft Corporation. All rights reserved.
#------------------------------------------------------------------------------

: "${REPO_ROOT_DIR:=`cd $(dirname $0); pwd`}"

echo $REPO_ROOT_DIR

python $REPO_ROOT_DIR/formula_directive.py