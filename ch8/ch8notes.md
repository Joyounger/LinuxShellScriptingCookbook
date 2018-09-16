###### 8.5 打印出10条最长使用的命令
```bash
#!/bin/bash

# top10_commands.sh
printf "COMMAND\tCOUNT\n"

cat ~/.bash_history | awk '{ list[$1]++; } \
END{
for(i in list)
{
printf("%s\t%d\n", i, list[i]); }
}' | sort -nrk 2 | head
```




###### 8.6 列出1小时内占用cpu最多的10个进程
```bash
#!/bin/bash

# 文件名：pcpu_usage.sh
# 用途：计算1小时内进程的cpu占用情况
SECS=3600
UNIT_TIME=60
# 将SECS更改成需要进行监视的总秒数
# UNIT_TIME是取样的时间间隔，单位是秒
STEPS=$(( $SECS / $UNIT_TIME ))
echo Watching CPU usage... ;
# 因为需要监视一个小时内cpu的使用情况,因此我们得在一个每次迭代时间为60秒的for循环中不停地使用os来获得cpu的使用统计
for ((i=0;i<STEPS;i++))
do
  # comm表示命令源,pcpu表示cpu使用率, tail -n +2将ps输出的头部和COMMAND %CPU剥除
  # $$表示当前脚本的进程id
  ps -eo comm,pcpu | tail -n +2 >> /tmp/cpu_usage.$$
  sleep $UNIT_TIME #确保每分钟执行一次ps
done
echo 
echo CPU eaters :
cat /tmp/cpu_usage.$$ | \
# 用awk求出每个进程总的cpu使用情况.用关联数组process统计,进程名作为数组索引
awk '
{ process[$1]+=$2 }
END{
   for(i in process)
   {
     printf("%-20s %s",i, process[i]);
   }
}' | sort -nrk 2 | head #最后根据总的cpu情况逆序排列,并通过head获得前10项
rm /tmp/cpu_usage.$$ #删除临时日志文件
```


###### 8.8对文件及目录访问进行记录
inotifywait可用来收集有关文件访问的信息.Linux发行版并没有默认包含此命令. sudo apt-get install inotify-tools.
这个命令还需要将inotify支持编译进内核,现在大多数发行版都在内核中启用了inotify
inotifywait -m -r -e create,move,delete $path -q
-m:持续监视而不是在事件发生后退出
-r:递归
-q:减少冗余信息
-e:执行要监视的事件
可监视的事件有:
access | 读取文件
modify | 文件内容被修改
attrib | 文件元数据被修改
move | 移动文件
create | 生成新文件
open | 
close |
delete | 

###### 8.9 用logrotate管理日志文件
logrotate采用一种称为rotate的技术来限制日志文件体积,一旦它超过了限定的大小,就要对它的内容进行抽取,同时将日志文件中的旧条目存到归档文件中.
logrotate的配置目录位于/etc/logrotate.d
可以为自己的日志文件编写一个特定的配置:
/etc/logrotate.d/program:
/var/log/program.log {
missingok
notifempty
size 30k
 compress
weekly
  rotate 5
create 0600 root root
}
折就是全部的配置.其中,/var/log/program.log指定了日志文件路径,就得日志文件之后也放入通一个目录中.
参数 | 描述
---|---
missingok | 如果日志文件丢失则忽略,然后返回
notifempty | 仅当源日志文件非空时才对其进行轮替
size 30k | 限制实施轮替的日志文件的大小.可以用1M表示1MB
compress | 允许用gzip对较旧的日志进行压缩
weekly | 指定进行轮替的间隔,weekly,yearly或daily
rotate 5 | 要保留的旧日志文件的归档数量
create 0600 root root | 指定所要创建的归档文件的模式,用户及用户组


###### 8.10 用syslog记录日志
日志文件 | 描述
/var/log/boot.log | 系统启动信息
/var/log/httpd | Apache Web服务器信息
/var/log/messages | 发布内核启动信息
/var/log/auth.log | 用户认证日志
/var/log/dmesg | 
/var/log/mail.log | 邮件服务器日志
/var/log/Xorg.0.log | X服务器日志

###### 8.11 监视登录找出入侵者
intruder_detect.sh


###### 8.12 监视远程磁盘的健康情况
disklog.sh

###### 8.13 找出系统中用户的活动时段
active_users.sh
