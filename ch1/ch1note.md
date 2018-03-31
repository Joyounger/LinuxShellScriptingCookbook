unix中用sharp或hash(有时是mesh)来称呼字符'#',用bang来称呼惊叹号"!",
因而shebang就是就代表"#!"


如果将脚本作为bash的命令行参数来运行,就用不着脚本中第一行的shebang.

如果有需要的话,可以利用shebang来实现脚本的独立运行,对比必须设置脚本的可执行权限,这样脚本可以使用位于#!之后的解释器路径来运行了


对于root用户, 它的主目录~为 /root

登陆shell是登陆主机后获得的那个shell,如果登陆gui环境(如gnome)后打开了一个shell,则不属于登陆shell  

当shell是交互式登录shell时，读取.bash_profile文件，如在系统启动、远程登录或使用su -切换用户时；当shell是交互式登录和非登录shell时都会读取.bashrc文件，如：在图形界面中打开新终端或使用su切换用户时，均属于非登录shell的情况。简单的说，.bash_profile只在会话开始时被读取一次，而.bashrc则每次打开新的终端时，都会被读取。


######1.2 终端打印
默认情况下,echo每次调用后会添加一个换行符

1 使用不带引号的echo时,没法在所要显示的文本中使用分号(;),因为分号在bash shell中被用作命令界定符
2 使用带单引号的echo时, 变量替换在单引号中无效
3 使用带双引号的echo时, 要在双引号中打印"!",则应该使用"\!"
如果要使用转义序列,则采用echo -e "包含转义序列的字符串"这种形式


printf:
printf的%s,%c,%d,%f成为格式替换符(format substitution character)

带选项执行echo或printf时,要确保选项应该出现在命令行内所有字符串之前,否则bash会将其视为另一个字符串  

