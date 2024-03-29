#!/bin/bash

#set -e -x

###########################################################################################################
## Single node CDP-DC install
###########################################################################################################

###########################################################################################################
# import parameters and utility functions 
###########################################################################################################
. utils.sh

###########################################################################################################
# install aws cli
###########################################################################################################
install_aws_cli

set -e -x
###########################################################################################################
# Set these password for access behind paywall
###########################################################################################################
#CLDR_REPO_USER="YourUserID"
#CLDR_REPO_PASS="YourUserPass"


###########################################################################################################
yum install -y wget
yum install -y epel-release
yum install -y python-pip

# upgrade pip version
pip install --upgrade pip==19.3.1

DB_PASSWORD="supersecret1"
TEMPLATE=$1
BLOCKDEVICE=$2

###########################################################################################################
# No Paywall 
###########################################################################################################
CLDR_MGR_BASEURL="https://archive.cloudera.com/cm7"
CLDR_MGR_VER_URL="$CLDR_MGR_BASEURL/7.0.3/redhat7/yum"
CLDR_MGR_VER_URL="$CLDR_MGR_BASEURL/7.1.4/redhat7/yum"

wget $CLDR_MGR_VER_URL/cloudera-manager-trial.repo -P /etc/yum.repos.d/


###########################################################################################################
# Paywall
###########################################################################################################
#CLDR_CM_LOCATION="@archive.cloudera.com/p/cm7"
#CLDR_MGR_BASEURL="https://$CLDR_REPO_USER:$CLDR_REPO_PASS$CLDR_CM_LOCATION"
#CLDR_MGR_VER_URL="$CLDR_MGR_BASEURL/7.1.4/redhat7/yum"

#wget $CLDR_MGR_VER_URL/cloudera-manager.repo -P /etc/yum.repos.d/
#wget $CLDR_MGR_VER_URL/cloudera-manager-trial.repo -P /etc/yum.repos.d/

###########################################################################################################
# End Paywall Section
###########################################################################################################


##CLDR includes an rpm for openjdk8 in the repo
OPENJDK_RPM_URL="$CLDR_MGR_VER_URL/RPMS/x86_64/openjdk8-8.0+232_9-cloudera.x86_64.rpm"
OPEN_JAVA_HOME="/usr/java/jdk1.8.0_232-cloudera"

##Indicate which JDK you want… TODO add Oracle option
JDK_RPM_URL="$OPENJDK_RPM_URL"
JAVA_HOME="$OPEN_JAVA_HOME"

#postgres info
PG_REPO_URL="https://yum.postgresql.org/9.6/redhat/rhel-7-x86_64/pgdg-redhat-repo-latest.noarch.rpm"

PG_HOME_DIR="/var/lib/pgsql/9.6"

#LOCAL_TIMEZONE="America/Los_Angeles"
#LOCAL_TIMEZONE="Europe/London"
#LOCAL_TIMEZONE="America/New_York"
LOCAL_TIMEZONE="America/Chicago"

###########################################################################################################
#  Configure OS pre-reqs 4 CM
###########################################################################################################

#if [ getenforce != Disabled ]
#then  setenforce 0;
#fi

ln -sf /usr/share/zoneinfo/$LOCAL_TIMEZONE /etc/localtime

## turn off Transparent Huge pages
echo never > /sys/kernel/mm/transparent_hugepage/defrag
echo never > /sys/kernel/mm/transparent_hugepage/enabled


#  turn off swappiness
sysctl vm.swappiness=10

echo "vm.swappiness = 10" >> /etc/sysctl.conf


###########################################################################################################
# Update the UserName and PWD in the repo here for paywall
###########################################################################################################
#sed -i "s/username=changeme/username=$CLDR_REPO_USER/g" /etc/yum.repos.d/cloudera-manager.repo
#sed -i "s/password=changeme/password=$CLDR_REPO_PASS/g" /etc/yum.repos.d/cloudera-manager.repo


## Import the GPG Key
rpm --import $CLDR_MGR_VER_URL/RPM-GPG-KEY-cloudera

###########################################################################################################
echo "-- Configure networking"
###########################################################################################################
PUBLIC_IP=`curl https://api.ipify.org/`
hostnamectl set-hostname `hostname -f`
PRIVATE_IP=`ip route get 1 | awk '{print $NF;exit}'`

