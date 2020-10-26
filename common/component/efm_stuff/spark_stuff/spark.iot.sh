ACCESS_KEY=${1}
PUBLIC_IP=$(curl https://api.ipify.org/)

# Install python configparser
pip install configparser

sed -i "s/YourHostname/`hostname -f`/" ~/spark.iot.py
sed -i "s/YourCDSWDomain/cdsw.${PUBLIC_IP}.nip.io/" ~/spark.iot.py
sed -i "s/YourAccessKey/${ACCESS_KEY}/" ~/spark.iot.py
#wget  http://central.maven.org/maven2/org/apache/kudu/kudu-spark2_2.11/1.9.0/kudu-spark2_2.11-1.9.0.jar
#wget https://repo1.maven.org/maven2/org/apache/kudu/kudu-spark2_2.11/1.9.0/kudu-spark2_2.11-1.9.0.jar
#wget https://raw.githubusercontent.com/swordsmanliu/SparkStreamingHbase/master/lib/spark-core_2.11-1.5.2.logging.jar
#wget https://repository.cloudera.com/artifactory/cloudera-repos/org/apache/kudu/kudu-spark2_2.11/1.12.0.7.1.3.0-100/kudu-spark2_2.11-1.12.0.7.1.3.0-100.jar
#wget https://repository.cloudera.com/artifactory/cloudera-repos/org/apache/spark/spark-core_2.11/2.4.0.7.1.3.0-100/spark-core_2.11-2.4.0.7.1.3.0-100.jar

#  cleanup stuff from last time it ran
rm -rf ~/.m2 ~/.ivy2/

#spark-submit --master local[2] --jars kudu-spark2_2.11-1.9.0.jar,spark-core_2.11-1.5.2.logging.jar --packages org.apache.spark:spark-streaming-kafka_2.11:1.6.3 ~/spark.iot.py
#spark-submit --master local[2] --jars kudu-spark2_2.11-1.12.0.7.1.3.0-100.jar,spark-core_2.11-1.5.2.logging.jar --packages org.apache.spark:spark-streaming-kafka_2.11:1.6.3 ~/spark.iot.py

#  check that jars have been downloaded
SPARK_CORE=~/spark-core_2.11-1.5.2.logging.jar
KUDU_SPARK=~/kudu-spark2_2.11-1.12.0.7.1.3.0-100.jar

if [[ -f "$SPARK_CORE" ]]; then
    echo "$SPARK_CORE exist."
    echo
else
    echo "$SPARK_CORE does NOT exist."
    wget https://raw.githubusercontent.com/swordsmanliu/SparkStreamingHbase/master/lib/spark-core_2.11-1.5.2.logging.jar
    echo
fi

if [[ -f "$KUDU_SPARK" ]]; then
    echo "$KUDU_SPARK exist."
    echo
else
    echo "$KUDU_SPARK does NOT exist."
    wget https://repository.cloudera.com/artifactory/cloudera-repos/org/apache/kudu/kudu-spark2_2.11/1.12.0.7.1.3.0-100/kudu-spark2_2.11-1.12.0.7.1.3.0-100.jar
    echo
fi


# submit the job that will run until its killed
spark-submit --master local[2] --jars kudu-spark2_2.11-1.12.0.7.1.3.0-100.jar,spark-core_2.11-1.5.2.logging.jar --packages org.apache.spark:spark-streaming-kafka-0-8_2.11:2.4.0 ~/spark.iot.py
