#!/usr/bin/env bash

#------------------------------------------------------------------------------
# Copyright (c) Microsoft Corporation. All rights reserved.
#------------------------------------------------------------------------------

: "${REPO_ROOT_DIR:=`cd $(dirname $0); pwd`}"

echo $REPO_ROOT_DIR

pip install pipdeptree
pip install jinja2~=2.10
pip install requests>=2.20.0
pip install pydocumentdb==2.3.3
pip list --format=columns

echo $REPO_ROOT_DIR

# azdata-cli is already installed at this point
python $REPO_ROOT_DIR/formula_directive.py