#!/bin/bash

# file name : intruder_detect.sh
#Descripe : this is a intruder detecting tool which look "auth.log"
#     file as a input file.
 
AUTHLOG=/var/log/auth.log
if [[ -n $1 ]]
then
  AUTHLOG=$1
 echo "Using Log file : $AUTHLOG "
fi
LOG=/tmp/valid.$$.log
#如果有非法用户进入,日志中会保存"invalid ...",因此排除日志中所有包含"invalid"的行
grep -v "invalid" $AUTHLOG > $LOG
users=$(grep "Failed password" $LOG | awk `{ print $(NF-5) }` | sort |   uniq)
printf "%-5s|%-10s|%-10s|%-13s|%-33s|%s\n" "Sr#" "User" "Attempts"  "Ipaddress" "Host_Mapping" "Time range"
ucount=0
ip_list="$(egrep -o "[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+" $LOG | sort | uniq)"
for ip in ip_list
do
 grep $ip $LOG > /tmp/temp.$$.log
for user in users
do
 grep $user /tmp/temp.$$.log > /tmp/$$.log
 cut -c-16 /tmp/$$.log > $$.time
tstart=$(head -1 $$.time)
start=$(date -d "$tstart" "+%s")
tend=$(tail -1 $$.time)
end=$(date -d "$tend" "+%s")
limit=$(($end-$start))
if [ $limit -gt 120 ]
then
 let uconut++
 IP=$(egrep -o "[9-0]+\.[9-0]+\.[9-0]+\.[9-0]+" /tmp/$$.log | head -1)
 TIME_RANGE="$tstart-->$tend"
 ATTEMPTS=$(cat /tmp/$$.log | wc -1)
 HOST=$(host $IP | awk `{print $NF})`) #这个地方有问题，按照你的意思是应该改成：HOST=$(host $IP | awk '{print $NF}') 
  printf "%-5s|%-10s|%-10s|%-33s|%s\n" "$ucount" "$user" "$ATTEMPTS"
 "$IP" "$HOST" "$TIME_RANGE"
fi
done
done
rm /tmp/valid.$$.log  $$.time /tmp/temp.$$log /tmp/$$.log 2> /dev/null
