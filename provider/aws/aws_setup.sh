#!/bin/bash

PROVIDER=$1
TEMPLATE=$2
BLOCKDEVICE=$3

PUBLIC_IP=`curl https://api.ipify.org/`

#########################################################
# Input parameters
#########################################################

echo "Begin install into AWS Instance from the aws_setup.sh script..."

echo "Parameter PROVIDER -->" $PROVIDER
echo "Parameter TEMPLATE -->" $TEMPLATE
echo "Parameter BLOCKDEICD -->" $BLOCKDEVICE
###########################################################################################################
#time issues for clock offset in aws	
###########################################################################################################
echo "setup clock offset issues for aws"
echo "server 169.254.169.123 prefer iburst minpoll 4 maxpoll 4" >> /etc/chrony.conf
systemctl restart chronyd


###########################################################################################################
#setup the template with public ip addresses	
###########################################################################################################
sed -i "s/YourCDSWDomain/$PUBLIC_IP/g" $starting_dir/common/templates/$TEMPLATE

###########################################################################################################
# update the nifi template here for model address
###########################################################################################################
sed -i "s/YourCDSWDomain/cdsw.${PUBLIC_IP}.nip.io/" $starting_dir/common/component/nifi_templates/cdsw_rest_api.xml



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

. $starting_dir/bin/echo_service_conns.sh
