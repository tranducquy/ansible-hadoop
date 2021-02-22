# Licensed to the Apache Software Foundation (ASF) under one
# or more contributor license agreements.  See the NOTICE file
# distributed with this work for additional information
# regarding copyright ownership.  The ASF licenses this file
# to you under the Apache License, Version 2.0 (the
# "License"); you may not use this file except in compliance
# with the License.  You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

# Set Hive and Hadoop environment variables here. These variables can be used
# to control the execution of Hive. It should be used by admins to configure
# the Hive installation (so that users do not have to set environment variables
# or set command line parameters to get correct behavior).
#
# The hive service being invoked (CLI etc.) is available via the environment
# variable SERVICE


# Hive Client memory usage can be an issue if a large number of clients
# are running at the same time. The flags below have been useful in
# reducing memory usage:
#
# if [ "$SERVICE" = "cli" ]; then
#   if [ -z "$DEBUG" ]; then
#     export HADOOP_OPTS="$HADOOP_OPTS -XX:NewRatio=12 -Xms10m -XX:MaxHeapFreeRatio=40 -XX:MinHeapFreeRatio=15 -XX:+UseParNewGC -XX:-UseGCOverheadLimit"
#   else
#     export HADOOP_OPTS="$HADOOP_OPTS -XX:NewRatio=12 -Xms10m -XX:MaxHeapFreeRatio=40 -XX:MinHeapFreeRatio=15 -XX:-UseGCOverheadLimit"
#   fi
# fi

# The heap size of the jvm stared by hive shell script can be controlled via:
#
# export HADOOP_HEAPSIZE=1024
#
# Larger heap size may be required when running queries over large number of files or partitions.
# By default hive shell scripts use a heap size of 256 (MB).  Larger heap size would also be
# appropriate for hive server.


# Set HADOOP_HOME to point to a specific hadoop install directory
# HADOOP_HOME=${bin}/../../hadoop

# Hive Configuration Directory can be controlled by:
# export HIVE_CONF_DIR=

# Folder containing extra libraries required for hive compilation/execution can be controlled by:
# export HIVE_AUX_JARS_PATH=


export HADOOP_HOME=/var/soft/hadoop-3.3.0
export HIVE_CONF_DIR=/var/soft/apache-hive-3.1.2-bin/conf
export HIVE_HOME=/var/soft/apache-hive-3.1.2-bin
export JAVA_HOME=/var/soft/jdk1.8.0_201
export HIVE_AUX_JARS_PATH=$HIVE_HOME/lib


export CLASSPATH=$CLASSPATH:$JAVA_HOME/lib:$HADOOP_HOME/lib:$HIVE_HOME/lib



if [ "SERVICE"="hiveserver2" ]; then
     export HADOOP_CLIENT_OPTS="-Xmx12g $HADOOP_CLIENT_OPTS"
     export HIVE_SERVER2_HADOOP_OPTS="-server -Xmx12g -Xms12g -Xmn2g -Xss256k -XX:SurvivorRatio=2 -XX:+UseConcMarkSweepGC -XX:+UseParNewGC -XX:+CMSParallelRemarkEnabled -XX:MaxTenuringThreshold=15 -XX:+UseCMSInitiatingOccupancyOnly -XX:CMSInitiatingOccupancyFraction=70 -XX:-DisableExplicitGC -XX:+PrintGCDetails -XX:+PrintGCTimeStamps -XX:+PrintGCApplicationStoppedTime -Xloggc:/var/soft/apache-hive-3.1.1-bin/logs/gc-hiveserver2.log-$(date +'%Y%m%d%H%M')"
elif [ "SERVICE"="metastore" ]; then
     export HADOOP_CLIENT_OPTS="-Xmx8g $HADOOP_CLIENT_OPTS"
     export HIVE_METASTORE_HADOOP_OPTS="-server -Xmx8g -Xms8g -Xmn2g -Xss256k -XX:SurvivorRatio=2 -XX:+UseConcMarkSweepGC -XX:+UseParNewGC -XX:+CMSParallelRemarkEnabled -XX:MaxTenuringThreshold=15 -XX:+UseCMSInitiatingOccupancyOnly -XX:CMSInitiatingOccupancyFraction=70 -XX:-DisableExplicitGC -XX:+PrintGCDetails -XX:+PrintGCTimeStamps -XX:+PrintGCApplicationStoppedTime -Xloggc:/var/soft/apache-hive-3.1.1-bin/logs/gc-metastore.log-$(date +'%Y%m%d%H%M')"
else
   export HADOOP_CLIENT_OPTS="-Xmx2g $HADOOP_CLIENT_OPTS"
fi