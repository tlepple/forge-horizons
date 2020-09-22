#!/bin/bash

#########################################################
# Input parameters
#########################################################

case "$1" in
        aws)
            echo "you chose aws"
            ;;
        azure)
            echo "you chose azure"
            ;;
        gcp)
	    echo "you chose gcp"
            ;;
        proxmox)
	    echo "you chose proxmox"
            ;;
        *)
            echo $"Usage: $0 {aws|azure|gcp|proxmox}"
            echo $"example: ./provider-pre-req-setup.sh azure"
            echo $"example: ./provider-pre-req-setup.sh aws"
            echo $"example: ./provider-pre-req-setup.sh gcp"
            echo $"example: ./provider-pre-req-setup.sh proxmox"
            echo
esac

CLOUD_PROVIDER=$1
NEWHOSTNAME=$2

########################################################
# utility functions
#########################################################
dir=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )

starting_dir=`pwd`

# logging function
log() {
    echo -e "[$(date)] [$BASH_SOURCE: $BASH_LINENO] : $*"
    echo -e "[$(date)] [$BASH_SOURCE: $BASH_LINENO] : $*" >> $starting_dir/setup-all.log
}

#####################################################
# Execute cloud provider specific code
#####################################################

case "$CLOUD_PROVIDER" in
        aws)
            echo "calling the pre-reqs-setup.sh script here... "
  			. $starting_dir/provider/aws/pre-reqs-setup.sh $CLOUD_PROVIDER $NEWHOSTNAME
            ;;
        azure)
	    echo "calling the pre-reqs-setup.sh script here... "
#  			. $starting_dir/provider/azure/pre-reqs-setup.sh $CLOUD_PROVIDER $NEWHOSTNAME
            ;;
        gcp)
	    echo "calling the pre-reqs-setup.sh script here... "
#     		. $starting_dir/provider/gcp/pre-reqs-setup.sh $CLOUD_PROVIDER $NEWHOSTNAME
            ;;
        proxmox)
	    echo "calling the pre-reqs-setup.sh script here... "
           . $starting_dir/provider/proxmox/pre-reqs-setup.sh $CLOUD_PROVIDER $NEWHOSTNAME
            ;;
        *)
            echo "you had a different choice... is this block needed?"
	    ;;
esac

cd $starting_dir
