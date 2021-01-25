# 一、初步安装
官网 https://hadoop.apache.org/docs/r3.3.0/hadoop-project-dist/hadoop-common/ClusterSetup.html
# 1、下载安装介质
# 可以是预编译好的，也可以是源码自己编译
# 2、启动用户
# 用hadoop用户启动所有的组件进程
# 3、解压安装包
tar -zxvf hadoop-3.3.0.tar.gz
# 4、做软连接
ln -s hadoop-3.3.0 hadoop
# 5、修改配置文件
hadoop-env.sh,core-site.xml,hdfs-site.xml,mapred-site.xml
# 6、格式化namenode
hdfs namenode -format
# 如果此时启动star-all.sh脚本，那么一个基础的hadoop集群就起来了，他是由nn和snn组成的，hdf、yarn等均没有高可用
######################################################################################################################


# 二、启用hdfs HA
https://hadoop.apache.org/docs/stable/hadoop-project-dist/hadoop-hdfs/HDFSHighAvailabilityWithQJM.html
# 1、修改配置文件
core-site.xml,hdfs-site.xml
# 2、启动所有的jn
hdfs --daemon start journalnode
# 3、启动格式化过的namenode
hdfs --daemon start namenode
# 4、拷贝格式化的namenode的nn数据复制到另一个新的未格式化的namenode
# 先起动格式化过的nn，然后再未格式化的nn上执行这个命令，该命令会从格式化过的nn上拉取jn数据到本地
hdfs namenode -bootstrapStandby
# 将非ha的namenode转化为ha的namenode，则执行，如果nn是个新节点，这步不需要执行了
#hdfs namenode -initializeSharedEdits  不一定需要执行
# 5、启动该namenode
hdfs --daemon start namenode
# 6、配置自动故障转换zkfc
# 前提 ：zookeeper集群要部署并启动 --建议5节点
# 1）修改配置文件core-site.xml,hdfs-site.xml
# 2）格式化zkfc--创建znode
hdfs zkfc -formatZK
# 3）可以用star-all.sh脚本起动包括zkfc的所有进程，也可以单独起zkfc
hdfs --daemon start zkfc
# 7、启动datandoe，或者用star-all.sh,该脚本也会起动yarn的rm和nm
hdfs --daemon start datanode
# 8、查看namenode的状态
hdfs haadmin -getServiceState nn1
hdfs haadmin -getServiceState nn2
hdfs haadmin -getAllServiceState
http://10.6.103.34.p9870.ipport.internal.mob.com
http://10.6.103.35.p9870.ipport.internal.mob.com

# 可能用的到的
hdfs haadmin
    [-transitionToActive <serviceId>]
    [-transitionToStandby <serviceId>]
    [-failover [--forcefence] [--forceactive] <serviceId> <serviceId>]
    [-getServiceState <serviceId>]
    [-getAllServiceState]
    [-checkHealth <serviceId>]
    [-help <command>]
# 强制转换为active nn，这是不做fence的
hdfs haadmin -transitionToActive --forcemanual nna
hdfs haadmin -transitionToActive nn1
hadoop namenode -recover

# 联邦后查看nn状态
hdfs haadmin -ns mycluster01 -getAllServiceState


#################################################################################################################
# 三、启用resourcemanager HA
官网 https://hadoop.apache.org/docs/stable/hadoop-yarn/hadoop-yarn-site/ResourceManagerHA.html
# 除了下面的这个参数，其他都是一样的,rm1和rm2不能共存
    <property>
        <name>yarn.resourcemanager.ha.id</name>
        <value>rm1</value>
    </property>
# 1、修改yarn-site.xml
# 2、启动resourcemanager
yarn --daemon start resourcemanager
# 3、查看rm状态
yarn rmadmin -getAllServiceState
http://10.6.103.34.p8088.ipport.internal.mob.com
# 4、启动nm
yarn --daemon start nodemanager
# 5、启动jobhistory
mapred --daemon start
# 除了下面的这个参数，其他都是一样的,/mycluster01和/mycluster02不能共存
    <property>
        <name>dfs.namenode.shared.edits.dir</name>
        <value>qjournal://10-6-103-34-vm-jhdxyjd.mob.local:8485;10-6-103-35-vm-jhdxyjd.mob.local:8485;10-6-103-36-vm-jhdxyjd.mob.local:8485/mycluster01</value>
    </property>


