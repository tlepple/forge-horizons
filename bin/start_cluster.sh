#!/bin/bash

starting_dir=`pwd`

export PRIVATE_IP=`ip route get 1 | awk '{print $NF;exit}'`

# assumes the cm host is being run from host of this script
export CM_HOST=`hostname -f`

# Load util functions.
. $starting_dir/bin/cm_utils.sh


# start CM Service:
start_cm_service

# Start all cluster services:
start_cluster_services

#check all services are started
#all_services_status_eq
new_all_services_status_eq
echo
echo "sleeping for 20s"
sleep 20s
while [ ${ARRAY_EQ} != 'YES' ]; do
    #all_services_status_eq
    new_all_services_status_eq
    echo;
    echo "sleeping for 20s"
    echo;
    sleep 20s
done

echo

echo "All Services Started!!!"
echo
#check that CDSW is ready   
#check_cdsw

# copy the zeppelin keytab
. ${starting_dir}/bin/zepplin_keytab_retrieval.sh

#echo services connections
. ${starting_dir}/bin/echo_service_conns.sh


#echo private services connections
. ${starting_dir}/bin/echo_private_service_conns.sh

