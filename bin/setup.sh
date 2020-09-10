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
            ;;
           echo "you chose proxmox"
        *)
            echo $"Usage: $0 {aws|azure|gcp}"
            echo $"example: ./setup.sh azure"
            echo $"example: ./setup.sh aws"
            echo $"example: ./setup.sh gcp"
            echo $"example: ./setup.sh proxmox"
#            exit 0
esac

CLOUD_PROVIDER=$1

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
            echo "execute aws code here... "
#  			. $starting_dir/provider/aws/aws_setup.sh
            ;;
        azure)
           echo "execute azure code here"
#  			. $starting_dir/provider/azure/azure_setup.sh
            ;;
        gcp)
           echo "execute gcp code here..."
#     		cd ./provider/gcp
#     		. $starting_dir/provider/gcp/gcp_setup.sh
            ;;
        proxmox)
           echo "execute proxmox code here..."
#           . $starting_dir/provider/proxmox/proxmox_setup.sh
            ;;
        *)
            echo "you had a different choice... is this block needed?"
	    ;;
esac

cd $starting_dir