echo "`hostname -I` `hostname`" >> /etc/hosts
sed -i "s/HOSTNAME=.*/HOSTNAME=`hostname`/" /etc/sysconfig/network

#systemctl disable firewalld
#systemctl stop firewalld

#echo "set enforce step"
#setenforce 0
echo "update selinux"
#sed -i 's/SELINUX=.*/SELINUX=disabled/' /etc/selinux/config


###########################################################################################################
# CDSW prereqs
###########################################################################################################

echo "-- Set ulimits for CDSW"
ulimit -n 1048576
echo "fs.file-max=1048576" >> /etc/sysctl.conf
echo "*               hard    nofile          1048576" >> /etc/security/limits.conf
echo "*               soft    nofile          1048576" >> /etc/security/limits.conf
echo "root               hard    nofile          1048576" >> /etc/security/limits.conf
echo "root               soft    nofile          1048576" >> /etc/security/limits.conf


###########################################################################################################
## Clear the yum cache
###########################################################################################################
yum clean all
yum repolist

###########################################################################################################
#install java
###########################################################################################################
rpm -ivh $JDK_RPM_URL

###########################################################################################################
## Install CM Server & Agent
###########################################################################################################
yum -y install cloudera-manager-server cloudera-manager-agent

###########################################################################################################
## Install Postgresql repo for Redhat
###########################################################################################################
yum -y install $PG_REPO_URL

###########################################################################################################
## Install PG 9.6
###########################################################################################################
yum -y install postgresql96-server postgresql96-contrib postgresql96 postgresql-jdbc*

###########################################################################################################
## setup the jdbc connetor
###########################################################################################################
cp /usr/share/java/postgresql-jdbc.jar /usr/share/java/postgresql-connector-java.jar
chmod 644 /usr/share/java/postgresql-connector-java.jar

echo 'LC_ALL="en_US.UTF-8"' >> /etc/locale.conf
## TODO - Is this really a requirement? do we support any other of utf-8 compat locale? fr_FR.UTF-8, de-DE.UTF-8 ?

###########################################################################################################
## Initialize Postgresql
###########################################################################################################
/usr/pgsql-9.6/bin/postgresql96-setup initdb


## Start Postgres service and config it for restart on reboot
systemctl enable postgresql-9.6
systemctl start postgresql-9.6

## Allow listeners from any host
sed -e 's,#listen_addresses = \x27localhost\x27,listen_addresses = \x27*\x27,g' -i $PG_HOME_DIR/data/postgresql.conf

## Increase number of connections
sed -e 's,max_connections = 100,max_connections = 300,g' -i  $PG_HOME_DIR/data/postgresql.conf

## Save the original & replace with a new pg_hba.conf
mv $PG_HOME_DIR/data/pg_hba.conf $PG_HOME_DIR/data/pg_hba.conf.orig

cat <<EOF > $PG_HOME_DIR/data/pg_hba.conf
  # TYPE  DATABASE        USER            ADDRESS                 METHOD
  local   all             all                                     peer
  host    scm             scm            0.0.0.0/0                md5
  host    das             das            0.0.0.0/0                md5
  host    hive            hive           0.0.0.0/0                md5
  host    hue             hue            0.0.0.0/0                md5
  host    oozie           oozie          0.0.0.0/0                md5
  host    ranger          rangeradmin    0.0.0.0/0                md5
  host    rman            rman           0.0.0.0/0                md5
  host    hbase           hbase          0.0.0.0/0                md5
  host    phoenix         phoenix        0.0.0.0/0                md5  
  host    registry        registry       0.0.0.0/0                md5
  host    streamsmsgmgr   streamsmsgmgr  0.0.0.0/0                md5
  host    nifireg         nifireg        0.0.0.0/0                md5
  host    efm             efm            0.0.0.0/0                md5
  host    datagen         datagen        0.0.0.0/0                md5
EOF

chown postgres:postgres $PG_HOME_DIR/data/pg_hba.conf
chmod 600 $PG_HOME_DIR/data/pg_hba.conf


## Restart Postgresql
systemctl restart postgresql-9.6

