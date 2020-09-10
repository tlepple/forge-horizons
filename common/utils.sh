#!/bin/bash

#####################################################
# Function to install passwordless access to hosts
#####################################################
install_pwdless_access() {

	echo "-- Enable passwordless root login via rsa key"
	ssh-keygen -f ~/myRSAkey -t rsa -N ""
	mkdir ~/.ssh
	cat ~/myRSAkey.pub >> ~/.ssh/authorized_keys
	chmod 400 ~/.ssh/authorized_keys
	ssh-keyscan -H `hostname` >> ~/.ssh/known_hosts
	sed -i 's/.*PermitRootLogin.*/PermitRootLogin without-password/' /etc/ssh/sshd_config
	systemctl restart sshd

}

#####################################################
# Function to install jq
#####################################################
install_jq_cli() {

	#####################################################
	# first check if JQ is installed
	#####################################################
	echo "Installing jq"
	yum install -y unzip

	jq_v=`jq --version 2>&1`
	if [[ $jq_v = *"command not found"* ]]; then
	  curl -L -s -o jq "https://github.com/stedolan/jq/releases/download/jq-1.6/jq-linux64"
	  chmod +x ./jq
	  cp jq /usr/bin
	else
	  echo "jq already installed. Skipping"
	fi

	jq_v=`jq --version 2>&1`
	if [[ $jq_v = *"command not found"* ]]; then
	  #log "error installing jq. Please see README and install manually"
	  echo "Error installing jq. Please see README and install manually"
	  exit 1 
	fi  

}

#####################################################
# Function to install aws cli
#####################################################

install_aws_cli() {

	#########################################################
	# BEGIN
	#########################################################
	echo "BEGIN setup.sh"
	yum install -y unzip


	#####################################################
	# first check if JQ is installed
	#####################################################
	echo "Installing jq"

        jq_v=`jq --version 2>&1`
        if [[ $jq_v = *"command not found"* ]]; then
          curl -L -s -o jq "https://github.com/stedolan/jq/releases/download/jq-1.6/jq-linux64"
          chmod +x ./jq
          cp jq /usr/bin
        else
          echo "jq already installed. Skipping"
        fi

        jq_v=`jq --version 2>&1`
        if [[ $jq_v = *"command not found"* ]]; then
          echo "Error installing jq. Please see README and install manually"
          exit 1
        fi

	####################################################
 	# then install AWS CLI
	#####################################################
  	echo "Installing AWS_CLI"
#  	aws_cli_version=`aws --version 2>&1`
#  	echo "Current CLI version: $aws_cli_version"
#  	if [[ $aws_cli_version = *"aws-cli"* ]]; then
#    		echo "AWS CLI already installed. Skipping"
#    		return
#  	fi
  		curl -s "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
  		unzip awscliv2.zip
  		./awscliv2/install -i /usr/local/aws -b /usr/local/bin/aws 
  		rm -rf awscliv2*
  	echo "Done installing AWS CLI"

}
