export SPARK_MASTER_WEBUI_PORT=8888
export SPARK_MASTER_PORT=7077
export SCALA_HOME=/data/apache/scala
export JAVA_HOME=/data/apache/java
export HADOOP_HOME=/data/apache/hadoop
export HADOOP_CONF_DIR=/data/apache/hadoop/etc/hadoop
export JAVA_OPTS="-verbose:gc -XX:+PrintGCDetails -XX:+PrintGCTimeStamps"
export SPARK_DAEMON_MEMORY=2048m
export SPARK_DAEMON_JAVA_OPTS="-Dspark.deploy.recoveryMode=ZOOKEEPER -Dspark.deploy.zookeeper.url=10-6-103-34-vm-jhdxyjd.mob.local:12181,10-6-103-35-vm-jhdxyjd.mob.local:12181,10-6-103-36-vm-jhdxyjd.mob.local:12181 -Dspark.deploy.zookeeper.dir=/spark"
export SPARK_HISTORY_OPTS="-Dspark.history.ui.port=18080 -Dspark.history.retainedApplications=3 -Dspark.history.fs.logDirectory=hdfs://myCluster01/sparklogs"
export SPARK_PID_DIR=/data/apache/data/tmp/spark/pids

export JAVA_LIBRARY_PATH=$JAVA_LIBRARY_PATH:$HADOOP_HOME/lib/native
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$HADOOP_HOME/lib/native

export SPARK_CLASSPATH=$SPARK_CLASSPATH:$SCALA_HOME/lib/*