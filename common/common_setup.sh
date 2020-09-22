##!/bin/bash

#########################################################
# Input parameters
#########################################################

PROVIDER=$1
TEMPLATE=$2

echo "Parameter PROVIDER -->"$PROVIDER
echo 
echo "Parameter TEMPLATE -->"$TEMPLATE
echo


echo "Ready to execude code here..."
echo
echo "Current directory is --> " `pwd`
echo
echo "Starting install of cluster..."
echo

# call the setup:
. common/setup_w_template.sh $TEMPLATE

