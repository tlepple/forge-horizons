#!/bin/bash

#########################################################
# setup the database items for datagen
#########################################################

# create directory and run script
mkdir -p /tmp/datagen
cp /root/forge-horizons/common/component/datagen/datagen_items.sql /tmp/datagen/
chmod 777 -R /tmp/datagen/
cd /tmp/datagen
sudo -u datagen psql -d datagen -U datagen -f /tmp/datagen/datagen_items.sql

#########################################################################################
#########################################################################################

# install needed python packages
python3 -m pip install uuid
python3 -m pip install kafka-python
python3 -m pip install simplejson
python3 -m pip install faker
python3 -m pip install boto3

python3 -m pip install psycopg2-binary

#########################################################################################
#########################################################################################
# create directories:
#########################################################################################
#########################################################################################

mkdir -p ~/datagen
cd ~/datagen

#########################################################################################
# python data generator files
#########################################################################################
cat <<EOF > ~/datagen/datagenerator.py
import time 
import collections
import datetime
from decimal import Decimal
from random import randrange, randint, sample
import sys
class DataGenerator():
	#  DataGenerator 
	def __init__(self):
	    #  comments
	    self.z = 0
	def fake_person_generator(self, startkey, iterateval, f):
	    self.startkey = startkey
	    self.iterateval = iterateval
	    self.f = f
	    endkey = startkey + iterateval
	    for x in range(startkey, endkey):
	    	yield {'last_name': f.last_name(),
	    		'first_name': f.first_name(),
	    		'street_address': f.street_address(),
	    		'city': f.city(),
	    		'state': f.state_abbr(),
	    		'zip_code': f.postcode(),
	    		'email': f.email(),
	    		'home_phone': f.phone_number(),
	    		'mobile': f.phone_number(),
	    		'ssn': f.ssn(),
	    		'job_title': f.job(),
	    		'create_date': (f.date_time_between(start_date="-60d", end_date="-30d", tzinfo=None)).strftime('%Y-%m-%d %H:%M:%S'),
	    		'cust_id': x}
	def fake_txn_generator(self, txnsKey, txniKey, fake):
	    self.txnsKey = txnsKey
	    self.txniKey = txniKey
	    self.fake = fake
	
	    txnendKey = txnsKey + txniKey
	    for x in range(txnsKey, txnendKey):
	    	for i in range(1,randrange(1,7,1)):
	    		yield {'transact_id': fake.uuid4(),
	    			'category': fake.safe_color_name(),
	    			'barcode': fake.ean13(),
	    			'item_desc': fake.sentence(nb_words=5, variable_nb_words=True, ext_word_list=None),
	    			'amount': fake.pyfloat(left_digits=2, right_digits=2, positive=True),
	    			'transaction_date': (fake.date_time_between(start_date="-29d", end_date="now", tzinfo=None)).strftime('%Y-%m-%d %H:%M:%S'),
	    			'cust_id': x}
EOF

##################################################################################
#  create python script to spool data generator data to a csv file
##################################################################################
cat <<EOF > ~/datagen/csv_dg.py
import datetime
import time
from faker import Faker
import sys
import csv
import boto3
import os
import shutil
from datagenerator import DataGenerator
#########################################################################################
#       Define variables
#########################################################################################
#bname_in = sys.argv[3]
dg = DataGenerator()
fake = Faker() # <--- Don't Forgot this
now = datetime.datetime.now()
dir_location = "/tmp/"
target_location = "/home/nifi/inbound/"
prefix = 'customer_csv'
#tname = now.strftime("%Y-%m-%d-%H:%M:%S")
tname = now.strftime("%Y-%m-%d-%H-%M-%S")
suffix = '.txt'
fname = dir_location + prefix + tname + suffix
s3bucket_location = 'data_gen/customer/' + prefix + tname + suffix
s3 = boto3.resource('s3')
#bucket_name = bname_in
bucket_name=${S3_BNAME}
#object_name = fname
dest = target_location + prefix + tname + suffix
startKey = int(sys.argv[1])
iterateVal = int(sys.argv[2])
#########################################################################################
#       Code execution below
#########################################################################################
#  open file to write csv
with open(fname, 'w', newline='') as csvfile:
#       Create a header row of data
        fpgheader = dg.fake_person_generator(1, 1, fake)
        for h in fpgheader:
                writer = csv.DictWriter(csvfile, fieldnames=h.keys() , delimiter='|', quotechar='"', quoting=csv.QUOTE_NONNUMERIC)
                writer.writeheader()
#       Create the data rows
        fpg = dg.fake_person_generator(startKey, iterateVal, fake)
        for person in fpg:
                writer = csv.DictWriter(csvfile, fieldnames=person.keys() , delimiter='|', quotechar='"', quoting=csv.QUOTE_NONNUMERIC)
                writer.writerow(person)
csvfile.close()
#Upload to S3
#s3.meta.client.upload_file(fname, bucket_name, s3bucket_location)
# move the file to a nifi in directory
shutil.move(fname,dest)
EOF

##################################################################################
#  create python script to send data to postgres script
##################################################################################
cat <<EOF > ~/datagen/pg_upsert_dg.py
############################################
# file contents:
############################################
from __future__ import print_function
from faker import Faker
from datagenerator import DataGenerator
import simplejson
import sys
import psycopg2
#########################################################################################
#	Define variables
#########################################################################################
dg = DataGenerator()
fake = Faker() # <--- Don't Forgot this
startKey = int(sys.argv[1])
iterateVal = int(sys.argv[2])
# functions to display errors
def printf (format,*args):
	sys.stdout.write (format % args)
def printException (exception):
	error, = exception.args
	printf("Error code = %s\n",error.code);
	printf("Error message = %s\n",error.message);
def myconverter(obj):
	if isinstance(obj, (datetime.datetime)):
		return obj.__str__()
#########################################################################################
#	Code execution below
#########################################################################################
try:
    try:
        conn = psycopg2.connect(host="${PRIVATE_IP}",database="datagen", user="datagen", password="supersecret1")
        print("Connection Established")
    except psycopg2.Error as exception:
        printf ('Failed to connect to database')
        printException (exception)
        exit (1)
    cursor = conn.cursor()
    try:
        fpg = dg.fake_person_generator(startKey, iterateVal, fake)
        for person in fpg:
#            print(simplejson.dumps(person, ensure_ascii=False, default = myconverter))
            json_out = simplejson.dumps(person, ensure_ascii=False, default = myconverter)
            print(json_out)
            insert_stmt = "SELECT datagen.insert_from_json('" + json_out +"');"
            cursor.execute(insert_stmt)
        print("Records inserted successfully")
    except psycopg2.Error as exception:
        printf ('Failed to insert\n')
        printException (exception)
        exit (1)
    finally:
        if(conn):
            conn.commit()
            cursor.close()
            conn.close()
            print("PostgreSQL connection is closed")
except (Exception, psycopg2.Error) as error:
    print("Something else went wrong...\n", error)
finally:
    print("script complete!")
EOF
##################################################################################
##################################################################################