###########################################################################################################
## Create a DDL file for all our Db’s
###########################################################################################################
cat <<EOF > ~/create_ddl_c703.sql
CREATE ROLE das LOGIN PASSWORD 'supersecret1';
CREATE ROLE hive LOGIN PASSWORD 'supersecret1';
CREATE ROLE hue LOGIN PASSWORD 'supersecret1';
CREATE ROLE oozie LOGIN PASSWORD 'supersecret1';
CREATE ROLE rangeradmin LOGIN PASSWORD 'supersecret1';
CREATE ROLE rman LOGIN PASSWORD 'supersecret1';
CREATE ROLE scm LOGIN PASSWORD 'supersecret1';
CREATE ROLE hbase LOGIN PASSWORD 'supersecret1';
CREATE ROLE phoenix LOGIN PASSWORD 'supersecret1';
CREATE ROLE registry LOGIN PASSWORD 'supersecret1';
CREATE ROLE streamsmsgmgr LOGIN PASSWORD 'supersecret1';
CREATE ROLE nifireg LOGIN PASSWORD 'supersecret1';
CREATE ROLE efm LOGIN PASSWORD 'supersecret1';
CREATE ROLE datagen LOGIN PASSWORD 'supersecret1';
CREATE DATABASE das OWNER das ENCODING 'UTF-8';
CREATE DATABASE hive OWNER hive ENCODING 'UTF-8';
CREATE DATABASE hue OWNER hue ENCODING 'UTF-8';
CREATE DATABASE oozie OWNER oozie ENCODING 'UTF-8';
CREATE DATABASE ranger OWNER rangeradmin ENCODING 'UTF-8';
CREATE DATABASE rman OWNER rman ENCODING 'UTF-8';
CREATE DATABASE scm OWNER scm ENCODING 'UTF-8';
CREATE DATABASE hbase OWNER hbase ENCODING 'UTF-8';
CREATE DATABASE phoenix OWNER phoenix ENCODING 'UTF-8';
CREATE DATABASE registry OWNER registry ENCODING 'UTF-8';
CREATE DATABASE streamsmsgmgr OWNER streamsmsgmgr ENCODING 'UTF-8';
CREATE DATABASE nifireg OWNER nifireg ENCODING 'UTF-8';
CREATE DATABASE efm OWNER efm ENCODING 'UTF-8';
CREATE DATABASE datagen OWNER datagen ENCODING 'UTF-8';
EOF

###########################################################################################################
## Run the sql file to create the schema for all DB’s
###########################################################################################################
sudo -u postgres psql < ~/create_ddl_c703.sql

## Run the prepare script for SCM db
/opt/cloudera/cm/schema/scm_prepare_database.sh postgresql scm scm supersecret1

## TODO - Do we have to do this for C7??
sudo -u postgres psql -c 'ALTER DATABASE hive SET standard_conforming_strings=off;'
sudo -u postgres psql -c 'ALTER DATABASE oozie SET standard_conforming_strings=off;'

###########################################################################################################
## Install rng-tools,  we are expecting to see values over 1000, anything less than 100-200 and rngd isnt working
###########################################################################################################
yum -y install rng-tools
cp /usr/lib/systemd/system/rngd.service /etc/systemd/system/
systemctl daemon-reload
systemctl start rngd

###########################################################################################################
#  nodejs items for SMM
###########################################################################################################
yum install -y gcc-c++ make 
curl -sL https://rpm.nodesource.com/setup_10.x | sudo -E bash - 
sudo yum install nodejs -y
node -v    #nodejs version greater than 10  
npm -v 
npm install forever -g 

###########################################################################################################
#time issues for clock offset in aws	
###########################################################################################################
#echo "setup clock offset issues for aws"
#echo "server 169.254.169.123 prefer iburst minpoll 4 maxpoll 4" >> /etc/chrony.conf
#systemctl restart chronyd

###########################################################################################################
echo "-- Enable passwordless root login via rsa key"
###########################################################################################################
ssh-keygen -f ~/myRSAkey -t rsa -N ""
mkdir -p ~/.ssh
cat ~/myRSAkey.pub >> ~/.ssh/authorized_keys
chmod 400 ~/.ssh/authorized_keys
ssh-keyscan -H `hostname` >> ~/.ssh/known_hosts
sed -i 's/.*PermitRootLogin.*/PermitRootLogin without-password/' /etc/ssh/sshd_config
systemctl restart sshd

#####################################################
#       Step 1: install passwordless access
#####################################################
#echo "setup pwdless access"
#install_pwdless_access

###########################################################################################################
# download CSDs & parcels
###########################################################################################################
#CSDs
cd /opt/cloudera/csd

