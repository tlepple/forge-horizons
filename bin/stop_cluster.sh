#!/bin/bash

starting_dir=`pwd`

export PRIVATE_IP=`ip route get 1 | awk '{print $NF;exit}'`

# assumes the cm host is being run from host of this script
export CM_HOST=`hostname -f`

# Load util functions.
. $starting_dir/bin/cm_utils.sh


#stop all cluster services:
stop_cluster_services
echo "stopping services..."
sleep 30s
echo

#check all services are stopped
new_all_services_status_eq
echo
echo "sleeping for 20s"
sleep 20s

while [[ ${ARRAY_EQ} != 'YES' ]]; do
    new_all_services_status_eq
    echo;
    echo "sleeping for 20s"
    echo;
    sleep 20s
done

echo
#echo "Stopping EFM..."
#/opt/cloudera/cem/efm-1.0.0.1.0.0.0-54/bin/efm.sh stop
echo

#echo "Stopping Superset..."
#systemctl stop superset
#echo

echo "All Services Stopped!!!"
echo

#check cdsw has stopped all pods
#check_role_state
#echo

# stop CM Service:
stop_cm_service
echo


# all services should be stopped here:
echo "Everything stopped.  It is safe to shutdown cloud instance..."
