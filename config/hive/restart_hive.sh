#!/bin/bash
# restart_hive.sh
ip=$(/sbin/ip addr|grep -oP '10(\.\d{1,3}){3}'|head -1)
# 1、restart hms
pid=`ps -ef 2>/dev/null | grep -v "grep" | grep "HiveMetaStore" | awk '{print $2}'`
ppid=`netstat -nltp 2>/dev/null | grep "9083" | awk '{print $7}' | cut -d '/' -f 1`
if [ $pid == $ppid ]
then
  kill $pid
  sleep 2
  nohup /var/soft/apache-hive-3.1.2-bin/bin/hive --service metastore &> /var/soft/apache-hive-3.1.2-bin/logs/metastore.log &
  sleep 3
  success=`ps -ef 2>/dev/null | grep -v "grep" | grep "HiveMetaStore" | awk '{print $2}'`
  if [ $success ]
  then
    echo `date '+%Y-%m-%d %H:%M:%S'` "$ip:HiveMetaStore restart success."
  fi
else
  echo "pid~=ppid,can not restart hms."
fi
# 2、restart hs2
pidd=`ps -ef 2>/dev/null | grep -v "grep" | grep -i HiveServer2 | awk '{print $2}'`
ppidd=`netstat -nltp 2>/dev/null | grep "10000" | awk '{print $7}' | cut -d '/' -f 1`
if [ $pidd == $ppidd ]
then
  kill $pidd
  sleep 2
  nohup /var/soft/apache-hive-3.1.2-bin/bin/hive --service hiveserver2 &> /var/soft/apache-hive-3.1.2-bin/logs/hiveserver2.log &
  sleep 3
  success=`ps -ef 2>/dev/null | grep -v "grep" | grep -i HiveServer2 | awk '{print $2}'`
  if [ $success ]
  then
    echo `date '+%Y-%m-%d %H:%M:%S'` "$ip:HiveServer2 restart success."
  fi
else
  echo "pidd~=ppidd,can not restart hs2."
fi

################################################################################################################
#!/bin/bash
# rolling restart hive
source /home/hadoop/.bash_profile
for SERVER in `cat /var/soft/sh/hive_host_all.info`
  do
    ssh -p 57522 hadoop@$SERVER "sh /var/soft/sh/restart_hive.sh"
    sleep 1
  done

#################################################################################################################
# 其他
# kill hms hs2
ps -ef | grep HiveMetaStore | grep -v "grep" | awk  '{print $2}' | xargs kill -9
ps -ef | grep HiveServer2 | grep -v "grep" | awk  '{print $2}' | xargs kill -9
# hms hs2 重启
nohup /var/soft/apache-hive-3.1.2-bin/bin/hive --service metastore &> /var/soft/apache-hive-3.1.2-bin/logs/metastore.log &
nohup /var/soft/apache-hive-3.1.2-bin/bin/hive --service hiveserver2 &> /var/soft/apache-hive-3.1.2-bin/logs/hiveserver2.log &
# hms hs2 查看
ps -ef | grep HiveMetaStore
ps -ef | grep HiveServer2