要打印彩色文本,可输出如下命令:
echo -e "\e[1;31m This is red text \e[0m"
\e[1;31将颜色设置为红色,\e[0m将颜色重置. 只需将31替换为想要的颜色码就行了.
彩色文本常使用的颜色码为:重置=0,黑色=30,红色=31,绿色=32,黄色=33,蓝色=34,洋红=35,青色=36,白色=37
要打印彩色背景,可输出如下命令:
echo -e "\e[1;42m This is green background \e[0m"
彩色背景常使用的颜色码为:重置=0,黑色=40,红色=41,绿色=42,黄色=43,蓝色=44,洋红=45,青色=46,白色=47


######1.3 玩转变量和环境变量
对于进程来说,其运行时的环境变量可以使用下面的命令来查看:
cat /proc/$PID/environ

1 赋值操作val=value,如果value不包含任何空白字符,则不需要用引号引用,否则必须用单引号或双引号
2 比较操作val = value

一个变量被export之后,从当前shell脚本执行的任何应用程序都会继承这个变量


获得变量值的长度 length = ${#var}
识别当前使用的shell: echo $0 或 echo $SHELL
检查是否为root用户:
```bash
if [ $UID -ne 0 ]; then
  echo "non root user. please run as root"
else
  echo "root"
fi
```

有一些特殊的字符可以扩展成系统参数,例如\u可以扩展为用户名,\h可以扩展为主机名,\w可以扩展为当前工作目录


######1.4 使用函数添加环境变量 
可以把下面的函数添加进~/.bashrc,
prepend() { [ -d "$2" ] && eval $1=\"$2':'\$$1\" && export $1; }
像下面这样来使用  
prepend PATH /opt/myapp/bin(等价于export PATH=/opt/myapp/bin:$PATH)
prepend LD_LIBRARY_PATH /opt/myapp/lib(等价于export LD_LIBRARY_PATH=/opt/myapp/lib:$LD_LIBRARY_PATH)
prepend函数先检查该函数第二个参数所指定的目录是否存在,如果存在eval表达式将第一个参数所指定的变量值设置成第二个参数的值加上":"(路径分隔符),随后再跟上首个参数的原始值.
如果变量为空,会在末尾留下一个分号":",要解决这个问题,可以将该函数再进行一次修改:
prepend() { [ -d "$2" ] && eval $1=\"$2\$\{$1:+':'\$$1\}\" && export $1; }
这样当追加环境变量时,当且仅当旧值存在,才会增加

######1.5 使用shell进行算数运算
再bash shell中,可以利用let, (())和[]执行基本的算数操作.高级算数操作可以用expr和bc
可以用bc执行浮点数运算并应用一些高级函数:
echo "4 * 0.56" | bc
no=54;
result=`echo "$no * 1.5" | bc`
echo $result
其他参数可置于要执行的具体操作之前,同时以分号作为界定符,通过stdin传给bc:
1 设定小数精度: echo "scale=2;3/8" | bc
2 进制转换: 
no=100
echo "obase=2;$no" | bc
no=1100100
echo "obase=10;ibase=2;$no" | bc
3 计算平方以及平方根:
echo "sqrt(100)" | bc #square root
echo "10^10" |  bc #Squre

######1.6 文件描述符及重定向
cmd 2>&1 output.txt 或者 cmd &> output.txt

如果对stderr或stdout进行重定向,被重定向的文本会传入文件.因为文本已经被重定向到文件中,也就没剩下什么东西可以通过管道(|)传给接下来的命令,而这些命令是通过stdin进行接收的
有一个方法既可以将数据重定向到文件,还可以提供一份重定向数据的副本作为后续命令的stdin.这一切都可以使用tee.

重定向操作符默认使用标准输出,如果想使用特定的文件描述符,你必须将文件描述符支付置于操作符前
>等同于1>, >>等同于1>>

从stdin读取输入的命令能以多种方式接受数据,也可以用cat和管道来制定我们自己的文件描述符  
1 将文件重定向到命令: cmd < file
2 将脚本内部的文本块进行重定向:
cat <<EOF>log.txt
LOG FILE HEADER
This is a test log file
Function: System statistics
EOF
3 自定义文件描述符
可以使用exec来创建自己的文件描述符,<操作符用于从文件中读取至stdin. >操作符用于截断模式的文件写入(数据在目标文件内容被截断之后写入)>>操作符用于追加模式的文件写入.文件描述符可以用以上三种模式中的任意一种来创建.
创建一个文件描述符进行读取:
echo "this is a test line" > input.txt
exec 3<input.txt #使用文件描述符3打开并读取文件
cat <&3
如果需要再次读取,不能继续使用文件描述符3了.而是需要使用exec重新分配文件描述符3来进行二次读取.


######1.7 数组和关联数组
bash从4.0版本之后才开始支持关联数组
以清单形式打印出数组中的所有值:
echo ${array_var[*]}
echo ${array_var[@]}
打印数组长度
echo ${#array_var[*]}

定义关联数组
声明:declare -A ass_array, 声明之后有两种方法将元素添加到关联数组:
ass_array=([index1]=val1 [index2]=val2)
使用独立的"索引-值"进行赋值:
ass_array[index1]=val1
ass_array[index2]=val2
echo "Apple costs ${fruits_value[apple]}"
列出数组索引:echo ${!array_var[*]} 或者echo ${!array_var[@]}

###### 1.8 对别名进行转义
可以将希望使用的命令进行转义,从而忽略当前定义的别名.
\command
字符\对命令实施转义,是我们可以执行原本的命令,而不是这些命令的别名替身.在不可信环境下执行特权命令,通过在命令前加上\来忽略可能存在的别名设置总是一个不错的安全实践.

######1.9 获取终端信息
tput和stty是两款终端处理工具
获取终端的行数和列数
tput cols 列数
tupt lines 行数
打印出当前的终端名 tput longname
将光标移动到坐标(100, 100)处:tput cup 100 100
设置终端背景色:tput setb n n取值在0到7之间
设置文本前景色:tput setf n n取值在0到7之间
设置文本样式为粗体tput hold
设置下划线的起止tput smul,tput rmul
删除从当前光标位置到行尾的所有内容:tput ed
输入密码时不显示输入内容
```bash
#!/bin/sh
#Filename: password.sh
echo -e "enter password: "
stty -echo  #选项-echo禁止将输出发送到终端,而选项echo允许
read password
stty echo
echo
echo Password read.
```

######1.10 日期时间
检查一组命令所花费的时间  
```bash
#!/bin/bash
# time_take.sh
start=$(date +%s)
commands;
statements
end=$(date +%s)
difference=$((end - start))
```
另一种方法是使用time <scriptpath>来得到执行脚本所花费的时间

在脚本中生成延时:
为了在脚本中推迟执行一段时间,可以使用sleep $sleep no_of_seconds.例如:
```bash
#!/bin/bash
# sleep.sh
echo -n count:
tput sc
count=0;
while true;
do
  if [ $count -lt 40 ]; then
    let count++;
    sleep 1;
    tput rc # 存储光标位置
    tput ed 
    echo -n $count;
  else exit 0;
  fi
done
```

######1.11 debug
在脚本中可以设置set -x和set +x,来对两者之间的部分语句调试

_DEBUG环境变量
```bash
function DEBUG()
{
  [ "$_DEBUG" == "on" ] && $@ || :
}

for i in {1..10}
do
  DEBUG echo $i
done

执行时:
_DEBUG=on ./script.sh
如果没有把_DEBUG=on传递给脚本,那么调试信息就不会打印出来.bash中命令":"告诉shell不进行任何操作

还可以把shebang给为#!/bin/bash -xv

###### 1.12 函数和参数
fork炸弹:
:(){ :|:& };:
此函数递归调用自身,不断生成新进程:https://en.wikipedia.org/wiki/Fork_bomb
可修改/etc/security/limits.conf来限制可生成的最大进程数来避开
导出函数:函数也能像环境变量一样用export导出,这样函数的作用域就可以扩展到子进程中.

###### 1.13 将命令序列的输出读入变量
利用子shell生成一个独立的进程:
可以使用()操作符来定义一个子shell:
pwd;
(cd /bin; ls);
pwd;
子shell本身就是独立的进程,不会对当前shell有任何影响;所有的改变仅限于子shell内.例如,当用cd命令改变子shell的当前目录时,这种变化不会反映到注shell环境中.
2 通过引用子shell的方式保留空格和换行符
假设我们使用子shell或反引用的方法将命令的输出读入一个变量中,可以将它放入双引号中,以保留空格和换行符(\n).例如:
$ cat text.txt
1
2
3
$ out=$(cat text.txt)
$ echo $out
1 2 3 # lost \n spacing
$ out="$(cat text.txt)"
$ echo $out
1
2
3

###### 1.15 运行命令直至执行成功
按照以下方式定义函数
function repeat()
{
  while true
  do
    $@ && return
  done
}
1 一种更快的做法:大多数现代系统中,true是作为/bin中的一个二进制文件来实现的.这就意味着每执行一次while循环,shell就不得不生成一个进程.可以使用shell内建的":"命令,它总是返回为0的退出码
function repeat () { while :; do $@ && return; done }
2 增加延时:
function repeat () { while :; do $@ && return; sleep 30; done }

###### 1.16 字段分隔符和迭代器
定界符(delimiter):把单个数据流划分成不同数据元素
内部字段分隔符(Internal Field Separator, IFS):存储定界符的环境变量,它是当前shell环境中使用的默认定界字符串.默认值为空白字符(换行符,制表符或者空格)
data="name,sex,rollno,location"
oldIFS=$IFS
IFS=,
for item in $data:
do
  echo Item:$item
done
输出为:
Item:name
Item:sex
Item:rollon
Item:location






















