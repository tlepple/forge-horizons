#!/bin/bash

###########################################################################################################
# 
###########################################################################################################

###########################################################################################################
# install aws cli
###########################################################################################################

echo "-- Install CEM Tarballs"
mkdir -p /opt/cloudera/cem
#wget https://archive.cloudera.com/CEM/centos7/1.x/updates/1.0.0.0/CEM-1.0.0.0-centos7-tars-tarball.tar.gz -P /opt/cloudera/cem
cd /opt/cloudera/cem

# pull from my s3 bucket
/usr/local/bin/aws s3 cp s3://zbuild-stuff2/other/CEM-1.1.1.0-25-centos7-tars-tarball.tar.gz .
tar xzf /opt/cloudera/cem/CEM-1.1.1.0-25-centos7-tars-tarball.tar.gz -C /opt/cloudera/cem
tar xzf /opt/cloudera/cem/CEM/centos7/1.1.1.0/tars/efm/efm-1.0.0.1.1.1.0-25-bin.tar.gz -C /opt/cloudera/cem
tar xzf /opt/cloudera/cem/CEM/centos7/1.1.1.0/tars/minifi/minifi-0.6.0.1.1.1.0-25-bin.tar.gz -C /opt/cloudera/cem
tar xzf /opt/cloudera/cem/CEM/centos7/1.1.1.0/tars/minifi/minifi-toolkit-0.6.0.1.1.1.0-25-bin.tar.gz -C /opt/cloudera/cem
rm -f /opt/cloudera/cem/CEM-1.1.1.0-25-centos7-tars-tarball.tar.gz
ln -s /opt/cloudera/cem/efm-1.0.0.1.1.1.0-25 /opt/cloudera/cem/efm
ln -s /opt/cloudera/cem/minifi-0.6.0.1.1.1.0-25 /opt/cloudera/cem/minifi
ln -s /opt/cloudera/cem/efm/bin/efm.sh /etc/init.d/efm
chown -R root:root /opt/cloudera/cem/efm-1.0.0.1.1.1.0-25
chown -R root:root /opt/cloudera/cem/minifi-0.6.0.1.1.1.0-25
chown -R root:root /opt/cloudera/cem/minifi-toolkit-0.6.0.1.1.1.0-25
rm -f /opt/cloudera/cem/efm/conf/efm.properties
cp /root/forge-horizons/common/component/efm_stuff/efm.properties /opt/cloudera/cem/efm/conf
rm -f /opt/cloudera/cem/minifi/conf/bootstrap.conf
cp /root/forge-horizons/common/component/efm_stuff/bootstrap.conf /opt/cloudera/cem/minifi/conf
sed -i "s/YourHostname/`hostname -f`/g" /opt/cloudera/cem/efm/conf/efm.properties
sed -i "s/YourHostname/`hostname -f`/g" /opt/cloudera/cem/minifi/conf/bootstrap.conf
/opt/cloudera/cem/minifi/bin/minifi.sh install

echo "-- Configure MiNiFi to run MQTT NAR"
# might need to update all these nifi versions to latest
#wget http://central.maven.org/maven2/org/apache/nifi/nifi-mqtt-nar/1.8.0/nifi-mqtt-nar-1.8.0.nar -P /opt/cloudera/cem/minifi/lib
#wget https://repo1.maven.org/maven2/org/apache/nifi/nifi-mqtt-nar/1.11.1/nifi-mqtt-nar-1.11.1.nar -P /opt/cloudera/cem/minifi/lib

wget https://repo1.maven.org/maven2/org/apache/nifi/nifi-mqtt-nar/1.8.0/nifi-mqtt-nar-1.8.0.nar  -P /opt/cloudera/cem/minifi/lib
chown root:root /opt/cloudera/cem/minifi/lib/nifi-mqtt-nar-1.8.0.nar
chmod 660 /opt/cloudera/cem/minifi/lib/nifi-mqtt-nar-1.8.0.nar

wget https://repo1.maven.org/maven2/org/apache/nifi/nifi-kafka-2-0-nar/1.8.0/nifi-kafka-2-0-nar-1.8.0.nar -P /opt/cloudera/cem/minifi/lib
chown root:root /opt/cloudera/cem/minifi/lib/nifi-kafka-2-0-nar-1.8.0.nar
chmod 660 /opt/cloudera/cem/minifi/lib/nifi-kafka-2-0-nar-1.8.0.nar

echo "-- Install Mosquitto and MQTT"
yum install -y mosquitto
pip install paho-mqtt
systemctl enable mosquitto
systemctl start mosquitto
mv ~/forge-horizons/common/component/efm_stuff/mqtt_stuff/mqtt.* ~
mv ~/forge-horizons/common/component/efm_stuff/spark_stuff/spark.iot* ~

echo "-- Start EFM and Minifi"
service efm start
service minifi start

# change back to starting dir
cd ~/forge-horizons
