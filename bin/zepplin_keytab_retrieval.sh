#!/bin/bash

############################################################################################
#  This script addresses an issue to overcome new keytabs written to dynamic directories
############################################################################################

DEST=/etc/security/keytabs


KEYTABLOCATION=$(find /var/run/cloudera-scm-agent/process/ -type f ! -empty -printf "%T@ %Tc %p\n" | sort -z | grep zeppelin.keytab | head -n1 |awk '{ print $9 }')

echo $KEYTABLOCATION

if [ ! -e $KEYTABLOCATION ] ; then 
 # keytab not found 
 echo "Keytab was not found in server." 1>&2 
 exit 1 
fi

echo "Copying current Zeppelin keytab from runtime to static directory..." 
# need to escape the cp -i alias
\cp $KEYTABLOCATION $DEST
chown zeppelin:zeppelin /etc/security/keytabs/zeppelin.keytab
chmod g+r /etc/security/keytabs/zeppelin.keytab
echo "Keytab written to destination."
# success 