/usr/local/bin/aws s3 cp s3://zbuild-stuff2/csd/NIFI-1.11.4.1.1.0.0-119.jar .
/usr/local/bin/aws s3 cp s3://zbuild-stuff2/csd/NIFICA-1.11.4.1.1.0.0-119.jar .
/usr/local/bin/aws s3 cp s3://zbuild-stuff2/csd/NIFIREGISTRY-0.6.0.1.1.0.0-119.jar .
/usr/local/bin/aws s3 cp s3://zbuild-stuff2/csd/SCHEMAREGISTRY-0.8.0.jar .
/usr/local/bin/aws s3 cp s3://zbuild-stuff2/csd/STREAMS_MESSAGING_MANAGER-2.1.0.jar .
#/usr/local/bin/aws s3 cp s3://zbuild-stuff2/csd/CLOUDERA_DATA_SCIENCE_WORKBENCH-CDPDC-1.7.2.jar .
/usr/local/bin/aws s3 cp s3://zbuild-stuff2/csd/CLOUDERA_DATA_SCIENCE_WORKBENCH-CDPDC-1.8.0.jar .
/usr/local/bin/aws s3 cp s3://zbuild-stuff2/csd/FLINK-1.9.1-csa1.1.0.0-cdh7.0.3.0-79-1753674.jar .


