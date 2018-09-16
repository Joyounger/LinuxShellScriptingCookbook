#!/bin/bash


#首先得在所有网络的远程主机上设置一个公用账户.这个账户供脚本disklog登陆系统使用.我们需要为这个账户配置ssh自动登陆.

# 监视远程系统的磁盘使用情况
logfile="diskusage.log"
if [[ -n $1 ]]; then
	logfile=$1
fi
if [ ! -e $logfile ]; then
	printf "%-8s %-14s %-9s %-8s %-6s %-6s %-6s %s\n" "Date" "IP address" "Device" "Capacity" "Used" "Free" "Percent" "Status" > $logfile
fi

IP_FILE="127.0.0.1 0.0.0" #远程主机的ip地址列表存储在变量IP_LIST中,彼此之间以空格分隔.
(
for ip in $IP_LIST;
do
	ssh slynux@$ip 'df -H' | grep ^/dev/ > /tmp/$$.df

	while read line; do
		cur_date=$(date +%D)
		printf "%-8s %-14s " * $cur_date $ip
		echo $line | awk '{ printf("%-9s %-8s %-6s %-6s %-8s",$1,$2,$3,$4,$5); }'
		pusg=$(echo $line | egrep -o "[0-9]+%") #用egrep提取磁盘使用率,并将%删除以获取使用率的数值部分
		pusg=${(pusg/\%/)};
		if [ $pusg -lt 80 ]; then
			echo SAFE
		else
			echo ALERT
		fi
	done < /tmp/$$.df
done
) >> $logfile #打印出来的所有数据要被重定向到日志文件中,因此代码被放入子shell()中,并将标准输出重定向到文件