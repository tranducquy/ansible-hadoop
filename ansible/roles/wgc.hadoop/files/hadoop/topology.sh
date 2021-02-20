#!/bin/bash
HADOOP_CONF=/var/soft/hadoop-3.3.0/etc/hadoop
while [ $# -gt 0 ] ;
do
 nodeArg=$1
#文件内容输入到标准输入流
 exec<${HADOOP_CONF}/topology.data
 result=""
 while read line
 do
#把输入的每一行定义为数组
 ar=( $line )
 if [ "${ar[0]}" = "$nodeArg" ]||[ "${ar[1]}" = "$nodeArg" ]
     then
     result="${ar[2]}"
 fi
 done
 shift
 if [ -z "$result" ]
     then
     echo  "/default-rack"
 else
     echo  "$result"
 fi
done

