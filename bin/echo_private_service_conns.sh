#!/bin/bash
 
#########################################################
# BEGIN
#########################################################

ECHO_GETHOST=`hostname -f`
ECHO_GETSHORT=`hostname --short`
ECHO_GETDOMAIN=`hostname --domain`
ECHO_GETIP=`ip route get 1 | awk '{print $NF;exit}'`
ECHO_PUBLICIP=`curl ifconfig.me`


echo "          ---------------------------------------------------------------------------------------------------------"
echo "          ---------------------------------------------------------------------------------------------------------"
echo "          ------------------------------   Private IP Links:      -------------------------------------------------"
echo "          ---------------------------------------------------------------------------------------------------------"
echo "          ---------------------------------------------------------------------------------------------------------"


echo
echo "          ---------------------------------------------------------------------------------------------------------"
echo "          ---------------------------------------------------------------------------------------------------------"
echo "          |          Service              |                       URL                                              "
echo "          ---------------------------------------------------------------------------------------------------------"
echo "          ---------------------------------------------------------------------------------------------------------"
echo "          | Cloudera Manager              |       http://$ECHO_GETIP:7180                                       "
echo "          ---------------------------------------------------------------------------------------------------------"
echo "           --------------------------------------------------------------------------------------------------------"
echo "          | Ranger                        |       http://$ECHO_GETIP:6080                                       "
echo "          ---------------------------------------------------------------------------------------------------------"
echo "          ---------------------------------------------------------------------------------------------------------"
echo "          | Atlas                         |       http://$ECHO_GETIP:31000                                      "
echo "          ---------------------------------------------------------------------------------------------------------"
echo "          ---------------------------------------------------------------------------------------------------------"
echo "          | Zeppelin                      |       http://$ECHO_GETIP:8885                                       "
echo "          ---------------------------------------------------------------------------------------------------------"
echo "          ---------------------------------------------------------------------------------------------------------"
echo "          | Hue                           |       http://$ECHO_GETIP:8888                                       "
echo "          ---------------------------------------------------------------------------------------------------------"
echo "          ---------------------------------------------------------------------------------------------------------"
echo "          | DAS                           |       http://$ECHO_GETIP:30800                                      "
echo "          ---------------------------------------------------------------------------------------------------------"
echo "          ---------------------------------------------------------------------------------------------------------"
echo "          | Edge Flow Manager             |       http://$ECHO_GETIP:10080/efm/ui                               "
echo "          ---------------------------------------------------------------------------------------------------------"
echo "          ---------------------------------------------------------------------------------------------------------"
echo "          | NiFi                          |       http://$ECHO_GETIP:8080/nifi                                  "
echo "          ---------------------------------------------------------------------------------------------------------"
echo "          ---------------------------------------------------------------------------------------------------------"
echo "          | NiFi Regisry                  |       http://$ECHO_GETIP:18080/nifi-registry                        "
echo "          ---------------------------------------------------------------------------------------------------------"
echo "          ---------------------------------------------------------------------------------------------------------"
echo "          | Streams Messaging Manager     |       http://$ECHO_GETIP:9991                                       "
echo "          ---------------------------------------------------------------------------------------------------------"
echo "          ---------------------------------------------------------------------------------------------------------"
echo "          | CDSW                          |       http://cdsw.$ECHO_PUBLICIP.nip.io                                "
echo "          ---------------------------------------------------------------------------------------------------------"
echo "          ---------------------------------------------------------------------------------------------------------"
echo "          | Schema Registry               |       http://$ECHO_GETIP:7788                            		 "
echo "          ---------------------------------------------------------------------------------------------------------"
echo "          ---------------------------------------------------------------------------------------------------------"
echo "          | Superset                      |       http://$ECHO_GETIP:8089                                       "
echo "          ---------------------------------------------------------------------------------------------------------"
echo
echo
