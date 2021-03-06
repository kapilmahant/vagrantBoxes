#!/usr/bin/env bash

# download flume
wget --quiet http://apache.claz.org/flume/1.6.0/apache-flume-1.6.0-bin.tar.gz


export FLUME_HOME=/opt/flume/
export FLUME=$FLUME_HOME/bin
export FLUME_CONFIG=$FLUME_HOME/conf


#write to environment file for all future sessions
sudo /bin/sh -c 'echo export FLUME_HOME="/opt/flume/" >> /etc/environment'
sudo /bin/sh -c 'echo export FLUME="$FLUME_HOME/bin" >> /etc/environment'
sudo /bin/sh -c 'echo export FLUME_CONF="$FLUME_HOME/conf" >> /etc/environment'


#sudo mkdir /opt/flume
sudo mkdir $FLUME_HOME

sudo  tar -zxvf apache-flume-1.6.0-bin.tar.gz  --strip-components 1  -C $FLUME_HOME


####################################################
############# get libs
####################################################

# get zookeeper libs
wget --quiet https://repo1.maven.org/maven2/org/apache/zookeeper/zookeeper/3.4.8/zookeeper-3.4.8.jar
sudo cp zookeeper-3.4.8.jar $FLUME_HOME/lib/

# TODO : replace following hdfs jars with hadoop client

# commons-configuration-1.6.jar
wget --quiet http://repo1.maven.org/maven2/commons-configuration/commons-configuration/1.6/commons-configuration-1.6.jar
sudo cp commons-configuration-1.6.jar $FLUME_HOME/lib/

# commons-httpclient-3.1.jar
wget --quiet http://repo1.maven.org/maven2/commons-httpclient/commons-httpclient/3.1/commons-httpclient-3.1.jar
sudo cp  commons-httpclient-3.1.jar $FLUME_HOME/lib/

# commons-io-2.4.jar
wget --quiet http://repo1.maven.org/maven2/commons-io/commons-io/2.4/commons-io-2.4.jar
sudo cp commons-io-2.4.jar $FLUME_HOME/lib/

# hadoop-auth-2.7.1.jar
wget --quiet http://repo1.maven.org/maven2/org/apache/hadoop/hadoop-auth/2.7.1/hadoop-auth-2.7.1.jar
sudo cp  hadoop-auth-2.7.1.jar $FLUME_HOME/lib/

# hadoop-common-2.7.2.jar
wget --quiet http://repo1.maven.org/maven2/org/apache/hadoop/hadoop-common/2.7.1/hadoop-common-2.7.1.jar
sudo cp  hadoop-common-2.7.1.jar $FLUME_HOME/lib/

# hadoop-hdfs-2.7.1.jar
wget --quiet http://repo1.maven.org/maven2/org/apache/hadoop/hadoop-hdfs/2.7.1/hadoop-hdfs-2.7.1.jar
sudo cp  hadoop-hdfs-2.7.1.jar $FLUME_HOME/lib/

# hadoop-nfs-2.7.1.jar
wget --quiet http://repo1.maven.org/maven2/org/apache/hadoop/hadoop-nfs/2.7.1/hadoop-nfs-2.7.1.jar
sudo cp  hadoop-nfs-2.7.1.jar $FLUME_HOME/lib/

# htrace-core-3.1.0-incubating.jar
wget --quiet http://repo1.maven.org/maven2/org/apache/htrace/htrace-core/3.1.0-incubating/htrace-core-3.1.0-incubating.jar
sudo cp  htrace-core-3.1.0-incubating.jar $FLUME_HOME/lib/

# jets3t-0.9.0.jar
wget --quiet http://repo1.maven.org/maven2/net/java/dev/jets3t/jets3t/0.9.0/jets3t-0.9.0.jar
sudo cp jets3t-0.9.0.jar $FLUME_HOME/lib/

####################################################
############# broker 1 specific settings
####################################################


echo '

flume1.sources = kafka-source-1
flume1.channels = hdfs-channel-1
flume1.sinks = hdfs-sink-1


