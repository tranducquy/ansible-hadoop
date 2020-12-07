#! /bin/bash
df -h|grep '/hadoop' && exit 1

yum install parted kmod-xfs xfsprogs -y
disk_num=`fdisk -l | awk '$1=="Disk"&&$2~"^/dev"&&$2!~"^/dev/sda" {split($2,s,":"); print s[1]}'`
NUM=0
for i in $disk_num
do
        parted  -s $i mklabel gpt
        parted  -s $i mkpart primary 1 100%
        mkfs.xfs -f ${i}1
 
        if [ $NUM -eq 0 ];then
                TMP=""
        else
                TMP=$NUM
        fi
 
        mkdir /data${TMP}
        mount -o noatime,nodiratime,osyncisdsync ${i}1 /data${TMP}
        uuid=`blkid ${i}1 |awk '{print $2}' |sed s#\"##g`
        echo "$uuid     /data${TMP}   xfs     noatime,nodiratime,osyncisdsync 0       0">>/etc/fstab
        ((NUM++))
done
