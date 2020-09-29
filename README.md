# forge-horizons

The goal of this repo is to automate the install of CDP-DC

### Install Git and pull the repo


* ssh into a new Centos 7 instance and run the below commands

```
sudo -i

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
