# .bash_profile

# Get the aliases and functions
if [ -f ~/.bashrc ]; then
        . ~/.bashrc
fi

# User specific environment and startup programs

export HADOOP_HOME=/data/apache/hadoop
export JAVA_HOME=/data/apache/java
export HIVE_HOME=/data/apache/hive
# 增加下面2行，解决执行hadoop命令时的告警：
# WARN util.NativeCodeLoader: Unable to load native-hadoop library for your platform... using builtin-java classes where applicable
export HADOOP_COMMON_LIB_NATIVE_DIR=$HADOOP_HOME/lib/native
export HADOOP_OPTS="-Djava.library.path=$HADOOP_HOME/lib:$HADOOP_COMMON_LIB_NATIVE_DIR"

PATH=$PATH:$HOME/.local/bin:$HOME/bin:$JAVA_HOME/bin:$ZOOKEEPER_HOME/bin:$SCALA_HOME/bin:$HADOOP_HOME/bin:$HADOOP_HOME/sbin:$HIVE_HOME/bin:$SPARK_HOME/bin
export PATH