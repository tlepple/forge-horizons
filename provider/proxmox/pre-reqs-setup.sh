#/bin/bash

PROVIDER=$1
NEWHOSTNAME=$2

##########################################################################################
#	Check that the hostname variable has been passed in
##########################################################################################
if [ -z "$NEWHOSTNAME" ] ; then
  echo 'HOSTNAME variable was not passed into this script.  Exiting...'        
  exit 1
fi

##########################################################################################
#	Set the hostname
##########################################################################################
hostnamectl set-hostname $NEWHOSTNAME

##########################################################################################
#	Format and mount the virtual disks
##########################################################################################
# This is for the mount '/dfs'
mkfs.xfs /dev/sdb1
mount /dev/sdb1 /dfs

# This is for the mount '/opt'
mkfs.xfs /dev/sdc1
mount /dev/sdc1 /opt

# This is for the mount '/kudu'
mkfs.xfs /dev/sdd1
mount /dev/sdd1 /kudu

##########################################################################################
#  Grab UUIDs for each vdisk & write to '/etc/fstab' so they persist through a reboot
##########################################################################################
SDB1=`lsblk -o name,mountpoint,uuid | grep 'sdb1' | awk '{print $3}'`
SDC1=`lsblk -o name,mountpoint,uuid | grep 'sdc1' | awk '{print $3}'`
SDD1=`lsblk -o name,mountpoint,uuid | grep 'sdd1' | awk '{print $3}'`


echo 'sdb1 --> ' $SDB1
echo
echo 'sdc1 --> ' $SDC1
echo
echo 'sdd1 --> ' $SDD1

echo 'UUID='$SDB1'		/dfs		xfs		defaults	0	2'  >> /etc/fstab
echo 'UUID='$SDC1'		/opt		xfs		defaults	0	2'  >> /etc/fstab
echo 'UUID='$SDD1'		/kudu		xfs		defaults	0	2'  >> /etc/fstab


##########################################################################################
##########################################################################################


#  Need to reboot the server to apply all items cleanly
echo
echo "you can reboot the server now..."
