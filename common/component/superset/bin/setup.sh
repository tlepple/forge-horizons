#!/bin/bash

#########################################################
# utility functions
#########################################################
dir=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )

log_dir=`pwd`

# logging function
log() {
    echo -e "[$(date)] [$BASH_SOURCE: $BASH_LINENO] : $*"
    echo -e "[$(date)] [$BASH_SOURCE: $BASH_LINENO] : $*" >> $log_dir/setup.log
}

#########################################################
# BEGIN
#########################################################
log "BEGIN setup.sh"

#########################################################
# Install yum tools
#########################################################
log "Install needed yum tools"

yum groupinstall -y 'development tools'
yum install -y zlib-dev openssl-devel sqlite-devel bzip2-devel xz-libs xz-devel wget libffi-devel cyrus-sasl-devel

#########################################################
# Install isolated version of python v. 3.7.4
#########################################################
log "Install python3.4 from source"

# create directory
mkdir -p /usr/local/downloads

# change to dir
cd /usr/local/downloads

# download source
wget https://www.python.org/ftp/python/3.7.4/Python-3.7.4.tar.xz

# unzip and untar this file:
xz -d Python-3.7.4.tar.xz
tar -xvf Python-3.7.4.tar

# change dir
cd Python-3.7.4

# build from source and install
./configure --prefix=/usr/local
make
make altinstall


#########################################################
# Update PATH and re-initialize
#########################################################
log "Update PATH"
sed -i '/^PATH=/ s/$/:\/usr\/local\/bin/' ~/.bash_profile

log "source bash_profile"
source ~/.bash_profile

#########################################################
# Create python virtual environment
#########################################################
log "create python virtual environment"

# create directory
mkdir -p ~/superset-install-oneNode

# change to dir
cd ~/superset-install-oneNode

# create the virtualenv
python3.7 -m venv supersetenv

# set the env active
log "set virtualenv active"
. supersetenv/bin/activate

# install some python tools
log "install - update python tools..."
pip install --upgrade setuptools pip


#########################################################
# Install Superset
#########################################################
log "Install Superset requirements..."

# change dir
cd ~/superset-install-oneNode/supersetenv

# install all the superset items
pip install -Ivr $dir/../files/requirements.txt

log "Upgrade superset DB"
superset db upgrade

log "Install sample data to superset"
superset load_examples


log "create roles and permissions"
superset init

# set the admin user and pwd
log "create the admin user..."

# set variables to echo into script
export superset_username=admin
export superset_user_fname=admin
export superset_user_lname=user
export superset_user_email=admin@fab.org
export superset_user_pwd=admin
export superset_confirm_pwd=admin

# start the script
export FLASK_APP=superset

flask fab create-admin --username "admin" --firstname "Tom" --lastname "Brown" --email "tom@tom.com" --password "admin" --password "admin"

# import the impala datasource with cli
log "Import impala datasource"
superset import_datasources -p $dir/../files/import_impala_data_source.yaml

# import the dashboard
superset import_dashboards -p $dir/../files/edge2aiDashboard.json

# deactivate the virtualenv
deactivate

#########################################################
# setup systemd components for start | stop | restart | status
#########################################################

log "create systemd components for superset"
#cp $dir/../files/superset.service.template ~/superset-install-oneNode/superset.service
cp ~/forge-horizons/common/component/superset/files/superset.service.template ~/superset-install-oneNode/superset.service

# create a softlink to the file
ln -s ~/superset-install-oneNode/superset.service /etc/systemd/system/superset.service

# copy shell startup script to destination
#cp $dir/../files/start_superset.sh ~/superset-install-oneNode/start_superset.sh
cp ~/forge-horizons/common/component/superset/files/start_superset.sh ~/superset-install-oneNode/start_superset.sh

# create a softlink to the script
ln -s ~/superset-install-oneNode/start_superset.sh /etc/init.d/superset

# restart the daemon so systemd can see this section
log "restart of systemctl daemon"
systemctl daemon-reload

# start superset
log "starting superset"
systemctl start superset

#########################################################
# restart superset
#########################################################
#log "stop superset service"
#systemctl stop superset

#sleep 20

#log "start superset service"
#systemctl start superset

#########################################################
#  END setup of superset
#########################################################
log "COMPLETED superset setup.sh"
