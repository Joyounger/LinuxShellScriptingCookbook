#!/bin/bash

#active_users.sh
# 查找活跃用户
log=/var/log/wtmp
if [[ -n $1 ]]; then
	log=$1
fi

printf "%-4s %-10s %-10s %-6s %-8s\n" "Rank" "User" "Start" "Logins"
"Usage hours"
last -f $log | head -n -2 > /tmp/ulog.$$
cat /tmp/ulog.$$ | cut -d ' ' -f1 | sort | uniq > /tmp/users.$$
(
while read user; do
	grep ^$user /tmp/ulog.$$ > /tmp/user.$$
	seconds=0
	while read t; do
		s=$(date -d $t +%s 2 > /dev/null)
		let seconds=seconds+s
	done< <(cat /tmp/user.$$ | awk '{ print $NF }' | tr -d' )(')

	firstlog=$(tail -n 1 /tmp/user.$$  | awk '{ print $5,$6 }')
	nlogins=$(cat /tmp/user.$$ | wc -l)
	hours=$(echo "seconds / 60.0" | bc)
	printf "%-10s %-10s %-6s %-8s\n" $user "$firstlog" $nlogins $hours
done < /tmp/users.$$
) | sort -nrk 4 | awk '{ printf("%-4s %s\n", NR, $0) }'
rm /tmp/users.$$ /tmp/user.$$ /tmp/ulog.$$