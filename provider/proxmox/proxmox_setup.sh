#!/bin/bash

#########################################################
# Input parameters
#########################################################
PROVIDER=$1
TEMPLATE=$2

echo "Begin install into ProxMox Instance from the proxmox_setup.sh script..."

echo "Parameter PROVIDER -->" $PROVIDER
echo "Parameter TEMPLATE -->" $TEMPLATE
#time issues for clock offset in aws	


###########################################################################################################
# install the common items from script 
###########################################################################################################
echo "calling common_setup.sh here..."
. $starting_dir/common/common_setup.sh $PROVIDER $TEMPLATE
