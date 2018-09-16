
1 打印网络接口列表
$ ifconfig | cut -c-10 | tr -d ' ' | tr -s '\n'
eth1
lo
wifi0

2 ifconfig iface_name
$ ifconfig wifi0

ifconfig wifi0 | egrep -o "inet addr:[^ ]*" | grep -o "[0-9.]*"




3 dns查找工具
一个域名可以分配多个ip地址,dns服务器只会返回一个.这时需要dns查找
dns查找工具有host, nslookup

host google.com #列出域名的所有ip
nslookup google.com #nslookup用于查询dns细节信息


4 设置默认网关,显示路由表信息
用命令route
-n以ip地址显示条目,否则以域名显示

5 traceroute 显示分组途径的所有网关地址


###### 7.4 列出网络上的所有活动主机
fping -a 192.160.1/23 -g 2 > /dev/null
fping -a 192.168.0.1 192.168.0.255 -g



###### 7.5 传输文件
通过ftp传文件可以用lftp
lftp username@ftphost
会提示输入密码,然后显示
lftp username@ftphost :->
这时支持命令自动补全,可输入的命令有:cd, lcd, mkdir,
get file
put file

lftp比ftp灵活, ftp用于自动传输


sftp运行在ssh连接之上,利用ssh模拟ftp接口.不需要远程运行ftp服务,但必须安装并运行openssh.
sftp跟lftp一样也是交互式命令
运行sftp:
sftp user@domainnane
ssh服务器有时并不在默认的端口22上运行,可以在sftp中-oPort=xxx指定端口,-oPort应为sftp的第一个参数

scp:比传统的远程复制工具rcp更安全,文件都是通过ssh加密通道传输的.

将文件传输到远程主机
scp file -user@remotehost:/home/path
remotehost可以用ip地址或域名
也可以在-oPort=xxx指定端口


###### 7.7 ssh无密码自动登陆
ssh的认证密钥分为一个公钥和一个私钥,可以用ssh-keygen创建.
要实现自动化认真,公钥必须放在登陆服务器中(将其加入~/.ssh/authorized_keys),私钥应放入用来登陆的客户机的~/.ssh
另一些与ssh相关的配置信息(如authorized_keys文件的名称与路径)可修改/etc/ssh/sshd_config配置
实现自动化认证需两步
1 创建ssh密钥:
ssh-keygen -t 加密算法类型
2 将生成的公钥放到远程主机.并加入文件~/.ssh/authorized_keys:
在客户端执行ssh user@remotehost "cat >> ~/.ssh/authorized_keys" < ~/.ssh/id_rsa.pub
以后执行ssh user@remotehost cmd时就不用输入密码了

###### 7.8 
直接登陆运行ssh服务的远程主机:
ssh user@remotehost
用-p port可指定端口

在远程主机中执行命令,并将命令输出显示在本地shell:
ssh user@remotehost 'cmd'
多天命令用分号分隔
ssh user@remotehost 'cmd;cmd2;cmd3'
命令输出可以用stdout获取
ssh user@remotehost "cmds" > stdout.txt 2 > error.txt
或者
echo "cmds" | ssh user@remotehost > stdout.txt 2 > error.txt


ssh协议支持对数据进行压缩传输,-C启用压缩功能
ssh -C user@remotehost 'cmd'

将数据重定向至远程shell命令的stdin:
echo "test" | ssh user@remotehost 'cat >> list'
或者
ssh user@remotehost 'car >> list' < file
数据从本地主机传递到远程shell的stdin了



###### 7.11 端口分析
列出系统中的开放端口以及运行在端口上的服务的详细信息:
lsof -i
每一项输出都对应打开了特定端口的服务

列出本地主机当前的开放端口:
lsof -i | grep ":[0-9]\+->" -o | grep ":[0-9]\+" -o | sort | uniq

同netstat列出开放端口与服务:
netstat -tnp





