flume1.sources.kafka-source-1.type = org.apache.flume.source.kafka.KafkaSource
flume1.sources.kafka-source-1.zookeeperConnect = 192.168.150.70:2181
flume1.sources.kafka-source-1.topic = my-topic3
flume1.sources.kafka-source-1.batchSize = 10
flume1.sources.kafka-source-1.channels = hdfs-channel-1


flume1.channels.hdfs-channel-1.type = memory
flume1.channels.hdfs-channel-1.capacity = 10000
flume1.channels.hdfs-channel-1.transactionCapacity = 1000

# Define a sink that outputs to hdfs.

flume1.sinks.hdfs-sink-1.channel = hdfs-channel-1
flume1.sinks.hdfs-sink-1.type = hdfs
flume1.sinks.hdfs-sink-1.hdfs.path =  hdfs://192.168.150.120:9000/tmp
flume1.sinks.hdfs-sink-1.hdfs.fileType = DataStream

flume1.sinks.hdfs-sink-1.hdfs.writeFormat = Text
flume1.sinks.hdfs-sink-1.hdfs.filePrefix = test-events
flume1.sinks.hdfs-sink-1.hdfs.useLocalTimeStamp = true
flume1.sinks.hdfs-sink-1.hdfs.rollCount=100
flume1.sinks.hdfs-sink-1.hdfs.rollSize=0


#flume1.sinks.hdfs-sink-1.hdfs.path = /tmp/kafka/%{topic}/%y-%m-%d
#flume1.sinks.hdfs-sink-1.hdfs.path = hdfs://NAME_NODE_HOST:PORT/flume/kafkaEvents/%y-%m-%d/%H%M/%S

' > $FLUME_CONFIG/kafka2hdfs.conf



echo '
flume1.sources = kafka-source-1
flume1.channels = c1
flume1.sinks = k1


flume1.sources.kafka-source-1.type = org.apache.flume.source.kafka.KafkaSource
flume1.sources.kafka-source-1.zookeeperConnect = 192.168.150.70:2181
flume1.sources.kafka-source-1.topic = my-topic3
flume1.sources.kafka-source-1.batchSize = 10
flume1.sources.kafka-source-1.channels = c1

flume1.channels.c1.type=memory

flume1.sinks.k1.type=logger
flume1.sinks.k1.channel=c1

flume1.sinks.k1.type = file_roll
flume1.sinks.k1.sink.directory = /data/flume_output

#flume1.sinks.hdfs-sink-1.hdfs.path = /tmp/kafka/%{topic}/%y-%m-%d

' > $FLUME_CONFIG/kafka2file.conf


# create output directory
sudo mkdir -p /data/flume_output
sudo chown vagrant:vagrant /data/flume_output/
sudo chmod 755 -R /data/flume_output


####################################################
######## start flume daemon
####################################################

# To read from kafka and write to file
# /opt/flume/bin/flume-ng   agent --name flume1 -c /opt/flume/conf -f /opt/flume/conf/kafka2file.conf   -Dflume.root.logger=INFO,console -Dflume.log.dir=/tmp -Dflume.log.file=flume-agent.log

# To read from kafka and write to hdfs
# /opt/flume/bin/flume-ng   agent --name flume1 -c /opt/flume/conf -f /opt/flume/conf/kafka2hdfs.conf   -Dflume.root.logger=INFO,console -Dflume.log.dir=/tmp -Dflume.log.file=flume-agent.log

# NOTE : use this param if you want to output STDOUT to a dir/file
# -Dlog4j.configuration=/opt/flume/conf/log4j.properties



####################################################
#### Restrict Java heap space to avoid overflowing limited free RAM
#### Else not all broker will get initialized
####################################################

#write to environment file for all future sessions
#sudo /bin/sh -c 'echo export KAFKA_HEAP_OPTS="-Xmx256M -Xms128M" >> /etc/environment'

#export for the current session before starting kafka cluster
#export KAFKA_HEAP_OPTS="-Xmx256M -Xms128M"



