#!/bin/bash

#########################################################
# Input parameters
#########################################################
PROVIDER=$1
TEMPLATE=$2
BLOCKDEVICE=$3

# get the private ip address
PRIVATE_IP=`ip route get 1 | awk '{print $NF;exit}'`

echo "Begin install into ProxMox Instance from the proxmox_setup.sh script..."

echo "Parameter PROVIDER -->" $PROVIDER
echo "Parameter TEMPLATE -->" $TEMPLATE
echo "Parameter BLOCKDEVICE -->" $BLOCKDEVICE
#time issues for clock offset in aws	

###########################################################################################################
# setup template for proxmox items
###########################################################################################################

sed -i "s/YourCDSWDomain/$PRIVATE_IP/g" $starting_dir/common/templates/$TEMPLATE

###########################################################################################################
# update the nifi template here for model address
###########################################################################################################
sed -i "s/YourCDSWDomain/cdsw.${PRIVATE_IP}.nip.io/" $starting_dir/common/component/nifi_templates/cdsw_rest_api.xml


###########################################################################################################
# update the spark streaming code
###########################################################################################################

sed -i "s/YourCDSWDomain/${PRIVATE_IP}/" $starting_dir/common/component/efm_stuff/spark_stuff/spark.iot.py

###########################################################################################################
# install the common items from script 
###########################################################################################################
echo "calling common_setup.sh here..."
. $starting_dir/common/common_setup.sh $PROVIDER $TEMPLATE $BLOCKDEVICE


###########################################################################################################
# echo private conns 
###########################################################################################################

. $starting_dir/bin/echo_private_service_conns.sh
