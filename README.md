# forge-horizons

The goal of this repo is to automate the install of CDP-DC

### Install Git and pull the repo


* ssh into a new Centos 7 instance and run the below commands

```

#install git
yum install -y git

cd ~
git clone https://github.com/tlepple/forge-horizons.git


```

## Export your aws credentials:

```

export AWS_ACCESS_KEY_ID=<your key>
export AWS_SECRET_ACCESS_KEY=<your secret key>
export AWS_DEFAULT_REGION=<aws region you want to run in>

```

### Edit the demo.properties file for your updates and set AMI and Region you are running in

```
vi /app/app_name/provider/aws/demo.properties
```

### Sample demo.properties

```
###############################################################################
#  Updates go here:
###############################################################################
OWNER_TAG=<your owner tag>
BIND_MNT_SOURCE="/Users/<your MacOS UserName>/Documents/cloud_stuff/docker_stuff"
HOST_PREFIX="demo-cdpdc7-1-3-"

# Below are the instance types for the various services. It's recommended to use
# the defaults, however you can change them below, if needed.
ONE_NODE_INSTANCE=m4.4xlarge

#PROJECT_TAG="'""personal development""'"
ENDATE_TAG=permanent

# set the docker bind mount properties
BIND_MNT_TARGET="/fishermans_wharf/"

# N. Virginia - us-east-1
#AMI_ID=ami-02eac2c0129f6376b
#AWS_REGION=us-east-1

# Ireland eu-west-1a
#AMI_ID=ami-0ff760d16d9497662

# Ohio us-east-2
#AMI_ID=ami-0f2b4fc905b0bd1f1
#AWS_REGION=us-east-2

#N. California us-west-1
#AMI_ID=ami-074e2d6769f445be5
#AWS_REGION=us-west-1

#Ireland
#AMI_ID=ami-0ff760d16d9497662
#AWS_REGION=eu-west-1

# Northern California ( This AMI has wwbank demo pre-installed )
AMI_ID=ami-043646c1ef78a684d
AWS_REGION=us-west-1

###############################################################################
#  No edits required below
###############################################################################

# Username to SSH to instances. All of the pre-selected AMIs use the 'centos' user.
# If you use your own AMI, you may need to change the ssh username as well.
SSH_USERNAME=centos

# set component flags.  helpful in case you need to restart a failed build or use alternate setup
setup_prereqs=true
setup_onenode=true

```

### Start the build.

* pass to this environment `aws` or `proxmox` and the path to the CDSW Block device

#### Example call to a build in AWS

```
cd ~/forge-horizons
. setup.sh aws edge2ai-7-1-3-v2-CDSW.json /dev/xvdc


```


#### Example call to build in ProxMox

```
. setup.sh proxmox edge2ai-7-1-3-v2-CDSW.json /dev/sde
```