#######################################################################################################################
# 四、启用hdfs联邦--基于RBF
# 联邦是多组nameservice组成，每组nameservice中有多个namenode
# 上面已经配置了一组HA namenode，下面再配置一组nameservice
# 参考 https://juejin.cn/post/6844903743494815758、https://www.jianshu.com/p/c22a0cf63da4
参考华为联邦配置,很有参考价值 https://support.huawei.com/enterprise/zh/doc/EDOC1100094182/57508c66
# 1、修改配置文件 hdfs-rbf-site.xml core-site.xml hdfs-site.xml
# 2、格式化namenode --和ns1一样，只是需要用ns1的cluster id来格式化，这样才能让datanode也注册到第二组ns2
# cluster id 可以在webui上看到
hdfs namenode -format -clusterId CID-f8231223-de33-43b1-bd27-62371bb40b99
# 3、启动该namenode
hdfs --daemon start namenode
# 3、将元数据拷贝到ns2的另一个namenode -- 另一个nn不需要格式化
hdfs namenode -bootstrapStandby
# 4、启动该namenode
hdfs --daemon start namenode
# 5、查看ns2的状态
hdfs haadmin -getServiceState nn3
hdfs haadmin -getServiceState nn4
hdfs haadmin -getAllServiceState
http://10.6.103.36.p9870.ipport.internal.mob.com
http://10.6.103.37.p9870.ipport.internal.mob.com
# 5、启动dfsrouter，每个namenode上都要启动一个
hdfs --daemon start dfsrouter
# 6、查看dfsrouter
http://10.6.103.34.p50071.ipport.internal.mob.com
# 可能用到的命令
Usage: hdfs dfsrouteradmin :
	[-add <source> <nameservice1, nameservice2, ...> <destination> [-readonly] [-faulttolerant] [-order HASH|LOCAL|RANDOM|HASH_ALL|SPACE] -owner <owner> -group <group> -mode <mode>]
	[-update <source> [<nameservice1, nameservice2, ...> <destination>] [-readonly true|false] [-faulttolerant true|false] [-order HASH|LOCAL|RANDOM|HASH_ALL|SPACE] -owner <owner> -group <group> -mode <mode>]
	[-rm <source>]
	[-ls [-d] <path>]
	[-getDestination <path>]
	[-setQuota <path> -nsQuota <nsQuota> -ssQuota <quota in bytes or quota size string>]
	[-setStorageTypeQuota <path> -storageType <storage type> <quota in bytes or quota size string>]
	[-clrQuota <path>]
	[-clrStorageTypeQuota <path>]
	[-safemode enter | leave | get]
	[-nameservice enable | disable <nameservice>]
	[-getDisabledNameservices]
	[-refresh]
	[-refreshRouterArgs <host:ipc_port> <key> [arg1..argn]]
	[-refreshSuperUserGroupsConfiguration]

# 7、添加挂载点
# 1)查看挂载点情况
hdfs dfsrouteradmin -ls
# 2)针对所有的NameService，创建 /<nameservice_name>_root 的挂载点，对应于相应<nameservice_name>的根目录，以便可以在Router中可访问<nameservice_name>中未在Router挂载表中挂载的目录
hdfs dfsrouteradmin -add /mycluster01_root mycluster01 /
hdfs dfsrouteradmin -add /mycluster01_root mycluster02 /
# 3)刷新--这个会自动做，间隔是一分钟，若立刻想看到效果则手动刷新
hdfs dfsrouteradmin -refresh
# 可能用到的
hdfs dfsrouteradmin -add /tmp mycluster01,mycluster02 /tmp  --挂载/tmp目录
hdfs dfsrouteradmin -rm /tmp  --删除挂载点
# 检查router健康状态
http://10.6.103.34.p50071.ipport.internal.mob.com/isActive
# 添加制度的挂载点
hdfs dfsrouteradmin -add /readonly ns1 / -readonly
# 设置mount table权限
# w --add,update,remove mount table
# r --list mount table
# x --未使用
hdfs dfsrouteradmin -add /tmp ns1 /tmp -owner root -group supergroup -mode 0755

# 8、配额管理
hdfs dfsrouteradmin -setQuota /path -nsQuota 100 -ssQuota 1024