# set ownership
chown cloudera-scm:cloudera-scm /opt/cloudera/csd/*
chmod 644 /opt/cloudera/csd/*

#parcels
cd /opt/cloudera/parcel-repo


#/usr/local/bin/aws s3 cp s3://zbuild-stuff2/parcel/CDSW-1.7.2.p1.2066404-el7.parcel .
/usr/local/bin/aws s3 cp s3://zbuild-stuff2/parcel/CDSW-1.8.0.p1.4968660-el7.parcel .
/usr/local/bin/aws s3 cp s3://zbuild-stuff2/parcel/CFM-1.1.0.0-el7.parcel .
/usr/local/bin/aws s3 cp s3://zbuild-stuff2/parcel/FLINK-1.9.1-csa1.1.0.0-cdh7.0.3.0-79-1753674-el7.parcel .
#/usr/local/bin/aws s3 cp s3://zbuild-stuff2/parcel/KAFKA-4.1.0-1.4.1.0.p0.4-el7.parcel .
/usr/local/bin/aws s3 cp s3://zbuild-stuff2/parcel/SCHEMAREGISTRY-0.8.0.2.0.1.0-29-el7.parcel .
/usr/local/bin/aws s3 cp s3://zbuild-stuff2/parcel/STREAMS_MESSAGING_MANAGER-2.1.0.2.0.1.0-29-el7.parcel .


#SHAs
#/usr/local/bin/aws s3 cp s3://zbuild-stuff2/sha/CDSW-1.7.2.p1.2066404-el7.parcel.sha .
/usr/local/bin/aws s3 cp s3://zbuild-stuff2/sha/CDSW-1.8.0.p1.4968660-el7.parcel.sha .
/usr/local/bin/aws s3 cp s3://zbuild-stuff2/sha/CFM-1.1.0.0-el7.parcel.sha .
/usr/local/bin/aws s3 cp s3://zbuild-stuff2/sha/FLINK-1.9.1-csa1.1.0.0-cdh7.0.3.0-79-1753674-el7.parcel.sha .
#/usr/local/bin/aws s3 cp s3://zbuild-stuff2/sha/KAFKA-4.1.0-1.4.1.0.p0.4-el7.parcel.sha .
/usr/local/bin/aws s3 cp s3://zbuild-stuff2/sha/SCHEMAREGISTRY-0.8.0.2.0.1.0-29-el7.parcel.sha .
/usr/local/bin/aws s3 cp s3://zbuild-stuff2/sha/STREAMS_MESSAGING_MANAGER-2.1.0.2.0.1.0-29-el7.parcel.sha .

#set ownership parcels and SHAs:

chown cloudera-scm:cloudera-scm /opt/cloudera/parcel-repo/*

# change back to starting dir
echo "starting dir --> " $starting_dir
cd $starting_dir/common

###########################################################################################################
echo "-- Start CM, it takes about 2 minutes to be ready"
###########################################################################################################
systemctl start cloudera-scm-server

while [ `curl -s -X GET -u "admin:admin"  http://localhost:7180/api/version` -z ] ;
    do
    echo "waiting 10s for CM to come up..";
    sleep 10;
done

###########################################################################################################
echo "-- Now CM is started and the next step is to automate using the CM API"
###########################################################################################################
pip install --upgrade pip cm_client

###########################################################################################################
# update variables in the template
###########################################################################################################
sed -i "s/YourHostname/`hostname -f`/g" templates/$TEMPLATE
sed -i "s/YourHostname/`hostname -f`/g" scripts/create_cluster.py
# CDSW items

#This is used for public cloud infrastructure -- it is now set in the cloud provider section
#sed -i "s/YourCDSWDomain/$PUBLIC_IP/g" templates/$TEMPLATE

# This is used for proxmox... it is now called from that setup script
#sed -i "s/YourCDSWDomain/$PRIVATE_IP/g" templates/$TEMPLATE
sed -i "s/YourPrivateIP/$PRIVATE_IP/g" templates/$TEMPLATE

#set the cdsw block device
sed -i "s#YourCDSW_BLK_DEVICE#$BLOCKDEVICE#g" templates/$TEMPLATE

###########################################################################################################
# create the cluster with API
###########################################################################################################
python scripts/create_cluster.py templates/$TEMPLATE

###########################################################################################################
#  Install EFM and Minifi
###########################################################################################################
echo "Installing EFM and Minifi..."
echo
. ~/forge-horizons/common/component/efm_stuff/cem_setup.sh

echo
echo "EFM install complete..."

###########################################################################################################
# Install superset
###########################################################################################################
echo
echo "Installing Superset..."

. ~/forge-horizons/common/component/superset/bin/setup.sh 

echo "Superset install complete..."
echo

###########################################################################################################
# Create the Kudu tables and views
###########################################################################################################
echo "Create Kudu tables and views"

impala-shell -i localhost -f ~/forge-horizons/common/component/hue_files/sensor-tbls-n-views.sql

echo "Kudu tables and views created"

###########################################################################################################
# Load the nifi template via api
###########################################################################################################
echo "unset shell variables that were set at the beginning..."
set +e +x

echo
echo "load nifi template"

#  get the host ip:
GETIP=`ip route get 1 | awk '{print $NF;exit}'`
echo "GETIP --> "${GETIP}

#get the root process group id for the main canvas:
ROOT_PG_ID=`curl -k -s GET http://${GETIP}:8080/nifi-api/process-groups/root | jq -r '.id'`
echo "root pg id -->"${ROOT_PG_ID}

# Update the IP/hostname for Kafka and Kudu in the NiFi template
sed -i "s/HOST_IP/${GETIP}/" ~/forge-horizons/common/component/nifi_templates/cdsw_rest_api.xml

# Upload the template
echo "starting_dir --> "${starting_dir}
curl -k -s -F template=@"/root/forge-horizons/common/component/nifi_templates/cdsw_rest_api.xml" -X POST http://${GETIP}:8080/nifi-api/process-groups/${ROOT_PG_ID}/templates/upload

echo "nifi template loaded"
echo

###########################################################################################################
# install datagen items
###########################################################################################################
echo
echo "setup datagen items..."

. ~/forge-horizons/common/component/datagen/setup_pg_datagen.sh

echo "datagen items installed"
echo

###########################################################################################################
# Create hdfs directory for admin user and set permissions
###########################################################################################################
echo 
echo "creating admin user directory in hdfs..."
hadoop fs -mkdir /user/admin
hadoop fs -chown admin:hadoop /user/admin
echo

###########################################################################################################
## Set up AutoTLS
###########################################################################################################
#JAVA_HOME="$JAVA_HOME" /opt/cloudera/cm-agent/bin/certmanager --location /opt/cloudera/CMCA setup --configure-services

###########################################################################################################
## Install MIT Kerberos
###########################################################################################################
#yum -y install krb5-server krb5-workstation

echo "If you wish, tail the log file and wait for  \": Started Jetty server\""
echo
echo "\"tail -f /var/log/cloudera-scm-server/cloudera-scm-server.log\""
echo
echo "login to CM  \"http://`curl ifconfig.me`:7180\" user:admin, pwd:admin"
echo 
echo "login to Private CM \"http://$PRIVATE_IP:7180\" user:admin, pwd:admin"
#exit 0
