#!/bin/bash

PROVIDER=$1
TEMPLATE=$2

#########################################################
# Input parameters
#########################################################

echo "Begin install into AWS Instance from the aws_setup.sh script..."

echo "Parameter PROVIDER -->" $PROVIDER
echo "Parameter TEMPLATE -->" $TEMPLATE
###########################################################################################################
#time issues for clock offset in aws	
###########################################################################################################
echo "setup clock offset issues for aws"
#echo "server 169.254.169.123 prefer iburst minpoll 4 maxpoll 4" >> /etc/chrony.conf
#systemctl restart chronyd


###########################################################################################################
# install the common items from script 
###########################################################################################################
echo "calling common_setup.sh here..."
. $starting_dir/common/common_setup.sh $PROVIDER $TEMPLATE