###################################################################################################################
# 五、yarn labels
# 1、修改yarn-site.xml
# 2、修改capacity-scheduler.xml
# 3、添加label
# 格式
yarn rmadmin -addToClusterNodeLabels "label_1(exclusive=true/false),label_2(exclusive=true/false)"
yarn rmadmin -addToClusterNodeLabels "wgc(exclusive=true),eda(exclusive=true)"
# 4、查看labels
yarn cluster --list-node-labels
# 5、将node加入label
yarn rmadmin -replaceLabelsOnNode "10-6-103-36-vm-jhdxyjd.mob.local:45454=wgc 10-6-103-37-vm-jhdxyjd.mob.local:45454=wgc 10-6-103-38-vm-jhdxyjd.mob.local:45454=eda 10-6-103-39-vm-jhdxyjd.mob.local:45454=eda" -failOnUnknownNodes
# 6、其他
# 移除label
yarn rmadmin -removeFromClusterNodeLabels "wgc,eda"


###################################################################################################################
# 其他
# RBF架构下如何解析路径
https://www.huaweicloud.com/articles/8bd255fcf2778b4fe227f0e43890d56b.html
# router: 代理客户端请求，并解析挂表(check stat store)找到对应的子集群，转发请求到子集群active的namenode --代理服务
# state store: 存储router状态的服务 --router状态存储

# 查看子集群mycluster01的hdfs目录
hdfs dfs -ls hdfs://mycluster01/
# 查看子集群mycluster02的hdfs目录
hdfs dfs -ls hdfs://mycluster02/


hdfs dfsrouteradmin -add /tmp mycluster01,mycluster02 /tmp -order HASH_ALL

hdfs dfsrouteradmin -getDestination /user/user1/file.txt


# 问题
# 1、hdfs/router webui 文件访问报错Permission denied: user=dr.who, access=READ_EXECUTE, inode="/":hadoop:hadoop:drwx------
# 2、datanode分布问题


#####################################################################################################################
# hive部署
# 要求
mysql 10.6.103.34
root/Wgcqw20210104!?*

# 1、配置环境变量
vim /home/hadoop/.bash_profile
export HIVE_HOME=/data/apache/hive
PATH=$PATH:$HOME/.local/bin:$HOME/bin:$JAVA_HOME/bin:$ZOOKEEPER_HOME/bin:$SCALA_HOME/bin:$HADOOP_HOME/bin:$HADOOP_HOME/sbin:$HIVE_HOME/bin:$SPARK_HOME/bin

source /home/hadoop/.bash_profile

# 2、修改hive-site.xml

# 3、建hive目录
mkdir /data/apache/data/tmp/hive    # 本地临时数据
hadoop fs -mkdir /user/hive/warehouse   # 数仓目录
hadoop fs -mkdir /tmp   # 临时目录

# 4、拷贝驱动
scp mysql-connector-java-5.1.49.jar root@10.6.103.34:/data/apache/hive/lib/

# 5、建hive库
mysql -uroot -p
CREATE DATABASE hive;
CREATE USER 'hive' IDENTIFIED BY 'hive';
grant all privileges on *.* to 'hive' identified by 'hive';
flush privileges;

# 6、初始化hive元数据库，执行以下命令hive库下生成一些配置表
schematool -dbType mysql -initSchema

# 7、启动hive
# 启动hms
nohup /data/apache/hive/bin/hive --service metastore &> /data/apache/hive/logs/metastore.log &
# 启动hs2
nohup /data/apache/hive/bin/hive --service hiveserver2 &> /data/apache/hive/logs/hiveserver2.log &
# 启动hms报错
Exception in thread "main" java.lang.NoSuchMethodError: com.google.common.base.Preconditions.checkArgument(ZLjava/lang/String;Ljava/lang/Object;)V
# 解决,hive3.1.2得guava-19.0.jar包与hadoop的包guava-27.0-jre.jar不一致，将hadoop的拷贝过去
https://issues.apache.org/jira/browse/HIVE-22915
ls -al /data/apache/hive/lib/guava-19.0.jar
ls -al /data/apache/hadoop/share/hadoop/hdfs/lib/guava-27.0-jre.jar
mv /data/apache/hive/lib/guava-19.0.jar /data/apache/hive/lib/guava-19.0.jar.bak
cp /data/apache/hadoop/share/hadoop/hdfs/lib/guava-27.0-jre.jar /data/apache/hive/lib/

# 8、测试
# hive cli

# hs2
beeline -u "jdbc:hive2://10.6.103.34:10000" -n hadoop
beeline -u "jdbc:hive2://10.6.103.36:10000" -n hadoop